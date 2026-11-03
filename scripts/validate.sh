#!/usr/bin/env bash
# Validation structurelle du plugin devflow (JSON, YAML, frontmatters, profils, rôles).
# Usage : scripts/validate.sh [--root <dir>]
# Sortie : une ligne par erreur (« fichier : message »), code 1 si au moins une erreur.
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
while [ $# -gt 0 ]; do
  case "$1" in
    --root) root="${2:?--root attend un dossier}"; shift 2 ;;
    -h|--help) sed -n '2,4p' "$0"; exit 0 ;;
    *) echo "option inconnue : $1" >&2; exit 2 ;;
  esac
done
[ -d "$root" ] || { echo "dossier introuvable : $root" >&2; exit 2; }

if ! python3 -c 'import yaml' 2>/dev/null; then
  echo "PyYAML manquant : pip install pyyaml" >&2
  exit 2
fi

exec python3 -I - "$root" <<'PY'
import json, re, sys
from pathlib import Path
import yaml

root = Path(sys.argv[1]).resolve()
errors = []
EXCLUDED = ("evals/results/", "_source/", ".claude/", ".git/")
PHASES = ["analyse", "plan", "implement", "test", "review", "simplifier", "gates", "pr"]


def rel(p):
    return p.relative_to(root).as_posix()


def err(p, msg):
    errors.append(f"{rel(p) if isinstance(p, Path) else p} : {msg}")


def excluded(p):
    r = rel(p)
    return "node_modules/" in r or any(r.startswith(e) or f"/{e}" in r for e in EXCLUDED)


def files(pattern):
    return sorted(p for p in root.glob(pattern) if p.is_file() and not excluded(p))


def frontmatter(p):
    """Renvoie le dict du frontmatter YAML, ou None (erreur déjà signalée)."""
    text = p.read_text(encoding="utf-8")
    m = re.match(r"---\n(.*?)\n---\n", text, re.S)
    if not m:
        err(p, "frontmatter YAML absent")
        return None
    try:
        data = yaml.safe_load(m.group(1))
    except yaml.YAMLError as e:
        err(p, f"frontmatter YAML invalide ({str(e).splitlines()[0]})")
        return None
    if not isinstance(data, dict):
        err(p, "frontmatter YAML n'est pas un objet")
        return None
    return data


def require(p, data, keys):
    for k in keys:
        if data.get(k) in (None, ""):
            err(p, f"clé « {k} » manquante ou vide")


def headings(p):
    return [l[3:].rstrip() for l in p.read_text(encoding="utf-8").splitlines() if l.startswith("## ")]


# 1. JSON
for p in files("**/*.json"):
    try:
        json.loads(p.read_text(encoding="utf-8"))
    except ValueError as e:
        err(p, f"JSON invalide ({e})")

# 2. YAML
for pattern in ("evals/cases/*/case.yaml", "templates/config.yml", "evals/_fixtures/*/.devflow/*.yml",
                "evals/_fixtures/*/*/.devflow/*.yml", ".github/workflows/*.yml"):
    for p in files(pattern):
        try:
            yaml.safe_load(p.read_text(encoding="utf-8"))
        except yaml.YAMLError as e:
            err(p, f"YAML invalide ({str(e).splitlines()[0]})")
for pattern in ("evals/cases/*/prompt.md", "evals/cases/*/graders/*.md"):
    for p in files(pattern):
        frontmatter(p)

# 3. Frontmatter des skills, agents, commandes
skills = set()
for p in files("skills/*/SKILL.md"):
    skills.add(p.parent.name)
    fm = frontmatter(p)
    if fm is not None:
        require(p, fm, ["name", "description"])
        if fm.get("name") and fm["name"] != p.parent.name:
            err(p, f"name « {fm['name']} » différent du dossier « {p.parent.name} »")
for d in sorted(root.glob("skills/*/")):
    if not (d / "SKILL.md").is_file():
        err(d, "SKILL.md absent")

agents = set()
for p in files("agents/*.md"):
    agents.add(p.stem)
    fm = frontmatter(p)
    if fm is not None:
        require(p, fm, ["name", "description", "tools", "model"])
        if fm.get("name") and fm["name"] != p.stem:
            err(p, f"name « {fm['name']} » différent du fichier « {p.stem} »")
        tools = fm.get("tools") or ""
        tools = tools if isinstance(tools, list) else re.split(r"[,\s]+", str(tools))
        if {"Agent", "Task"} & set(tools):
            err(p, "un agent ne lance pas d'autre agent (outil Agent/Task interdit)")

commands = set()
for p in files("commands/*.md"):
    commands.add(p.stem)
    fm = frontmatter(p)
    if fm is not None:
        require(p, fm, ["description"])

# 4. Sections obligatoires
template = root / "knowledge/stacks/_template.md"
stack_sections = headings(template) if template.is_file() else []
if not template.is_file():
    err("knowledge/stacks/_template.md", "fichier absent")
profiles = {}
for p in files("knowledge/stacks/*.md"):
    if p.name == "_template.md":
        continue
    fm = frontmatter(p)
    if fm is not None:
        for k in ("profile", "extends", "detect"):
            if k not in fm:
                err(p, f"clé « {k} » absente de l'en-tête")
        if fm.get("profile") != p.stem:
            err(p, f"profile « {fm.get('profile')} » différent du fichier « {p.stem} »")
        if "detect" in fm and not isinstance(fm["detect"], dict):
            err(p, "detect doit être un objet")
        profiles[p.stem] = fm.get("extends")
    present = set(headings(p))
    for s in stack_sections:
        if s not in present:
            err(p, f"section « ## {s} » absente")

for pattern in ("knowledge/modes/*.md", "knowledge/tasks/*.md"):
    for p in files(pattern):
        present = set(headings(p))
        for s in PHASES:
            if s not in present:
                err(p, f"section « ## {s} » absente")

# 5. Chaînes extends
for name, parent in profiles.items():
    if parent is not None and parent not in profiles:
        err(f"knowledge/stacks/{name}.md", f"extends « {parent} » : profil inexistant")
for name in profiles:
    seen, cur = [], name
    while cur in profiles and cur not in seen:
        seen.append(cur)
        cur = profiles[cur]
    if cur in seen:
        err(f"knowledge/stacks/{name}.md", "cycle d'héritage : " + " -> ".join(seen + [cur]))

# 6. Références devflow:<nom> et table des rôles
known = agents | skills | commands
for pattern in ("skills/*/SKILL.md", "commands/*.md", "agents/*.md"):
    for p in files(pattern):
        for name in sorted(set(re.findall(r"devflow:([a-z0-9-]+)", p.read_text(encoding="utf-8")))):
            if name not in known:
                err(p, f"devflow:{name} ne correspond à aucun agent, skill ou commande")

resolver = root / "knowledge/RESOLVER.md"
if resolver.is_file():
    in_table, roles = False, []
    for line in resolver.read_text(encoding="utf-8").splitlines():
        if line.startswith("## "):
            in_table = line.strip() == "## Table des rôles"
        elif in_table and line.startswith("|") and not line.startswith("|---"):
            roles += re.findall(r"`([a-z0-9-]+)`", line.split("|")[1])
    if not roles:
        err(resolver, "table des rôles vide ou introuvable")
    for r in roles:
        if r not in agents | skills:
            err(resolver, f"rôle « {r} » : ni agent ni skill")
else:
    err("knowledge/RESOLVER.md", "fichier absent")

for e in errors:
    print(e)
if errors:
    print(f"{len(errors)} erreur(s)", file=sys.stderr)
    sys.exit(1)
print("validate : OK")
PY
