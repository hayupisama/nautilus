# Composant du design system : sélecteur et liste d'options

Statut : spec rédigée AVANT le développement de l'US U48 (nautilus-flutter-commun#7, tag 0.1.0). À valider avant le dev.
Date : 2026-11-21. Rédigée par : rôle UX/UI.
Périmètre : `nautilus-flutter-commun/lib/design/` (nouveaux composants `NautilusOptionList` et `NautilusSelector`). Réutilise `NautilusFocusRing`, `NautilusTokens`, `NautilusTheme`, `NautilusButton`.

Limite de cette passe : le corps de l'issue #7 n'a pas pu être relu (outil `gh` indisponible dans cette session). Le périmètre ci-dessous vient du sprint S02, du cahier des charges (§5.1, §6.2) et du code existant. Le développeur doit relire l'issue #7 et signaler toute option attendue qui n'est pas listée ici.

## 1. But

Donner aux écrans des applis passager et chauffeur un moyen simple de faire un choix parmi une liste fermée (mobilité, transfert, aide, communication, critère de tri), où chaque option est lisible en entier, activable au clavier, annoncée clairement et jamais cachée derrière un geste.

## 2. Verdict

Spec prête pour le dev sous réserve des 3 points de décision de la section 13. Aucun écart existant ne bloque : sur les composants déjà livrés, les écarts E1 à E5 sont traités dans le code, E6 et E7 restent ouverts (section 12).

## 3. Rôle et usages

Deux composants, à livrer dans U48 :

| Composant | Rôle | Quand l'utiliser |
| --- | --- | --- |
| `NautilusOptionList` | Afficher toutes les options d'une question, en clair, sur l'écran. Choix unique (un seul bouton radio) ou multiple (cases à cocher). | 2 à 7 options. Le cas par défaut. |
| `NautilusSelector` | Afficher une ligne de type champ avec la valeur choisie ; un appui ouvre une page dédiée contenant la liste. | Plus de 7 options, ou un écran où la liste prendrait trop de place. |

Usages tirés du cahier des charges (§5.1) :

