# Manual: Personalización de terminal con Starship

Automatiza la configuración de una terminal con un prompt moderno usando **Starship**: colores, iconos, información de git, versión de lenguajes de programación, y un ajuste extra para ver asteriscos al escribir la contraseña de `sudo`.

## Contenido de este repositorio

| Archivo | Descripción |
|---|---|
| `setup-terminal-starship-arch.sh` | Script para Arch Linux y derivadas (CachyOS, Manjaro, EndeavourOS...) |
| `setup-terminal-starship-fedora.sh` | Script para Fedora y derivadas (Nobara...) |
| `setup-terminal-starship-debian.sh` | Script para Debian, Ubuntu y derivadas |
| `MANUAL-terminal-starship.md` | Tutorial paso a paso, explicado desde cero |
| Este README | Explicación general y guía para elegir el script correcto |

---

## ¿Qué distro tengo? ¿Qué script uso?

| Si tu distro es... | Usa este script |
|---|---|
| CachyOS, Arch Linux, Manjaro, EndeavourOS | `setup-terminal-starship-arch.sh` |
| Fedora, Nobara | `setup-terminal-starship-fedora.sh` |
| Debian, Ubuntu, Linux Mint, Pop!_OS | `setup-terminal-starship-debian.sh` |

Si tu distro no está en la lista pero se basa en una de estas (por ejemplo, cualquier distro basada en Arch, en Fedora o en Debian), el script correspondiente debería funcionarte igual.

---

## ¿Qué hace cada script?

1. Instala **Starship** (motor del prompt).
2. Comprueba si la Nerd Font **MesloLG** está instalada y, si no, la instala.
3. Aplica el diseño de prompt oficial **pastel-powerline** de Starship.
4. Activa Starship en `bash` (añade la línea de inicialización a `~/.bashrc`).
5. Activa el **feedback visual (asteriscos) al escribir la contraseña de `sudo`**, de forma segura, sin tocar `/etc/sudoers` directamente.

Los tres scripts son **idempotentes**: se pueden ejecutar varias veces sin romper nada — si un paso ya está hecho, lo detectan y lo saltan.

### Por qué cada script instala Starship de forma distinta

| Distro | Cómo instala Starship | Por qué |
|---|---|---|
| Arch/CachyOS | `pacman -S starship` | Está disponible en los repos oficiales |
| Fedora | Instalador universal (`curl \| sh`) | No siempre está en los repos oficiales |
| Debian/Ubuntu | Instalador universal (`curl \| sh`) | No está en los repos oficiales |

El instalador universal (`curl -sS https://starship.rs/install.sh | sh`) es el método oficial que ofrece el propio proyecto Starship, y descarga el binario directamente sin depender de ningún gestor de paquetes — por eso funciona igual en cualquier distro.

Para la fuente, cada script usa el método más fiable en su distro: en Arch, el paquete oficial `ttf-meslo-nerd`; en Fedora, intenta el paquete del repositorio y si no existe descarga la fuente manualmente; en Debian/Ubuntu, va directo a la descarga manual desde el proyecto [nerd-fonts](https://github.com/ryanoasis/nerd-fonts), ya que no suele estar empaquetada en sus repos.

---

## Estado de validación

| Script | Estado |
|---|---|
| `setup-terminal-starship-arch.sh` | ✅ Validado en equipo real y en VM limpia de CachyOS |
| `setup-terminal-starship-fedora.sh` | ⏳ Pendiente de validar en VM |
| `setup-terminal-starship-debian.sh` | ⏳ Pendiente de validar en VM |

---

## Requisitos previos

- Una de las distros mencionadas arriba, con `bash` como shell
- Usuario con permisos de `sudo`
- Un emulador de terminal (Konsole, GNOME Terminal, Ptyxis, Alacritty, etc.)

---

## Uso

```bash
git clone <url-de-tu-repo>
cd <carpeta-del-repo>
chmod +x setup-terminal-starship-<tu-distro>.sh
./setup-terminal-starship-<tu-distro>.sh
```

(sustituye `<tu-distro>` por `arch`, `fedora` o `debian` según corresponda)

Al terminar, el script te recuerda el único paso que **no** se puede automatizar por terminal: elegir la fuente en tu emulador de terminal (ver más abajo).

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

Si usas otro emulador de terminal (GNOME Terminal, Ptyxis, Alacritty...), el paso es equivalente: entra a las preferencias del perfil y busca la opción de tipo de letra, ahí selecciona una variante que diga "Nerd Font Mono".

---

## Verificación

Tras ejecutar el script y ajustar la fuente:

```bash
starship --version                 # confirma que el binario está instalado
cat ~/.config/starship.toml        # debe mostrar el preset pastel-powerline
grep starship ~/.bashrc            # debe mostrar la línea de inicialización
sudo -k && sudo ls                 # fuerza a pedir contraseña; deben verse asteriscos
cat /etc/sudoers.d/pwfeedback      # debe mostrar "Defaults pwfeedback"
```

Al abrir una nueva terminal deberías ver un prompt de dos líneas, con bloques de colores pastel conectados por flechas, mostrando usuario, carpeta actual, rama de git (si aplica), lenguaje de programación detectado (si aplica) y hora.

---

## Archivos que modifica cada script

| Archivo | Cambio |
|---|---|
| `~/.config/starship.toml` | Creado/sobrescrito con el preset `pastel-powerline` |
| `~/.bashrc` | Se añade la línea `eval "$(starship init bash)"` |
| `/etc/sudoers.d/pwfeedback` | Archivo nuevo con `Defaults pwfeedback`, validado con `visudo -c` |

## Cómo revertir

- **Prompt de Starship**: eliminar o editar `~/.config/starship.toml`
- **Starship en bash**: quitar la línea correspondiente de `~/.bashrc`
- **Asteriscos en sudo**: `sudo rm /etc/sudoers.d/pwfeedback`
