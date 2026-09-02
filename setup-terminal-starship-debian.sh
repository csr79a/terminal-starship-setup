#!/bin/bash
#
# setup-terminal-starship-debian.sh
#
# Script para automatizar la personalización de terminal con Starship
# en Debian / Ubuntu y derivadas:
# - Instala Starship (usando el instalador oficial universal)
# - Instala una Nerd Font (si no está presente)
# - Aplica el preset "pastel-powerline" de Starship
# - Activa Starship en bash
# - Activa asteriscos al escribir la contraseña de sudo (pwfeedback)
#
# Uso:
#   chmod +x setup-terminal-starship-debian.sh
#   ./setup-terminal-starship-debian.sh

set -e  # Si algún comando falla, el script se detiene en vez de seguir con errores

echo "=== 1. Instalando Starship ==="
if command -v starship &> /dev/null; then
    echo "Starship ya está instalado, se omite este paso."
else
    # Starship no está en los repos oficiales de Debian/Ubuntu,
    # así que usamos el instalador universal del propio proyecto.
    curl -sS https://starship.rs/install.sh | sh -s -- --yes
fi

echo ""
echo "=== 2. Comprobando la Nerd Font MesloLG ==="
if fc-list | grep -qi "meslo.*nerd font mono"; then
    echo "La fuente MesloLG Nerd Font Mono ya está instalada, se omite este paso."
else
    echo "No se encontró la fuente. Instalando manualmente desde nerd-fonts..."
    # Debian/Ubuntu no suelen tener las Nerd Fonts en sus repos oficiales,
    # así que se descarga directamente del proyecto nerd-fonts.
    sudo apt update
    sudo apt install -y curl unzip fontconfig
    mkdir -p ~/.local/share/fonts
    TMP_DIR=$(mktemp -d)
    curl -sSLo "$TMP_DIR/Meslo.zip" \
        "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Meslo.zip"
    unzip -oq "$TMP_DIR/Meslo.zip" -d ~/.local/share/fonts
    rm -rf "$TMP_DIR"
    fc-cache -f ~/.local/share/fonts
    echo "Fuente instalada en ~/.local/share/fonts"
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
    echo "Defaults pwfeedback" | sudo tee "$SUDOERS_FILE" > /dev/null
    sudo chmod 440 "$SUDOERS_FILE"

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
echo "     (GNOME Terminal, Konsole, Ptyxis, etc.)"
echo "  2. Crea o edita un perfil, márcalo como predeterminado"
echo "  3. Selecciona una fuente 'Nerd Font Mono' instalada, por ejemplo"
echo "     'MesloLGL Nerd Font Mono'"
echo ""
echo "Cierra y vuelve a abrir tu terminal para ver el nuevo prompt."
