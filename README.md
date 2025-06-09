# Widget de Tareas Conky

Un widget elegante y funcional para mostrar y gestionar tus tareas pendientes directamente en el escritorio usando Conky.

![Preview del Widget](preview.png) *(añadir una captura de pantalla)*

## 🚀 Instalación Automática

### Opción 1: Script de instalación (Recomendado)

```bash
# Clona o descarga los archivos
git clone https://github.com/tu-usuario/conky-tareas-widget.git
cd conky-tareas-widget

# Ejecuta el instalador
chmod +x install.sh
./install.sh
```

### Opción 2: Instalación manual

1. **Instalar dependencias:**
   ```bash
   # Ubuntu/Debian
   sudo apt update
   sudo apt install conky-all coreutils fonts-dejavu
   
   # Fedora
   sudo dnf install conky coreutils dejavu-sans-mono-fonts
   
   # Arch/Manjaro
   sudo pacman -S conky coreutils ttf-dejavu
   ```

2. **Configurar directorios:**
   ```bash
   mkdir -p ~/.tareas
   ```

3. **Crear archivo de tareas inicial:**
   ```bash
   cat > ~/.tareas/tareas.txt << 'EOF'
   - [ ] Bienvenido al widget de tareas
   - [ ] Edita este archivo con: nvim ~/.tareas/tareas.txt
   - [ ] Marca las tareas completadas cambiando [ ] por [x]
   - [ ] Añade nuevas tareas con: echo "- [ ] nueva tarea" >> ~/.tareas/tareas.txt
   EOF
   ```

4. **Instalar configuración:**
   ```bash
   cp .conkyrc ~/.conkyrc
   ```

5. **Iniciar el widget:**
   ```bash
   conky -c ~/.conkyrc &
   ```

## 📋 Características

- **Visualización clara**: Lista numerada de tareas pendientes
- **Actualización automática**: Se actualiza cada 3 segundos
- **Transparencia**: Fondo semi-transparente que no interfiere con el escritorio
- **Filtrado inteligente**: Solo muestra líneas no vacías
- **Posicionamiento**: Esquina superior izquierda con márgenes configurables

## 🛠️ Uso

### Comandos básicos:

```bash
# Añadir nueva tarea
echo "- [ ] Nueva tarea" >> ~/.tareas/tareas.txt

# Editar tareas
nvim ~/.tareas/tareas.txt
# o usa tu editor preferido:
gedit ~/.tareas/tareas.txt
nano ~/.tareas/tareas.txt

# Marcar tarea como completada
# Cambia [ ] por [x] en el archivo

# Reiniciar el widget
killall conky
conky -c ~/.conkyrc &
```

### Scripts incluidos (si usaste el instalador):

```bash
# Iniciar/reiniciar widget
~/start_conky_tareas.sh

# El widget se inicia automáticamente al hacer login
```

## ⚙️ Configuración

### Personalizar posición y apariencia

Edita `~/.conkyrc` para modificar:

- **Posición**: Cambia `gap_x` y `gap_y`
- **Tamaño**: Modifica `minimum_width` y `maximum_width`
- **Transparencia**: Ajusta `own_window_argb_value` (0-255)
- **Fuente**: Cambia `font`
- **Colores**: Modifica los valores `${color}`

### Estructura del archivo de tareas

El formato esperado es:
```
- [ ] Tarea pendiente
- [x] Tarea completada
- [ ] Otra tarea pendiente
```

## 🔧 Dependencias

### Dependencias del sistema:
- `conky` - El motor del widget
- `sed` - Procesamiento de texto (incluido en coreutils)
- `nl` - Numeración de líneas (incluido en coreutils)

### Fuentes:
- `DejaVu Sans Mono` - Fuente principal (generalmente pre-instalada)

### Estructura de archivos:
- `~/.conkyrc` - Configuración principal
- `~/.tareas/` - Directorio de tareas
- `~/.tareas/tareas.txt` - Archivo de tareas

## 🐛 Solución de problemas

### El widget no aparece:
```bash
# Verificar que conky esté instalado
conky --version

# Verificar configuración
conky -c ~/.conkyrc -t

# Iniciar en modo debug
conky -c ~/.conkyrc -d
```

### Problemas de fuentes:
```bash
# Listar fuentes disponibles
fc-list | grep -i dejavu

# Si no está instalada, instalar:
sudo apt install fonts-dejavu  # Ubuntu/Debian
```

### El archivo de tareas no se encuentra:
```bash
# Verificar que existe
ls -la ~/.tareas/tareas.txt

# Crearlo si no existe
mkdir -p ~/.tareas
touch ~/.tareas/tareas.txt
```

## 📁 Estructura del proyecto

```
conky-tareas-widget/
├── .conkyrc              # Configuración principal de Conky
├── install.sh            # Script de instalación automática
├── README.md             # Este archivo
└── preview.png           # Captura de pantalla (opcional)
```

## 🔄 Inicio automático

El script de instalación configura el inicio automático. Si instalaste manualmente:

1. **Crear script de inicio:**
   ```bash
   cat > ~/start_conky_tareas.sh << 'EOF'
   #!/bin/bash
   killall conky 2>/dev/null
   sleep 2
   conky -c ~/.conkyrc &
   EOF
   chmod +x ~/start_conky_tareas.sh
   ```

2. **Configurar autostart:**
   ```bash
   mkdir -p ~/.config/autostart
   cat > ~/.config/autostart/conky-tareas.desktop << EOF
   [Desktop Entry]
   Type=Application
   Name=Conky Tareas Widget
   Exec=$HOME/start_conky_tareas.sh
   Hidden=false
   NoDisplay=false
   X-GNOME-Autostart-enabled=true
   EOF
   ```

## 🤝 Contribuir

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📝 Licencia

Distribuido bajo la licencia MIT. Ver `LICENSE` para más información.

## 🙏 Reconocimientos

- [Conky](https://github.com/brndnmtthws/conky) - El fantástico motor de widgets
- Comunidad de Linux por las herramientas de línea de comandos

---

**¿Problemas o sugerencias?** Abre un [issue](https://github.com/tu-usuario/conky-tareas-widget/issues) en GitHub.

