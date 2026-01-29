#!/bin/bash

echo "=== Déploiement du portfolio sur $VM_HOST ==="

# Ajouter la VM aux known_hosts pour SSH
mkdir -p ~/.ssh
ssh-keyscan -H $VM_HOST >> ~/.ssh/known_hosts

# Connexion SSH et déploiement
ssh -p $VM_PORT -o StrictHostKeyChecking=no $VM_USER@$VM_HOST << EOF
  set -e

  echo "-> Création du dossier projet"
  mkdir -p $PROJECT_DIR
  cd $PROJECT_DIR

  echo "-> Clonage ou mise à jour du repo"
  if [ -d .git ]; then
    git pull
  else
    git clone $REPO_URL .
  fi

  echo "-> Création ou mise à jour du fichier .env"
  echo "$ENV_FILE" > .env

  echo "-> Vérification installation Docker"
  if ! command -v docker &> /dev/null; then
    echo "Docker non trouvé, installation..."
    sudo apt update
    sudo apt install -y docker.io
    sudo systemctl enable docker
    sudo systemctl start docker
  fi

  echo "-> Vérification installation Docker Compose"
  if ! command -v docker-compose &> /dev/null; then
    echo "Docker Compose non trouvé, installation..."
    sudo curl -L "https://github.com/docker/compose/releases/download/v2.23.1/docker-compose-\$(uname -s)-\$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
  fi

  echo "-> Pull de l'image Docker"
  docker login -u $DOCKERHUB_USERNAME -p $DOCKERHUB_TOKEN
  docker pull $DOCKERHUB_USERNAME/samahmoumen-portfolio:latest

  echo "-> Lancement ou redémarrage des containers avec .env"
  docker compose --env-file .env down
  docker compose --env-file .env up -d --build

  echo "-> Nettoyage des anciennes images et conteneurs"
  docker system prune -f

  echo "-> Vérification des containers et health"
  docker ps
  docker inspect --format='{{json .State.Health}}' portfolio | jq
EOF

echo "=== Déploiement terminé ✅ ==="
