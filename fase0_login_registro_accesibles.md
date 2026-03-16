# Fase 0 - Investigacion previa: Login y Registro accesibles en InstaDAM

## 1. Labels vs placeholders
### Diferencia entre placeholder y label visible
- El placeholder es un texto de ayuda dentro del campo que suele desaparecer cuando el usuario escribe.
- El label visible es una etiqueta persistente fuera del campo o en formato flotante, siempre disponible para identificar el dato.

### Problemas cuando el texto desaparece al escribir
- El usuario puede olvidar que campo estaba completando.
- Con lector de pantalla, la referencia contextual se vuelve menos estable si solo depende del placeholder.
- En formularios largos o con interrupciones, aumenta el riesgo de errores.

### Como garantizar que siempre se sepa que campo se completa
- Mostrar etiquetas visibles encima de cada TextFormField (por ejemplo, Usuario y Contrasena).
- Mantener hints como apoyo, pero no como unica fuente de contexto.
- Usar nombres coherentes en etiqueta visual, validacion y semantica.

### Ejemplo aplicado a InstaDAM
- En login y registro se ha implementado la etiqueta visible Usuario y Contrasena antes de cada campo.
- El hint se conserva como ayuda secundaria (Introduce tu usuario / Introduce tu contrasena).

## 2. Errores accesibles
### Como anunciar automaticamente errores de campo o globales
- Errores de campo: usar validator + errorText de TextFormField. Flutter expone este cambio a accesibilidad cuando el campo se valida.
- Error global: renderizar un contenedor de error con Semantics(liveRegion: true) para que TalkBack lo anuncie cuando aparezca.

### Que es un liveRegion y cuando usarlo
- liveRegion es una region que notifica cambios dinamicos al lector de pantalla sin que el usuario tenga que mover foco.
- Se usa para mensajes importantes del estado actual: credenciales invalidas, usuario existente o errores bloqueantes del envio.

### Por que importa aunque no mire la pantalla
- En uso real con TalkBack, la persona puede navegar por gestos y audio.
- Si el error no se anuncia, no sabe por que fallo el formulario y queda bloqueada.

### Ejemplo aplicado a InstaDAM
- Login: si falla autenticacion, se muestra mensaje global accesible con liveRegion.
- Registro: si el usuario ya existe, el mensaje global tambien se anuncia automaticamente.

## 3. Focus management
### Navegacion correcta con teclado o lector de pantalla
- El orden de foco debe ser logico y predecible: Usuario -> Contrasena -> Recordar usuario -> Boton principal.
- Cada campo debe declarar textInputAction para avanzar con Enter/Next.

### Importancia de Enter al siguiente campo
- Reduce friccion y tiempo de relleno.
- Evita perdida de contexto para personas que no interactuan tocando la pantalla.
- Mejora consistencia entre teclado fisico, teclado virtual y lector.

### Ejemplo aplicado a InstaDAM
- Enter en Usuario mueve foco a Contrasena.
- Enter en Contrasena mueve foco al control Recordar usuario.
- Desde ahi se llega al boton de accion principal.

## 4. Botones y switches accesibles
### Que necesita un boton para ser accesible
- Nombre claro de accion (Iniciar sesion, Registrarse).
- Estado comprensible (habilitado/deshabilitado y cargando).
- Tamano tactil minimo 48dp para usabilidad.

### Que significa un switch accesible
- Debe anunciar funcion y estado actual (activado/desactivado).
- Debe exponer propiedad toggled/checked a semantica.

### Relevancia de la medida minima del boton
- Mejora precision tactil y reduce errores de pulsacion.
- Es una recomendacion estandar de accesibilidad movil.

### Ejemplo aplicado a InstaDAM
- Botones principales con minimumSize: Size(double.infinity, 48).
- Switch Recordar usuario envuelto en Semantics con estado toggled.
- Estado de carga anunciado en el boton durante autenticacion.

## Conclusiones
Aplicar accesibilidad en formularios no es solo cumplir una checklist: mejora usabilidad para todas las personas. En InstaDAM, separar login y registro, mantener labels visibles, anunciar errores y gestionar foco permite completar el flujo sin mirar la pantalla.

## Fuentes consultadas
1. Flutter Docs - Accessibility overview: https://docs.flutter.dev/ui/accessibility-and-internationalization/accessibility
2. Flutter API - Semantics: https://api.flutter.dev/flutter/widgets/Semantics-class.html
3. Flutter API - TextFormField: https://api.flutter.dev/flutter/material/TextFormField-class.html
4. Android Accessibility - TalkBack principles: https://support.google.com/accessibility/android/answer/6283677
5. Material Design Accessibility guidance: https://m3.material.io/foundations/designing/overview
