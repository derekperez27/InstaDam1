# Fase 0 - Investigacio previa: Crear Post Accessible 

## Context i objectiu
L'objectiu es garantir que una persona usuaria de TalkBack pugui completar el flux sencer de creacio de publicacio sense mirar la pantalla:
1. Seleccionar una imatge.
2. Escriure una descripcio.
3. Publicar.
4. Rebre confirmacio clara.
5. Tornar al feed i verificar que la publicacio apareix.

## Problemes d'accessibilitat detectats 
1. Selector d'imatge sense estat anunciat.
2. Camp de descripcio sense etiqueta visible externa (nomes label intern del camp).
3. Validacio de descripcio buida no integrada com a error de formulari (nomes missatge generic).
4. Estat de carrega de publicacio poc explicit per lector de pantalla.
5. Confirmacio de publicacio sense estrategia explicita de live region i anunci.
6. Recarrrega duplicada del feed despres de publicar (pot retardar percepcio de resultat).

## Decisions de disseny accessibles

### 1) Text visual vs etiqueta accessible
- Text visual: el que veu qualsevol usuari a la UI (titols, labels, botons).
- Etiqueta accessible: descripcio que llegeix TalkBack (Semantics label/hint/value).
- Decisio: mantenir tots dos canals, evitant confiar nomes en text visual.

### 2) Descripcio de l'estat d'elements interactius
- Selector d'imatge amb estat dinamic:
  - "No image selected".
  - "Image selected".
- Decisio Flutter: Semantics(button: true) amb label canviant segons l'estat.

### 3) Comunicacio de canvis dinamics 
- Per errors, carrega i confirmacio, cal anunci automatic.
- Decisio Flutter:
  - Semantics(liveRegion: true) als continguts de feedback.
  - SemanticsService.sendAnnouncement(...) per anuncis explicits en moments clau.

### 4) Validacio accessible en formularis
- Un formulari accessible necessita errorText associat al camp obligatori.
- Decisio Flutter:
  - Form + TextFormField + validator.
  - Missatge d'error en el mateix camp.
  - Anunci adicional per TalkBack quan la validacio falla.

### 5) Mida minima tactil 
- Referencia: minim 48dp x 48dp.
- Decisio Flutter:
  - Boto "Publicar" amb minimumSize de minim 48dp d'alt.

### 6) Ordre de focus en formularis
- El focus ha de seguir l'ordre logic de la tasca.
- Decisio Flutter:
  - FocusTraversalGroup + OrderedTraversalPolicy.
  - Ordre: selector imatge -> label/camp descripcio -> boto publicar.

### 7) Indicadors de carrega accessibles
- Durant la publicacio, l'usuari ha de saber que el proces segueix actiu.
- Decisio Flutter:
  - Estat _saving amb spinner i text "Publishing post" dins live region.
  - Boto deshabilitat mentre hi ha carrega.

### 8) Feedback accessible despres d'una accio
- La confirmacio ha de ser immediata, clara i anunciada.
- Decisio Flutter:
  - SnackBar amb Semantics(liveRegion: true).
  - Anunci explicit amb SemanticsService.
  - Retorn al feed funcional i aparicio immediata del post.






