## Pushforce

Verificador para PushForce  
======================================

Este script te ayuda a verificar si tu Termux tiene todo listo para usar `pushforce.sh`.  
Detecta si tienes instalado Git, configurado tu nombre, correo, credenciales de GitHub y si el alias `push` está funcionando bien.

### Opciones

    -test   # Simula todo el proceso sin ejecutar nada (modo demostración)

---

## Cómo usarlo sin descargarlo (desde GitHub)

### Método 1: Usando `curl`

    bash <(curl -s https://raw.githubusercontent.com/ketch502m/pushforce/main/verify.sh)

### Método 2: Usando `wget`

    bash <(wget -qO- https://raw.githubusercontent.com/ketch502m/pushforce/main/verify.sh)

### Modo de prueba

Agrega `-test` para simular lo que haría:

    bash <(curl -s https://raw.githubusercontent.com/ketch502m/pushforce/main/verify.sh) -test

o

    bash <(wget -qO- https://raw.githubusercontent.com/ketch502m/pushforce/main/verify.sh) -test

---

## Alias para facilitar la vida

Si lo usas seguido, crea un alias en tu `.bashrc` o `.zshrc`:

    alias verifypush='bash <(curl -s https://raw.githubusercontent.com/ketch502m/pushforce/main/verify.sh)'

Después solo ejecuta:

    verifypush -test

---

## Requisitos

- Termux con bash  
- Tener conexión a internet  
- Tener al menos uno: `curl` o `wget` (Termux ya viene con `curl`)  

---

## ¿Para qué sirve?

Este script se encarga de:

1. Verificar si Git está instalado (y lo instala si no lo está).
2. Revisar si tienes configurado nombre y correo de Git.
3. Pedirte tu token personal de GitHub y guardarlo.
4. Verificar si el alias `push` existe y apunta a un `pushforce.sh` funcional.

---

## ¿Y después de verificar qué sigue?

Una vez finalizada la verificación con éxito, ya podrás usar `pushforce.sh`.  
Si aún no lo tienes, aquí te muestro cómo descargarlo:

### Opción 1: Usar `curl` para obtenerlo directamente

    curl -o ~/pushforce.sh https://raw.githubusercontent.com/ketch502m/pushforce/main/pushforce.sh
    chmod +x ~/pushforce.sh

### Opción 2: Usar `wget`

    wget -O ~/pushforce.sh https://raw.githubusercontent.com/ketch502m/pushforce/main/pushforce.sh
    chmod +x ~/pushforce.sh

### Opción 3: Clonar el repositorio completo

    git clone https://github.com/ketch502m/pushforce.git
    cd pushforce
    chmod +x pushforce.sh verify.sh

Después puedes mover `pushforce.sh` a tu home si quieres:

    mv pushforce.sh ~/pushforce.sh

Y por último, crea el alias:

    echo "alias push='bash ~/pushforce.sh'" >> ~/.bashrc && source ~/.bashrc
