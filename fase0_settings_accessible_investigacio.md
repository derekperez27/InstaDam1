# Fase 0 - Investigacio previa: Settings Accessible

## Objectiu
Garantir que la pantalla de configuracio sigui completament usable amb TalkBack i que el text respecti l'escalat de mida del sistema.

L'usuari ha de poder:
1. Canviar tema clar/fosc.
2. Seleccionar idioma.
3. Activar/desactivar notificacions.
4. Tancar sessio amb confirmacio accessible.
5. Llegir tot el text escalat segons preferencies del sistema.

## Problemes d'accessibilitat detectats
1. Switch sense context semantic complet.
Si un switch no te label clar + estat `toggled`, TalkBack pot anunciar un control generic sense context funcional.

2. Canvis d'estat sense feedback audible immediat.
Canviar tema/notificacions/idioma sense anunci provoca dubte sobre si l'accio s'ha aplicat.

3. Selector d'idioma poc clar per lector.
Sense label visible i semantic clar, costa identificar que es un selector i quin idioma esta actiu.

4. Tancar sessio sense confirmacio accessible.
Fer logout directe pot generar errors d'usuari; cal dialeg clar amb opcions accessibles (cancelar/confirmar).

5. Risc d'incompatibilitat amb text gran.
Si algun punt de l'app fixa escalat (`textScaleFactor: 1.0`), es trenca accessibilitat per usuaris amb baixa visio.

## Decisions de disseny accessibles

### 1) Semantics per switches i botons
- Cada switch amb:
  - `label` semantic clar 
  - `toggled` per estat actual.
  - `onTapHint` per accio esperada.
- Botons d'accio (logout, confirmar, cancelar) amb `Semantics

### 2) Feedback audible de canvis 
- Despres de cada canvi de configuracio:
  - `SemanticsService.sendAnnouncement per anunci immediat.
  - `SnackBar` amb `Semantics(liveRegion: true)` com a reforc audible.
- Missatges per:
  - tema activat/desactivat,
  - notificacions activades/desactivades,
  - idioma canviat,
  - sessio tancada.

### 3) Text escalable del sistema
- Es mantingut l'escalat nadiu de Flutter.
- No es fa servir cap bloqueig del tipus `textScaleFactor: 1.0`.
- Titols, subtitols, labels i contingut es mostren amb widgets de text normals.
- S'utilitza scroll vertical a Settings per evitar retalls quan el text es fa gran.

### 4) Selector d'idioma accessible
- Label visible a pantalla 
- `Semantics` amb idioma actual i hint d'accio.
- Opcions legibles i navegables amb TalkBack.
- En canviar idioma, confirmacio audible immediata.

### 5) Dialeg de confirmacio de logout
- Dialeg amb titol i missatge clars.
- Opcions "Cancelar" i "Tancar sessio" accessibles com a botons semantics.
- Logout nomes s'executa si l'usuari confirma explicitament.

### 6) Reforc visual 
- Switch de tema/notificacions amb icona + text d'estat 
- L'estat no depen nomes de color.

