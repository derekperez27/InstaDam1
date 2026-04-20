# Fase 0 - Investigacio previa: Perfil accessible


## Problemes d'accessibilitat detectats
1. Foto de perfil sense context semantic suficient.
Si nomes es llegeix com "imatge", l'usuari no sap de qui es.

2. Estadistiques separades i poc coherents.
Si posts, seguidors i seguint es llegeixen en elements independents, es perd el resum global.

3. Grid de posts sense resum util.
Sense posicio, descripcio i likes, l'usuari no pot decidir quina miniatura obrir.

4. Boto "Editar perfil" poc clar.
Sense mida minima i label clar, pot ser dificil d'enfocar o activar amb TalkBack.

5. Nom d'usuari i bio fragmentats.
Una lectura trencada en massa nodes semantics dificulta la comprensio.

6. Feed filtrat per usuari amb risc d'inconsistencia.
Ha de tenir el mateix nivell d'accessibilitat que el feed principal.

7. Canvi de foto de perfil no definit.
Si no hi ha accio clara per canviar la foto (label + hint), l'usuari amb TalkBack no pot personalitzar el perfil de forma autonoma.

## Decisions de disseny accessibles
### 1) Labels i descripcions semantiques d'elements visuals
- Foto de perfil: Semantics amb label descriptiu i image: true.
- Miniatura del grid: label amb:
  - Posicio dins del grid (ex: "Post 2 de 9")
  - Descripcio del post (o "Sense descripcio")
  - Nombre de likes
- Cada miniatura ha d'indicar que es accionable (es pot obrir).

### 2) Agrupacio d'informacio amb MergeSemantics
- Agrupar les estadistiques (posts, seguidors, seguint) en una sola unitat.
- Objectiu: que TalkBack llegeixi un resum coherent en una sola passada.

### 3) Exclusion de contingut decoratiu 
- Excloure icones o capes visuals que no aporten informacio funcional.
- Evitar soroll per prioritzar contingut util.

### 4) Ordre de focus i navegacio per grid
- Definir ordre de focus consistent:
  1. Capcalera (foto + identitat)
  2. Estadistiques
  3. Boto "Editar perfil"
  4. Grid de miniatures
  5. Feed filtrat
- Recorregut previsible amb swipe esquerra/dreta de TalkBack.

### 5) Boto accessible amb mida minima i label clar
- Mida minima: 48dp d'alcada (i area tactil suficient).
- Label semantic clar: "Editar perfil".
- Hint opcional: "Doble toc per editar el perfil".

### 6) Canvi de foto de perfil accessible
- Afegir una accio clara sobre la foto (o boto separat) per "Canviar foto de perfil".
- Semantics de l'accio amb label clar: "Canviar foto de perfil".
- Hint recomanat: "Doble toc per seleccionar una nova foto".
- Mantenir area tactil minima de 48dp i feedback de confirmacio quan la foto es canvia.

### 7) Com anunciar informacio resumida
- Estadistiques: frase unica curta i completa.
- Cada post del grid: resum curt amb dades essencials.
- Evitar textos massa llargs per no sobrecarregar l'usuari.

## Com assegurar lectura correcta de nom d'usuari i bio
- Presentar nom d'usuari i bio en ordre logic.
- Si es necessari, agrupar-los en un contenidor semantic per lectura continua.
- Evitar duplicar lectura visual + semantic del mateix contingut.

## Com fer que el feed filtrat per usuari sigui igual d'usable
- Reutilitzar el mateix patro d'accessibilitat que el feed principal:
  - Targetes/posts amb labels complets
  - Elements accionables amb rol de boto
  - Navegacio i feedback coherents
- No reduir informacio en la versio filtrada.


### Checklist de validacio
- [ ] Foto de perfil amb Semantics image: true i label del nom d'usuari.
- [ ] Puc canviar la foto de perfil nomes amb TalkBack (focus + doble toc + confirmacio).
- [ ] Estadistiques agrupades amb MergeSemantics.
- [ ] Cada miniatura del grid amb posicio + descripcio + likes.
- [ ] Boto "Editar perfil" minim 48dp i label clar.
- [ ] Nom i bio llegibles amb TalkBack.
- [ ] Feed filtrat accessible igual que el feed principal.
- [ ] Navegacio completa del perfil sense suport visual.

