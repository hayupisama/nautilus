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

## 2026-11-21 — Environnement local, dépôts publics, secrets (Fouad, archi-infra)

- **Dépôts publics** : les 8 dépôts sont publics (audit de secrets fait, historique et refs de PR scannés) pour pouvoir protéger les tags `v*` (plan GitHub Free). Le projet « Nautilus - Backlog » reste privé. La mention « contrat privé » ci-dessus (U08) n'est plus vraie ; la copie versionnée du contrat reste le mécanisme retenu.
- **Tags `v*`** : 2 rulesets par dépôt, `tags-v-immuables` (suppression, mise à jour, forçage interdits) et `tags-v-creation-admin`. Corriger un tag raté = désactiver brièvement le premier.
- **Règle secrets** : jamais de mot de passe, clé ou identifiant en dur dans un dépôt, même factice ; modèle `.env.example` avec instructions, `.env` ignoré, scripts qui lisent l'environnement. Les valeurs factices du commit a40abbe / 33211f5 (PR infra#13) sont considérées compromises, jamais réutilisées, non purgées.
- **Keycloak local (U44)** : realm `nautilus`, rôles passenger/booker/driver/admin, clients publics PKCE S256 pour passager, chauffeur, back-office ; émetteur `http://localhost:8180/realms/nautilus` ; redirections `fr.nautilus.passenger:/oauthredirect`, `fr.nautilus.driver:/oauthredirect` (à aligner avec les identifiants d'application Flutter), back-office `http://localhost:4200` ; client `nautilus-dev-tools` réservé au local (ne jamais en recette/prod, cf. infra#14). Base de l'API : `QUARKUS_DATASOURCE_USERNAME` / `QUARKUS_DATASOURCE_PASSWORD`, config `%dev` dans `nautilus-infra/local/README.md`.
- **OSRM local (U45)** : extrait Geofabrik Pays de la Loire figé au 01/01/2026, serveur sur `127.0.0.1:5000` ; licence ODbL, mention © OpenStreetMap à afficher dans les applis et le back-office (nautilus#21).
- **Versions du package commun** : `v0.1.0` = design system (S01), `v0.2.0` = composants champ, carte, étape, sélecteur (S02). Texte de base 18 sp, anneau de focus externe `NautilusFocusRing`.
