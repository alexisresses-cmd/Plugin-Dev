# Patterns de bikeshedding & faux positifs récurrents

## 🚲 Bikeshedding classique

**"J'aurais nommé ça autrement"** → ❌ Invalide si le nom est cohérent avec le domaine métier.

**"Cette fonction est trop longue"** → ⚠️ Discutable — la longueur seule n'est pas un critère. La lisibilité et le niveau d'abstraction le sont.

**"Tu devrais utiliser X pattern"** → ❌ Invalide si YAGNI s'applique (un seul cas d'usage).

**"Les magic numbers c'est mal"** → ⚠️ Discutable — si le sens est immédiatement clair dans le contexte, une constante nommée peut alourdir sans valeur.

## 🔍 Faux positifs de sécurité

**"Injection SQL potentielle"** sur code avec requêtes préparées → ❌ Invalide.

**"Les logs ne devraient pas afficher ça"** sur des logs de dev non actifs en prod → ⚠️ Discutable.

**"Tu devrais chiffrer ça"** sur données non-sensibles ou déjà protégées à un autre niveau → ⚠️ Discutable.

## ⚡ Faux positifs de performance

**"forEach est plus lent que for"** sans benchmark → ❌ Invalide dans 95% des cas.

**"Tu fais trop de requêtes DB"** sans mesure du temps réel → ⚠️ Discutable — valide si N+1 query prouvé.

**"Évite les regex, c'est lent"** sans benchmark → ❌ Invalide. Les regex compilées sont très performantes.

## 🧪 Faux positifs de tests

**"Il manque un test unitaire pour chaque méthode"** → ❌ Invalide sur code trivial (getters, wrappers).

**"Teste tous les edge cases"** sans priorisation → ⚠️ Discutable — valide pour les cas critiques, bikeshedding pour les cas impossibles par construction.

## 🏗️ Faux positifs d'architecture

**"Viole le principe X"** sans démonstration concrète de l'impact → ⚠️ Discutable.

**"Il faudrait séparer ça en microservice"** → ❌ Invalide dans 99% des PR. Décision architecturale hors review.

## 📖 Faux positifs de lisibilité

**"Ajoute des commentaires"** sur code auto-documenté → ❌ Invalide. Les commentaires expliquent le *pourquoi*, pas le *quoi*.

**"Utilise un early return"** sans règle d'équipe explicite → ❌ Style personnel, pas un standard.

## 🎯 Règle d'usage

1. Identifier si le point correspond à un de ces patterns
2. Appliquer le verdict présumé (Invalide ou Discutable)
3. Chercher des preuves qui **invalident** ce verdict (benchmark réel, bug prouvé, règle d'équipe documentée)
4. Ajuster le verdict final
