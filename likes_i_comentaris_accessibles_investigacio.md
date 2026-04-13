# Fase 0 - Investigacio previa: Likes i Comentaris Accessibles ACT 5



## Problemes d'accessibilitat detectats
1. Inconsistencia entre pantalles: al feed el Like ja tenia semantica completa, pero al detall del post no informava correctament d'estat/accio/recompte.
2. Comentaris incomplets per lector: el comentari no incloia sempre tota la informacio necessaria en una sola lectura (autor + text + temps).
3. Elements decoratius potencialment sorollosos: avatars i icones visuals poden distreure si no s'exclouen semanticament.
4. Formulari de comentari millorable: dependre nomes del placeholder no es suficient; cal etiqueta visible i ordre de focus clar.
5. Feedback post-accio: cal anunciar explicitament quan un like canvia o quan s'afegeix un comentari, i no nomes actualitzar la UI visual.

## Decisions de disseny accessibles

### 1) Labels i descripcions semantiques 
- Like: Semantics amb:
  - `label`: accio que fara (`like_action` / `unlike_action`).
  - `toggled`: estat actual activat/desactivat.
  - `value`: nombre de likes (`likes`).
  - `hint`: instruccio d'uso (`like_hint`).
- Enviar comentari: botó amb label semantic clar (`send_comment_button`) i hint (`send_comment_hint`).

### 2) Estat i canvis dinamics 
- El botó Like utilitza `toggled` per anunciar estat actual.
- Els canvis de like i comentari utilitzen:
  - `SemanticsService.sendAnnouncement(...)` per anuncio immediat.
  - `SnackBar` amb `Semantics(liveRegion: true, ...)` com a reforc audible.
- Missatges de confirmacio inclouen recompte actualitzat per context.

### 3) Agrupacio semantica 
- Cada comentari es llegeix com una sola unitat coherent:
  - Autor + temps + text.
- `MergeSemantics` evita lectures fragmentades i fa mes natural el recorregut amb gestos de TalkBack.

### 4) Exclusio de decoratiu
- Avatars de comentari i altres elements purament visuals es marquen com a decoratius.
- Objectiu: evitar soroll i prioritzar informacio rellevant.

### 5) Formulari d'afegir comentari usable
- Camp amb etiqueta visible (`comment_field_visible_label`) per no dependre nomes de placeholder.
- Camp amb semantica de text field (`comment_field_label`) i hint (`add_comment_hint`).
- Ordre de focus controlat amb `FocusTraversalGroup` + `OrderedTraversalPolicy`:
  1. Camp de text.
  2. Botó Enviar.
- Enviament per tecla d'accio (`TextInputAction.send`) i amb botó.

### 6) Feedback accessible despres de l'accio
- Like afegit/retirat: anunci immediat + SnackBar live region.
- Comentari afegit: anunci immediat amb nou recompte (`comment_added_with_count`) + SnackBar live region.
- El nou comentari apareix immediatament en la llista despres d'insercio.

### 7) Icona i color 
- El Like canvia d'icona:
  - Actiu: `favorite`.
  - Inactiu: `favorite_border`.
- El color acompanya, pero la diferencia principal es iconografica i semantica.

