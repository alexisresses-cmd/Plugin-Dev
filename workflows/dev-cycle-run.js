export const meta = {
  name: 'dev-cycle-run',
  description: 'Cycle de développement automatisé : implement (Sonnet/medium) → test (Sonnet/medium) → review (Opus/high pour sécurité) → PR (Sonnet/low)',
  phases: [
    { title: 'Initialisation', detail: 'Lecture de l’analyse, vérification git' },
    { title: 'Phase 1 — Implémentation', detail: 'Sonnet/medium + Gate G1' },
    { title: 'Gate G1', detail: 'Critères d’implémentation, correction auto max 2×' },
    { title: 'Phase 2 — Tests', detail: 'Sonnet/medium + Gate G2' },
    { title: 'Gate G2', detail: 'Couverture logique, correction auto max 2×' },
    { title: 'Phase 3 — Review', detail: 'Opus/high sécurité, Sonnet/medium qualité+bugs + Gate G3' },
    { title: 'Gate G3', detail: 'Zéro bloquant, correction auto max 2× (via dev-review)' },
    { title: 'Phase 4 — PR', detail: 'Sonnet/low — push + description + ready for review' },
  ],
}

// ─── Schémas ──────────────────────────────────────────────────────────────────

const ANALYSIS_SCHEMA = {
  type: 'object',
  properties: {
    content: { type: 'string' },
    branch: { type: 'string' },
    ticketId: { type: 'string' },
    tasks: { type: 'array', items: { type: 'string' } },
  },
  required: ['content', 'branch'],
}

const GIT_STATE_SCHEMA = {
  type: 'object',
  properties: {
    branch: { type: 'string' },
    isClean: { type: 'boolean' },
    uncommittedFiles: { type: 'array', items: { type: 'string' } },
  },
  required: ['branch', 'isClean'],
}

const IMPL_SCHEMA = {
  type: 'object',
  properties: {
    tasks_completed: { type: 'array', items: { type: 'string' } },
    commits: { type: 'array', items: { type: 'string' } },
    files_modified: { type: 'array', items: { type: 'string' } },
    out_of_scope: { type: 'array', items: { type: 'string' } },
    warnings: { type: 'array', items: { type: 'string' } },
    gate_criteria: {
      type: 'object',
      properties: {
        all_tasks_covered: { type: 'boolean' },
        working_tree_clean: { type: 'boolean' },
        no_debug_code: { type: 'boolean' },
        no_new_todos: { type: 'boolean' },
        conventions_respected: { type: 'boolean' },
        commits_format: { type: 'boolean' },
        no_out_of_scope_files: { type: 'boolean' },
      },
      required: ['all_tasks_covered', 'working_tree_clean', 'no_debug_code', 'no_new_todos', 'conventions_respected', 'commits_format', 'no_out_of_scope_files'],
    },
  },
  required: ['tasks_completed', 'commits', 'files_modified', 'gate_criteria'],
}

const TEST_SCHEMA = {
  type: 'object',
  properties: {
    scripts_generated: { type: 'array', items: { type: 'string' } },
    test_cases_count: { type: 'integer' },
    manual_scenarios_count: { type: 'integer' },
    new_logic_covered: { type: 'boolean' },
    no_fatal_errors: { type: 'boolean' },
  },
  required: ['scripts_generated', 'new_logic_covered', 'no_fatal_errors'],
}

// ─── Initialisation ───────────────────────────────────────────────────────────

phase('Initialisation')

const analysisFile = typeof args === 'string' ? args : args?.analysisFile
const pluginRoot = typeof args === 'object' && args?.pluginRoot ? args.pluginRoot : null
const cleanCodeRef = pluginRoot ? pluginRoot + '/knowledge/core/clean-code.md' : 'knowledge/core/clean-code.md du plugin devflow'

if (!analysisFile || typeof analysisFile !== 'string') {
  log('❌ Argument manquant — usage : /devflow:dev-cycle analysis/{slug}.md')
  return { error: 'missing_analysis_file' }
}

const analysis = await agent(
  'Lis le fichier ' + analysisFile + ' entièrement. Extrais : branch (nom de branche depuis la section Plan), ticketId (identifiant du ticket), tasks (liste des tâches). Retourne aussi content (contenu complet du fichier).',
  { label: 'lire-analyse', phase: 'Initialisation', model: 'sonnet', effort: 'low', schema: ANALYSIS_SCHEMA }
)

const gitState = await agent(
  'Vérifie l’état git. Lance `git branch --show-current` et `git status --short`. Retourne branch (string), isClean (bool), uncommittedFiles (liste des fichiers non committés).',
  { label: 'git-state', phase: 'Initialisation', model: 'sonnet', effort: 'low', schema: GIT_STATE_SCHEMA }
)

