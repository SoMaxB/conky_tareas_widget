#!/bin/bash

# Script de instalación automática para widget de tareas Conky
# Autor: [Tu nombre]
# Descripción: Instala y configura automáticamente el widget de tareas

echo "=== Instalador del Widget de Tareas Conky ==="
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
        print_error "No se pudo detectar la distribución"
        exit 1
    fi
}

# Instalar conky según la distribución
install_conky() {
    print_status "Instalando Conky..."
    
    case $DISTRO in
        ubuntu|debian)
            sudo apt update
            sudo apt install -y conky-all coreutils
            ;;
        fedora)
            sudo dnf install -y conky coreutils
            ;;
        arch|manjaro)
            sudo pacman -S --noconfirm conky coreutils
            ;;
        opensuse*)
            sudo zypper install -y conky coreutils
            ;;
        *)
            print_warning "Distribución no reconocida: $DISTRO"
            print_warning "Por favor instala 'conky' manualmente"
            read -p "¿Continuar asumiendo que conky está instalado? (y/N): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                exit 1
            fi
            ;;
    esac
}

# Verificar si conky está instalado
check_conky() {
    if command -v conky &> /dev/null; then
        print_success "Conky encontrado: $(conky --version | head -1)"
        return 0
    else
        return 1
    fi
}

# Crear estructura de directorios
setup_directories() {
    print_status "Creando estructura de directorios..."
    
    mkdir -p ~/.tareas
    
    if [ ! -f ~/.tareas/tareas.txt ]; then
        cat > ~/.tareas/tareas.txt << 'EOF'
- [ ] Bienvenido al widget de tareas
- [ ] Edita este archivo con: nvim ~/.tareas/tareas.txt
- [ ] Marca las tareas completadas cambiando [ ] por [x]
- [ ] Añade nuevas tareas con: echo "- [ ] nueva tarea" >> ~/.tareas/tareas.txt
EOF
        print_success "Archivo de tareas creado con ejemplos"
    else
        print_warning "El archivo ~/.tareas/tareas.txt ya existe, no se modificará"
    fi
}

# Instalar configuración de conky
install_config() {
    print_status "Instalando configuración de Conky..."
    
    # Backup si existe configuración previa
    if [ -f ~/.conkyrc ]; then
        cp ~/.conkyrc ~/.conkyrc.backup.$(date +%Y%m%d_%H%M%S)
        print_warning "Configuración anterior respaldada como ~/.conkyrc.backup.*"
    fi
    
    # Copiar nueva configuración
    cp .conkyrc ~/.conkyrc
    print_success "Configuración de Conky instalada"
}

# Verificar fuentes
check_fonts() {
    print_status "Verificando fuentes..."
    
    if fc-list | grep -i "dejavu sans mono" > /dev/null; then
        print_success "Fuente DejaVu Sans Mono encontrada"
    else
        print_warning "Fuente DejaVu Sans Mono no encontrada"
        print_status "Instalando fuentes..."
        
        case $DISTRO in
            ubuntu|debian)
                sudo apt install -y fonts-dejavu
                ;;
            fedora)
                sudo dnf install -y dejavu-sans-mono-fonts
                ;;
            arch|manjaro)
                sudo pacman -S --noconfirm ttf-dejavu
                ;;
            opensuse*)
                sudo zypper install -y dejavu-fonts
                ;;
            *)
                print_warning "Instala manualmente las fuentes DejaVu"
                ;;
        esac
    fi
}

# Crear script de inicio
create_startup_script() {
    print_status "Creando script de inicio..."
    
    cat > ~/start_conky_tareas.sh << 'EOF'
#!/bin/bash
# Script para iniciar el widget de tareas

# Matar instancias previas de conky
killall conky 2>/dev/null

# Esperar un momento
sleep 2

# Iniciar conky en segundo plano
conky -c ~/.conkyrc &

echo "Widget de tareas iniciado"
EOF
    
    chmod +x ~/start_conky_tareas.sh
    print_success "Script de inicio creado: ~/start_conky_tareas.sh"
}

# Crear .desktop file para autostart
create_autostart() {
    print_status "Configurando inicio automático..."
    
    mkdir -p ~/.config/autostart
    
    cat > ~/.config/autostart/conky-tareas.desktop << EOF
[Desktop Entry]
Type=Application
Name=Conky Tareas Widget
Comment=Widget de tareas pendientes
Exec=$HOME/start_conky_tareas.sh
Icon=conky
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
StartupNotify=false
Terminal=false
EOF
    
    print_success "Inicio automático configurado"
}

# Función principal
main() {
    echo "Este script instalará automáticamente el widget de tareas Conky"
    echo "Incluye: conky, dependencias, configuración y scripts de inicio"
    echo
    
    read -p "¿Continuar con la instalación? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Instalación cancelada"
        exit 0
    fi
    
    # Detectar distribución
    detect_distro
    print_success "Distribución detectada: $DISTRO"
    
    # Verificar/instalar conky
    if ! check_conky; then
        install_conky
        if ! check_conky; then
            print_error "Error instalando Conky"
            exit 1
        fi
    fi
    
    # Verificar fuentes
    check_fonts
    
    # Configurar directorios y archivos
    setup_directories
    
    # Instalar configuración
    install_config
    
    # Crear scripts
    create_startup_script
    create_autostart
    
    echo
    print_success "=== INSTALACIÓN COMPLETADA ==="
    echo
    echo "Comandos útiles:"
    echo "  Iniciar widget:        ~/start_conky_tareas.sh"
    echo "  Editar tareas:         nvim ~/.tareas/tareas.txt"
    echo "  Añadir tarea rápida:   echo '- [ ] nueva tarea' >> ~/.tareas/tareas.txt"
    echo "  Configurar conky:      nvim ~/.conkyrc"
    echo
    echo "El widget se iniciará automáticamente en el próximo login."
    
    read -p "¿Quieres iniciar el widget ahora? (Y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        echo "Puedes iniciarlo manualmente con: ~/start_conky_tareas.sh"
    else
        ~/start_conky_tareas.sh
        print_success "Widget iniciado!"
    fi
}

# Ejecutar función principal
main "$@"

