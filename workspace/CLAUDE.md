# CLAUDE.md — espace de travail Nautilus

Ce dossier contient les 8 dépôts du projet Nautilus. Lancer Claude Code ICI pour travailler sur plusieurs dépôts.
Chaque dépôt a son propre CLAUDE.md (conventions locales), lu dès qu'on travaille dans ce dépôt.

## À lire en premier
1. `nautilus/CLAUDE.md` puis `nautilus/.claude/scrum/PROCESS.md` (processus Scrum autogéré, autonomie, DoR/DoD).
2. Dernier sprint : `nautilus/.claude/scrum/sprints/` ; dernière session : `nautilus/.claude/sessions/`.

## Dépôts
| Dossier | Rôle |
| --- | --- |
| nautilus | cahier des charges, décisions, glossaire, scrum, sessions globales, revues pour Fouad |
| nautilus-contrat-api | OpenAPI (source de vérité) |
| nautilus-api | Quarkus hexagonal |
| nautilus-flutter-commun | package Flutter partagé |
| nautilus-app-passager | appli passager |
| nautilus-app-chauffeur | appli chauffeur |
| nautilus-back-office | Angular admin |
| nautilus-infra | k3s, Helm, secrets, sauvegardes |

## Sessions (espace de travail)
- Journal global : `nautilus/.claude/sessions/AAAA-MM-JJ.md`, format `nautilus/.claude/sessions/_PROTOCOLE.md`.
- `/reprise` au début, `/cloture` à la fin (commandes de ce dossier). Les sessions des autres dépôts servent si Claude Code est lancé directement dans un dépôt.
- Le dossier racine n'est pas un dépôt git : ses fichiers viennent de `nautilus/workspace/` (mettre à jour là-bas puis recopier).
