#!/data/data/com.termux/files/usr/bin/bash

# Bloqueo CPU evita cierre inesperado
termux-wake-lock

ORIG=~/storage/shared/Ketch502m.github.io
DEST=~/Ketch502m.github.io

# Colores
AZUL='\033[1;34m'
VERDE='\033[1;32m'
AMARILLO='\033[1;33m'
ROJO='\033[1;31m'
MAGENTA='\033[1;35m'
CYAN='\033[1;36m'
BLANCO='\033[1;37m'
RESET='\033[0m'

#Libera el termux-wake-lock al usar CTRL+C
trap ctrl_c INT
ctrl_c() {
    clear
    echo -e "\n${ROJO}[Push Force] Interrupción detectada. Liberando wakelock...${RESET}"
    termux-wake-unlock
    termux-vibrate -d 50
    exit 0
}

# Mostrar ayuda
VERSION="1.0"
AUTOR="[KETCH502M]"

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
clear
    echo -e "${AZUL}Push Force - Ayuda rápida${RESET}"
    echo -e "${VERDE}Versión:${RESET} $VERSION"
    echo -e "${VERDE}Autor:${RESET} $AUTOR"
    echo -e "\n${VERDE}Descripción:${RESET} Sincroniza cambios desde
    ${AMARILLO}~/storage/shared/repo.github.io${RESET} hacia tu clon local y los
    sube a GitHub."
    
    echo -e "\n${VERDE}Uso:${RESET} ${AMARILLO}pushforce.sh${RESET} ${AZUL}[opciones]${RESET}"
    echo -e "\n${VERDE}Opciones disponibles:${RESET}"
    echo -e "  ${AMARILLO}-h, --help${RESET}       Muestra esta ayuda y termina el script"
    echo -e "  ${AMARILLO}-v, --version${RESET}    Muestra la versión actual y autor"
    echo -e "  ${AMARILLO}-alias --a${RESET}            Crea un alias llamado ${AZUL}push${RESET} para ejecutarlo desde cualquier lugar"
    echo -e "                        (si el script está fuera de \$HOME, se muestra advertencia)"
    echo -e "  ${AMARILLO}-rm-alias${RESET}         Elimina el alias ${AZUL}push${RESET} si ya no lo necesitas"

    echo -e "\n${VERDE}Notas:${RESET}"
    echo -e "  - ${AMARILLO}Requiere configuración de Git global${RESET} (nombre y correo)."
    echo -e "  - El token de GitHub se puede guardar la primera vez que lo uses."
    echo -e "  - Usa ${AZUL}termux-wake-lock${RESET} para evitar suspensión."

    echo -e "\n${VERDE}Comportamiento automático:${RESET}"
    echo -e "  - Monitorea cambios locales constantemente."
    echo -e "  - Si detecta cambios, te pregunta antes de hacer push."
    echo -e "  - Puedes cancelar el push o salir del script con ${ROJO}q${RESET}."

    echo -e "\n${VERDE}Mejora la experiencia:${RESET}"
    echo -e "  - Puedes crear un alias en tu ${AMARILLO}~/.bashrc${RESET} o ${AMARILLO}~/.zshrc${RESET} así:"
    echo -e "  - Ingresa ${AMARILLO}nano ~/.bashrc${RESET}"
    echo -e "  - Pega este código ${AZUL}alias push='bash /ruta/del/script/pushforce.sh'${RESET}"
    echo -e "  - Guarda con la combinacion ${AMARILLO}CTRL + X${RESET}"
    echo -e "  - Pulsas la tecla ${AMARILLO}Y${RESET}"
    echo -e "  - Pulsa ${AMARILLO}ENTER${RESET}, y listo. Puedes usar
    ${AZUL}push -h${RESET}
    desde la terminal."

    echo -e "\n${VERDE}Ejemplos sin alias:${RESET}"
    echo -e "  ${AMARILLO}./pushforce.sh${RESET}        # Inicia el monitoreo automático"
    echo -e "  ${AMARILLO}./pushforce.sh -h${RESET}     # Muestra ayuda"
    echo -e "  ${AMARILLO}./pushforce.sh -v${RESET}     # Muestra la versión"
    echo -e "  ${AMARILLO}./pushforce.sh -alias${RESET}   # Crea el alias 'push'"
    echo -e "  ${AMARILLO}./pushforce.sh -rm-alias${RESET}   # Elimina el alias 'push'"
    
    echo -e "\n${VERDE}Ejemplos con alias:${RESET}"
    echo -e "  ${AMARILLO}push${RESET}        # Inicia el monitoreo automático"
    echo -e "  ${AMARILLO}push -h${RESET}     # Muestra ayuda"
    echo -e "  ${AMARILLO}push -v${RESET}     # Muestra la versión"
    echo -e "  ${AMARILLO}push -alias${RESET}   # Crea el alias 'push'"
    echo -e "  ${AMARILLO}push -rm-alias${RESET}   # Elimina el alias 'push'"

    echo -e "\n${VERDE}Colores utilizados:${RESET}"
    echo -e "  ${AZUL}MODIFICADO${RESET}, ${VERDE}AÑADIDO / NUEVO${RESET}, ${ROJO}ELIMINADO${RESET}, ${AMARILLO}OTRO CAMBIO / AVISOS${RESET}"
    
    exit 0
