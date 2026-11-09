#!/usr/bin/env bash
set -e

# ==============================================================================
# feature-start Toolkit - Script de Instalación y Enlace
# ==============================================================================

BOLD="\033[1m"
GREEN="\033[32m"
YELLOW="\033[33m"
CYAN="\033[36m"
RED="\033[31m"
RESET="\033[0m"

echo -e "${CYAN}${BOLD}"
echo "=========================================================="
echo "   🚀 Instalador de feature-start CLI Suite"
echo "=========================================================="
echo -e "${RESET}"

# 1. Comprobar Node.js
if ! command -v node >/dev/null 2>&1; then
  echo -e "${RED}❌ Error: Node.js no está instalado.${RESET}"
  echo "Por favor, instala Node.js (v18 o superior) antes de continuar."
  exit 1
fi

NODE_VERSION=$(node -v | tr -d 'v')
NODE_MAJOR=$(echo "$NODE_VERSION" | cut -d. -f1)
if [ "$NODE_MAJOR" -lt 18 ]; then
  echo -e "${YELLOW}⚠️ Advertencia: Se detectó Node.js v$NODE_VERSION. Se recomienda v18 o superior.${RESET}"
else
  echo -e "${GREEN}✔ Node.js detectado:${RESET} v$NODE_VERSION"
fi

# 2. Comprobar Git
if ! command -v git >/dev/null 2>&1; then
  echo -e "${RED}❌ Error: Git no está instalado.${RESET}"
  exit 1
else
  echo -e "${GREEN}✔ Git detectado:${RESET} $(git --version)"
fi

# 3. Directorio de instalación local
INSTALL_DIR="$HOME/.local/bin"
mkdir -p "$INSTALL_DIR"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_SOURCE="$SCRIPT_DIR/bin"

if [ ! -d "$BIN_SOURCE" ]; then
  echo -e "${RED}❌ Error: No se encontró la carpeta bin en $SCRIPT_DIR.${RESET}"
  exit 1
fi

echo -e "\n${BOLD}==> 🔗 Creando enlaces simbólicos en $INSTALL_DIR...${RESET}"

for script in "$BIN_SOURCE"/*; do
  if [ -f "$script" ]; then
    fname=$(basename "$script")
    chmod +x "$script"
    ln -sf "$script" "$INSTALL_DIR/$fname"
    echo -e "  ${GREEN}✔${RESET} $fname -> $INSTALL_DIR/$fname"
  fi
done

# 4. Asegurar estructura de configuración
CONFIG_DIR="$HOME/.config/aidlc"
mkdir -p "$CONFIG_DIR"
CONFIG_FILE="$CONFIG_DIR/config.env"

if [ ! -f "$CONFIG_FILE" ]; then
  if [ -f "$SCRIPT_DIR/templates/config.env.example" ]; then
    cp "$SCRIPT_DIR/templates/config.env.example" "$CONFIG_FILE"
    chmod 600 "$CONFIG_FILE"
    echo -e "\n${YELLOW}ℹ️  Se ha inicializado una plantilla de configuración en:${RESET} $CONFIG_FILE"
    echo "   (La primera vez que ejecutes 'feature-start' se iniciará un asistente interactivo para configurarla)."
  fi
else
  echo -e "\n${GREEN}✔ Archivo de configuración existente detectado en:${RESET} $CONFIG_FILE"
fi

# 5. Validar si ~/.local/bin está en el PATH
case ":$PATH:" in
  *":$INSTALL_DIR:"*)
    PATH_OK=true
    ;;
  *)
    PATH_OK=false
    ;;
esac

echo -e "\n${CYAN}==========================================================${RESET}"
echo -e "${GREEN}${BOLD}🎉 ¡Instalación completada con éxito!${RESET}"
echo -e "${CYAN}==========================================================${RESET}"

if [ "$PATH_OK" = false ]; then
  echo -e "\n${YELLOW}⚠️  ATENCIÓN:${RESET} $INSTALL_DIR no está en tu variable PATH actual."
  echo "Agrega la siguiente línea a tu archivo ~/.zshrc o ~/.bashrc:"
  echo -e "  ${BOLD}export PATH=\"\$HOME/.local/bin:\$PATH\"${RESET}"
  echo "Luego ejecuta: ${BOLD}source ~/.zshrc${RESET} (o reinicia tu terminal)."
fi

echo -e "\nPara comenzar a trabajar en un ticket:"
echo -e "  ${BOLD}feature-start <ID_TICKET_JIRA>${RESET}  (ej: feature-start PROJ-101)"
echo ""