| Question (rubrique) | Choix | Nombre d'options | Composant |
| --- | --- | --- | --- |
| Mobilité (fauteuil, déambulateur, béquilles, aucun) | Multiple | 4 (+ « Aucun », exclusif) | `NautilusOptionList` |
| Transfert (passer sur un siège) | Unique | 3 | `NautilusOptionList` |
| Aide requise | Multiple (« Aucune » exclusif) | 4 | `NautilusOptionList` |
| Communication préférée (SMS, appel, LSF) | Multiple | 3 | `NautilusOptionList` |
| Accompagnement (accompagnant, chien) | Multiple | 2 | `NautilusOptionList` |
| Critère de classement des chauffeurs (§5.3) | Unique | 5 | `NautilusOptionList` (ou `NautilusSelector` si l'écran est chargé) |

Hors périmètre de ce composant : la liste des chauffeurs compatibles (cartes `NautilusInfoCard` en bouton, voir la spec champ/carte/étape) et la saisie d'une adresse (`NautilusTextField`).

## 4. Anatomie

### 4.1 `NautilusOptionList`

Ordre de lecture et de focus, de haut en bas :
1. Légende (la question), titre : « Quel type de fauteuil utilisez-vous ? ». Texte gras, 20 sp. Elle n'a pas de focus ; elle est lue en tête du groupe.
2. Consigne (obligatoire) : « Choisissez une seule réponse. » ou « Vous pouvez choisir plusieurs réponses. ». Texte 18 sp.
3. Aide (optionnelle) de la question.
4. Lignes d'options, une par option, dans l'ordre fourni par l'appelant. Chaque ligne contient :
   - l'indicateur (bouton radio rond en choix unique, case carrée en choix multiple), 24 dp, contour 1,5 dp ;
   - le libellé (18 sp), qui passe à la ligne ;
   - une aide d'option facultative, en texte plus petit (16 sp), ex. « Peut passer seul ».
   La ligne entière est la cible tactile (>= 48 dp de haut, pleine largeur).
5. Message d'erreur (si présent), après les options : « Erreur : Choisissez une option. ».

### 4.2 `NautilusSelector`

Ordre de lecture et de focus :
1. Libellé permanent de la question (ex. « Transfert »), au-dessus du champ, comme `NautilusTextField`.
2. Zone de valeur : affiche la valeur choisie (« Peut passer sur un siège seul ») ou, si rien n'est choisi, le texte « Aucun choix fait ». Hauteur >= 48 dp, contour 1,5 dp, angles 12 dp. Une icône décorative (flèche vers le bas) est à droite ; elle est exclue de la lecture.
3. Aide (optionnelle).
4. Message d'erreur (optionnel), « Erreur : … ».

Ouvre une page dédiée (section 9) : titre = libellé de la question, liste `NautilusOptionList` en choix unique, bouton « Valider le choix » en bas (`NautilusButton`), bouton « Retour » en haut.

## 5. États

### 5.1 Ligne d'option (`NautilusOptionList`)

| État | Indicateur | Texte | Contour de ligne | Note |
| --- | --- | --- | --- | --- |
| Non coché | Cercle vide (ou case vide), contour 1,5 dp, couleur de texte | Couleur de texte | Aucun | Défaut |
| Coché | Point plein au centre (radio) ou coche (case), fond couleur primaire | Couleur de texte, gras | Aucun | La forme est le signal principal, pas seulement la couleur |
| Focus | Idem à son état | Idem | Anneau externe 3 dp, couleur de texte, espace 2 dp (`NautilusFocusRing`) | Ratio de l'anneau : 17,4 (clair), 16,0 (sombre), 21,0 (contraste élevé) |
| Pressé | Effet d'encre du thème | Idem | Idem | Retour visuel obligatoire |
| Désactivé | Contour 1 dp | Couleur de texte (non estompée) | Aucun | Une aide dit pourquoi : « Non disponible avec un fauteuil électrique » (donnée par l'appelant) |
| Erreur du groupe | Idem | Idem | Aucun | L'erreur est portée par le message du groupe, pas par chaque ligne |

### 5.2 Groupe (`NautilusOptionList`)

| État | Rendu | Information portée |
| --- | --- | --- |
| Défaut | Légende, consigne, lignes | Consigne « Choisissez une seule réponse » |
| Obligatoire non rempli | La légende se termine par « (obligatoire) » | Texte, pas seulement une étoile |
| Erreur | Message « Erreur : Choisissez une option. » après les lignes, en gras, couleur d'erreur | Préfixe texte + annonce (section 6) |
| Chargement (si l'appelant charge les options) | Texte « Chargement des choix… » (rôle statut), pas de liste | Pas de spinner seul |
| Vide | Texte « Aucune option disponible pour le moment. » (rôle statut) | Jamais une zone vide muette |

### 5.3 `NautilusSelector`

| État | Contour | Zone de valeur | Message |
| --- | --- | --- | --- |
| Défaut (rien choisi) | 1,5 dp | « Aucun choix fait » | Aide si fournie |
| Rempli | 1,5 dp | Valeur choisie, en gras | Aide |
| Focus | Anneau externe 3 dp (voir 5.1) | Idem | Idem |
| Erreur | 2 dp, couleur d'erreur | Idem | « Erreur : … » en gras |
| Désactivé | 1 dp | Valeur, non estompée | Explication donnée par l'appelant (« Choix non modifiable ») |

## 6. Annonce au lecteur d'écran (FR)

Le libellé et la valeur sont donnés par `Semantics`. Le système annonce l'état (coché ou non) et le rôle. Les textes sont donnés par l'appelant, en français.

| Élément | Libellé lu (label) | Valeur / état | Rôle | Annonce supplémentaire |
| --- | --- | --- | --- | --- |
| Groupe (choix unique) | « Quel type de fauteuil utilisez-vous ? Choisissez une seule réponse. » | Aucune | Groupe | Aucune |
| Groupe (choix multiple) | « Mobilité. Vous pouvez choisir plusieurs réponses. » | Aucune | Groupe | Aucune |
| Option, choix unique | « Fauteuil manuel pliable » | Coché / non coché (état système) | Bouton radio | Le système peut annoncer la position (« 1 sur 4 ») ; ne pas la répéter dans le libellé |
| Option, choix multiple | « Béquilles » | Coché / non coché | Case à cocher | Aucune |
| Option désactivée | « Fauteuil électrique » | Non disponible (état système) | Bouton radio ou case | Aide lue après le libellé : « Non disponible avec ce véhicule » |
| Sélecteur, fermé | « Transfert : Peut passer sur un siège seul » | Valeur | Bouton | Indication : « Appuyez pour changer » |
| Sélecteur, rien choisi | « Transfert : Aucun choix fait » | Vide | Bouton | Indication : « Appuyez pour choisir » |
| Page du sélecteur | Titre de la question | Aucune | Titre | Lue à l'ouverture de la page |
| Erreur du groupe | « Erreur : Choisissez une option. » | Aucune | Statut | Annoncée à l'apparition (assertive, comme `NautilusTextField`) |

Règles :
- Pas de « bouton » ni « case » répété dans le libellé de l'option : le rôle vient du système.
- Pas d'annonce supplémentaire quand la sélection change (le système annonce déjà l'état coché).
- Aucune option n'est lue avec un libellé vide ou une valeur codée (« opt_3 »).

## 7. Navigation clavier et focus

Ordre général : la légende est lue, puis les options dans l'ordre affiché, puis l'élément suivant de l'écran. L'ordre suit la lecture (haut en bas).

### 7.1 Choix unique

1. `Tab` entre dans le groupe sur l'option cochée ; si rien n'est coché, sur la première option (focus unique dans le groupe, « roving focus »).
2. Flèches haut / bas (et gauche / droite) : déplacent le focus sur l'option précédente ou suivante, et la cochent. Au bord, la flèche ne boucle pas.
3. `Espace` ou `Entrée` : cochent l'option focalisée (utile si le focus est déjà sur elle sans flèche).
4. `Tab` quitte le groupe et passe à l'élément suivant (sans parcourir chaque option).

### 7.2 Choix multiple

1. `Tab` : une option à la fois (chaque case est un arrêt de focus), dans l'ordre.
2. `Espace` ou `Entrée` : bascule la case.
3. Flèches : facultatif ; si implémenté, elles déplacent le focus sans cocher.

### 7.3 `NautilusSelector` et page de choix

1. `Tab` : le sélecteur reçoit le focus (anneau externe).
2. `Espace` ou `Entrée` : ouvre la page. Le focus va sur le titre de la page, puis sur l'option cochée (ou la première).
3. Dans la page : mêmes règles que 7.1. Le choix est validé par « Valider le choix » (voir point de décision D2).
4. `Échap` ou « Retour » ferme la page sans changer le choix ; le focus revient sur le sélecteur (pas en tête d'écran).
5. Une option hors de vue reçoit le focus : la liste défile pour la rendre visible.

### 7.4 Focus visible

- L'anneau externe (`NautilusFocusRing`, 3 dp, couleur de texte, espace 2 dp) est présent sur chaque ligne focalisée et sur le sélecteur. La ligne entière est encadrée ; l'espace de l'anneau est réservé en permanence (la mise en page ne bouge pas).
- La légende et le texte d'aide ne prennent jamais le focus.
- Un test vérifie la présence de l'anneau au focus (clé `NautilusFocusRing.ringKey`).

## 8. Cibles et espacement

- Ligne d'option : hauteur >= 48 dp, pleine largeur ; l'indicateur seul (24 dp) n'est pas la cible.
- Sélecteur : hauteur >= 48 dp, pleine largeur.
- Espacement entre deux lignes : 8 dp minimum (`NautilusTokens.spacing`) ; l'espace de l'anneau (5 dp par côté) ne doit pas chevaucher la ligne voisine.
- Boutons « Valider le choix » et « Retour » : 48 dp minimum.

## 9. Liste longue et page de choix

Seuil : au-delà de 7 options, utiliser `NautilusSelector` (page dédiée). Les listes du cahier (§5.1, §5.3) comptent 5 options au maximum ; le seuil sert de règle pour la suite.

Page de choix :
- En-tête : bouton « Retour » (48 dp) et titre = libellé de la question.
- Corps : `NautilusOptionList` en choix unique, défilement vertical. Le défilement au doigt est autorisé (ce n'est pas un geste complexe) ; le défilement au clavier et la barre de défilement restent disponibles.
- Pied de page fixe : bouton « Valider le choix » (`NautilusButton`), toujours visible, même quand la liste défile.
- Pas de recherche au MVP (la saisie vocale est prévue au lot 1, cahier §6.3).
- Pas de fermeture automatique au premier appui (point de décision D2).

## 10. Texte, taille et 200 %

- Libellés d'option et consigne : 18 sp (`bodyLarge`) ; légende : 20 sp gras (`titleMedium`) ; boutons : 18 sp gras (`labelLarge`) ; aide d'option : 16 sp minimum. Interligne 1,4.
- Le texte suit le réglage système jusqu'à 200 %, sans troncature (pas de `maxLines` fixé sur les libellés).
- À 200 %, la ligne grandit ; l'indicateur reste aligné en haut de la ligne (pas centré sur plusieurs lignes de texte).
- Les valeurs du sélecteur passent à la ligne ; la zone de valeur ne tronque rien.
- Test attendu : capture à 200 % sans débordement ni perte de texte, sur les 3 thèmes (au moins une liste de 5 options).
- Le texte d'erreur utilise un préfixe « Erreur : » avec une espace insécable (U+00A0) avant le deux-points, comme `NautilusTextField.errorPrefix`.

## 11. Contrastes (WCAG 2.2 AA)

Ratios calculés à partir de `tokens.dart`. Seuils : 4,5:1 pour le texte (1.4.3), 3:1 pour les composants graphiques et contours (1.4.11). Les états désactivés sont exemptés, sans supprimer l'explication.

| Thème | Paire | Ratio | Seuil | Résultat |
| --- | --- | --- | --- | --- |
| Clair | Texte `1A1A1A` sur fond `FFFFFF` (libellés, légende) | 17,4 | 4,5 | OK |
| Clair | Contour de l'indicateur `1A1A1A` sur `FFFFFF` | 17,4 | 3 | OK |
| Clair | Anneau de focus `1A1A1A` sur `FFFFFF` | 17,4 | 3 | OK |
| Clair | Fond coché `0B4F8A` sur `FFFFFF` (point ou coche) | 8,4 | 3 | OK |
| Clair | Coche/point `FFFFFF` sur `0B4F8A` | 8,4 | 3 | OK |
| Clair | Erreur `B00020` sur `FFFFFF` | 7,3 | 4,5 | OK |
| Sombre | Texte `EDEDED` sur `121212` | 16,0 | 4,5 | OK |
| Sombre | Contour et anneau `EDEDED` sur `121212` | 16,0 | 3 | OK |
| Sombre | Fond coché `9CC9F5` sur `121212` | 10,8 | 3 | OK |
| Sombre | Coche/point `0A1929` sur `9CC9F5` | 10,2 | 3 | OK |
| Sombre | Erreur `FFB4AB` sur `121212` | 11,0 | 4,5 | OK |
| Contraste élevé | Texte `FFFFFF` sur `000000` | 21,0 | 4,5 | OK |
| Contraste élevé | Contour et anneau `FFFFFF` sur `000000` | 21,0 | 3 | OK |
| Contraste élevé | Fond coché `FFEB3B` sur `000000` | 17,2 | 3 | OK |
| Contraste élevé | Coche/point `000000` sur `FFEB3B` | 17,2 | 3 | OK |
| Contraste élevé | Erreur `FF8A80` sur `000000` | 9,2 | 4,5 | OK |

Règle : le fond de la ligne cochée reste celui de la surface ; ne pas ajouter de teinte de fond comme seul signal (une teinte légère ne doit pas remplacer la forme).

## 12. Information jamais portée par la seule couleur

- Coché : point ou coche dans un indicateur (forme) + état système « coché » + texte en gras. OK.
- Non coché : cercle ou case vide. OK.
- Erreur : préfixe texte « Erreur : », contour du sélecteur plus épais (2 dp), texte gras. OK.
- Désactivé : l'explication est écrite à côté de l'option (texte), pas seulement grisée. OK.
- Sélecteur : la valeur choisie est écrite dans la zone ; la flèche est décorative. OK.

### Écarts déjà relevés sur les autres composants (ne pas répéter)

| Écart | Composant | Statut dans le code lu | Action pour U48 |
| --- | --- | --- | --- |
| E1 focus visible (anneau externe) | Champ, carte bouton | Appliqué : `NautilusFocusRing` dans `NautilusTextField` et `NautilusInfoCard` (mode bouton) | Réutiliser `NautilusFocusRing` ; même motif sur les lignes |
| E2 annonce de l'erreur | Champ | Appliqué : `SemanticsService.sendAnnouncement` à l'apparition de l'erreur | Même règle pour l'erreur du groupe |
| E3 texte 18 sp | Thème (3 thèmes) | Appliqué : `NautilusTheme._accessibleTextTheme` | Ne pas redéfinir les tailles dans le composant |
| E4 repère de l'étape en cours | Indicateur d'étape | Appliqué (contour 3 dp) | Hors périmètre |
| E5 espace insécable avant « : » | Champ, indicateur | Présent (U+00A0 dans `errorPrefix` et le séparateur de l'indicateur) ; à confirmer par test | Même convention pour « Erreur : » du groupe |
| E6 explication d'un champ désactivé | Champ | Ouvert : spec seule, aucun code (attendu de l'appelant) | Documenter dans la spec de chaque écran qui désactive une option |
| E7 verbe d'action sur les cartes bouton | Carte bouton | Partiel : `assert` sur la présence de `semanticLabel`, pas sur le verbe | Pour les lignes du sélecteur, la règle est le libellé « Question : valeur » (pas de verbe requis) |

Écart nouveau à traiter dans U48 : aucun écart nouveau identifié sur les composants existants pendant cette passe.

## 13. Points de décision (orchestrateur, puis Fouad si besoin)

- D1 (périmètre) : U48 livre-t-elle le choix multiple ? Recommandation : oui, car 4 rubriques du cahier (mobilité, aide, communication, accompagnement) sont à choix multiple. Option alternative : choix unique seul en U48, multiple reporté à une US suivante.
- D2 (validation) : le choix se valide-t-il au premier appui dans la page du sélecteur, ou par le bouton « Valider le choix » ? Recommandation : bouton « Valider le choix », sans fermeture automatique, pour éviter un choix fait par erreur (public PMR, motricité réduite, déficience intellectuelle). Option alternative : choix immédiat avec retour texte « Choix enregistré : … ».
- D3 (seuil) : 7 options au plus dans `NautilusOptionList`, au-delà `NautilusSelector`. Recommandation : garder ce seuil. Option alternative : 5.

Questions métier : aucune.

## 14. Textes fixes (FR, phrases courtes)

| Usage | Texte |
| --- | --- |
| Consigne choix unique | « Choisissez une seule réponse. » |
| Consigne choix multiple | « Vous pouvez choisir plusieurs réponses. » |
| Question obligatoire | « (obligatoire) » |
| Erreur de groupe | « Erreur : Choisissez une option. » |
| Sélecteur vide | « Aucun choix fait » |
| Indication sélecteur | « Appuyez pour changer » (rempli) ; « Appuyez pour choisir » (vide) |
| Bouton de validation | « Valider le choix » |
| Bouton retour | « Retour » |
| Liste vide | « Aucune option disponible pour le moment. » |
| Chargement | « Chargement des choix… » |

Règles FALC : phrases courtes, un verbe par phrase, « vous » (cohérent avec l'appli), pas d'abréviation. Le texte des options vient de l'appelant et suit les mêmes règles.

## 15. Composants du design system

- `NautilusOptionList` : nouveau, à créer dans `lib/design/`. Rôle : choix unique ou multiple, lignes de 48 dp, annonce par `Semantics` (valeur coché/non coché, rôle bouton radio ou case).
- `NautilusSelector` : nouveau, à créer dans `lib/design/`. Rôle : ligne de type champ qui ouvre une page de choix.
- Réutilisés : `NautilusFocusRing`, `NautilusTokens`, `NautilusTheme` (3 thèmes), `NautilusButton` (bouton « Valider le choix »), même convention d'erreur que `NautilusTextField`.

## 16. Tests attendus (cahier 6.4)

- `meetsGuideline(androidTapTargetGuideline)`, `iOSTapTargetGuideline`, `labeledTapTargetGuideline`, `textContrastGuideline` sur `NautilusOptionList` (choix unique et multiple) et `NautilusSelector`, dans les 3 thèmes.
- Sémantique : chaque ligne expose son libellé et son état coché / non coché ; le groupe expose sa légende.
- Focus : anneau présent sur la ligne focalisée et sur le sélecteur ; flèches déplacent et cochent en choix unique ; `Espace` bascule en choix multiple.
- Erreur : annonce à l'apparition du message (comme E2).
- Liste vide et chargement : texte de statut présent, pas de zone muette.
- À 200 % : pas de débordement sur une liste de 5 options.
- Vérification manuelle sous VoiceOver et TalkBack avant de considérer l'écran terminé (cahier 6.4).
