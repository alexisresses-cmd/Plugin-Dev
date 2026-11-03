---
runs: 1
max_turns: 60
timeout_seconds: 1200
allowed_tools: [Read, Glob, Grep, Skill, Agent, Write]
expected_outcome: Analyse qui localise la cause dans OrderTotalCalculator (arrondi de la remise) et borne le périmètre.
---
/devflow:dev-analyse #57 — Le total d'une commande est faux de 1 centime sur certaines remises (ex. 3 articles à 19,99 € avec 15 % de remise : 50,97 € attendu, 50,98 € affiché). Le calcul se fait en float.
