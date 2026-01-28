#!/bin/bash
# deploy.sh - Déploiement minimal du portfolio sur VM via SSH + Docker Compose


USER_VM="tython"                     # utilisateur VM
IP_VM="123.456.78.90"                # IP publique VM
PROJECT_DIR="~/Portfolio"             # dossier projet sur la VM
REPO_URL="https://github.com/samahmoumen/Portfolio.git" # repo GitHub

# ===========================
# SCRIPT
# ===========================
echo "=== Déploiement du portfolio sur $IP_VM ==="

ssh $USER_VM@$IP_VM << 'EOF'
  # Créer le dossier projet
  mkdir -p ~/portfolio
  cd ~/portfolio

  # Cloner ou mettre à jour le repo
  if [ -d .git ]; then
    git pull
  else
    git clone https://github.com/samahmoumen/Portfolio.git .
  fi

  # Pull de l'image Docker
  docker pull samahmoumen/portfolio:latest

  # Lancer ou redémarrer les conteneurs
  docker compose up -d

  # Nettoyer anciennes images et conteneurs
  docker system prune -f

  # Vérifier les conteneurs
  docker ps
EOF

echo "=== Déploiement terminé ✅ ==="
