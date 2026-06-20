# Questie

[![Discord](https://img.shields.io/badge/discord-Questie-738bd7)](https://discord.gg/s33MAYKeZd)
[![Stars](https://img.shields.io/github/stars/Questie/Questie)](https://img.shields.io/github/stars/Questie/Questie)

[![Downloads](https://img.shields.io/github/downloads/Questie/Questie/total.svg)](https://github.com/Questie/Questie/releases/)
[![Downloads Latest](https://img.shields.io/github/downloads/Questie/Questie/v11.29.5/total.svg)](https://github.com/Questie/Questie/releases/latest)
[![Date Latest](https://img.shields.io/github/release-date/Questie/Questie.svg)](https://github.com/Questie/Questie/releases/latest)
[![Commits Since Latest](https://img.shields.io/github/commits-since/Questie/Questie/latest.svg)](https://github.com/Questie/Questie/commits/master)

## Versiones de idioma
- [English](README.md)
- [Español](README_ES.md)
- [简体中文](README_CN.md)

## Descarga
Recomendamos usar el [Cliente CurseForge](https://curseforge.overwolf.com/) para gestionar tus addons de WoW en general. Encontrarás Questie [aquí en CurseForge](https://www.curseforge.com/wow/addons/questie).

Alternativamente, siempre puedes usar [la última versión en GitHub](https://github.com/Questie/Questie/releases/latest) y seguir la [Guía de instalación](https://github.com/Questie/Questie/wiki/Installation-Guide) en el Wiki para poner Questie en marcha.

Si tienes problemas, por favor lee las [Preguntas Frecuentes](https://github.com/Questie/Questie/wiki/FAQ-for-Classic-(1.13)).

## Información
- [Preguntas Frecuentes](https://github.com/Questie/Questie/wiki/FAQ)
- Ven a chatear con nosotros en [nuestro servidor de Discord](https://discord.gg/s33MAYKeZd).
- Puedes usar el [rastreador de incidencias](https://github.com/Questie/Questie/issues) para reportar errores y publicar solicitudes de funciones (requiere cuenta de GitHub).
- Al crear una incidencia, por favor sigue la estructura de plantilla para acelerar una posible solución.
- Si recibes un mensaje de error del cliente de WoW, incluye el texto **completo** o una captura de pantalla en tu reporte.
    - Debes ejecutar `/console scriptErrors 1` una vez en el chat dentro del juego para que los mensajes de error de Lua se muestren. Más tarde puedes desactivarlos con `/console scriptErrors 0`.

Confía en nosotros, ¡es (bueno)!

## Idiomas

Questie viene con traducciones para todos los idiomas oficiales de WoW Classic. Estos son:

Inglés, Alemán, Francés, Español, Portugués, Ruso, Chino simplificado, Chino tradicional y Coreano.

Si quieres ayudar con las traducciones, revisa la [carpeta de Traducciones](https://github.com/Questie/Questie/tree/master/Localization/Translations) y busca traducciones faltantes con:
> `["<yourLanguage>"] = false` (por ejemplo `["deDE"] = false`) y reemplaza el `false` por una cadena con la nueva traducción, p. ej. `["<yourLanguage>"] = "TuTraduccion"`.

Además hay soporte para ucraniano ([a través de otro addon](https://www.curseforge.com/wow/addons/questie-translation-ukrainian)).
Siguiendo [esta guía](https://github.com/Questie/Questie/wiki/Localization-to-more-languages) puedes añadir soporte para aún más idiomas.

## Contribución

[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](http://makeapullrequest.com)
- Agradecemos cualquier ayuda y contribución, así que no dudes en enviar un Pull Request en GitHub.
- Información adicional que podría interesarte está disponible [aquí](https://github.com/Questie/Questie/wiki/Contributing).

### Instalando Lua

1. Instala [Lua](https://www.lua.org/download.html) (5.1, ya que el cliente de WoW usa Lua 5.1)
   - En macOS eso es `brew install lua@5.1`
2. Instala [luarocks](https://luarocks.org/)
   - En macOS eso es `brew install luarocks`
3. Configura `luarocks` para usar la versión correcta de Lua (por defecto luarocks usa la versión más reciente instalada)
   - `luarocks config lua_version 5.1`
4. Instala [busted](https://github.com/lunarmodules/busted)
   - `luarocks install busted`
5. Instala `bit32`
   - `luarocks install bit32`
6. Instala [luacheck](https://github.com/lunarmodules/luacheck)
   - `luarocks install luacheck`

### luacheck

Questie usa `luacheck` para linting. Puedes ejecutarlo localmente con:

`luacheck -q Database Localization Modules Questie.lua`

### Tests unitarios

1. Ejecuta `busted -p ".test.lua" .` en el directorio raíz del proyecto
2. Al agregar nuevos tests, asegúrate de nombrarlos `<module>.test.lua` y ubicarlos junto al módulo

### Validación de la base de datos

Hay un script de validación para cada expansión que comprueba la base de datos en busca de errores comunes. De esa manera intentamos mantener los datos lo más correctos posible, y no olvidarnos de ajustar el campo `NPC.questStarts` cuando ajustamos `Quest.startedBy`. Puedes ejecutar los scripts con:

`lua cli/validate-<expansion>.lua`

Reemplaza `<expansion>` con la expansión que quieras validar (revisa la carpeta `cli` para ver los scripts disponibles).

## Donaciones
Si quieres apoyar el desarrollo de Questie mediante una donación, puedes hacerlo vía PayPal:

<a href="https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=JCUBJWKT395ME&source=url"><img src="https://www.paypalobjects.com/en_US/i/btn/btn_donate_LG.gif"/></a>

## Integrar Questie en tu addon

Revisa el [README de la API de Questie](./Public/README.md).

## Características

### Mostrar misiones en el mapa
- Muestra notas para los puntos de inicio de la misión, puntos de entrega y objetivos.
- Líneas de ruta para PNJ mostrando su patrón de movimiento.

![Questie Quest Givers](https://i.imgur.com/4abi5yu.png)
![Questie Complete](https://i.imgur.com/DgvBHyh.png)
![Questie Tooltip](https://i.imgur.com/uPykHKC.png)

### Rastreador de misiones
- Rastrea automáticamente las misiones al aceptarlas
- Puede mostrar todas las misiones del registro a la vez (en lugar de las 5 predeterminadas)
- Clic izquierdo en la misión para abrir el registro de misiones (configurable)
- Clic derecho para más opciones, por ejemplo:
    - Fijar misión (hace que los demás iconos de misión sean translúcidos)
    - Apuntar la flecha hacia el objetivo (requiere el addon [TomTom](https://www.curseforge.com/wow/addons/tomtom))

![QuestieTracker](https://user-images.githubusercontent.com/8838573/67285596-24dbab00-f4d8-11e9-9ae1-7dd6206b5e48.png)

### Comunicación de misiones
- Puedes ver el progreso de las misiones de los miembros del grupo en el tooltip.

### Tooltips
- Muestra tooltips en las notas del mapa y en los PNJ/objetos de las misiones.
- Mantén presionada la tecla Mayús mientras pasas el cursor sobre un icono del mapa para mostrar más información, como la experiencia de la misión.

### Viaje
- Questie registra los pasos de tu viaje en la ventana "Mi viaje". (clic izquierdo en el botón del minimapa y selecciona la pestaña "Mi viaje" o escribe `/questie journey`)

![Journey](https://user-images.githubusercontent.com/8838573/67285651-3cb32f00-f4d8-11e9-95d8-e8ceb2a8d871.png)

### Misiones por zona
- Questie lista todas las misiones de una zona divididas entre completadas y disponibles. Hay que completarlas todas. (clic izquierdo en el botón del minimapa (o escribe `/questie journey`) y selecciona la pestaña "Misiones por zona")

![QuestsByZone](https://user-images.githubusercontent.com/8838573/67285665-450b6a00-f4d8-11e9-9283-325d26c7c70d.png)

### Búsqueda
- La base de datos de Questie puede buscarse. (clic izquierdo en el botón del minimapa (o escribe `/questie journey`) y selecciona la pestaña "Búsqueda avanzada")

![Search](https://user-images.githubusercontent.com/8838573/67285691-4f2d6880-f4d8-11e9-8656-b3e37dce2f05.png)

### Configuración
- Amplias opciones de configuración. (mantén Mayús y haz clic izquierdo en el botón del minimapa para abrir o escribe `/questie`)