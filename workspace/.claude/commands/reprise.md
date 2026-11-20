---
description: Daily / reprise — état du sprint, dernière session, prochaine action
---
<!-- RÉSERVÉ À CLAUDE CODE -->
1. Lire `nautilus/.claude/scrum/PROCESS.md`, le dernier fichier de `nautilus/.claude/sessions/` et le sprint courant de `nautilus/.claude/scrum/sprints/`.
2. Pour chaque dépôt touché récemment : `git -C <depot> status -sb` et `git -C <depot> log --oneline -5`. Faire `git -C <depot> pull --ff-only` si propre.
3. Lister les US du sprint et leur statut (`gh project item-list` ou `gh issue list --label us`).
4. Signaler tout écart entre journal, sprint et réalité.
5. Répondre à Fouad en français, 5 lignes max : avancement du sprint, blocages, ce que je fais maintenant. Puis enchaîner sur l'US suivante (autonomie) sauf si une question métier bloque.
