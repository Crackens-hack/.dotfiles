#!/bin/bash

# Función para verificar si el usuario es root
check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        echo "No eres root. Intentando cambiar a root..."
        # Intentar cambiar a root sin contraseña si está configurado en Dockerfile
        sudo -v
        if [ $? -ne 0 ]; then
            echo "No se pudo obtener privilegios de root. Saliendo..."
            exit 1
        fi
    fi
}

# Función para verificar si bash está instalado, si no, instalarlo
check_bash() {
    if ! command -v bash &> /dev/null; then
        echo "Bash no está instalado. Intentando instalarlo..."

        # Verificar apt primero
        if command -v apt &> /dev/null; then
            sudo apt update && sudo apt install bash -y
            if [ $? -ne 0 ]; then
                echo "Error al instalar bash con apt. Intentando con apk..."
                install_bash_apk
            fi
        # Si apt no está disponible, intenta con apk
        elif command -v apk &> /dev/null; then
            sudo apk add bash
            if [ $? -ne 0 ]; then
                echo "Error al instalar bash con apk. Saliendo..."
                exit 1
            fi
        else
            echo "No se encontró un gestor de paquetes adecuado (ni apt ni apk). Saliendo..."
            exit 1
        fi
    else
        echo "Bash ya está instalado."
    fi
}

# Intentar instalar bash usando apk si apt falla
install_bash_apk() {
    if command -v apk &> /dev/null; then
        sudo apk add bash
        if [ $? -ne 0 ]; then
            echo "Error al instalar bash con apk. Saliendo..."
            exit 1
        fi
    else
        echo "No se pudo encontrar apk para instalar bash. Saliendo..."
        exit 1
    fi
}

# Eliminar .bashrc de root
remove_root_bashrc() {
    if [ -f /root/.bashrc ]; then
        echo "Eliminando .bashrc de root..."
        sudo rm /root/.bashrc
        if [ $? -ne 0 ]; then
            echo "Error al eliminar .bashrc de root. Saliendo..."
            exit 1
        fi
    fi
}

# Eliminar .bashrc del usuario
remove_user_bashrc() {
    echo "Por favor, ingresa el nombre del usuario (ej. usuario):"
    read usuario

    user_bashrc="/home/$usuario/.bashrc"
    if [ -f "$user_bashrc" ]; then
        echo "Eliminando .bashrc del usuario $usuario..."
        rm "$user_bashrc"
        if [ $? -ne 0 ]; then
            echo "Error al eliminar .bashrc del usuario. Saliendo..."
            exit 1
        fi
    else
        echo "No se encontró .bashrc en /home/$usuario. Creando uno nuevo."
    fi
}

# Otorgar permisos al archivo .bashrc dentro del repositorio .dotfiles
set_permissions_bashrc() {
    echo "Otorgando permisos al .bashrc en el repositorio .dotfiles..."
    dotfiles_dir="/home/$usuario/.dotfiles"
    bashrc_in_dotfiles="$dotfiles_dir/.bashrc"
    
    if [ ! -f "$bashrc_in_dotfiles" ]; then
        echo "No se encontró .bashrc en el directorio .dotfiles. Saliendo..."
        exit 1
    fi

    sudo chmod 644 "$bashrc_in_dotfiles"
    if [ $? -ne 0 ]; then
        echo "Error al otorgar permisos al archivo .bashrc. Saliendo..."
        exit 1
    fi
}

# Crear enlaces simbólicos
create_symlinks() {
    echo "Creando enlaces simbólicos..."

    # Enlace simbólico para root
    sudo ln -sf "$bashrc_in_dotfiles" /root/.bashrc
    if [ $? -ne 0 ]; then
        echo "Error al crear el enlace simbólico para root. Saliendo..."
        exit 1
    fi

    # Enlace simbólico para el usuario
    ln -sf "$bashrc_in_dotfiles" "/home/$usuario/.bashrc"
    if [ $? -ne 0 ]; then
        echo "Error al crear el enlace simbólico para el usuario. Saliendo..."
        exit 1
    fi

    echo "Enlaces simbólicos creados correctamente."
}

# Secuencia de pasos del script
check_root
check_bash
remove_root_bashrc
remove_user_bashrc
set_permissions_bashrc
create_symlinks

echo "Proceso completado con éxito."
