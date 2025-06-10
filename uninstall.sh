#!/bin/bash

# Script de desinstalación para widget de tareas Conky
# Autor: SoMaxB
# Descripción: Desinstala y limpia completamente el widget de tareas

echo "=== Desinstalador del Widget de Tareas Conky ==="
echo

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para imprimir mensajes
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Detectar distribución
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
    else
        print_warning "No se pudo detectar la distribución"
        DISTRO="unknown"
    fi
}

# Detener procesos de conky
stop_conky() {
    print_status "Deteniendo procesos de Conky..."
    
    if pgrep conky > /dev/null; then
        killall conky 2>/dev/null
        sleep 2
        
        # Verificar si aún hay procesos corriendo
        if pgrep conky > /dev/null; then
            print_warning "Algunos procesos de Conky siguen activos"
            killall -9 conky 2>/dev/null
        fi
        
        print_success "Procesos de Conky detenidos"
    else
        print_status "No hay procesos de Conky ejecutándose"
    fi
}

# Remover autostart
remove_autostart() {
    print_status "Removiendo inicio automático..."
    
    if [ -f ~/.config/autostart/conky-tareas.desktop ]; then
        rm -f ~/.config/autostart/conky-tareas.desktop
        print_success "Autostart removido"
    else
        print_status "No se encontró configuración de autostart"
    fi
}

# Remover scripts de inicio
remove_startup_script() {
    print_status "Removiendo script de inicio..."
    
    if [ -f ~/start_conky_tareas.sh ]; then
        rm -f ~/start_conky_tareas.sh
        print_success "Script de inicio removido"
    else
        print_status "No se encontró script de inicio"
    fi
}

# Restaurar configuración de conky
restore_conky_config() {
    print_status "Gestionando configuración de Conky..."
    
    # Buscar backups
    backup_files=$(ls ~/.conkyrc.backup.* 2>/dev/null)
    
    if [ -n "$backup_files" ]; then
        print_status "Se encontraron backups de configuración anterior"
        
        # Obtener el backup más reciente
        latest_backup=$(ls -t ~/.conkyrc.backup.* 2>/dev/null | head -1)
        
        if [ -n "$latest_backup" ]; then
            print_status "Restaurando configuración desde: $(basename "$latest_backup")"
            cp "$latest_backup" ~/.conkyrc
            print_success "Configuración anterior restaurada"
            
            # Preguntar si quiere limpiar los backups
            read -p "¿Quieres eliminar los archivos de backup? (y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                rm -f ~/.conkyrc.backup.*
                print_success "Archivos de backup eliminados"
            fi
        fi
    else
        # No hay backup, preguntar si eliminar .conkyrc
        if [ -f ~/.conkyrc ]; then
            print_warning "No se encontró backup de configuración anterior"
            read -p "¿Quieres eliminar el archivo .conkyrc actual? (y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                rm -f ~/.conkyrc
                print_success "Archivo .conkyrc eliminado"
            else
                print_warning "Se mantiene el archivo .conkyrc actual"
            fi
        else
            print_status "No se encontró archivo .conkyrc"
        fi
    fi
}

# Remover directorio de tareas
remove_tasks_directory() {
    print_status "Gestionando directorio de tareas..."
    
    if [ -d ~/.tareas ]; then
        echo "Se encontró el directorio ~/.tareas/"
        if [ -f ~/.tareas/tareas.txt ]; then
            echo "Contiene archivo de tareas con $(wc -l < ~/.tareas/tareas.txt) líneas"
        fi
        
        read -p "¿Quieres eliminar completamente el directorio ~/.tareas/? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf ~/.tareas/
            print_success "Directorio de tareas eliminado"
        else
            print_warning "Se mantiene el directorio de tareas"
        fi
    else
        print_status "No se encontró directorio de tareas"
    fi
}

# Desinstalar conky del sistema
uninstall_conky() {
    print_status "Gestión de Conky del sistema..."
    
    if command -v conky &> /dev/null; then
        echo "Conky está instalado en el sistema: $(conky --version | head -1)"
        
        read -p "¿Quieres desinstalar Conky del sistema? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_status "Desinstalando Conky..."
            
            case $DISTRO in
                ubuntu|debian)
                    sudo apt remove -y conky-all
                    sudo apt autoremove -y
                    ;;
                fedora)
                    sudo dnf remove -y conky
                    ;;
                arch|manjaro)
                    sudo pacman -R --noconfirm conky
                    ;;
                opensuse*)
                    sudo zypper remove -y conky
                    ;;
                *)
                    print_warning "Distribución no reconocida: $DISTRO"
                    print_warning "Desinstala Conky manualmente con tu gestor de paquetes"
                    ;;
            esac
            
            print_success "Conky desinstalado del sistema"
        else
            print_warning "Se mantiene Conky en el sistema"
        fi
    else
        print_status "Conky no está instalado en el sistema"
    fi
}

# Mostrar resumen de limpieza
show_cleanup_summary() {
    echo
    print_success "=== RESUMEN DE DESINSTALACIÓN ==="
    echo
    
    echo "Archivos y configuraciones verificados:"
    echo "  ✓ Procesos de Conky detenidos"
    echo "  ✓ Autostart removido"
    echo "  ✓ Script de inicio removido"
    echo "  ✓ Configuración de Conky gestionada"
    
    if [ -d ~/.tareas ]; then
        echo "  ! Directorio ~/.tareas/ conservado"
    else
        echo "  ✓ Directorio de tareas removido"
    fi
    
    if command -v conky &> /dev/null; then
        echo "  ! Conky conservado en el sistema"
    else
        echo "  ✓ Conky removido del sistema"
    fi
    
    echo
    echo "La desinstalación se ha completado."
    
    if [ -d ~/.tareas ] || command -v conky &> /dev/null; then
        echo
        print_warning "Algunos componentes se conservaron por elección del usuario"
        echo "Puedes eliminarlos manualmente más tarde si lo deseas."
    fi
}

# Función principal
main() {
    echo "Este script desinstalará completamente el widget de tareas Conky"
    echo "Incluye: procesos, configuraciones, scripts y opcionalmente Conky del sistema"
    echo
    
    read -p "¿Continuar con la desinstalación? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Desinstalación cancelada"
        exit 0
    fi
    
    # Detectar distribución
    detect_distro
    if [ "$DISTRO" != "unknown" ]; then
        print_success "Distribución detectada: $DISTRO"
    fi
    
    # Ejecutar proceso de desinstalación
    stop_conky
    remove_autostart
    remove_startup_script
    restore_conky_config
    remove_tasks_directory
    
    # Preguntar sobre desinstalar conky del sistema
    uninstall_conky
    
    # Mostrar resumen
    show_cleanup_summary
}

# Ejecutar función principal
main "$@"

