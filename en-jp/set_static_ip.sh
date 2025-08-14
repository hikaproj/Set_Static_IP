#!/bin/bash

BACKUP_DIR="/etc/netplan/backup"

restore_mode() {
    if [ ! -d "$BACKUP_DIR" ] || [ -z "$(ls -A "$BACKUP_DIR" 2>/dev/null)" ]; then
        whiptail --msgbox "No backup files found in $BACKUP_DIR" 8 50 --title "Restore"
        exit 1
    fi

    MENU_ITEMS=()
    for FILE in "$BACKUP_DIR"/*.bak; do
        BASENAME=$(basename "$FILE")
        MENU_ITEMS+=("$BASENAME" "Backup file")
    done

    SELECTED=$(whiptail --menu "Select a backup to restore:" 20 70 10 "${MENU_ITEMS[@]}" 3>&1 1>&2 2>&3) || exit 1

    if [ -n "$SELECTED" ]; then
        sudo cp "$BACKUP_DIR/$SELECTED" "/etc/netplan/${SELECTED%%.*}"
        sudo netplan apply
        whiptail --msgbox "Restored $SELECTED and applied network settings." 8 60 --title "Restore Complete"
    fi
    exit 0
}

# Restore mode check
if [ "$1" == "--restore" ]; then
    restore_mode
fi

# 1. Update & Upgrade
sudo apt update -y
sudo apt upgrade -y

# 2. Install required software
sudo apt install -y whiptail net-tools iproute2

# Info Varsion
whiptail --ok-button "OK" --msgbox "Set Static IP\n[langage] English\n[Area] Japan\n[Varsion] Main 1.0.0" 10 25

# Create backup directory
sudo mkdir -p "$BACKUP_DIR"

# Backup existing netplan configs
BACKUP_TIME=$(date +"%Y%m%d_%H%M%S")
for FILE in /etc/netplan/*.yaml; do
    if [ -f "$FILE" ]; then
        sudo cp "$FILE" "$BACKUP_DIR/$(basename "$FILE").$BACKUP_TIME.bak"
    fi
done

# 3. Set system locale
DEFAULT_LOCALE="ja_JP.UTF-8"
LOCALE=$(whiptail --inputbox "Enter system locale:" 8 50 "$DEFAULT_LOCALE" --title "System Locale" 3>&1 1>&2 2>&3)
if [ -n "$LOCALE" ]; then
    sudo locale-gen "$LOCALE"
    sudo update-locale LANG="$LOCALE"
fi

# 4. Set system timezone
DEFAULT_TZ="Asia/Tokyo"
TIMEZONE=$(whiptail --inputbox "Enter timezone (e.g., Asia/Tokyo):" 8 50 "$DEFAULT_TZ" --title "Timezone" 3>&1 1>&2 2>&3)
if [ -n "$TIMEZONE" ]; then
    sudo timedatectl set-timezone "$TIMEZONE"
fi

while true; do
    # 5. Select LAN interface
    INTERFACES=($(ls /sys/class/net | grep -v lo))
    MENU_ITEMS=()
    for i in "${INTERFACES[@]}"; do
        MENU_ITEMS+=("$i" "Network Interface")
    done
    IFACE=$(whiptail --menu "Select network interface:" 15 50 ${#MENU_ITEMS[@]} "${MENU_ITEMS[@]}" 3>&1 1>&2 2>&3) || exit 1

    # 6. Get current network info for defaults
    CURRENT_IP=$(ip addr show "$IFACE" | grep 'inet ' | awk '{print $2}' | cut -d'/' -f1)
    CURRENT_MASK=$(ip addr show "$IFACE" | grep 'inet ' | awk '{print $2}' | cut -d'/' -f2)
    CURRENT_GW=$(ip route | grep default | grep "$IFACE" | awk '{print $3}')
    CURRENT_DNS="8.8.8.8,8.8.4.4"

    IP=$(whiptail --inputbox "Enter static IP address:" 8 50 "$CURRENT_IP" --title "Static IP" 3>&1 1>&2 2>&3)
    MASK=$(whiptail --inputbox "Enter subnet mask (CIDR format, e.g., 24):" 8 50 "$CURRENT_MASK" --title "Subnet Mask" 3>&1 1>&2 2>&3)
    GW=$(whiptail --inputbox "Enter gateway:" 8 50 "$CURRENT_GW" --title "Gateway" 3>&1 1>&2 2>&3)
    DNS=$(whiptail --inputbox "Enter DNS servers (comma separated):" 8 50 "$CURRENT_DNS" --title "DNS Servers" 3>&1 1>&2 2>&3)

    # Apply configuration
    NETPLAN_FILE="/etc/netplan/01-$IFACE-static.yaml"
    sudo bash -c "cat > $NETPLAN_FILE" <<EOL
network:
  version: 2
  ethernets:
    $IFACE:
      dhcp4: no
      addresses:
        - $IP/$MASK
      gateway4: $GW
      nameservers:
        addresses: [${DNS//,/ , }]
EOL

    sudo netplan apply

    # 7. Ask if another interface should be configured
    if whiptail --yesno "Do you want to configure another interface?" 8 50 --title "Repeat?" ; then
        continue
    else
        break
    fi
done

whiptail --msgbox "Static IP configuration complete! Backup saved in $BACKUP_DIR" 8 50 --title "Done"
exit 0