if (gitState.branch !== analysis.branch) {
  log('🛑 Mauvaise branche : on est sur "' + gitState.branch + '", le plan attend "' + analysis.branch + '"')
  return { error: 'wrong_branch', current: gitState.branch, expected: analysis.branch }
}

if (!gitState.isClean) {
  log('🛑 Arbre de travail non propre : ' + (gitState.uncommittedFiles || []).join(', '))
  return { error: 'dirty_working_tree', files: gitState.uncommittedFiles }
}

log('🚀 dev-cycle démarré')
log('   Branche : ' + analysis.branch)
log('   Fichier : ' + analysisFile)
log('   Pipeline : Implement → Test → Review → PR')

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PHASE 1 — IMPLÉMENTATION
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

phase('Phase 1 — Implémentation')

let implBilan = await agent(
  `Tu es un développeur expert PHP. Implémente le plan suivant tâche par tâche.

Mode : orchestrateur — commite automatiquement, n’attends pas de confirmation humaine.

Fichier d’analyse complet :
${analysis.content}

Instructions :
1. Lis CLAUDE.md à la racine du projet (conventions, architecture, patterns)
2. Lis ${cleanCodeRef} (principes PHP génériques)
3. Implémente chaque tâche dans l’ordre du plan
4. Valide chaque tâche : code fait exactement ce qui est demandé, conventions respectées, pas de code mort
5. Commite après chaque tâche ou groupe logique via le skill devflow:dev-commit en mode --auto (jamais de git commit direct)
6. Retourne uniquement le bilan JSON avec gate_criteria évalués honnêtement`,
  { label: 'implement', phase: 'Phase 1 — Implémentation', model: 'sonnet', effort: 'medium', schema: IMPL_SCHEMA }
)

// Gate G1
phase('Gate G1')

