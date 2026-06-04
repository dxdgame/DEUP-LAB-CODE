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

# 1. PREMIUM INTRO BANNER
echo -e "${CYAN}================================================================${NC}"
echo -e "${MAGENTA}    ____  _____ _   _ ____    _        _     ____  ${NC}"
echo -e "${MAGENTA}   |  _ \\| ____| | | |  _ \\  | |      / \\   | __ ) ${NC}"
echo -e "${MAGENTA}   | | | |  _| | | | | |_) | | |     / _ \\  |  _ \\ ${NC}"
echo -e "${MAGENTA}   | |_| | |___| |_| |  __/  | |___ / ___ \\ | |_) |${NC}"
echo -e "${MAGENTA}   |____/|_____|\\___/|_|     |_____/_/   \\_\\|____/ ${NC}"
echo -e "${CYAN}================================================================${NC}"
echo -e "${YELLOW}           KEXSONHOST x DEUP LABS | MULTI-OS DEPLOYMENT PANEL    ${NC}"
echo -e "${CYAN}================================================================${NC}"
echo ""

# Dependencies Check
echo -e "${YELLOW}[*] Initializing core components...${NC}"
sudo apt update && sudo apt install -y qemu-system-x86 qemu-utils wget novnc websockify >/dev/null 2>&1
clear

# --- MENU NAVIGATION ---

# STEP 1: Environment Selection
echo -e "${CYAN}================================================================${NC}"
echo -e "${MAGENTA}                 STEP 1: SELECT DEPLOYMENT TARGET                ${NC}"
echo -e "${CYAN}================================================================${NC}"
echo -e " 1) VPS Instance / Cloud Server"
echo -e " 2) Local Dedicated Node"
read -p "Choose Target Environment (1-2): " TARGET_CHOICE
echo ""

# STEP 2: KVM vs Non-KVM Selection
echo -e "${CYAN}================================================================${NC}"
echo -e "${MAGENTA}                 STEP 2: CHOOSE VIRTUALIZATION MODE             ${NC}"
echo -e "${CYAN}================================================================${NC}"
echo -e " 1) Non-KVM Mode (TCG Software Accelerator - Safe for nested VPS)"
echo -e " 2) KVM Mode (Hardware Acceleration - Requires KVM Enabled on Host)"
read -p "Choose Mode (1-2): " ACCEL_CHOICE

if [ "$ACCEL_CHOICE" == "2" ]; then
    ACCEL_TYPE="kvm"
else
    ACCEL_TYPE="tcg"
fi
echo ""

# STEP 3: Multi-OS Database Selection
echo -e "${CYAN}================================================================${NC}"
echo -e "${MAGENTA}                 STEP 3: SELECT OPERATING SYSTEM                ${NC}"
echo -e "${CYAN}================================================================${NC}"
echo -e " 1) Proxmox VE 8.2 (Virtualization OS)"
echo -e " 2) Debian 11 (Bullseye - Stable Linux)"
echo -e " 3) Ubuntu Server 22.04 (LTS)"
echo -e " 4) Alpine Linux (Ultra Lightweight)"
read -p "Select OS to Install (1-4): " OS_CHOICE

# System mappings based on choices
case $OS_CHOICE in
    1)
        ISO_NAME="proxmox-ve_8.2-1.iso"
        ISO_URL="https://mirrors.apua.org/proxmox/iso/proxmox-ve_8.2-1.iso"
        DISK_NAME="proxmox.qcow2"
        SERVICE_PORT="8006"
        ;;
    2)
        ISO_NAME="debian-11.10.0-amd64-netinst.iso"
        ISO_URL="https://cdimage.debian.org/debian-cd/current-images/amd64/iso-cd/debian-11.10.0-amd64-netinst.iso"
        DISK_NAME="debian11.qcow2"
        SERVICE_PORT="80"
        ;;
    3)
        ISO_NAME="ubuntu-22.04.4-live-server-amd64.iso"[cite: 1]
        ISO_URL="https://releases.ubuntu.com/22.04/ubuntu-22.04.4-live-server-amd64.iso"[cite: 1]
        DISK_NAME="ubuntu.qcow2"[cite: 1]
        SERVICE_PORT="3389"
        ;;
    4)
        ISO_NAME="alpine-virt-3.20.0-x86_64.iso"
        ISO_URL="https://dl-cdn.alpinelinux.org/alpine/v3.20/releases/x86_64/alpine-virt-3.20.0-x86_64.iso"
        DISK_NAME="alpine.qcow2"
        SERVICE_PORT="80"
        ;;
    *)
        echo -e "${RED}[X] Invalid Option! Defaulting to Proxmox VE.${NC}"
        ISO_NAME="proxmox-ve_8.2-1.iso"
        ISO_URL="https://mirrors.apua.org/proxmox/iso/proxmox-ve_8.2-1.iso"
        DISK_NAME="proxmox.qcow2"
        SERVICE_PORT="8006"
        ;;
