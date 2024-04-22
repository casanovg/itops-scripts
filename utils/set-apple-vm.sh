#!/bin/sh

# Setup a virtual machine for Apple macOS X
# ..........................................................
# NOTES:
# =====
# Date for High Sierra installation: sudo date 121401582018
# Date for Mojave installation:      sudo date 030300002019
# Date for Catalina installation:    sudo date 012219142020
# ..........................................................
# 2020-01-18 gustavo.casanova@gmail.com

APPLE_VM=$1

if [ ! -z $APPLE_VM ]; then
	VBoxManage modifyvm "$APPLE_VM" --cpuidset 00000001 000106e5 00100800 0098e3fd bfebfbff
	VBoxManage setextradata "$APPLE_VM" "VBoxInternal/Devices/efi/0/Config/DmiSystemProduct" "iMac11,3"
	VBoxManage setextradata "$APPLE_VM" "VBoxInternal/Devices/efi/0/Config/DmiSystemVersion" "1.0"
	VBoxManage setextradata "$APPLE_VM" "VBoxInternal/Devices/efi/0/Config/DmiBoardProduct" "Iloveapple"
	VBoxManage setextradata "$APPLE_VM" "VBoxInternal/Devices/smc/0/Config/DeviceKey" "ourhardworkbythesewordsguardedpleasedontsteal(c)AppleComputerInc"
	VBoxManage setextradata "$APPLE_VM" "VBoxInternal/Devices/smc/0/Config/GetKeyFromRealSMC" 1
	
	# VBoxManage setextradata "$APPLE_VM" VBoxInternal2/EfiGraphicsResolution 1920x1080
else
	echo ""
	echo "Usage: set-apple-vm.sh <Virtual Machine>"
	echo ""
fi

