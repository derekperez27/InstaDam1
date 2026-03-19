
# Fase 0 - Investigacio previa: Feed Principal Accessible (InstaDAM)

## 1. Jerarquia i agrupacio semantica

### Per que un lector de pantalla llegeix element per element?
- TalkBack recorre l'arbre semantic, no el disseny visual.
- Si una card no esta agrupada, el lector anuncia peces separades sense context: icona, numero, text curt, etc.

### Com agrupar diversos elements visuals en una sola unitat comprensible?
- En Flutter, es pot usar `Semantics` per donar un resum complet del post i `MergeSemantics` per unir contingut relacionat.
- Aixi, la publicacio es presenta com una unitat logica i no com fragments desordenats.

### Per que es important entendre una publicacio com un conjunt?
- Perque la informacio util d'un post no es una sola etiqueta: cal autor, temps, descripcio i interaccions.
- Sense aquesta unio, una persona amb TalkBack no pot interpretar el context real del contingut.

### Exemple aplicat a InstaDAM
- Resum semantic de cada card: "Publicacio de Marc Gomez, fa 2 hores. Foto de platja al capvespre. 5 m'agrada i 3 comentaris."

## 2. Elements decoratius vs informatius

### Quins elements d'una card son decoratius?
- Avatar amb inicial quan el nom de l'autor ja es llegeix.
- Ombres, gradients i icones purament ornamentals.

### Per que no tot s'ha de llegir?
- Si TalkBack anuncia decoracio, afegeix soroll i dificulta trobar la informacio important.
- L'objectiu no es dir-ho tot, sino dir allò necessari per entendre i actuar.

### Impacte d'un exces d'informacio
- Navegacio mes lenta.
- Fatiga cognitiva.
- Errors d'interpretacio de l'ordre i les accions disponibles.

### Exemple aplicat a InstaDAM
- A PostCard, avatar i algunes icones visuals s'exclouen amb `ExcludeSemantics`.
- El que si es llegeix: autor, temps, descripcio, likes, comentaris i botons d'accio.

## 3. Descripcio d'imatges

### Per que una imatge necessita descripcio alternativa?
- Perque una foto pot contenir la part central del missatge del post.
- Sense descripcio, una persona cega perd contingut essencial.

### Que es un alt text?
- Es una descripcio textual breu i util del contingut visual.
- No descriu pixels; descriu el significat de la imatge en el context del post.

### Com ha de ser una descripcio util?
- Curta, concreta i contextual.
- Evitar "imatge" generic o descripcions massa llargues.

### Exemple aplicat a InstaDAM
- Si la descripcio del post es "Sortida a la muntanya", l'alt text pot ser: "Imatge de la publicacio: Sortida a la muntanya".
- Si no hi ha descripcio, fallback: "Imatge de la publicacio sense descripcio".

## 4. Botons amb estat (Like)

### Que significa que un boto tingui estat?
- Que no nomes executa una accio, tambe reflecteix una condicio actual (activat/desactivat).

### Diferencia entre "Donar m'agrada" i "Treure m'agrada"
- Son dues accions diferents amb efectes diferents sobre el comptador i la intencio de l'usuari.
- TalkBack ha d'indicar accio possible i estat actual (`toggled`).

### Com comunicar el nombre actual de likes?
- Com a valor semantic del boto i al resum de la card.
- Exemple: "Treure m'agrada. 5 m'agrada".

### Exemple aplicat a InstaDAM
- Boto like amb `Semantics(button: true, toggled: ...)`.
- Label dinamica: "Donar m'agrada" o "Treure m'agrada" segons estat.

## 5. Canvis d'estat i anuncis dinamics

### Quan l'usuari dona like, que canvia?
- Estat del boto (activat/desactivat).
- Nombre de likes.

### Per que el lector no ho detecta automaticament?
- Perque canviar un numero en pantalla no sempre implica un anunci de veu automatic.
- Cal marcar el canvi com a missatge rellevant per tecnologia assistiva.

### Com anunciar canvis d'estat?
- Amb `SemanticsService.announce(...)` i/o `SnackBar` amb `Semantics(liveRegion: true, ...)`.

### Exemple aplicat a InstaDAM
- En fer like: "M'agrada afegit. Ara hi ha 6 m'agrada."
- En treure like: "M'agrada eliminat. Ara hi ha 5 m'agrada."

## Fonts consultades (Feed)
1. Flutter API - MergeSemantics: https://api.flutter.dev/flutter/widgets/MergeSemantics-class.html
2. Flutter API - ExcludeSemantics: https://api.flutter.dev/flutter/widgets/ExcludeSemantics-class.html
3. Flutter API - SemanticsService: https://api.flutter.dev/flutter/semantics/SemanticsService-class.html
4. Android Developers - Accessibility principles: https://developer.android.com/guide/topics/ui/accessibility/principles
5. W3C WAI - Text alternatives (WCAG 1.1.1): https://www.w3.org/WAI/WCAG21/Understanding/non-text-content.html