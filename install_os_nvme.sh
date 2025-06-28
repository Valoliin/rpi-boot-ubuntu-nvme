#!/bin/bash
if [ "$EUID" -ne 0 ]; then
  echo "❌ Ce script doit être exécuté avec les droits root (sudo)."
  exit 1
fi

set -e

echo "=== Script de configuration du Raspberry Pi 5 pour booter sur NVMe ==="

# Détection du disque NVMe
NVME_DEV=$(lsblk -d -o NAME,MODEL | grep -i nvme | awk '{print $1}')
if [ -z "$NVME_DEV" ]; then
  echo "❌ Aucun disque NVMe détecté. Vérifie ton HAT ou ton câblage."
  exit 1
fi

DISK="/dev/$NVME_DEV"
# Vérification de la capacité détectée du disque
NVME_SIZE=$(lsblk -b -dn -o SIZE "/dev/$NVME_DEV")

if [ "$NVME_SIZE" -eq 0 ]; then
  echo "❌ Le SSD NVMe est détecté, mais sa capacité est de 0 octet."
  echo "Cela signifie qu'il est mal initialisé ou mal alimenté."
  echo "👉 Consulte la section dépannage du README à l'adresse suivante :"
  echo "   https://github.com/Valoliin/rpi-boot-ubuntu-nvme#-dépannage"
  exit 1
fi

echo "✅ Disque NVMe détecté : $DISK"

# Choix de l'image
echo "Choisis l'OS à installer sur le SSD NVMe :"
echo "1. Ubuntu MATE 22.04.5 LTS (robot version 2025)"
echo "2. Ubuntu 24.04.2 Server LTS (robot version 2026)"
echo "3. Autre image personnalisée (URL ou chemin local)"
read -p "Ton choix (1, 2 ou 3) : " choix

case $choix in
  1)
    OS_NAME="Ubuntu MATE 22.04.5 LTS (robot version 2025)"
    IMG_URL="https://releases.ubuntu-mate.org/22.04/arm64/ubuntu-mate-22.04-desktop-arm64+raspi.img.xz"
    FILE_NAME=$(basename "$IMG_URL")
    TMP_IMG="/tmp/$FILE_NAME"
    ;;
  2)
    OS_NAME="Ubuntu 24.04.2 Server LTS (robot version 2026)"
    IMG_URL="https://cdimage.ubuntu.com/releases/24.04.2/release/ubuntu-24.04.2-preinstalled-server-arm64+raspi.img.xz"
    FILE_NAME=$(basename "$IMG_URL")
    TMP_IMG="/tmp/$FILE_NAME"
    ;;
  3)
    read -p "Entre l'URL de l'image (.img ou .img.xz) ou son chemin local : " IMG_SOURCE
    if [[ "$IMG_SOURCE" =~ ^http ]]; then
      FILE_NAME=$(basename "$IMG_SOURCE")
      TMP_IMG="/tmp/$FILE_NAME"
      if [[ -f "$TMP_IMG" ]]; then
        echo "✅ Image déjà téléchargée dans /tmp : $FILE_NAME"
      else
        echo "📥 Téléchargement de l'image personnalisée..."
        wget -O "$TMP_IMG" "$IMG_SOURCE"
      fi
    elif [[ -f "$IMG_SOURCE" ]]; then
      echo "✅ Fichier local détecté : $IMG_SOURCE"
      TMP_IMG="$IMG_SOURCE"
    else
      echo "❌ Lien ou chemin invalide. Arrêt."
      exit 1
    fi
    OS_NAME="Image personnalisée"
    ;;
  *)
    echo "❌ Choix invalide. Arrêt du script."
    exit 1
    ;;
esac

# Téléchargement si nécessaire pour 1 et 2
if [[ "$choix" == "1" || "$choix" == "2" ]]; then
  if [[ -f "$TMP_IMG" ]]; then
    echo "✅ Image déjà présente : $TMP_IMG"
  else
    echo "📥 Téléchargement de $OS_NAME..."
    wget -O "$TMP_IMG" "$IMG_URL"
  fi
fi

# Décompression si .xz
if [[ "$TMP_IMG" == *.xz ]]; then
  echo "📦 Décompression de l'image..."
  unxz -f "$TMP_IMG"
  TMP_IMG="${TMP_IMG%.xz}"
fi

# Confirmation
echo "⚠️ ATTENTION : le SSD $DISK va être entièrement effacé."
read -p "Es-tu sûr de vouloir continuer ? (oui/non) : " confirm
if [ "$confirm" != "oui" ]; then
  echo "❌ Annulé."
  exit 1
fi

# Création des fichiers cloud-init avant flash
echo "🛠️ Injection du mot de passe utilisateur dans l'image..."

LOOP_DEV=$(sudo losetup --show -Pf "$TMP_IMG")

sleep 1
sudo mkdir -p /mnt/img_boot
sudo mount "${LOOP_DEV}p1" /mnt/img_boot

# Injecter user-data et meta-data
echo "$USER_DATA" | sudo tee /mnt/img_boot/user-data > /dev/null
sudo touch /mnt/img_boot/meta-data

sudo umount /mnt/img_boot
sudo losetup -d "$LOOP_DEV"

echo "✅ Mot de passe 'rpicrof' injecté dans l'image pour l'utilisateur 'ubuntu'."

# Flash
echo "💾 Flash de $OS_NAME sur le SSD..."
dd if="$TMP_IMG" of="$DISK" bs=4M status=progress conv=fsync

echo "✅ Flash terminé. Synchronisation..."
sync

echo "✅ Le Raspberry Pi est maintenant prêt à booter sur le SSD NVMe."
echo "⏏️ Tu peux maintenant éteindre le Raspberry Pi, retirer la carte SD et redémarrer sur le SSD."
