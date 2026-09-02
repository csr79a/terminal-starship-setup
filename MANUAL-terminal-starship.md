# Manual: Personalizar la terminal con Starship (paso a paso)

Esta guía explica, paso a paso y sin dar nada por sabido, cómo dejar tu terminal con un prompt bonito y funcional usando **Starship**, además de un pequeño ajuste de seguridad en `sudo`.

No necesitas saber programar ni tener experiencia previa en Linux para seguir esta guía: solo copiar y pegar los comandos en el orden indicado.

> Esta guía cubre **Arch Linux/CachyOS, Fedora y Debian/Ubuntu** (las mismas distros que los scripts automatizados del repositorio). En cada paso que depende del gestor de paquetes se muestran los tres comandos, uno por distro — usa el que corresponda a la tuya. El resto de pasos (el diseño del prompt, `.bashrc`, el ajuste de `sudo`) es idéntico sea cual sea tu distro. El ejemplo visual (capturas y menús) usa **Konsole** en KDE Plasma, pero el proceso es equivalente en cualquier otro emulador de terminal.

---

## ¿Qué vamos a instalar?

- **Starship**: un programa que cambia el aspecto de la línea de comandos (el "prompt"), añadiendo colores, iconos y información útil como en qué carpeta estás o si hay cambios en un repositorio de git.
- Una **Nerd Font**: un tipo de letra especial que incluye iconos, necesaria para que Starship se vea bien y no aparezcan símbolos raros o cuadros vacíos.
- Un ajuste en tu **emulador de terminal** (Konsole, GNOME Terminal, etc.) para usar esa fuente.
- Un ajuste en **sudo** para que, al escribir tu contraseña de administrador, aparezcan asteriscos (por defecto no se ve nada, ni siquiera puntos).

---

## Paso 1: Instalar Starship

Abre tu terminal y ejecuta el comando correspondiente a tu distro:

| Distro | Comando |
|---|---|
| Arch Linux / CachyOS / Manjaro | `sudo pacman -S starship` |
| Fedora / Nobara | `curl -sS https://starship.rs/install.sh \| sh -s -- --yes` |
| Debian / Ubuntu | `curl -sS https://starship.rs/install.sh \| sh -s -- --yes` |

En Arch, Starship está en los repositorios oficiales. En Fedora y en Debian/Ubuntu no siempre está disponible en los repos, así que se usa el instalador oficial del propio proyecto Starship (descarga el binario directamente, sin depender de ningún gestor de paquetes).

Si usas `pacman`, te pedirá tu contraseña (no vas a ver nada mientras la escribes, es normal) y luego te preguntará si quieres continuar — confirma con `S` o `Y` según tu idioma, y pulsa Enter. Si usas el instalador de `curl`, con `--yes` no hace falta confirmar nada.

---

## Paso 2: Comprobar que tienes una Nerd Font instalada

Ejecuta:

```bash
fc-list | grep -i meslo
```

Este comando busca entre todas tus fuentes instaladas si hay alguna de la familia "Meslo" (una Nerd Font muy usada). Si te aparece una lista larga de resultados, ya la tienes instalada y puedes saltar al Paso 3.

Si no aparece nada, instálala con el comando de tu distro:

| Distro | Comando |
|---|---|
| Arch Linux / CachyOS / Manjaro | `sudo pacman -S ttf-meslo-nerd` |
| Fedora / Nobara | `sudo dnf install -y meslo-lg-fonts` |
| Debian / Ubuntu | *(no hay paquete oficial, ver instalación manual abajo)* |

**Si el paquete de tu distro no existe o el comando falla** (esto pasa siempre en Debian/Ubuntu, y a veces en Fedora según la versión), instala la fuente manualmente:

```bash
mkdir -p ~/.local/share/fonts
TMP_DIR=$(mktemp -d)
curl -sSLo "$TMP_DIR/Meslo.zip" \
    "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Meslo.zip"
unzip -oq "$TMP_DIR/Meslo.zip" -d ~/.local/share/fonts
rm -rf "$TMP_DIR"
fc-cache -f ~/.local/share/fonts
```

*(En Debian/Ubuntu puede que necesites instalar antes las herramientas para descomprimir: `sudo apt install -y curl unzip fontconfig`.)*

---

## Paso 3: Configurar la fuente en tu terminal

