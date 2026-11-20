---
description: Clôture de session (journal, sprint, statuts) — lancée par Fouad ou par la limite de session
---
1. Ne plus démarrer de travail. Amener l'US en cours à un point stable (commit poussé ou PR ouverte, sinon noter l'état exact).
2. Date/heure : `TZ=Europe/Paris date +%F` / `+%H:%M`.
3. Journal global `nautilus/.claude/sessions/AAAA-MM-JJ.md` : nouvelle section au format strict de `_PROTOCOLE.md` (`refs:` = depot#n touchés, agents appelés).
4. Sprint courant : ligne de suivi datée. Projet : statuts et étiquettes `agent:*` exacts.
5. Commit + push dans `nautilus` : `chore(session): AAAA-MM-JJ`.
6. Mettre `"closed": true` dans `.nautilus/session.json`.
7. Dire à Fouad en 3 lignes : ce qui est fait, ce qu'il peut tester, ce qui vient ensuite.
