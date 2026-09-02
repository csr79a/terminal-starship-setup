# Manual: Personalización de terminal con Starship

Automatiza la configuración de una terminal con un prompt moderno usando **Starship**: colores, iconos, información de git, versión de lenguajes de programación, y un ajuste extra para ver asteriscos al escribir la contraseña de `sudo`.

> **Este manual está probado en CachyOS (Arch Linux) con Konsole (KDE Plasma) y bash.** Los pasos de Starship, la fuente y `sudo` son universales para cualquier distro de Linux; solo cambian los comandos de instalación de paquetes y el emulador de terminal que uses. Más abajo hay una tabla de equivalencias para adaptarlo a Fedora, Ubuntu/Debian y otras distros.

## Contenido de este repositorio

| Archivo | Descripción |
|---|---|
| `setup-terminal-starship.sh` | Script que automatiza todo lo que se puede automatizar por terminal |
| Este README | Explicación paso a paso, tabla de adaptación a otras distros, y el único paso manual (elegir fuente en el emulador de terminal) |

---

## ¿Qué hace el script?

1. Instala **Starship** (motor del prompt).
2. Comprueba si la Nerd Font **MesloLG** está instalada y, si no, la instala.
3. Aplica el diseño de prompt oficial **pastel-powerline** de Starship.
4. Activa Starship en `bash` (añade la línea de inicialización a `~/.bashrc`).
5. Activa el **feedback visual (asteriscos) al escribir la contraseña de `sudo`**, de forma segura, sin tocar `/etc/sudoers` directamente.

Es **idempotente**: se puede ejecutar varias veces sin romper nada — si un paso ya está hecho, lo detecta y lo salta.

---

## Adaptar este manual a otra distro

El script está escrito usando `pacman` (Arch Linux / CachyOS), pero **solo dos pasos dependen del gestor de paquetes**: instalar Starship y la fuente. Todo lo demás (el preset de Starship, la línea en `.bashrc`, el ajuste de `sudo`) funciona exactamente igual en cualquier distro.

| Distro | Comando de instalación equivalente |
|---|---|
| Arch / CachyOS / Manjaro | `sudo pacman -S <paquete>` |
| Fedora | `sudo dnf install -y <paquete>` |
| Ubuntu / Debian | `sudo apt install -y <paquete>` |
| openSUSE | `sudo zypper install -y <paquete>` |

Alternativa universal para Starship, que funciona igual en cualquier distro sin depender del gestor de paquetes:

```bash
curl -sS https://starship.rs/install.sh | sh
```