let g1Corrections = 0
while (true) {
  const failed = Object.entries(implBilan.gate_criteria).filter(([, v]) => !v).map(([k]) => k)

  if (failed.length === 0) {
    log('Gate G1 ✅ — ' + implBilan.tasks_completed.length + ' tâche(s), ' + implBilan.commits.length + ' commit(s)')
    break
  }

  if (g1Corrections >= 2) {
    log('Gate G1 🛑 — critères toujours en échec après 2 corrections : ' + failed.join(', '))
    return { halt: 'G1', failed_criteria: failed, impl_bilan: implBilan }
  }

  g1Corrections++
  log('Gate G1 ❌ → correction ' + g1Corrections + '/2 (' + failed.join(', ') + ')')

  implBilan = await agent(
    `Gate G1 en échec. Corrige les critères suivants :
${failed.map(c => '- ' + c).join('\n')}

Contexte (bilan actuel) :
${JSON.stringify(implBilan, null, 2)}

Pour chaque critère en échec :
- Lis les fichiers concernés
- Applique la correction ciblée
- Commite via le skill devflow:dev-commit en mode --auto (contexte : correction gate G1)

Retourne un nouveau bilan JSON complet avec gate_criteria réévalués honnêtement.`,
    { label: 'g1-correction:' + g1Corrections, phase: 'Gate G1', model: 'sonnet', effort: 'low', schema: IMPL_SCHEMA }
  )
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PHASE 2 — TESTS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

phase('Phase 2 — Tests')

let testBilan = await agent(
  `Tu es un expert en test PHP. Génère des tests pour la logique implémentée.

Fichiers modifiés : ${implBilan.files_modified.join(', ')}
Tâches réalisées : ${implBilan.tasks_completed.join(' | ')}

Instructions :
1. Pour chaque logique métier nouvelle ou modifiée : crée un script PHP de test (sans framework)
2. Pour ce qui ne peut pas être automatisé : écris un plan de test manuel détaillé
3. Lance les scripts PHP pour détecter les erreurs fatales
4. Retourne le bilan JSON`,
  { label: 'test', phase: 'Phase 2 — Tests', model: 'sonnet', effort: 'medium', schema: TEST_SCHEMA }
)

// Gate G2
phase('Gate G2')

let g2Corrections = 0
while (true) {
  const g2Failed = []
  if (!testBilan.new_logic_covered) g2Failed.push('new_logic_covered')
  if (!testBilan.no_fatal_errors) g2Failed.push('no_fatal_errors')

  if (g2Failed.length === 0) {
    log('Gate G2 ✅ — ' + (testBilan.test_cases_count || 0) + ' test(s), ' + (testBilan.manual_scenarios_count || 0) + ' scénario(s) manuel(s)')
    break
  }

  if (g2Corrections >= 2) {
    log('Gate G2 🛑 — critères toujours en échec après 2 corrections : ' + g2Failed.join(', '))
    return { halt: 'G2', failed_criteria: g2Failed, test_bilan: testBilan, impl_bilan: implBilan }
  }

  g2Corrections++
  log('Gate G2 ❌ → correction ' + g2Corrections + '/2 (' + g2Failed.join(', ') + ')')

  testBilan = await agent(
    `Gate G2 en échec. Corrige les problèmes suivants dans les scripts de test :
${g2Failed.map(c => '- ' + c).join('\n')}

Contexte (bilan actuel) :
${JSON.stringify(testBilan, null, 2)}

Corrige les scripts défaillants, relance-les, retourne un nouveau bilan JSON.`,
    { label: 'g2-correction:' + g2Corrections, phase: 'Gate G2', model: 'sonnet', effort: 'low', schema: TEST_SCHEMA }
  )
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PHASE 3 — REVIEW (via workflow dev-review)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

phase('Phase 3 — Review')
log('Lancement du workflow dev-review (Opus/high pour sécurité, Sonnet/medium pour qualité+bugs)')

const reviewResult = await workflow('devflow:dev-review-run')

// Gate G3
phase('Gate G3')

if (!reviewResult || !reviewResult.gate_pass) {
  log('Gate G3 🛑 — bloquants persistants après corrections automatiques dans dev-review')
  return {
    halt: 'G3',
    impl_bilan: implBilan,
    test_bilan: testBilan,
    review_result: reviewResult,
  }
}

log('Gate G3 ✅ — review clean' + (reviewResult.corrections_applied > 0 ? ' (après ' + reviewResult.corrections_applied + ' correction(s))' : ''))

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PHASE 4 — PR
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

phase('Phase 4 — PR')

const prResult = await agent(
  `Finalise la PR pour ce ticket.

Contexte :
- Tâches réalisées : ${implBilan.tasks_completed.join(', ')}
- Commits : ${implBilan.commits.join(' | ')}
- Fichiers modifiés : ${implBilan.files_modified.join(', ')}
- Tests : ${testBilan.scripts_generated.join(', ')} — ${testBilan.manual_scenarios_count || 0} scénario(s) manuel(s)
- Review : ${(reviewResult.findings_to_fix || []).length} point(s) à corriger (non bloquants), ${(reviewResult.findings_notes || []).length} observation(s)

Instructions :
1. Lis CLAUDE.md à la racine → extrais MAIN_REVIEWER
2. Lance git push si le remote n’est pas à jour
3. gh pr edit → mets à jour la description avec le contexte ci-dessus
4. gh pr ready → passe la PR en ready for review
5. gh pr edit --add-reviewer {MAIN_REVIEWER}
6. Retourne l’URL de la PR`,
  {
    label: 'pr',
    phase: 'Phase 4 — PR',
    model: 'sonnet',
    effort: 'low',
    schema: {
      type: 'object',
      properties: { url: { type: 'string' } },
      required: ['url'],
    },
  }
)

// ─── Rapport final ────────────────────────────────────────────────────────────

log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━')
log('✅ dev-cycle terminé')
log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━')
log('📋 Implémentation')
log('   Tâches    : ' + implBilan.tasks_completed.length)
log('   Commits   : ' + implBilan.commits.length)
log('   Fichiers  : ' + implBilan.files_modified.length)
log('🧪 Tests')
log('   Scripts   : ' + testBilan.scripts_generated.length)
log('   Scénarios : ' + (testBilan.manual_scenarios_count || 0) + ' manuels')
log('🔍 Review')
log('   À corriger (non bloquant) : ' + (reviewResult.findings_to_fix || []).length)
log('   Observations : ' + (reviewResult.findings_notes || []).length)
log('🔗 PR')
log('   ' + prResult.url)
log('   Statut : ready for review ✅')
log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━')

return {
  success: true,
  branch: analysis.branch,
  ticket_id: analysis.ticketId,
  impl: {
    tasks: implBilan.tasks_completed,
    commits: implBilan.commits,
    files: implBilan.files_modified,
    g1_corrections: g1Corrections,
  },
  tests: {
    scripts: testBilan.scripts_generated,
    manual_scenarios: testBilan.manual_scenarios_count || 0,
    g2_corrections: g2Corrections,
  },
  review: {
    to_fix: reviewResult.findings_to_fix,
    notes: reviewResult.findings_notes,
    g3_corrections: reviewResult.corrections_applied,
  },
  pr_url: prResult.url,
}
