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

## 2026-11-20 — VPS reporté, développement 100 % local

- Le VPS (U03 à U07) est reporté : il fera l'objet d'un sprint dédié une fois une v0.0.1 stable obtenue en local, avec tous les branchements (même sans fonctionnalités).
- Tout tourne en local (docker compose : PostgreSQL/PostGIS, Keycloak ; API et applis en local). L'authentification s'appuie sur ce Keycloak local (U44), plus sur le VPS.
- Décision de Fouad.

## 2026-11-20 — Conception du contrat v0.2.0 (proposées par archi-logiciel)

- **D1 Authentification hors API** : Keycloak (Authorization Code + PKCE, clients publics) ; l'API est serveur de ressources ; pas de routes `/auth/*`.
- **D2 Versionnage** : semver ; cassant autorisé en mineure tant que < 1.0.0 ; ensuite cassant = majeure ; préfixe `/v1`.
- **D3 Rôles** : `passenger`, `booker`, `driver`, `admin` (cumulables) ; contrôle rôle + propriétaire ; 404 si ressource non visible.
- **D4 Erreurs** : RFC 9457, `type` = `urn:nautilus:problem:<code>` ; 400 schéma / 422 règle métier / 409 état.
- **D5 Compatibilité générateurs** : OpenAPI 3.1 limité au sous-ensemble 3.0 ; aucun type en ligne ; montants en euros.
- **D6 Routes en anglais** : suit le glossaire ; routes françaises du CDC 8.3 indicatives (en attente d'accord de Fouad pour modifier le CDC).

## 2026-11-20 — Squelette de l'API (U08, archi-logiciel)

- **Génération serveur** : openapi-generator `jaxrs-spec` 7.14.0, interfaces seules, Jakarta EE, `java.time`, sans annotations Swagger ; code généré à chaque build (jamais versionné) ; paquet `fr.nautilus.contract` utilisé seulement par `adapter.in.rest`.
- **Contrat (dépôt privé)** : copie versionnée dans `src/main/openapi` avec tag et sha256, mise à jour par `scripts/sync-contract.sh <tag>`, vérifiée par la CI sans secret. Sous-module et GitHub Packages écartés (jeton inter-dépôts = secret).
- **Base de l'API** : `/v1` via `quarkus.rest.path` ; endpoints techniques sous `/q/*`.
- **Données géographiques** : hibernate-spatial accepté sous condition (validation en natif avec une vraie entité `geography` ; repli WKT/WKB + SQL natif) ; le domaine utilise son propre value object (`GeoPoint`), jamais JTS.
- **Auth en test** : OIDC désactivé en `%test` jusqu'à U44, qui le réactive avec Keycloak Dev Services.
