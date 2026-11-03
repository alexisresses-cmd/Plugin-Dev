export const meta = {
  name: 'dev-review-run',
  description: 'Revue de code multi-agents : qualité (Sonnet/medium), bugs (Sonnet/medium), sécurité (Opus/high) — Gate G2 avec correction automatique max 2×',
  phases: [
    { title: 'Initialisation', detail: 'Récupération du diff et du contexte projet' },
    { title: 'Review', detail: '3 agents spécialisés en parallèle' },
    { title: 'Gate G2', detail: 'Vérification des bloquants + correction auto si besoin' },
  ],
}

// ─── Schéma partagé ──────────────────────────────────────────────────────────

const FINDING_SCHEMA = {
  type: 'object',
  properties: {
    findings: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          level: { type: 'string', enum: ['blocking', 'to_fix', 'note'] },
          file: { type: 'string' },
          description: { type: 'string' },
          suggestion: { type: 'string' },
        },
        required: ['level', 'description'],
      },
    },
  },
  required: ['findings'],
}

// ─── Initialisation ───────────────────────────────────────────────────────────

phase('Initialisation')

const ctx = await agent(
  `Récupère le contexte nécessaire pour la revue de code.

Exécute ces commandes bash et retourne les résultats :
  git diff main...HEAD
  git diff main...HEAD --name-only
  git log main..HEAD --oneline
(Si "main" n’existe pas, utilise "master".)

Lis aussi le fichier CLAUDE.md à la racine du projet.

Retourne le tout en JSON structuré.`,
  {
    label: 'context',
    phase: 'Initialisation',
    model: 'sonnet',
    effort: 'low',
    schema: {
      type: 'object',
      properties: {
        diff: { type: 'string' },
        files: { type: 'array', items: { type: 'string' } },
        commits: { type: 'array', items: { type: 'string' } },
        claudeMd: { type: 'string' },
      },
      required: ['diff', 'files', 'commits', 'claudeMd'],
    },
  }
)

log('Diff récupéré — ' + ctx.files.length + ' fichier(s) modifié(s)')

// ─── Gate G2 : boucle review → correction ─────────────────────────────────────

const filesStr = ctx.files.join(', ')
let allFindings = []
let blockingFindings = []
let correctionCount = 0

