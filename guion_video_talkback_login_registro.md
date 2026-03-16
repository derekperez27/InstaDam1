# Guion de video (30-60 s) - Demo TalkBack InstaDAM

## Objetivo del video
Demostrar que login y registro son completables con TalkBack sin mirar la pantalla.

## Duracion estimada
45 segundos.

## Guion sugerido
1. Mostrar TalkBack activado y abrir InstaDAM en pantalla de login.
2. Navegar por elementos con gestos de TalkBack:
- Se anuncian labels visibles: Usuario, Contrasena.
- Se anuncia switch Recordar usuario con su estado.
3. Forzar error de validacion:
- Intentar enviar vacio.
- TalkBack anuncia errores de campo (Introduce el usuario / Introduce la contrasena).
4. Forzar error global:
- Introducir credenciales invalidas y enviar.
- Se anuncia mensaje global de error (Credenciales invalidas).
5. Mostrar focus management:
- Enter en Usuario mueve a Contrasena.
- Enter en Contrasena mueve al control de recordar usuario y luego boton principal.
6. Ir a registro con el boton de enlace.
7. Repetir validacion breve en registro:
- Error por usuario corto o contrasena corta.
- Mostrar mensaje global si el usuario ya existe.
8. Cerrar con envio correcto y navegacion a Home.

## Checklist visual para grabar
- Labels visibles fuera de TextFields.
- Error de campo visible y anunciado.
- Error global con liveRegion anunciado.
- Switch con estado activado/desactivado anunciado.
- Boton principal >= 48dp y estado cargando anunciado.
- Flujo completable sin mirar la pantalla.
