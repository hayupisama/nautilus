# Décisions transverses

Journal des décisions qui touchent plusieurs dépôts. Plus récentes en haut.

## 2026-11-20 — Cadrage initial

| Sujet | Décision |
| --- | --- |
| Nom de code | Nautilus (provisoire) |
| Modèle | Marketplace de chauffeurs VTC indépendants ; la plateforme ne fixe pas les prix et n'encaisse rien |
| Zone | Nantes Métropole + aéroport Nantes Atlantique + gare |
| Public | Fauteuil, seniors, sensoriel, déficience intellectuelle, mobilité temporaire ; majeurs ou mineurs accompagnés |
| Réservation | Planifiée, au moins 12 h à l'avance ; réponse chauffeur sous 1 h |
| Licence | PolyForm Noncommercial 1.0.0 + CLA |
| Dépôts | Un dépôt par composant, privés pendant le prototype, sur GitHub |
| Contrat | Contract-first OpenAPI dans `nautilus-contrat-api` |
| API | Quarkus, hexagonal par module, Hibernate ORM + Panache (repositories), Flyway, JVM en dev / natif en prod |
| Auth | Keycloak (OIDC), Authorization Code + PKCE |
| Mobile | Flutter, deux applis + package commun, Riverpod |
| Back-office | Angular + Angular Material |
| Infra | VPS français ~8 Go, k3s + Helm, SOPS, Prometheus + Loki + Grafana |
| Cartes | OpenStreetMap : OSRM (itinéraires), Photon ou API Adresse (géocodage) |
| CI | GitHub Actions (runners macOS pour iOS) |

Détails et justifications : [cahier des charges](cahier-des-charges.md), sections 1 à 10.
