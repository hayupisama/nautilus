<!-- RÉSERVÉ À CLAUDE CODE. Pas destiné à une lecture humaine. -->
# PROCESSUS SCRUM AUTOGÉRÉ — NAUTILUS

## RÔLES
- Fouad = client (MOA/MOE). Lance/arrête les sessions (`nautilus start` / `stop`), valide le plan du daily, teste les livraisons. NE LIT PAS les tickets, n'intervient pas sur les agents.
- Orchestrateur = session principale (CLAUDE.md racine). Seul interlocuteur de Fouad. Délègue, intègre, fusionne.
- Sous-agents (`.claude/agents/`) : po, scrum-master, archi-logiciel, archi-infra, ux-ui, dev-back, dev-mobile, dev-web, testeur-fonctionnel, testeur-qualite. Chacun n'intervient que si sa compétence est nécessaire.
- Validation d'une PR : testeur-fonctionnel toujours ; testeur-qualite si interface ; archi-logiciel si contrat/architecture/modèle ; archi-infra si infra/CI. Fusion par l'orchestrateur.
- Assignation : étiquette `agent:<nom>` sur l'issue + statut dans le projet.
- Specs UX : `nautilus/docs/ux/<appli>-<ecran>.md`, obligatoires avant tout écran.

## OUTILS (source de vérité = GitHub)
- Issues : epics dans `hayupisama/nautilus` ; features et US dans les dépôts de code. Hiérarchie par sous-tickets (epic > feature > us).
- Étiquettes : `epic` `feature` `us` `bug` `tech-debt` `bloque` `lot-0`..`lot-3` `accessibilite`.
- Jalons : `Lot 0 - Prototype` … `Lot 3 - Extension` dans chaque dépôt.
- Projet : « Nautilus - Backlog » (owner hayupisama). Champs : Status (Todo / In Progress / Done), Type, Lot, Estimation (h), Sprint (S01…S12).
- Correspondance clés -> issues : `nautilus/.claude/scrum/backlog-map.json` (clé U01 -> dépôt#numéro).

## COMMANDES UTILES
```
gh issue list -R hayupisama/<depot> --label us --milestone "Lot 0 - Prototype" --state open
gh project item-list <N> --owner hayupisama --format json --limit 200
gh issue view <n> -R hayupisama/<depot>
gh issue edit <n> -R hayupisama/<depot> --add-label bloque
gh pr create --fill --body "Closes hayupisama/<depot>#<n>"
gh pr merge --squash --delete-branch
```

## CYCLE DE SPRINT
- Durée : défini par l'objectif, ~10 h estimées par sprint. Numérotation S01, S02…
- PLANNING (`/sprint-debut`) : objectif en 1 phrase ; sélection d'US « prêtes » par ordre de dépendances ; champ Sprint renseigné ; fichier `.claude/scrum/sprints/SNN.md` créé.
- DAILY : au début de chaque session (`/daily`) : état du sprint, US en cours, blocages.
- FIN (`/sprint-fin`) : revue + rétro dans `SNN.md` ; vélocité dans `velocity.md` ; revue lisible pour Fouad dans `nautilus/docs/revues/SNN.md` ; message à Fouad avec ce qu'il peut tester.

## DEFINITION OF READY (US)
- Récit + critères d'acceptation testables + estimation.
- Dépendances terminées ou dans le même sprint, avant elle.
- Aucune question métier ouverte. Sinon -> étiquette `bloque` + question à Fouad.

## DEFINITION OF DONE (US)
- Critères d'acceptation tous cochés dans l'issue.
- Tests écrits et verts (unitaires domaine ; intégration si API ; widgets + guidelines a11y si écran).
- Écran : conformité WCAG 2.2 AA vérifiée (cf. CLAUDE.md du dépôt).
- CI verte, PR fusionnée (squash) avec `Closes`, branche supprimée.
- Déployé en recette quand l'infra existe.
- Commentaire de clôture sur l'issue : `Temps réel : X h` + écarts éventuels.
- Statut Done dans le projet.

## FLUX D'UNE US
1. Statut In Progress. Branche `us/<numero>-<slug>` dans le dépôt concerné.
2. Lire l'issue, ses dépendances, la section du cahier des charges citée.
3. Coder par petits commits (Conventional Commits, `refs #<n>`).
4. PR -> CI -> fusion -> cocher les critères -> commentaire temps réel -> Done.
5. Mettre à jour la session (`refs:` avec les numéros).

## DÉCOUVERTES PENDANT LE TRAVAIL
- Bug : issue `bug` + lot courant, rattachée à la feature concernée.
- Dette technique : issue `tech-debt`, priorisée en planning.
- Besoin d'une nouvelle US : la créer (format existant), la rattacher, l'estimer ; si elle change le périmètre -> demander à Fouad d'abord.

## QUESTIONS À FOUAD
- Seulement pour : règle métier ambiguë, arbitrage de périmètre, action listée en « demander avant » (CLAUDE.md).
- Format : questions fermées avec options et recommandation. Ne jamais inventer une règle métier.
- Pendant l'attente : étiquette `bloque`, passer à une autre US prête.

## REVUE POUR FOUAD (docs/revues/SNN.md, lisible par un humain)
- En français simple, sans jargon de ticket ni numéros d'issue.
- Sections : Ce qui est livré · Comment le tester (URL de recette, comptes de démo, étapes) · Ce qui reste / risques · Questions éventuelles.
- Max ~1 écran.
