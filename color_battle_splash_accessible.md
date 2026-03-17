# Color Battle - Palette accessible per a InstaDAM

## Palette seleccionada
- Color primario: #0057B8
- Color de error: #B3261E
- Color de texto principal: #212121
- Color de texto secundario: #5F6368
- Fondo base: #FFFFFF
- Texto sobre boton primario: #FFFFFF

## Ratios verificados
### 1. Color primario sobre fondo blanco
- Combinacion: #0057B8 sobre #FFFFFF
- Ratio WebAIM: 6.87:1
- Resultado: WCAG AA OK para texto normal, texto grande y componentes
- Verificacion: https://webaim.org/resources/contrastchecker/?fcolor=0057B8&bcolor=FFFFFF&api

### 2. Color de error sobre fondo blanco
- Combinacion: #B3261E sobre #FFFFFF
- Ratio WebAIM: 6.53:1
- Resultado: WCAG AA OK para texto normal, texto grande y componentes
- Verificacion: https://webaim.org/resources/contrastchecker/?fcolor=B3261E&bcolor=FFFFFF&api

### 3. Texto principal sobre fondo blanco
- Combinacion: #212121 sobre #FFFFFF
- Ratio WebAIM: 16.1:1
- Resultado: supera AA y AAA
- Verificacion: https://webaim.org/resources/contrastchecker/?fcolor=212121&bcolor=FFFFFF&api

### 4. Texto secundario sobre fondo blanco
- Combinacion: #5F6368 sobre #FFFFFF
- Ratio WebAIM: 6.04:1
- Resultado: WCAG AA OK para texto normal
- Verificacion: https://webaim.org/resources/contrastchecker/?fcolor=5F6368&bcolor=FFFFFF&api

### 5. Texto del boton sobre color primario
- Combinacion: #FFFFFF sobre #0057B8
- Ratio WebAIM: 6.87:1
- Resultado: WCAG AA OK para texto del boton
- Verificacion: https://webaim.org/resources/contrastchecker/?fcolor=FFFFFF&bcolor=0057B8&api

## Checklist Color Battle
- [x] Color primario verificado: contraste minimo 4.5:1 sobre fondo blanco
- [x] Color de error verificado: contraste minimo 4.5:1 sobre fondo blanco
- [x] Texto principal (#212121) con contraste 16.1:1
- [x] Texto secundario con contraste minimo 4.5:1
- [x] Botones con contraste del texto sobre color del boton minimo 4.5:1

## Justificacion de uso
- El color primario se reserva para marca, acciones principales y elementos de estado positivo o neutro.
- El color de error se usa junto con texto o icono, nunca como unica senal.
- El texto secundario mantiene jerarquia visual sin perder legibilidad.
- En la splash, el estado de carga se comunica con texto y spinner, no solo con color.