El programa de terminal necesita usar esa fuente especial para que los iconos se vean bien. El ejemplo aquí es para **Konsole** (KDE Plasma); si usas otro programa (GNOME Terminal, Ptyxis, Alacritty...), el proceso es equivalente: busca "Preferencias" o "Perfil" y ahí la opción de tipo de letra.

1. Abre Konsole.
2. Ve al menú (el icono con tres líneas horizontales, arriba a la izquierda) y haz clic en **"Configurar Konsole..."**.
3. En la ventana que se abre, haz clic en **"Perfiles"** (en el menú lateral).
4. Haz clic en el botón **"+ Nuevo..."**.
5. Ponle un nombre al perfil, por ejemplo `Starship`.
6. Marca la casilla **"Perfil predeterminado"**.
7. En el menú lateral de esa misma ventana, haz clic en **"Aspecto"**.
8. Verás un texto que dice "Tipo de letra" con un botón **"Escoger..."** al lado — haz clic ahí.
9. En el buscador de fuentes, escribe `Meslo`.
10. Elige **"MesloLGL Nerd Font Mono"** (o cualquier variante que termine en "Nerd Font Mono"), con estilo **Regular** y tamaño **12**.
11. Haz clic en **Aceptar** en la ventana de la fuente.
12. Haz clic en **Aceptar** en la ventana del perfil para guardar todo.
13. Cierra **todas** las ventanas de tu terminal que tengas abiertas y vuelve a abrir una nueva.

Este paso es igual en las tres distros: no depende del gestor de paquetes, sino de la interfaz gráfica de tu emulador de terminal.

---

## Paso 4: Aplicar un diseño de prompt para Starship

Starship no viene con un diseño bonito activado por defecto — viene "en blanco". Para no tener que diseñar uno desde cero, el propio proyecto de Starship ofrece diseños ya hechos y probados, llamados "presets". Vamos a usar uno con bloques de colores conectados por flechas.

Ejecuta este comando:

```bash
starship preset pastel-powerline -o ~/.config/starship.toml --force
```

**¿Qué hace este comando?**
- `starship preset pastel-powerline` le dice a Starship que use el diseño llamado "pastel-powerline" (bloques de colores pastel con forma de flecha).
- `-o ~/.config/starship.toml` significa que ese diseño se va a guardar en ese archivo, que es donde Starship busca su configuración.
- `--force` simplemente permite sobrescribir el archivo si ya existía uno antes en esa misma ruta.

Este paso es idéntico sin importar la distro que uses.

---

## Paso 5: Activar Starship en la terminal

Instalar Starship no es suficiente — hay que decirle a la terminal que lo use cada vez que se abre. Para eso, hay que añadir una línea a un archivo de configuración llamado `.bashrc`, que se ejecuta automáticamente cada vez que abres una terminal.

Ejecuta:

```bash
echo 'eval "$(starship init bash)"' >> ~/.bashrc
```

Este comando añade esa línea al final del archivo `.bashrc` automáticamente, sin que tengas que abrir ningún editor de texto.

Ahora recarga la configuración para que el cambio se aplique sin tener que cerrar la terminal:

```bash
source ~/.bashrc
```

En este momento ya deberías ver tu nuevo prompt con colores, flechas y la hora a la derecha.

*(Si usas otro shell en vez de bash, por ejemplo zsh, el comando cambia a `eval "$(starship init zsh)"` y se añade a `~/.zshrc` en vez de `~/.bashrc`.)*

Este paso también es idéntico en las tres distros.

---

## Paso 6: Comprobar que todo quedó bien

Puedes verificarlo con estos comandos:

```bash
cat ~/.config/starship.toml
```
Debe mostrarte el contenido del diseño "pastel-powerline" (verás colores en formato `#9A348E`, `#DA627D`, etc.)

```bash
grep starship ~/.bashrc
```
Debe mostrarte la línea `eval "$(starship init bash)"`.

```bash
starship --version
```
Debe mostrarte un número de versión, confirmando que el programa está instalado correctamente.

---

## Paso 7: Ver asteriscos al escribir la contraseña de sudo

Por defecto, cuando escribes tu contraseña después de `sudo`, no aparece absolutamente nada en pantalla (ni puntos ni asteriscos), por motivos de seguridad. Si prefieres ver asteriscos mientras escribes, sigue estos pasos. Este ajuste es idéntico en cualquier distro que use `sudo`.

### 7.1. Instalar un editor de texto (opcional)

Este paso solo es necesario si prefieres editar el archivo de `sudo` a mano en vez de usar el comando directo del apartado 7.2. Si quieres tener `nano` instalado:

