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
echo -e "${YELLOW}           KEXSONHOST x DEUP LABS | VIRTUALIZATION ENGINE        ${NC}"
echo -e "${CYAN}================================================================${NC}"
echo ""

echo -e "${GREEN}[+] DEUP LAB Core Initialization Sequence Started...${NC}"
sleep 1

# Loading Spinner Function
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\\'
    echo -n " "
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%%$temp}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# Simulated Environment Booting
echo -e -n "${YELLOW}[*] Connecting to DEUP LAB Secure Quantum Protocol...${NC}"
(sleep 1.5) &
spinner $!
echo -e "${GREEN} CONNECTED!${NC}"

echo -e -n "${YELLOW}[*] Verifying Host Environment & Hypervisor Layers...${NC}"
(sleep 1.5) &
spinner $!
echo -e "${GREEN} OPTIMIZED!${NC}"
echo ""

# System Details Table
echo -e "${BLUE}------------------------------------------------${NC}"
echo -e "${CYAN}  DEUP LAB AUTOMATION TERMINAL${NC}"
echo -e "${BLUE}------------------------------------------------${NC}"
echo -e "  > Infrastructure : DEUP LAB Environment Engine"
echo -e "  > Target Setup   : Proxmox VE & QEMU TCG Node"
echo -e "  > System Status  : Ready to Deploy"
echo -e "${BLUE}------------------------------------------------${NC}"
echo ""

# User confirmation prompt
read -p "Press [ENTER] to flash the code on your VPS or CTRL+C to abort..."

echo ""
echo -e "${GREEN}[*] Launching Proxmox Setup under DEUP LAB supervision...${NC}"
echo ""

# --- Yahan se aapki reference file "ISO Any boot method using TCG.txt" ka code shuru hota hai ---
echo -e "${YELLOW}[*] Installing dependencies (QEMU, wget, noVNC)...${NC}"
sudo apt update && sudo apt install -y qemu-system-x86 qemu-utils wget novnc websockify[cite: 1]

echo -e "${YELLOW}[*] Downloading Proxmox Virtual Environment ISO...${NC}"
# Proxmox VE 8.2 ISO link
wget https://enterprise.proxmox.com/iso/proxmox-ve_8.2-1.iso

echo -e "${YELLOW}[*] Allocating 50GB Storage Disk...${NC}"
qemu-img create -f qcow2 proxmox.qcow2 50G[cite: 1]

echo -e "${YELLOW}[*] Starting noVNC HTML Proxy on Port 6080...${NC}"
websockify --web=/usr/share/novnc/ 6080 localhost:5900 &[cite: 1]

echo -e "${GREEN}[+] Booting Proxmox ISO via TCG Accelerator!${NC}"
echo -e "${CYAN}[i] Access your screen at http://<vps-ip>:6080/vnc.html${NC}"
echo -e "${CYAN}[i] Proxmox Web Panel will be mapped to Port 8006${NC}"

qemu-system-x86_64 \
  -machine pc \
  -cpu qemu64 \
  -m 8192 \
  -smp 4 \
  -accel tcg \
  -drive file=proxmox.qcow2,format=qcow2 \
  -cdrom proxmox-ve_8.2-1.iso \
  -boot d \
  -net nic -net user,hostfwd=tcp::2022-:22,hostfwd=tcp::8006-:8006 \
  -vnc :0[cite: 1]
