#!/bin/bash

# Rangon ke codes (UI Colors)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Clear Screen
clear

# Premium ASCII Art Banner (KexSonHost + DEUP LAB)
echo -e "${CYAN}================================================================${NC}"
echo -e "${MAGENTA}    ____  _____ _   _ ____    _        _     ____  ${NC}"
echo -e "${MAGENTA}   |  _ \\| ____| | | |  _ \\  | |      / \\   | __ ) ${NC}"
echo -e "${MAGENTA}   | | | |  _| | | | | |_) | | |     / _ \\  |  _ \\ ${NC}"
echo -e "${MAGENTA}   | |_| | |___| |_| |  __/  | |___ / ___ \\ | |_) |${NC}"
echo -e "${MAGENTA}   |____/|_____|\\___/|_|     |_____/_/   \\_\\|____/ ${NC}"
echo -e "${CYAN}================================================================${NC}"
echo -e "${YELLOW}           KEXSONHOST x DEUP LABS | FIREWALL BYPASS TERMINAL     ${NC}"
echo -e "${CYAN}================================================================${NC}"
echo ""

# Dependencies Auto-Installation
echo -e "${YELLOW}[*] Validating core dependencies...${NC}"
sudo apt update && sudo apt install -y qemu-system-x86 qemu-utils wget novnc websockify
clear

# Banner Dubara Display
echo -e "${CYAN}================================================================${NC}"
echo -e "${MAGENTA}           DEUP LAB VIRTUALIZATION CONFIGURATION PANEL          ${NC}"
echo -e "${CYAN}================================================================${NC}"
echo ""

# --- USER INPUT CONTROLS ---

echo -e "${YELLOW}Select Installation Mode:${NC}"
echo -e " 1) Proxmox VE 8.2 (High-Speed Backup Mirror)"
echo -e " 2) Ubuntu Server 22.04"
read -p "Enter choice (1 or 2): " ISO_CHOICE

if [ "$ISO_CHOICE" == "2" ]; then
    ISO_NAME="ubuntu-22.04.4-live-server-amd64.iso"
    ISO_URL="https://releases.ubuntu.com/22.04/ubuntu-22.04.4-live-server-amd64.iso"
    DISK_NAME="ubuntu.qcow2"
    WEB_PORT="80"        # Bypass port for direct web access
    SSH_PORT="2222"
    SERVICE_PORT="3389"
else
    # 100% Working Open-Source Mirror for Proxmox VE 8.2 (No 404 Error)
    ISO_NAME="proxmox-ve_8.2-1.iso"
    ISO_URL="https://mirrors.apua.org/proxmox/iso/proxmox-ve_8.2-1.iso"
    DISK_NAME="proxmox.qcow2"
    WEB_PORT="80"        # Bypass port for direct web access
    SSH_PORT="2022"
    SERVICE_PORT="8006"
fi

echo ""
echo -e "${CYAN}--- HARDWARE ALLOCATION ---${NC}"

read -p "Enter RAM in MB (e.g. 2048, 4096, 8192) [Default 8192]: " USER_RAM
USER_RAM=${USER_RAM:-8192}

read -p "Enter CPU Cores (e.g. 2, 4, 8) [Default 4]: " USER_CPU
USER_CPU=${USER_CPU:-4}

read -p "Enter Disk Size (e.g. 50, 100, 128) [Default 50]: " USER_DISK
USER_DISK=${USER_DISK:-50}
USER_DISK=$(echo "$USER_DISK" | sed 's/[Gg]//g')

echo ""
echo -e "${GREEN}[+] Configuration Captured Successfully!${NC}"
echo -e "${BLUE}------------------------------------------------${NC}"
echo -e " > Target ISO : $ISO_NAME"
echo -e " > Allocated RAM  : ${USER_RAM} MB"
echo -e " > Allocated CPU  : ${USER_CPU} Cores"
echo -e " > Disk Storage   : ${USER_DISK} GB"
echo -e "${BLUE}------------------------------------------------${NC}"
echo ""

read -p "Press [ENTER] to lock configurations and deploy..."

# --- AUTOMATION EXECUTION ---

# Check and Create Disk
if [ ! -f "$DISK_NAME" ]; then
    echo -e "${YELLOW}[*] Creating ${USER_DISK}G Virtual Disk Asset...${NC}"
    qemu-img create -f qcow2 "$DISK_NAME" "${USER_DISK}G"
else
    echo -e "${GREEN}[+] Disk image already exists. Skipping creation.${NC}"
fi

# Download ISO if not exists
if [ ! -f "$ISO_NAME" ]; then
    echo -e "${YELLOW}[*] Fetching ISO from trusted mirror...${NC}"
    wget -O "$ISO_NAME" "$ISO_URL"
else
    echo -e "${GREEN}[+] ISO file detected locally. Skipping download.${NC}"
fi

# Kill anything running on Port 80 to free up space
sudo fuser -k 80/tcp >/dev/null 2>&1
pkill -f websockify

# Start noVNC Proxy on Port 80
echo -e "${YELLOW}[*] Launching noVNC Proxy Stream on Bypass Port $WEB_PORT...${NC}"
sudo websockify --web=/usr/share/novnc/ "$WEB_PORT" localhost:5900 &
sleep 2

# Main QEMU Boot Core
echo -e "${GREEN}[*] Starting Hypervisor via DEUP LAB TCG Engine...${NC}"

qemu-system-x86_64 \
  -machine pc \
  -cpu qemu64 \
  -m "$USER_RAM" \
  -smp "$USER_CPU" \
  -accel tcg \
  -drive file=proxmox.qcow2,format=qcow2 \
  -cdrom proxmox-ve_8.2-1.iso \
  -boot d \
  -net nic -net user,hostfwd=tcp::${SSH_PORT}-:22,hostfwd=tcp::${SERVICE_PORT}-:${SERVICE_PORT} \
  -vnc :0 
  
echo ""
echo -e "${GREEN}================================================================${NC}"
echo -e "${CYAN}🔥 DEUP LAB APPARATUS SUCCESSFULLY DEPLOYED!${NC}"
echo -e "${GREEN}================================================================${NC}"
echo -e "${YELLOW}1. Web Console VNC :${NC} http://<your-vps-ip>/vnc.html"
echo -e "${YELLOW}2. SSH Tunnel Port :${NC} $SSH_PORT"
echo -e "${YELLOW}3. Dashboard Port  :${NC} $SERVICE_PORT (Requires firewall rule unblock)"
echo -e "${MAGENTA}Note: Port 80 bypass active. Open link directly without any port numbers!${NC}"
echo -e "${GREEN}================================================================${NC}"