| Distro | Comando |
|---|---|
| Arch Linux / CachyOS / Manjaro | `sudo pacman -S nano` |
| Fedora / Nobara | `sudo dnf install -y nano` |
| Debian / Ubuntu | normalmente ya viene instalado por defecto |

### 7.2. Editar el archivo de configuración de sudo

Este archivo es sensible, así que **nunca se edita directamente** con un editor normal. Vamos a crear un archivo aparte, específico para este ajuste, usando `visudo` (un comando especial que revisa que no haya errores antes de guardar):

```bash
echo "Defaults pwfeedback" | sudo tee /etc/sudoers.d/pwfeedback > /dev/null
sudo chmod 440 /etc/sudoers.d/pwfeedback
sudo visudo -c -f /etc/sudoers.d/pwfeedback
```

El último comando debe responder algo como `/etc/sudoers.d/pwfeedback: parsed OK`, confirmando que no hay errores de sintaxis. Este paso es igual en las tres distros.

*(Si prefieres editar el archivo principal de sudo directamente en vez de crear uno aparte, usa `sudo EDITOR=nano visudo`, añade la línea `Defaults pwfeedback` al final, y guarda con `Ctrl+O`, `Enter`, `Ctrl+X`.)*

### 7.3. Probar que funcionó

Ejecuta cualquier comando con `sudo`, por ejemplo:

```bash
sudo ls
```

Al escribir tu contraseña, ahora deberías ver un asterisco (`*`) aparecer por cada letra que escribes.

### 7.4. (Opcional) Dejar nano configurado como editor por defecto

Si quieres que `nano` se use automáticamente la próxima vez que necesites editar algo con `visudo` u otras herramientas similares, ejecuta:

```bash
echo 'export EDITOR=nano' >> ~/.bashrc
echo 'export VISUAL=nano' >> ~/.bashrc
source ~/.bashrc
```

---

## Resumen de todos los comandos (para copiar y pegar de una vez)

```bash
# 1. Instalar Starship
sudo pacman -S starship                                          # Arch/CachyOS
curl -sS https://starship.rs/install.sh | sh -s -- --yes         # Fedora / Debian / Ubuntu

# 2. Comprobar la Nerd Font (si no aparece nada, instalarla)
fc-list | grep -i meslo
sudo pacman -S ttf-meslo-nerd            # Arch/CachyOS (solo si el comando anterior no mostró nada)
sudo dnf install -y meslo-lg-fonts       # Fedora (si falla, instalación manual, ver Paso 2)

# 3. La configuración de la fuente en tu terminal se hace desde la interfaz gráfica (ver Paso 3)

# 4. Aplicar el diseño del prompt
starship preset pastel-powerline -o ~/.config/starship.toml --force

# 5. Activar Starship en la terminal
echo 'eval "$(starship init bash)"' >> ~/.bashrc
source ~/.bashrc

# 7. Asteriscos en la contraseña de sudo
echo "Defaults pwfeedback" | sudo tee /etc/sudoers.d/pwfeedback > /dev/null
sudo chmod 440 /etc/sudoers.d/pwfeedback
sudo visudo -c -f /etc/sudoers.d/pwfeedback
```

---

## Archivos que quedan modificados

| Archivo | Qué contiene ahora |
|---|---|
| `~/.config/starship.toml` | El diseño del prompt "pastel-powerline" |
| `~/.bashrc` | La línea que activa Starship, y opcionalmente las líneas de `EDITOR`/`VISUAL` |
| `/etc/sudoers.d/pwfeedback` | Archivo nuevo con `Defaults pwfeedback` |
| Perfil de tu terminal | Un perfil nuevo con la fuente Nerd Font, marcado como predeterminado |

---

## ¿Prefieres automatizarlo?

Este mismo repositorio incluye tres scripts que hacen automáticamente los pasos 1, 2, 4, 5 y 7 de este manual (todo excepto el Paso 3, que requiere la interfaz gráfica) — elige el que corresponda a tu distro:

| Distro | Script |
|---|---|
| Arch Linux / CachyOS / Manjaro / EndeavourOS | `setup-terminal-starship-arch.sh` |
| Fedora / Nobara | `setup-terminal-starship-fedora.sh` |
| Debian / Ubuntu / Linux Mint / Pop!_OS | `setup-terminal-starship-debian.sh` |

Consulta el `README.md` del repositorio para su uso.
