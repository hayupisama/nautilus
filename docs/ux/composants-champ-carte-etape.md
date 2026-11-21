# Composants du design system : champ, carte d'information, indicateur d'étape

Statut : spec rédigée a posteriori pour la PR nautilus-flutter-commun#13 (US U47), qui a livré les composants sans spec préalable.
Date : 2026-11-21. Rédigée par : rôle UX/UI.
Périmètre : `nautilus-flutter-commun/lib/design/` (thèmes `theme.dart`, tokens `tokens.dart`, `NautilusButton` de référence).

## 1. But

Donner aux trois composants une spec commune (rôle, états, contrastes, sémantique) pour que les écrans des applis passager et chauffeur les utilisent sans réinventer leur accessibilité, et lister les écarts à corriger avant la fusion de la PR #13.

## 2. Verdict

**Écarts à corriger** (3 écarts majeurs, 4 mineurs). Les contrastes et les cibles sont conformes dans les 3 thèmes. Les points bloquants sont le focus (champ et carte), l'annonce des erreurs, et la taille du texte de base.

## 3. Rôle de chaque composant

| Composant | Rôle | Interactif |
| --- | --- | --- |
| `NautilusTextField` | Saisir une information (adresse, téléphone, code) avec libellé permanent, aide et erreur en texte | Oui (saisie) |
| `NautilusInfoCard` (mode informatif) | Présenter une information importante (chauffeur qui arrive, prix estimé) | Non |
| `NautilusInfoCard` (mode bouton, `onTap` non null) | Ouvrir une action (voir le détail d'une course) | Oui |
| `NautilusStepIndicator` | Indiquer où en est l'utilisateur dans un parcours en N étapes | Non |

## 4. Anatomie

### 4.1 Champ (`NautilusTextField`)

Ordre de lecture et d'affichage, de haut en bas :
1. Libellé permanent (ex. « Adresse de départ »). Il reste affiché quand le champ a une valeur ou le focus.
2. Zone de saisie : contour de 1,5 dp (3 dp au focus, 2 dp en erreur), angles arrondis, hauteur >= 48 dp.
3. Aide (optionnelle) : « Numéro et nom de rue ».
4. Message d'erreur (si présent) : « Erreur : Adresse obligatoire ». Il remplace l'aide.

### 4.2 Carte d'information (`NautilusInfoCard`)

1. Icône décorative facultative (exclue de la lecture).
2. Titre (gras).
3. Texte du corps.
Contour de 1,5 dp (3 dp au focus) ; fond de la couleur de surface du thème.

### 4.3 Indicateur d'étape (`NautilusStepIndicator`)

1. Texte « Étape X sur N : nom de l'étape » (ex. « Étape 2 sur 4 : Destination »). C'est l'information principale.
2. Rangée de N segments : pleins (étapes faites et étape en cours), vides (étapes à venir). Hauteur 12 dp, contour 1,5 dp.

## 5. États

### 5.1 Champ

| État | Contour | Libellé | Texte | Message |
| --- | --- | --- | --- | --- |
| Défaut | 1,5 dp, couleur de texte du thème | Permanent, couleur de texte | Couleur de texte | Aide si fournie |
| Focus | 3 dp (voir écart E1 : anneau externe à ajouter) | Permanent | Couleur de texte | Aide |
| Erreur | 2 dp, couleur d'erreur | Permanent | Couleur de texte | « Erreur : … » en gras, couleur d'erreur |
| Désactivé | 1 dp | Permanent | Couleur de texte (non estompée) | Doit dire pourquoi (ex. « Champ non modifiable ») |
| Rempli | Comme défaut | Permanent | Couleur de texte | Aide |

### 5.2 Carte

| État | Rendu | Note |
| --- | --- | --- |
| Informative | Contour 1,5 dp, pas de focus | Lue comme un seul bloc |
| Bouton, défaut | Contour 1,5 dp | Rôle « bouton » annoncé |
| Bouton, focus | Contour 3 dp (voir écart E1) | Activable par Entrée et Espace |
| Bouton, pressé | Effet d'encre du thème | Retour visuel obligatoire |

### 5.3 Indicateur d'étape

| État du segment | Rendu | Information portée |
| --- | --- | --- |
| Étape faite | Plein, couleur primaire | Par le texte « Étape X sur N » |
| Étape en cours | Plein (voir écart E4 : repère de forme) | Par le texte |
| Étape à venir | Vide (fond de surface, contour) | Par le texte |

## 6. Tailles et cibles

- Champ : hauteur minimale 48 dp (implémentée par `constraints`). Conforme.
- Carte bouton : hauteur minimale 48 dp, cible entière. Conforme.
- Indicateur : non interactif, pas de cible à respecter. Hauteur des segments 12 dp, le texte grandit avec le réglage système.
- Espacement entre éléments interactifs : 8 dp minimum (`NautilusTokens.spacing`).

## 7. Contrastes (WCAG 2.2 AA)

Calcul du ratio à partir des tokens de `tokens.dart`. Seuils : 4,5:1 pour le texte, 3:1 pour les contours et composants graphiques (1.4.3 et 1.4.11).

| Thème | Paire | Ratio | Seuil | Résultat |
| --- | --- | --- | --- | --- |
| Clair | Texte `1A1A1A` sur fond `FFFFFF` | 17,4 | 4,5 | OK |
| Clair | Erreur `B00020` sur `FFFFFF` | 7,3 | 4,5 | OK |
| Clair | Primaire `0B4F8A` sur `FFFFFF` (bouton, segment plein) | 8,4 | 3 | OK |
| Clair | Texte blanc sur primaire (bouton) | 8,4 | 4,5 | OK |
| Clair | Contour `1A1A1A` sur `FFFFFF` | 17,4 | 3 | OK |
| Sombre | Texte `EDEDED` sur `121212` | 16,0 | 4,5 | OK |
| Sombre | Erreur `FFB4AB` sur `121212` | 11,0 | 4,5 | OK |
| Sombre | Primaire `9CC9F5` sur `121212` | 10,8 | 3 | OK |
| Sombre | Texte `0A1929` sur primaire `9CC9F5` (bouton) | 10,2 | 4,5 | OK |
| Contraste élevé | Texte `FFFFFF` sur `000000` | 21,0 | 4,5 | OK |
| Contraste élevé | Erreur `FF8A80` sur `000000` | 9,2 | 4,5 | OK |
| Contraste élevé | Primaire `FFEB3B` sur `000000` | 17,2 | 3 | OK |
| Contraste élevé | Texte `000000` sur primaire `FFEB3B` (bouton) | 17,2 | 4,5 | OK |

Les états désactivés sont exemptés du critère de contraste (1.4.3 et 1.4.11), mais doivent rester compréhensibles : voir E6.

## 8. Accessibilité et sémantique

### 8.1 Ordre de focus

- Champ : libellé et saisie forment un seul élément de focus ; l'aide et l'erreur sont lus après le libellé.
- Carte bouton : un seul élément de focus, rôle « bouton ».
- Indicateur : pas de focus (non interactif).
- L'ordre suit l'ordre de lecture de l'écran (haut en bas, gauche à droite).

### 8.2 Libellés lecteur d'écran

| Composant | Libellé lu | Rôle |
| --- | --- | --- |
| Champ | libellé ; puis « aide » ; puis « Erreur : … » | Champ de saisie ; état désactivé dit par le système |
| Carte informative | « Titre. Texte. » (ou `semanticLabel`) | Aucun |
| Carte bouton | « Titre. Texte. » ou `semanticLabel` avec un verbe d'action | Bouton |
| Indicateur | « Étape X sur N : nom » | Aucun |

Règles :
- Le libellé d'une carte bouton commence par le verbe de l'action (« Voir le détail de la course du mardi »), jamais seulement par le titre.
- Le point entre titre et texte est lu comme une pause ; il est acceptable.
- Un bouton désactivé est annoncé comme « indisponible » par le système.

### 8.3 Erreur

- L'erreur est une information en texte (préfixe « Erreur : ») et en couleur. La couleur seule ne suffit pas.
- L'erreur doit être annoncée au lecteur d'écran au moment où elle apparaît (voir E2).
- Le message dit quoi corriger (« Adresse obligatoire », « Format attendu : 06 12 34 56 78 »).

### 8.4 Texte à 200 %

- Le texte suit le réglage système jusqu'à 200 %, sans troncature (`maxLines` levé, retour à la ligne).
- L'aide et l'erreur peuvent occuper jusqu'à 5 lignes. Au-delà, le champ grandit ; il ne coupe rien.
- L'indicateur garde le texte entier ; les segments restent de même hauteur.
- Carte et bouton : la hauteur s'adapte au texte, la cible reste >= 48 dp.
- Test attendu : capture à 200 % sans perte d'information ni chevauchement.

### 8.5 Information jamais portée par la seule couleur ou la seule carte

- Erreur : préfixe texte + bordure plus épaisse + texte gras. OK.
- Étape : texte « Étape X sur N ». OK (voir E4 pour le repère visuel).
- Carte : le temps d'approche et l'adresse sont écrits dans le texte de la carte, pas seulement dans une carte graphique (cahier 6.2).

### 8.6 Commande vocale et clavier

- Les champs et les cartes boutons sont activables par les commandes vocales du système (Voice Control, Voice Access) grâce à leur libellé.
- Activation clavier : Entrée et Espace sur une carte bouton.

## 9. Typographie et copie FR

### 9.1 Tailles (à appliquer dans `NautilusTheme`)

- Texte du corps (`bodyLarge`) : 18 sp minimum (le thème Material 3 par défaut donne 16 sp).
- Titre de carte (`titleMedium`) : 20 sp, gras.
- Libellé de champ : 18 sp.
- Texte de bouton : 18 sp, gras.
- Interligne : 1,4 minimum.

Ces tailles sont la base avant le réglage système ; le réglage système s'y ajoute.

### 9.2 Copie des textes fixes des composants

| Usage | Texte | Remarque |
| --- | --- | --- |
| Préfixe d'erreur | « Erreur : » | Espace insécable avant le deux-points (voir E5) |
| Séparateur indicateur | « Étape 2 sur 4 : Destination » | Idem, espace insécable |
| Champ désactivé | « Champ non modifiable » (à donner par l'écran) | Phrase courte |

Règles FALC pour les textes saisis par les écrans : phrases courtes, un verbe par phrase, pas d'abréviation, « vous » ou tutoiement cohérent avec l'appli.

## 10. Composants du design system concernés

- `NautilusTextField` : existant (PR #13), à corriger (E1, E2, E5, E6).
- `NautilusInfoCard` : existant (PR #13), à corriger (E1, E7).
- `NautilusStepIndicator` : existant (PR #13), à corriger (E4).
- `NautilusButton` (U25) : référence du focus (anneau externe de 3 dp, espace de 2 dp). Les autres composants doivent suivre ce même motif.
- `NautilusTheme` (3 thèmes) et `NautilusTokens` : tailles de texte à revoir (E3).
- Aucun nouveau composant à créer pour cette US.

## 11. Écarts à corriger par dev-mobile

Ordre de priorité : E1 à E3 avant fusion de la PR #13 ; E4 à E7 dans la même PR si le temps le permet, sinon ticket `tech-debt`.

**E1 (majeur) : focus du champ et de la carte bouton non assez visible.**
Constat : au focus, seule l'épaisseur du contour change (1,5 dp vers 3 dp), la couleur reste la même. WCAG 2.4.13 demande un contraste de 3:1 entre l'état focus et l'état non focus, et ce contraste n'est pas atteint.
Correction : au focus, ajouter un anneau externe de 3 dp en couleur `onSurface`, séparé du contour de 2 dp (`NautilusTokens.focusRingGap`), comme `NautilusButton`. Le contour reste à 1,5 dp. Ratio de l'anneau sur le fond : 17,4 (clair), 16,0 (sombre), 21,0 (contraste élevé). Même motif pour le champ (via `Focus`/`FocusNode` ou un `DecoratedBox` externe) et la carte bouton. Test : test de widget qui vérifie la présence de l'anneau au focus.

**E2 (majeur) : l'erreur n'est pas annoncée au lecteur d'écran.**
Constat : Flutter n'annonce pas automatiquement l'apparition d'un `errorText`. La spec exige l'annonce (cahier 6.2).
Correction : quand `errorText` passe de null à une valeur, déclencher une annonce (`SemanticsService.announce` avec le texte « Erreur : … », ou `liveRegion: true` sur le texte d'erreur). Test de widget sur l'annonce.

**E3 (majeur) : taille du texte de base trop petite pour le public visé.**
Constat : le thème reprend les tailles Material 3 par défaut (16 sp pour le corps et les titres de carte). Pour seniors et personnes malvoyantes, le minimum recommandé est 18 sp.
Correction : régler `textTheme` dans `NautilusTheme` (corps 18 sp, titres 20 sp, bouton 18 sp, interligne 1,4) pour les 3 thèmes. Vérifier qu'aucun écran à 200 % ne déborde.

**E4 (mineur, recommandé) : segment en cours identique aux segments faits.**
Constat : les segments faits et en cours ont le même rendu. La progression est portée par le texte (conforme), mais le segment en cours n'a pas de repère visuel propre.
Correction : donner au segment en cours un contour de 3 dp (au lieu de 1,5 dp) en plus du plein. Pas de changement de sémantique.

**E5 (mineur) : espace avant le deux-points.**
Constat : « Erreur : » et « Étape X sur N : » utilisent une espace ordinaire. Sous 200 %, le deux-points peut passer seul en début de ligne.
Correction : utiliser une espace insécable (U+00A0) avant le deux-points dans `errorPrefix` et dans `progressText`/`label` de l'indicateur. Tests : mettre à jour les attentes des tests de widget.

**E6 (mineur) : champ désactivé peu explicite.**
Constat : le seul signal est un contour plus fin (1 dp). Le texte n'est pas estompé (bien), mais rien ne dit pourquoi le champ est désactivé.
Correction : documenter dans la spec de chaque écran un texte d'explication (« Champ non modifiable »), donné par l'appelant ; le composant n'a pas à le produire. Aucun changement de code obligatoire.

**E7 (mineur) : libellé des cartes boutons laissé à l'appelant.**
Constat : `semanticLabel` par défaut est « titre. texte », sans verbe d'action. Le composant ne peut pas le garantir.
Correction : ajouter une assertion en debug ou une règle de revue : une carte avec `onTap` doit fournir un `semanticLabel` commençant par un verbe. Pas de changement obligatoire dans le composant ; à vérifier en revue de PR des applis.

Points conformes à garder tels quels :
- Libellé permanent du champ (`FloatingLabelBehavior.always`).
- Cible minimale 48 dp (champ, carte bouton).
- Erreur en texte préfixé, pas seulement en couleur.
- Aide et erreur sur 5 lignes maximum, pas de troncature.
- Indicateur lu comme un seul bloc, segments exclus de la sémantique.
- Carte informative lue comme un seul bloc.
- Contrastes des 3 thèmes (section 7).

## 12. Tests attendus (rappel cahier 6.4)

- `meetsGuideline(androidTapTargetGuideline)`, `iOSTapTargetGuideline`, `labeledTapTargetGuideline`, `textContrastGuideline` sur chaque composant dans les 3 thèmes.
- Test de focus : anneau présent au focus (E1).
- Test d'annonce de l'erreur (E2).
- Test à 200 % de texte : pas de débordement (E3).
- Vérification manuelle sous VoiceOver et TalkBack avant de considérer l'écran terminé (cahier 6.4).

## 13. Questions métier

Aucune.
