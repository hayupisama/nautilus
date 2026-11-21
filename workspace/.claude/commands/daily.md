---
description: Daily de début de session (lancé automatiquement par `nautilus start`)
---
1. Lire `.nautilus/session.json` et le dernier journal `nautilus/.claude/sessions/`.
2. `git -C <depot> pull --ff-only` sur chaque dépôt propre.
3. Appeler l'agent `scrum-master` (mode DAILY), en lui demandant aussi l'état des CI des 8 dépôts.
3b. CI rouge sur `main` -> la placer en tête du plan de session.
4. Présenter à Fouad en français (5-8 lignes, sans numéros de tickets) :
   - Fait depuis la dernière session · Reste dans le sprint · Blocages · CI (« toutes vertes » ou nombre de rouges et dépôts)
   - Plan de cette session : US dans l'ordre (titre court + agent), parallélisme, objectif, durée max
5. Terminer par : « Je lance ce plan ? » et ATTENDRE la réponse.
