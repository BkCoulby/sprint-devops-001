#!/usr/bin/env bash

# Durcissement de mon serveur — défi-001, Promo 001
# Usage : sudo bash durcir.sh

set -euo pipefail

# Vérifie que le script est exécuté avec les privilèges administrateur.
# Le durcissement du pare-feu, SSH et les mises à jour nécessitent root.
if [[ $EUID -ne 0 ]]; then
    echo "Erreur : exécute ce script avec sudo."
    exit 1
fi

echo "=== Début du durcissement du serveur ==="

# ============================================================
# 1. PARE-FEU
# ============================================================

# Installe UFW s'il n'est pas déjà installé.
# UFW permet de contrôler les connexions réseau entrantes et sortantes.
apt update
apt install -y ufw

# Autorise SSH AVANT d'activer le pare-feu.
# Cette règle est indispensable pour éviter de perdre l'accès distant.
ufw allow ssh

# Autorise HTTP et HTTPS afin que le serveur Web reste accessible.
ufw allow 80/tcp
ufw allow 443/tcp

# Refuse toutes les connexions entrantes qui ne correspondent
# pas à une règle explicitement autorisée.
ufw default deny incoming

# Autorise les connexions sortantes afin que le serveur puisse
# communiquer avec Internet et effectuer notamment ses mises à jour.
ufw default allow outgoing

# Active le pare-feu seulement après avoir configuré les règles.
ufw --force enable

echo "Pare-feu configuré."

# ============================================================
# 2. SSH : INTERDIRE LE MOT DE PASSE ET ROOT
# ============================================================

# Crée une sauvegarde de la configuration SSH avant modification.
# Cela permet de revenir en arrière en cas de problème.
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

# Désactive l'authentification SSH par mot de passe.
# L'accès SSH doit utiliser une clé plutôt qu'un mot de passe.
sed -i 's/^[[:space:]]*#\?[[:space:]]*PasswordAuthentication[[:space:]].*/PasswordAuthentication no/' /etc/ssh/sshd_config

# Désactive complètement la connexion directe de root via SSH.
sed -i 's/^[[:space:]]*#\?[[:space:]]*PermitRootLogin[[:space:]].*/PermitRootLogin no/' /etc/ssh/sshd_config

# Si les directives n'existent pas dans le fichier, on les ajoute.
grep -qE '^[[:space:]]*PasswordAuthentication[[:space:]]+no' /etc/ssh/sshd_config || \
    echo 'PasswordAuthentication no' >> /etc/ssh/sshd_config

grep -qE '^[[:space:]]*PermitRootLogin[[:space:]]+no' /etc/ssh/sshd_config || \
    echo 'PermitRootLogin no' >> /etc/ssh/sshd_config

# Vérifie la syntaxe avant de recharger SSH.
# Une erreur de syntaxe pourrait empêcher le serveur SSH de redémarrer.
sshd -t

# Affiche la configuration SSH réellement appliquée.
echo "Configuration SSH effective :"
sshd -T | grep -iE 'passwordauthentication|permitrootlogin'

# Recharge SSH sans interrompre les connexions existantes.
systemctl reload ssh

echo "SSH durci."

# ============================================================
# 3. MISES À JOUR
# ============================================================

# Met à jour la liste des paquets disponibles.
apt update

# Installe les dernières versions des paquets.
apt upgrade -y

# Supprime les dépendances devenues inutiles.
apt autoremove -y

echo "Système mis à jour."

# ============================================================
# 4. VÉRIFICATIONS FINALES
# ============================================================

# Vérifie que le pare-feu est actif et affiche ses règles.
echo
echo "=== État du pare-feu ==="
ufw status verbose

# Vérifie la configuration SSH réellement appliquée.
echo
echo "=== Configuration SSH ==="
sshd -T | grep -iE 'passwordauthentication|permitrootlogin'

# Vérifie que le serveur Web répond toujours.
echo
echo "=== Vérification du serveur Web ==="
curl -I http://localhost

echo
echo "=== Durcissement terminé avec succès ==="