fi

if [[ "$1" == "-v" || "$1" == "--version" ]]; then
clear
    echo -e "${VERDE}Push Force${RESET} - versión ${AZUL}$VERSION${RESET} | Autor: ${AMARILLO}$AUTOR${RESET}"
    exit 0
fi

if [[ "$1" == "-alias" || "$1" == "--a" ]]; then
    clear
    SCRIPT_PATH="$(realpath "$0")"
    SHELL_RC="$HOME/.bashrc"
    [[ "$SHELL" == *zsh ]] && SHELL_RC="$HOME/.zshrc"

    # Comprobamos si ya existe el alias
    if grep -q "alias pushforce=" "$SHELL_RC"; then
        echo -e "${AMARILLO}[Push Force] Ya existe un alias llamado 'pushforce' en ${SHELL_RC}.${RESET}"
        exit 0
    fi

    # Crea el alias
    echo "alias pushforce='bash $SCRIPT_PATH'" >> "$SHELL_RC"
    echo -e "${VERDE}[Push Force] Alias creado correctamente en ${AMARILLO}${SHELL_RC}${RESET}"
    echo -e "${AZUL}Para usarlo ahora mismo, ejecuta:${RESET} source $SHELL_RC"

    # Verifica si está dentro de $HOME o fuera
    if [[ "$SCRIPT_PATH" == "$HOME/"* ]]; then
        echo -e "${VERDE}[Push Force] El script está dentro de tu HOME. Sin problemas.${RESET}"
    else
        echo -e "${ROJO}[ADVERTENCIA]${RESET} El script está fuera del HOME (en ${AMARILLO}$SCRIPT_PATH${RESET})"
        echo -e "${AMARILLO}Esto puede causar errores de permisos o accesos con Termux.${RESET}"
        echo -e "Se recomienda moverlo a ${VERDE}~/${RESET} con:"
        echo -e "  ${AZUL}mv \"$SCRIPT_PATH\" ~/${RESET}"
        echo -e "Y luego volver a correr: ${AZUL}bash ~/$(basename "$SCRIPT_PATH") -alias${RESET}"
    fi

    exit 0
fi

if [[ "$1" == "-rm-alias" || "$1" == "--rm-a" ]]; then
    clear
    SHELL_RC="$HOME/.bashrc"
    [[ "$SHELL" == *zsh ]] && SHELL_RC="$HOME/.zshrc"

    if grep -q "alias pushforce=" "$SHELL_RC"; then
        # Borra la línea del alias
        sed -i '/alias pushforce=/d' "$SHELL_RC"
        echo -e "${VERDE}[Push Force] Alias eliminado correctamente de ${AMARILLO}${SHELL_RC}${RESET}"
        echo -e "${AZUL}Para aplicar los cambios, ejecuta:${RESET} source $SHELL_RC"
    else
        echo -e "${ROJO}[Push Force] No se encontró ningún alias 'pushforce' en
        ~/.bashrc.${RESET}"
    fi

    exit 0
fi

clear

while true; do
    rsync -a --delete --exclude='.git' "$ORIG"/ "$DEST"/ > /dev/null 2>&1
    cd "$DEST" || exit 1

    git reset -q
    git add -A