Para la fuente, el nombre del paquete puede variar según la distro (por ejemplo, en algunas puede venir como `nerd-fonts-meslo` o requerir descargarla manualmente desde [github.com/ryanoasis/nerd-fonts](https://github.com/ryanoasis/nerd-fonts)). El resto de pasos (crear el archivo de Starship, activar `pwfeedback`) son idénticos sea cual sea tu distro.

Si adaptas el script a tu distro, solo tienes que cambiar las líneas que empiezan por `sudo pacman -S --noconfirm` por el comando equivalente de tu tabla — el resto del script no necesita ningún cambio.

---

## Requisitos previos

- Cualquier distro de Linux con `bash` como shell
- Usuario con permisos de `sudo`
- Un emulador de terminal (Konsole, GNOME Terminal, Alacritty, etc.)

---

## Uso

```bash
git clone <url-de-tu-repo>
cd <carpeta-del-repo>
chmod +x setup-terminal-starship.sh
./setup-terminal-starship.sh
```

Al terminar, el script te recuerda el único paso que **no** se puede automatizar por terminal: elegir la fuente en tu emulador de terminal (ver más abajo).

---

## El script completo, comentado

```bash
#!/bin/bash
#
# setup-terminal-starship.sh
#
# Script para automatizar la personalización de terminal con Starship:
# - Instala Starship
# - Instala la Nerd Font MesloLG (si no está presente)
# - Aplica el preset "pastel-powerline" de Starship
# - Activa Starship en bash
# - Activa asteriscos al escribir la contraseña de sudo (pwfeedback)
#
# NOTA SOBRE COMPATIBILIDAD:
# Este script usa "pacman", el gestor de paquetes de Arch Linux y sus
# derivadas (probado en CachyOS). Si usas otra distro, cambia únicamente
# las líneas que empiezan por "sudo pacman -S --noconfirm" por el
# equivalente de tu sistema:
#
#   Fedora:          sudo dnf install -y <paquete>
#   Ubuntu / Debian:  sudo apt install -y <paquete>
#   openSUSE:         sudo zypper install -y <paquete>
#
# Los nombres de los paquetes también pueden variar ligeramente
# según la distro (por ejemplo, la Nerd Font puede llamarse distinto
# en cada repositorio). El resto del script (Starship, bash, sudoers)
# funciona igual en cualquier distro basada en Linux.
#
# Uso:
#   chmod +x setup-terminal-starship.sh
#   ./setup-terminal-starship.sh

set -e  # Si algún comando falla, el script se detiene en vez de seguir con errores

echo "=== 1. Instalando Starship ==="
if command -v starship &> /dev/null; then
    echo "Starship ya está instalado, se omite este paso."
else
    # Alternativa universal, funciona en cualquier distro sin depender
    # del gestor de paquetes (instala el binario oficial de Starship):
    #   curl -sS https://starship.rs/install.sh | sh
    sudo pacman -S --noconfirm starship
fi

echo ""
echo "=== 2. Comprobando la Nerd Font MesloLG ==="
if fc-list | grep -qi "meslo.*nerd font mono"; then
    echo "La fuente MesloLG Nerd Font Mono ya está instalada, se omite este paso."
else
    echo "No se encontró la fuente. Instalando ttf-meslo-nerd..."
    sudo pacman -S --noconfirm ttf-meslo-nerd
fi

echo ""
echo "=== 3. Aplicando el diseño de prompt (preset pastel-powerline) ==="
starship preset pastel-powerline -o ~/.config/starship.toml --force

echo ""
echo "=== 4. Activando Starship en bash ==="
if grep -q 'starship init bash' ~/.bashrc 2>/dev/null; then
    echo "Starship ya estaba activado en ~/.bashrc, se omite este paso."
else
    echo 'eval "$(starship init bash)"' >> ~/.bashrc
    echo "Línea añadida a ~/.bashrc"
fi

echo ""
echo "=== 5. Activando asteriscos en la contraseña de sudo (pwfeedback) ==="
SUDOERS_FILE="/etc/sudoers.d/pwfeedback"
if [ -f "$SUDOERS_FILE" ]; then
    echo "pwfeedback ya estaba configurado, se omite este paso."
else
    # Se crea un archivo aparte en sudoers.d en vez de editar /etc/sudoers directamente.
    # Es el método recomendado: cada ajuste queda en su propio archivo, más fácil de revertir.
    # Este paso funciona igual en cualquier distro que use sudo.
    echo "Defaults pwfeedback" | sudo tee "$SUDOERS_FILE" > /dev/null
    sudo chmod 440 "$SUDOERS_FILE"

    # Se valida la sintaxis antes de dar el cambio por bueno.
    if sudo visudo -c -f "$SUDOERS_FILE" > /dev/null 2>&1; then
        echo "pwfeedback configurado y validado correctamente."
    else
        echo "ERROR: la sintaxis del archivo de sudo no es válida. Revirtiendo cambio."
        sudo rm -f "$SUDOERS_FILE"
        exit 1
    fi
fi

echo ""
echo "=== Todo listo ==="
echo "Pasos manuales pendientes (requieren la interfaz gráfica de tu terminal):"
echo "  1. Abre las preferencias/perfil de tu emulador de terminal"
echo "     (Konsole, GNOME Terminal, Ptyxis, Alacritty, etc.)"
echo "  2. Crea o edita un perfil, márcalo como predeterminado"
echo "  3. Selecciona una fuente 'Nerd Font Mono' instalada, por ejemplo"
echo "     'MesloLGL Nerd Font Mono'"
echo ""
echo "Cierra y vuelve a abrir tu terminal para ver el nuevo prompt."
```

---

## Paso manual: configurar la fuente en tu emulador de terminal

Elegir la fuente es un ajuste de interfaz gráfica que varía según el programa que uses. Aquí el ejemplo con **Konsole** (KDE Plasma):

1. Abrir Konsole → menú (☰) → **Configurar Konsole...**
2. **Perfiles** → **+ Nuevo...**
3. Ponerle un nombre (por ejemplo `Starship`) y marcar **Perfil predeterminado**
4. Ir a **Aspecto** → **Escoger...** (junto al tipo de letra)
5. Buscar y seleccionar **MesloLGL Nerd Font Mono**, estilo Regular, tamaño 12
6. **Aceptar** en la ventana de fuente, y **Aceptar** en la ventana del perfil
7. Cerrar todas las ventanas y volver a abrir una nueva

Si usas otro emulador de terminal, el paso es equivalente: entra a las preferencias del perfil y busca la opción de tipo de letra, ahí selecciona una variante que diga "Nerd Font Mono".

---

## Verificación

Tras ejecutar el script y ajustar la fuente:

```bash
starship --version                 # confirma que el binario está instalado
cat ~/.config/starship.toml        # debe mostrar el preset pastel-powerline
grep starship ~/.bashrc            # debe mostrar la línea de inicialización
sudo -l | grep pwfeedback          # confirma que pwfeedback está activo (o revisa /etc/sudoers.d/pwfeedback)
```

Al abrir una nueva terminal deberías ver un prompt de dos líneas, con bloques de colores pastel conectados por flechas, mostrando usuario, carpeta actual, rama de git (si aplica), lenguaje de programación detectado (si aplica) y hora.

---

## Archivos que modifica el script

| Archivo | Cambio |
|---|---|
| `~/.config/starship.toml` | Creado/sobrescrito con el preset `pastel-powerline` |
| `~/.bashrc` | Se añade la línea `eval "$(starship init bash)"` |
| `/etc/sudoers.d/pwfeedback` | Archivo nuevo con `Defaults pwfeedback`, validado con `visudo -c` |

## Cómo revertir

- **Prompt de Starship**: eliminar o editar `~/.config/starship.toml`
- **Starship en bash**: quitar la línea correspondiente de `~/.bashrc`
- **Asteriscos en sudo**: `sudo rm /etc/sudoers.d/pwfeedback`
