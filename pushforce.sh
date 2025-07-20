#!/data/data/com.termux/files/usr/bin/bash

# ================== CONFIGURACIÓN ==================
ORIG=~/storage/shared/Ketch502m.github.io
DEST=~/Ketch502m.github.io
VERSION="1.0"
AUTOR="[KETCH502M]"

# ================== COLORES ==================
AZUL='\033[1;34m'
VERDE='\033[1;32m'
AMARILLO='\033[1;33m'
ROJO='\033[1;31m'
RESET='\033[0m'

# ================== ATRAPAR CTRL+C ==================
trap ctrl_c INT
ctrl_c() {
    clear
    echo -e "\n${ROJO}[Push Force] Interrupción detectada. Liberando wakelock...${RESET}"
    termux-vibrate -d 50
    termux-wake-unlock
    exit 0
}

# ================== AYUDA ==================
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    clear
    echo -e "${AZUL}Push Force - Ayuda rápida${RESET}"
    echo -e "${VERDE}Versión:${RESET} $VERSION"
    echo -e "${VERDE}Autor:${RESET} $AUTOR"
    echo -e "\n${VERDE}Descripción:${RESET} Sincroniza cambios desde ${AMARILLO}~/storage/shared/Ketch502m.github.io${RESET} hacia tu clon local y los sube a GitHub."
    echo -e "\n${VERDE}Opciones:${RESET}"
    echo -e "  ${AMARILLO}-h, --help${RESET}        Muestra esta ayuda"
    echo -e "  ${AMARILLO}-v, --version${RESET}     Muestra la versión"
    echo -e "  ${AMARILLO}-alias${RESET}            Crea un alias llamado 'push' al script actual"
    echo -e "\n${VERDE}Alias sugerido:${RESET}"
    echo -e "  ${AMARILLO}alias push='bash ~/pushforce.sh'${RESET}"
    exit 0
fi

if [[ "$1" == "-v" || "$1" == "--version" ]]; then
    echo -e "${VERDE}Push Force v$VERSION${RESET} - Autor: ${AMARILLO}$AUTOR${RESET}"
    exit 0
fi

if [[ "$1" == "-alias" ]]; then
    ALIAS_CMD="alias push='bash $(realpath "$0")'"
    if ! grep -q "$ALIAS_CMD" ~/.bashrc; then
        echo "$ALIAS_CMD" >> ~/.bashrc
        echo -e "${VERDE}[Push Force] Alias 'push' creado exitosamente.${RESET}"
        echo -e "${AMARILLO}Recuerda ejecutar: ${AZUL}source ~/.bashrc${RESET} para activarlo."
    else
        echo -e "${VERDE}[Push Force] Ya existe un alias 'push'.${RESET}"
    fi
    exit 0
fi

# ================== BLOQUEO DE CPU ==================
termux-wake-lock
clear

# ================== LOOP PRINCIPAL ==================
while true; do
    rsync -a --delete --exclude='.git' "$ORIG"/ "$DEST"/ > /dev/null 2>&1
    cd "$DEST" || exit 1

    git reset -q
    git add -A

    if ! git diff --cached --quiet; then
        echo -e "${VERDE}[Push Force] Cambios detectados:${RESET}"
        termux-vibrate -d 50
        echo -e "${AMARILLO}--- Archivos modificados: ---${RESET}"

        git status --short | while read -r line; do
            estado=${line:0:2}
            archivo=${line:3}
            case "$estado" in
                M*|*M) echo -e "${AZUL}MODIFICADO:${RESET} $archivo" ;;
                A*) echo -e "${VERDE}AÑADIDO:${RESET} $archivo" ;;
                D*) echo -e "${ROJO}ELIMINADO:${RESET} $archivo" ;;
                ??) echo -e "${VERDE}NUEVO:${RESET} $archivo" ;;
                *) echo -e "${AMARILLO}OTRO CAMBIO:${RESET} $archivo" ;;
            esac
        done

        read -p "$(echo -e "${AMARILLO}[Push Force] Presiona Enter para continuar...${RESET}")" _
        read -p "$(echo -e "${AZUL}[Push Force] ¿Deseas hacer commit y push? (s/n, ${ROJO}q para salir${AZUL}): ${RESET}")" CONFIRMAR

        case "$CONFIRMAR" in
            s)
                USER_NAME=$(git config --global user.name)
                USER_EMAIL=$(git config --global user.email)

                if [[ -z "$USER_NAME" || -z "$USER_EMAIL" ]]; then
                    echo -e "${ROJO}[Push Force] Git no tiene configurado nombre y/o correo.${RESET}"
                    read -p "$(echo -e "${AZUL}Tu nombre para Git: ${RESET}")" NAME
                    read -p "$(echo -e "${AZUL}Tu correo para Git: ${RESET}")" EMAIL
                    git config --global user.name "$NAME"
                    git config --global user.email "$EMAIL"
                fi

                if ! grep -q "github.com" ~/.git-credentials 2>/dev/null; then
                    read -p "$(echo -e "${AZUL}Usuario GitHub: ${RESET}")" GUSER
                    read -p "$(echo -e "${AZUL}Token GitHub: ${RESET}")" -s GTOKEN
                    echo
                    git config --global credential.helper store
                    echo "https://$GUSER:$GTOKEN@github.com" > ~/.git-credentials
                fi

                read -p "$(echo -e "${AZUL}Mensaje del commit (Enter para automático): ${RESET}")" MENSAJE
                HORA=$(date +"%I:%M:%S %p")
                [[ -z "$MENSAJE" ]] && MENSAJE="Update | $HORA UP" || MENSAJE="$MENSAJE | $HORA"

                git commit -m "$MENSAJE" || continue
                git pull --rebase origin main || continue
                git push origin main || {
                    echo -e "${ROJO}[Push Force] Falló el push incluso con token guardado.${RESET}"
                    continue
                }

                termux-vibrate -d 80
                termux-notification --title "[Push Force]" --content "Cambios subidos correctamente." --priority max --id 503 --sound
                echo -e "${VERDE}[Push Force] Cambios subidos correctamente.${RESET}"
                ;;
            q)
                echo -e "${ROJO}[Push Force] Saliendo...${RESET}"
                termux-wake-unlock
                termux-vibrate -d 100
                exit 0
                ;;
            *)
                clear
                echo -e "${AMARILLO}[Push Force] ${ROJO}Push cancelado. ${AMARILLO}Esperando nuevos cambios...${RESET}"
                ;;
        esac
    else
        # ANIMACIÓN DE ESPERA
        SPIN='|/-\'
        i=0
        cls_t=true
        while true; do
            i=$(( (i+1) %4 ))
            [[ "$cls_t" = true ]] && clear && cls_t=false
            rsync -a --delete --exclude='.git' "$ORIG"/ "$DEST"/ > /dev/null 2>&1
            git add -A
            printf "\r${AZUL}[Push Force] Esperando cambios... ${SPIN:$i:1}   ${RESET}"
            sleep 0.4
            if ! git diff --cached --quiet; then break; fi
        done
    fi
    sleep 1
done