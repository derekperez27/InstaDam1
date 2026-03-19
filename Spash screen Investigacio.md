# Fase 0 - Investigacion previa: Splash Screen Accessible i Color Battle

## 1. Splash Screen
### Que funcion tiene dentro de una aplicacion movil
- La splash screen es la primera pantalla que aparece mientras la app prepara recursos, estado y navegacion inicial.
- Su funcion principal no es decorar, sino dar contexto inmediato: que app se ha abierto y que el sistema esta cargando.

### Es solo decorativa
- No. Puede tener una parte visual de marca, pero tambien cumple una funcion tecnica y de orientacion.
- Si solo se usa como pantalla bonita sin informar del estado, la persona usuaria no sabe si la app responde o se ha quedado bloqueada.

### Problemas si no es accesible
- Una persona con baja vision puede no distinguir logo, texto o estado de carga si el contraste es bajo.
- Una persona con TalkBack puede oir solo "imagen" o no oir nada, y no saber que pantalla se ha abierto.
- Si la navegacion automatica ocurre sin contexto, el cambio de pantalla se vuelve confuso.

### Ejemplo aplicado a InstaDAM
- En InstaDAM la splash debe anunciar "InstaDAM" y despues "Loading application" o "Cargando aplicacion" antes de pasar al login.
- El estado de carga no puede depender solo del color; por eso conviene combinar texto y indicador visual.

## 2. Accesibilidad visual y WCAG 2.1 AA
### Que es WCAG
- WCAG es la guia internacional mas usada para definir cuando una interfaz digital es perceptible, operable, comprensible y robusta.
- No dice como hacer una app "bonita", sino como evitar barreras reales de uso.

### Que implica el nivel AA
- El nivel AA es el umbral profesional minimo mas habitual para producto real.
- Obliga, entre otras cosas, a asegurar contraste suficiente en texto normal y en elementos interactivos.

### Que es el contraste de color
- Es la diferencia de luminancia entre un color de primer plano y su fondo.
- Cuanto mas clara sea esa diferencia, mas facil es leer y reconocer elementos.

### Por que el minimo recomendado para texto normal es 4.5:1
- Porque WCAG 2.1 AA busca que el contenido siga siendo legible para personas con vision reducida moderada, perdida de sensibilidad al contraste o envejecimiento visual.
- En texto pequeno, un contraste mas bajo hace que letras y numeros se mezclen con el fondo.

### Por que el color no puede ser el unico medio de informacion
- Porque no todas las personas distinguen los mismos colores o intensidades.
- Si solo usamos rojo para indicar error o verde para indicar correcto, parte de la informacion se pierde.
- Hay que combinar color con texto, iconos o cambios de estado anunciables.

### Ejemplo aplicado a InstaDAM
- La splash usa fondo blanco, color primario con contraste suficiente y texto secundario legible.
- El estado de carga se comunica con texto explicito, no solo con un spinner azul.

## 3. Lectores de pantalla
### Que es TalkBack
- TalkBack es el lector de pantalla de Android.
- Convierte la interfaz visual en informacion hablada y gestual para navegar sin mirar la pantalla.

### Como navega una persona con lector de pantalla
- Normalmente recorre los elementos uno a uno con gestos horizontales y activa acciones con doble toque.
- La experiencia depende del orden semantico y de que cada elemento tenga nombre y funcion claros.

### Que pasa cuando una imagen no tiene descripcion
- El lector puede anunciar solo "imagen" o incluso ignorar el contenido util.
- Eso deja fuera informacion clave como la identidad de la app o el proposito del elemento.

### Que es una region live y por que es importante
- Una live region es una zona cuyo cambio debe anunciarse automaticamente sin mover el foco.
- Sirve para estados dinamicos como cargando, error de validacion o progreso.

### Ejemplo aplicado a InstaDAM
- La splash de InstaDAM necesita una region live para anunciar que la aplicacion se esta cargando.
- Los elementos decorativos del fondo no deben entrar en el arbol semantico.

## 4. Semantica en interfaces
### Que significa semantica en una interfaz
- Significa explicar a la tecnologia asistiva que es cada cosa y para que sirve.
- No basta con que algo se vea como un logo o un boton; la app debe declararlo de forma accesible.

### Por que un lector de pantalla necesita informacion adicional
- Porque el lector no interpreta el diseno igual que una persona vidente.
- Necesita etiquetas, roles, estados y cambios de contenido para construir una narracion util.

### Diferencia entre elemento visual y elemento semantico
- Un elemento visual es lo que se pinta en pantalla.
- Un elemento semantico es la descripcion accesible que recibe TalkBack sobre ese mismo contenido.
- Puede haber decoracion visual que no deba anunciarse, y tambien contenido importante que necesite una descripcion mejor de la que se ve.

### Ejemplo aplicado a InstaDAM
- El icono del logo puede ser solo un circulo con una camara a nivel visual.
- A nivel semantico debe leerse simplemente como "InstaDAM" para no forzar a TalkBack a decir "icono" o "imagen" sin contexto.

## Fuentes consultadas
1. W3C WAI - Understanding SC 1.4.3 Contrast (Minimum): https://www.w3.org/WAI/WCAG21/Understanding/contrast-minimum.html
2. WebAIM - Contrast Checker: https://webaim.org/resources/contrastchecker/
3. Android Accessibility Help - Get started on Android with TalkBack: https://support.google.com/accessibility/android/answer/6283677
4. Flutter API - Semantics: https://api.flutter.dev/flutter/widgets/Semantics-class.html


