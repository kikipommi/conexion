# conexion
Un script interactivo en Bash diseñado para simplificar la gestión de interfaces de red en sistemas Linux. Permite visualizar, activar/desactivar interfaces y configurar conexiones cableadas (Ethernet) e inalámbricas (Wi-Fi) con soporte para IP dinámica (DHCP) y estática.

Caracteristicas:
Visualización rápida: Muestra el estado actual y las direcciones IP de todas las interfaces disponibles.

Control de estado: Permite levantar (up) o bajar (down) interfaces manualmente.

Gestor de Wi-Fi: Escaneo de redes inalámbricas en tiempo real y conexión con autenticación.

Configuración IP Dual: Soporte para configuración automática (DHCP) o manual (Estática).

Persistencia: Utiliza nmcli para asegurar que las configuraciones se guarden en el sistema.

Requisitos:
Sistemas Compatibles: Distribuciones Linux con NetworkManager instalado (Debian, Ubuntu, Fedora, Arch, etc.).

Dependencias:
  iproute2
  network-manager

Privilegios: El script requiere permisos de superusuario (root) para modificar la configuración de red.

Uso:
sudo ./ipconf.sh

Opciones:
1. Mostrar interfaces
Muestra una tabla resumida con el nombre de la interfaz, su estado (UP/DOWN) y su dirección IPv4 actual.

2. Cambiar estado
Permite activar o desactivar una tarjeta de red específica. Útil para reiniciar hardware o ahorrar energía.

3. Conectar a una red
  Ethernet: Detecta la conexión por cable y configura el  perfil de red.
  Wi-Fi: Escanea redes cercanas, solicita el SSID y la contraseña.
  Configuración Estática: Si eliges "estatica", el script te guiará para ingresar la IP, la Máscara (prefijo), el Gateway y los DNS.

Notas:
Uso de sudo: El script verifica el $EUID al inicio para asegurar que se ejecuta con los privilegios necesarios.

Nombres de interfaces: Asegúrate de escribir el nombre exacto de la interfaz (ej. wlan0, enp3s0) tal como aparece en la opción 1.