while (true) {
  phase('Review')
  log(correctionCount === 0 ? 'Lancement des 3 agents de review' : 'Re-review après correction ' + correctionCount + '/2')

  const reviews = await parallel([
    () => agent(
      `Tu es un expert PHP chargé de la revue qualité du code.
Analyse le diff en te concentrant sur : clean code, SOLID, dette technique, lisibilité, conventions du projet.

Conventions projet (CLAUDE.md) :
${ctx.claudeMd}

Fichiers modifiés : ${filesStr}

Diff complet :
${ctx.diff}

Retourne tes findings en JSON. Level :
- "blocking" : doit être corrigé avant merge
- "to_fix"   : devrait être corrigé (non bloquant)
- "note"     : observation ou amélioration future`,
      { label: 'qualité', phase: 'Review', model: 'sonnet', effort: 'medium', schema: FINDING_SCHEMA }
    ),

    () => agent(
      `Tu es un expert PHP chargé de détecter les bugs.
Analyse le diff en te concentrant sur : logique incorrecte, cas limites non couverts, régressions, états incohérents, valeurs nulles non gérées.

Fichiers modifiés : ${filesStr}

Diff complet :
${ctx.diff}

Retourne tes findings en JSON. Level :
- "blocking" : bug certain qui doit être corrigé avant merge
- "to_fix"   : problème probable ou risque
- "note"     : observation`,
      { label: 'bugs', phase: 'Review', model: 'sonnet', effort: 'medium', schema: FINDING_SCHEMA }
    ),

    () => agent(
      `Tu es un expert sécurité PHP chargé de la revue OWASP.
Analyse le diff en te concentrant sur : injections SQL, XSS, CSRF, exposition de données sensibles, failles d’authentification et d’autorisation, uploads non sécurisés, erreurs non gérées exposant des infos système.

Fichiers modifiés : ${filesStr}

Diff complet :
${ctx.diff}

Retourne tes findings en JSON. Level :
- "blocking" : faille de sécurité à corriger avant merge
- "to_fix"   : risque potentiel
- "note"     : bonne pratique à renforcer

Sois rigoureux : mieux vaut un faux positif qu’une faille non détectée.`,
      { label: 'sécurité', phase: 'Review', model: 'opus', effort: 'high', schema: FINDING_SCHEMA }
    ),
  ])

  allFindings = reviews.filter(Boolean).flatMap(r => r.findings)
  blockingFindings = allFindings.filter(f => f.level === 'blocking')

  phase('Gate G2')

  if (blockingFindings.length === 0) {
    log('Gate G2 ✅ — ' + allFindings.filter(f => f.level === 'to_fix').length + ' à corriger, ' + allFindings.filter(f => f.level === 'note').length + ' observations')
    break
  }

  if (correctionCount >= 2) {
    log('Gate G2 🛑 — ' + blockingFindings.length + ' bloquant(s) persistant(s) après 2 corrections')
    break
  }

  correctionCount++
  log('Gate G2 ❌ — ' + blockingFindings.length + ' bloquant(s) → correction automatique ' + correctionCount + '/2')

  const blockingList = blockingFindings
    .map((f, i) => (i + 1) + '. [' + (f.file || '?') + '] ' + f.description + (f.suggestion ? '\n   Suggestion : ' + f.suggestion : ''))
    .join('\n')

  await agent(
    `Tu es un développeur correctif.
Ces points bloquants ont été détectés par la review de code :

${blockingList}

Ta mission :
- Corriger chacun de ces points dans le code
- Ne rien modifier hors de ces corrections (pas de nettoyage opportuniste)
- Committer chaque correction via le skill devflow:dev-commit en mode --auto (contexte : correction review)
- Confirmer les corrections effectuées`,
    { label: 'correction:' + correctionCount, phase: 'Gate G2', model: 'sonnet', effort: 'low' }
  )
}

// ─── Rapport final ────────────────────────────────────────────────────────────

const toFix = allFindings.filter(f => f.level === 'to_fix')
const notes = allFindings.filter(f => f.level === 'note')
const gatePass = blockingFindings.length === 0
const verdict = gatePass ? (toFix.length > 0 ? 'go_with_reserves' : 'go') : 'no_go'

const verdictIcon = verdict === 'go' ? '✅' : verdict === 'go_with_reserves' ? '⚠️' : '❌'

log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━')
log(verdictIcon + ' Verdict : ' + verdict.toUpperCase())
if (blockingFindings.length > 0) {
  log('Bloquants (' + blockingFindings.length + ') :')
  blockingFindings.forEach(f => log('  ❌ [' + (f.file || '?') + '] ' + f.description))
}
if (toFix.length > 0) {
  log('À corriger (' + toFix.length + ') :')
  toFix.forEach(f => log('  ⚠️  [' + (f.file || '?') + '] ' + f.description))
}
if (notes.length > 0) {
  log('Observations (' + notes.length + ') :')
  notes.forEach(f => log('  ℹ️  ' + f.description))
}

if (gatePass) {
  log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━')
  log('✅ GATE G2 — PASS' + (correctionCount > 0 ? ' (après ' + correctionCount + ' correction(s))' : ''))
  log('➡️  PRÊT POUR CONTEXT 4 → /devflow:challenge-review')
} else {
  log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━')
  log('🛑 GATE G2 — HALT — correction manuelle requise avant de continuer')
}

return {
  findings_blocking: blockingFindings,
  findings_to_fix: toFix,
  findings_notes: notes,
  verdict: verdict,
  gate_pass: gatePass,
  corrections_applied: correctionCount,
}
