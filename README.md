# 🐧 Raspberry Pi 5 – Boot sur SSD NVMe avec Ubuntu

> ⚠️ Ce script doit être lancé depuis un **Raspberry Pi 5** avec **Raspberry Pi OS Lite installé sur une carte microSD**. Le script va ensuite préparer le SSD NVMe et configurer le Pi pour démarrer dessus.

---

## ⚙️ Ce que fait ce script

- Détecte automatiquement le SSD NVMe.
- Propose une liste d’OS à installer :
  - **Ubuntu MATE 22.04.5 LTS** (robot version 2025)
  - **Ubuntu 24.04.2 Server LTS** (robot version 2026)
  - Ou une image personnalisée depuis une **URL ou un chemin local**.
- Télécharge et décompresse l’image si nécessaire.
- Flashe l’image sur le SSD NVMe.
- Configure le Raspberry Pi pour démarrer depuis le SSD.
- Te laisse retirer la carte SD et rebooter directement sur le SSD.

---

## 🧰 Prérequis

Avant d’exécuter le script, assure-toi d’avoir les outils suivants installés :

```bash
sudo apt update
sudo apt install -y curl wget xz-utils parted util-linux
````

---

## 🚀 Installation en une ligne

Exécute cette commande sur le Pi 5 avec la carte SD :

```bash
curl -sSL https://raw.githubusercontent.com/Valoliin/rpi-boot-ubuntu-nvme/main/install_os_nvme.sh -o install_os_nvme.sh
chmod +x install_os_nvme.sh
sudo ./install_os_nvme.sh
```

---

## 📝 Remarques

* Le script supprime **tout le contenu du SSD NVMe**.
* Si tu relances le script plus tard, il détectera automatiquement les images déjà téléchargées dans `/tmp`.
* Ubuntu MATE **ne fournit plus d’image officielle** pour Raspberry Pi pour les versions récentes.

  * Seule la **22.04.5** est encore maintenue par l'équipe Ubuntu MATE.
  * La version **24.04.2** utilise l'image **Ubuntu Server officielle de Canonical**.

---

## 📦 Structure du dépôt

```
.
├── install_os_nvme.sh   # Script principal
└── README.md            # Ce fichier
```

---

## 🛠️ Dépannage

* Vérifie que ton SSD est bien détecté avec `lsblk`.
* Assure-toi que ton HAT NVMe est compatible avec le Raspberry Pi 5.
* Si tu veux flasher une autre distribution (DietPi, Debian, etc.), choisis l'option 3 dans le script.

---

## 🧠 Auteur

**Valoliin**
🔗 [https://github.com/Valoliin](https://github.com/Valoliin)
