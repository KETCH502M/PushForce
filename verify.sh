#!/data/data/com.termux/files/usr/bin/bash

# Colores
VERDE='\033[0;32m'
ROJO='\033[0;31m'
AMARILLO='\033[1;33m'
AZUL='\033[0;34m'
RESET='\033[0m'

# Modo test
TEST_MODE=false
if [[ "$1" == "-test" ]]; then
    TEST_MODE=true
    echo -e "${AMARILLO}[TEST] Modo simulación activado.${RESET}"
fi

function print_or_execute() {
    if $TEST_MODE; then
        echo -e "${AMARILLO}[SIMULADO]$1${RESET}"
    else
        eval "$1"
    fi
}

# Verifica si Git está instalado
if ! command -v git >/dev/null 2>&1; then
    echo -e "${ROJO}[X] Git no está instalado.${RESET}"
    echo -e "${AMARILLO}[!] Instalando Git...${RESET}"
    print_or_execute "pkg install -y git"
else
    echo -e "${VERDE}[OK] Git ya está instalado.${RESET}"
fi

# Verifica si hay nombre de usuario global de Git
USERNAME=$(git config --global user.name)
if [[ -z "$USERNAME" ]]; then
    echo -e "${ROJO}[X] No hay nombre de usuario de Git configurado.${RESET}"
    if ! $TEST_MODE; then
        read -p "Ingresa tu nombre de usuario Git: " USERNAME
        git config --global user.name "$USERNAME"
    else
        echo -e "${AMARILLO}[SIMULADO] Se pediría el nombre de usuario.${RESET}"
    fi
else
    echo -e "${VERDE}[OK] Nombre de usuario Git configurado: ${RESET}$USERNAME"
fi

# Verifica si hay correo global de Git
EMAIL=$(git config --global user.email)
if [[ -z "$EMAIL" ]]; then
    echo -e "${ROJO}[X] No hay correo de Git configurado.${RESET}"
    if ! $TEST_MODE; then
        read -p "Ingresa tu correo Git: " EMAIL
        git config --global user.email "$EMAIL"
    else
        echo -e "${AMARILLO}[SIMULADO] Se pediría el correo.${RESET}"
    fi
else
    echo -e "${VERDE}[OK] Correo Git configurado: ${RESET}$EMAIL"
fi

# Verifica si hay credenciales de GitHub configuradas
GIT_CONFIG=$(git config --global credential.helper)
if [[ "$GIT_CONFIG" != "store" ]]; then
    echo -e "${ROJO}[X] No hay helper de credenciales configurado.${RESET}"
    if ! $TEST_MODE; then
        git config --global credential.helper store
        echo -e "${VERDE}[OK] Se configuró credential.helper=store${RESET}"
    else
        echo -e "${AMARILLO}[SIMULADO] Se configuraría credential.helper=store${RESET}"
    fi
else
    echo -e "${VERDE}[OK] credential.helper=store ya está configurado.${RESET}"
fi

CREDENTIALS_FILE="$HOME/.git-credentials"
if [[ ! -f "$CREDENTIALS_FILE" ]]; then
    echo -e "${ROJO}[X] No se encontró el archivo de credenciales.${RESET}"
    if ! $TEST_MODE; then
        echo -e "${AMARILLO}[!] Para autenticar, necesitas un token personal de GitHub.${RESET}"
        read -p "Ingresa tu usuario de GitHub: " GHUSER
        read -p "Ingresa tu token personal de GitHub: " GHTOKEN
        read -p "Ingresa el nombre del repositorio (usuario/repo): " REPO
        echo "https://$GHUSER:$GHTOKEN@github.com/$REPO" > "$CREDENTIALS_FILE"
        echo -e "${VERDE}[OK] Credenciales guardadas en .git-credentials${RESET}"
    else
        echo -e "${AMARILLO}[SIMULADO] Se pediría user, token y repo para .git-credentials${RESET}"
    fi
else
    echo -e "${VERDE}[OK] Archivo de credenciales encontrado.${RESET}"
fi

# Verifica el alias 'push'
ALIAS_LINE=$(grep -E "^alias push=" ~/.bashrc 2>/dev/null | tail -n 1)
if [[ -n "$ALIAS_LINE" ]]; then
    SCRIPT_PATH=$(echo "$ALIAS_LINE" | sed -E "s/alias push=['\"]bash (.*)['\"]/\1/")
    if [[ -f "$SCRIPT_PATH" ]]; then
        echo -e "${VERDE}[OK] pushforce.sh encontrado en: ${AZUL}$SCRIPT_PATH${RESET}"
    else
        echo -e "${ROJO}[X] El alias apunta a una ruta inválida o inexistente.${RESET}"
        echo -e "${AMARILLO}[!] Ruta encontrada en alias: ${RESET}${AMARILLO}$SCRIPT_PATH${RESET}"
    fi
else
    echo -e "${ROJO}[X] No se encontró un alias 'push'.${RESET}"
    echo -e "${AZUL}Sugerencia:${RESET} puedes crearlo manualmente con:"
    echo -e "${AMARILLO}echo \"alias push='bash ~/pushforce.sh'\" >> ~/.bashrc && source ~/.bashrc${RESET}"
fi

# Confirmación final
echo -e "\n${VERDE}[*] Verificación completada.${RESET}"