if ! git diff --cached --quiet; then
    echo -e "\n${VERDE}[Push Force] Cambios detectados:${RESET}"
    termux-vibrate -d 50

    echo -e "${AMARILLO}--- Archivos modificados: ---${RESET}"
    git status --short | while read -r line; do
        estado=${line:0:2}
        archivo=${line:3}
        case "$estado" in
            M*|*M) echo -e "${AZUL}MODIFICADO:${RESET} $archivo" ;;
            A*) echo -e "${VERDE}AÑADIDO:${RESET} $archivo" ;;
            D*) echo -e "${ROJO}ELIMINADO:${RESET} $archivo" ;;
            ??) echo -e "${CYAN}NUEVO:${RESET} $archivo" ;;
            *) echo -e "${MAGENTA}OTRO CAMBIO:${RESET} $archivo" ;;
        esac
    done

    read -p "$(echo -e "${AMARILLO}[Push Force] Presiona Enter para continuar...${RESET}")" _
    read -p "$(echo -e "${MAGENTA}[Push Force] ¿Deseas hacer commit y push? (${VERDE}s${MAGENTA}/${ROJO}n${MAGENTA}, ${ROJO}q${MAGENTA} para salir): ${RESET}")" CONFIRMAR

    case "$CONFIRMAR" in
        s)
            USER_NAME=$(git config --global user.name)
            USER_EMAIL=$(git config --global user.email)

            if [[ -z "$USER_NAME" || -z "$USER_EMAIL" ]]; then
                echo -e "${ROJO}[Push Force] Git no tiene configurado nombre y/o correo global.${RESET}"
                read -p "$(echo -e "${AZUL}Ingresa tu nombre para Git: ${RESET}")" NAME
                read -p "$(echo -e "${AZUL}Ingresa tu correo para Git: ${RESET}")" EMAIL
                git config --global user.name "$NAME"
                git config --global user.email "$EMAIL"
                echo -e "${VERDE}[Push Force] Nombre y correo configurados globalmente.${RESET}"

                read -p "$(echo -e "${AZUL}Pega tu token personal de GitHub (PAT): ${RESET}")" -s GTOKEN
                echo
                read -p "$(echo -e "${AZUL}Ingresa tu usuario de GitHub: ${RESET}")" GUSER
                git config --global credential.helper store
                echo "https://$GUSER:$GTOKEN@github.com" > ~/.git-credentials
                echo -e "${VERDE}[Push Force] Token guardado globalmente.${RESET}"
            fi

            read -p "$(echo -e "${CYAN}[Push Force] Ingresa el mensaje del commit (Enter para automático): ${RESET}")" MENSAJE
            HORA=$(date +"%I:%M:%S %p")
            [[ -z "$MENSAJE" ]] && MENSAJE="Update | $HORA UP" || MENSAJE="$MENSAJE | $HORA"

            git commit -m "$MENSAJE" || continue
            git pull --rebase origin main || continue
            git push origin main || {
                echo -e "${ROJO}[Push Force] Falló el push incluso con token guardado.${RESET}"
                continue
            }

            termux-vibrate -d 50
            termux-notification --title "[Termux] > [Push Force]" \
                --content "Cambios subidos correctamente al repositorio." \
                --priority max --id 503 --sound
            echo -e "${VERDE}[Push Force] Cambios subidos correctamente.${RESET}"
            ;;
        q)
            echo -e "${ROJO}[Push Force] Saliendo...${RESET}"
            termux-wake-unlock
            termux-vibrate -d 50
            termux-vibrate -d 50
            exit 0
            ;;
        *)
            clear
            echo -e "${AMARILLO}[Push Force] ${ROJO}Push cancelado. ${AMARILLO}Esperando nuevos cambios...${RESET}"
            ;;
    esac
else
    # Animación de espera mientras se revisan cambios
    SPIN='|/-\'
    i=0
    cls_t=true
    while true; do
        i=$(( (i+1) %4 ))

        if $cls_t; then 
            clear
            cls_t=false
        fi

        rsync -a --delete --exclude='.git' "$ORIG"/ "$DEST"/ > /dev/null 2>&1
        git add -A

        printf "\r${BLANCO}[Push Force]${RESET} ${CYAN}Esperando cambios... ${SPIN:$i:1}   ${RESET}"
        sleep 0.5

        if ! git diff --cached --quiet; then
            break
        fi
    done
fi
done