esac

echo ""
echo -e "${CYAN}--- STEP 4: RESOURCE PROVISIONING ---${NC}"
read -p "Enter RAM in MB (e.g. 2048, 4096, 8192) [Default 8192]: " USER_RAM
USER_RAM=${USER_RAM:-8192}[cite: 1]

read -p "Enter CPU Cores [Default 4]: " USER_CPU
USER_CPU=${USER_CPU:-4}[cite: 1]

read -p "Enter Disk Size in GB [Default 50]: " USER_DISK
USER_DISK=${USER_DISK:-50}[cite: 1]
USER_DISK=$(echo "$USER_DISK" | sed 's/[Gg]//g')

# Lock configurations display
clear
echo -e "${GREEN}================================================================${NC}"
echo -e "${GREEN}🔥 CONFIGURATION COMPLETED | PRE-FLIGHT MANIFEST${NC}"
echo -e "${GREEN}================================================================${NC}"
echo -e " > Acceleration Engine : $ACCEL_TYPE"
echo -e " > OS Target Node      : $ISO_NAME"
echo -e " > Allocated Memory    : ${USER_RAM} MB"
echo -e " > Compute Cores       : ${USER_CPU} vCPU"
echo -e " > Storage Capacity    : ${USER_DISK} GB"
echo -e "${GREEN}================================================================${NC}"
echo ""
read -p "Press [ENTER] to execute full deployment pipeline..."

# --- DEPLOYMENT ENGINE ---

# Create Disk Asset
if [ ! -f "$DISK_NAME" ]; then
    echo -e "${YELLOW}[*] Provisioning empty virtual storage block...${NC}"
    qemu-img create -f qcow2 "$DISK_NAME" "${USER_DISK}G"[cite: 1]
fi

# Download Target ISO
if [ ! -f "$ISO_NAME" ]; then
    echo -e "${YELLOW}[*] Streaming OS image installation media...${NC}"
    wget -O "$ISO_NAME" "$ISO_URL"
fi

# Clean port blocks & Web Proxy Refresh
sudo fuser -k 80/tcp >/dev/null 2>&1
pkill -f websockify
sleep 1

echo -e "${YELLOW}[*] Launching secure VNC socket on firewall bypass port 80...${NC}"
sudo websockify --web=/usr/share/novnc/ 80 localhost:5900 &[cite: 1]
sleep 2

# Execute QEMU Daemon
echo -e "${GREEN}[*] Booting guest instance inside backend hypervisor...${NC}"

nohup qemu-system-x86_64 \
  -machine pc \
  -cpu qemu64 \
  -m "$USER_RAM" \
  -smp "$USER_CPU" \
  -accel "$ACCEL_TYPE" \
  -drive file="$DISK_NAME",format=qcow2 \
  -cdrom "$ISO_NAME" \
  -boot d \
  -net nic -net user,hostfwd=tcp::2022-:22,hostfwd=tcp::${SERVICE_PORT}-:${SERVICE_PORT} \
  -vnc :0 > deup_qemu.log 2>&1 &[cite: 1]

echo ""
echo -e "${GREEN}================================================================${NC}"
echo -e "${CYAN}🚀 DEUP LAB NODE ONLINE AND RUNNING 24/7!${NC}"
echo -e "${GREEN}================================================================${NC}"
echo -e "${YELLOW}URL Access :${NC} http://<your-vps-ip>/vnc.html"
echo -e "${YELLOW}Mapped Port:${NC} $SERVICE_PORT"
echo -e "${GREEN}================================================================${NC}"
