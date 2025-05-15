#!/data/data/com.termux/files/usr/bin/bash
#Descargador de repositorio Github en .zip

# Colores
AZUL='\033[1;34m'
VERDE='\033[1;32m'
RESET='\033[0m'

echo -e "${AZUL}¿Quieres ingresar el usuario y repo o el link completo?${RESET}"
echo "1. Usuario y repositorio"
echo "2. Link completo"
read -rp "Elige (1 o 2): " opcion

if [[ "$opcion" == "1" ]]; then
  read -rp "Usuario de GitHub: " user
  read -rp "Nombre del repositorio: " repo
  zip_url="https://github.com/${user}/${repo}/archive/refs/heads/main.zip"
  nombre_archivo="${repo}_main.zip"
else
  read -rp "Link completo del ZIP: " zip_url
  nombre_archivo=$(basename "$zip_url")
fi

echo -e "${AZUL}[Descargando ZIP]${RESET} Desde: $zip_url"
echo -e "${AZUL}Espere...${RESET}"

curl -L --progress-bar -o "$nombre_archivo" \
  --write-out "\n${VERDE}Completado al 100%%${RESET}\n${VERDE}Descargado: %{size_download} bytes${RESET}\n${VERDE}Velocidad promedio: %{speed_download} bytes/s${RESET}\n" \
  "$zip_url"

echo -e "${VERDE}[Listo] Archivo guardado como:${RESET} $nombre_archivo"