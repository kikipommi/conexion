#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Por favor, ejecuta este script como root o usando sudo."
  exit 1
fi

mostrar_interfaces() {
    echo -e "\n--- Interfaces de Red Disponibles ---"
    ip -brief a show
    echo ""
}

cambiar_estado() {
    mostrar_interfaces
    read -p "Ingresa el nombre de la interfaz (ej. eth0, wlan0): " interfaz
    read -p "¿Deseas levantar (up) o bajar (down) la interfaz? [up/down]: " estado
    
    if [[ "$estado" == "up" || "$estado" == "down" ]]; then
        ip link set dev "$interfaz" "$estado"
        echo "El estado de la interfaz '$interfaz' ha cambiado a '$estado'."
    else
        echo "Estado no válido. Usa 'up' o 'down'."
    fi
}

configurar_ip() {
    local tipo_conexion="$1"
    local iface_o_ssid="$2"
    local password="$3"

    read -p "¿Deseas configuración dinamica o estatica?: " tipo_ip

    if [[ "$tipo_ip" == "estatica" ]]; then
        read -p "Ingresa la dirección IP con su prefijo (ej. 192.168.1.50/24): " ip_addr
        read -p "Ingresa la puerta de enlace (Gateway, ej. 192.168.1.254): " gateway
        read -p "Ingresa los servidores DNS (separados por comas, 8.8.8.8,1.1.1.1): " dns

        if [[ "$tipo_conexion" == "wifi" ]]; then
            nmcli device wifi connect "$iface_o_ssid" password "$password" ipv4.method manual ipv4.addresses "$ip_addr" ipv4.gateway "$gateway" ipv4.dns "$dns"
        else
            # configura ethernet para estático
            local con_name="${iface_o_ssid}-estatica"
            nmcli connection add type ethernet ifname "$iface_o_ssid" con-name "$con_name" ipv4.method manual ipv4.addresses "$ip_addr" ipv4.gateway "$gateway" ipv4.dns "$dns"
            nmcli connection up "$con_name"
        fi
        echo "Configuración estática aplicada y guardada permanentemente."
    else
        if [[ "$tipo_conexion" == "wifi" ]]; then
            nmcli device wifi connect "$iface_o_ssid" password "$password"
        else
            # configura para ethernet 
            local con_name="${iface_o_ssid}-dhcp"
            nmcli connection add type ethernet ifname "$iface_o_ssid" con-name "$con_name" ipv4.method auto
            nmcli connection up "$con_name"
        fi
        echo "Configuración por DHCP aplicada y guardada permanentemente."
    fi
}

conectar_red() {
    mostrar_interfaces
    read -p "Ingresa el nombre de la interfaz que usarás para conectar: " interfaz

    # determina si la interfaz es inalámbrica o cableada
    tipo_iface=$(nmcli -t -f TYPE dev show "$interfaz" 2>/dev/null | head -n1)

    if [[ "$tipo_iface" == "wifi" ]]; then
        echo -e "\n--- Escaneando Redes Inalámbricas... ---"
        ip link set dev "$interfaz" up
        nmcli device wifi rescan
        sleep 3
        nmcli device wifi list ifname "$interfaz"

        echo -e "\n"
        read -p "Ingresa el SSID (Nombre) de la red a la que te quieres conectar: " ssid
        read -sp "Ingresa la contraseña (deja en blanco si la red es abierta): " password
        echo ""

        configurar_ip "wifi" "$ssid" "$password"
    elif [[ "$tipo_iface" == "ethernet" ]]; then
        echo "Configurando conexión cableada para $interfaz..."
        ip link set dev "$interfaz" up
        configurar_ip "ethernet" "$interfaz" ""
    else
        echo "Interfaz no encontrada o tipo no soportado por el script."
    fi
}


while true; do
    echo "      GESTOR DE RED      "
    echo " "
    echo "1. Mostrar interfaces y su estado"
    echo "2. Cambiar estado de interfaz (Up/Down)"
    echo "3. Conectar a una red (Cableada/Inalámbrica)"
    echo "4. Salir"
    echo " "
    read -p "Selecciona una opción [1-4]: " opcion

    case $opcion in
        1) mostrar_interfaces ;;
        2) cambiar_estado ;;
        3) conectar_red ;;
        4) echo "Saliendo..."; exit 0 ;;
        *) echo "Opción no válida. Intenta de nuevo." ;;
    esac
done
