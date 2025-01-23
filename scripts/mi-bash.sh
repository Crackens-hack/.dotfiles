#!/bin/bash

# Función para verificar si el usuario es root
check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        echo "No eres root. Intentando cambiar a root..."
        # Si estamos configurados para sudo sin contraseña, no debería preguntar
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
        
        if command -v apt &> /dev/null; then
            sudo apt update && sudo apt install bash -y
        elif command -v apk &> /dev/null; then
            sudo apk add bash
        else
            echo "No se encontró un gestor de paquetes adecuado. Saliendo..."
            exit 1
        fi
    else
        echo "Bash ya está instalado."
    fi
}

# Eliminar .bashrc de root
remove_root_bashrc() {
    if [ -f /root/.bashrc ]; then
        echo "Eliminando .bashrc de root..."
        sudo rm /root/.bashrc
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
}

# Crear enlaces simbólicos
create_symlinks() {
    echo "Creando enlaces simbólicos..."

    # Enlace simbólico para root
    sudo ln -sf "$bashrc_in_dotfiles" /root/.bashrc

    # Enlace simbólico para el usuario
    ln -sf "$bashrc_in_dotfiles" "/home/$usuario/.bashrc"

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


#### esta claro que estara perfecto creo