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
