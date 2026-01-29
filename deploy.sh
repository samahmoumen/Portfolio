#!/bin/bash

set -e

echo "=== Déploiement du portfolio sur $VM_HOST ==="

mkdir -p ~/.ssh
ssh-keyscan -H "$VM_HOST" >> ~/.ssh/known_hosts

ssh -p "$VM_PORT" -o StrictHostKeyChecking=no "$VM_USER@$VM_HOST" << EOF
  set -e

  PROJECT_DIR="$PROJECT_DIR"
  REPO_URL="$REPO_URL"
  ENV_FILE="$ENV_FILE"
  DOCKERHUB_USERNAME="$DOCKERHUB_USERNAME"
  DOCKERHUB_TOKEN="$DOCKERHUB_TOKEN"

  echo "-> Création du dossier projet"
  mkdir -p "\$PROJECT_DIR"
  cd "\$PROJECT_DIR"

  echo "-> Clonage ou mise à jour du repo"
  if [ -d .git ]; then
    git pull
  else
    git clone "\$REPO_URL" .
  fi

  echo "-> Création du fichier .env"
  echo "\$ENV_FILE" > .env

  echo "-> Vérification Docker"
  if ! docker version &> /dev/null; then
    sudo apt update
    sudo apt install -y docker.io
    sudo systemctl enable docker
    sudo systemctl start docker
  fi

  echo "-> Login Docker Hub"
  echo "\$DOCKERHUB_TOKEN" | docker login -u "\$DOCKERHUB_USERNAME" --password-stdin

  echo "-> Pull image Docker"
  docker pull "\$DOCKERHUB_USERNAME/${DOCKERHUB_IMAGE}:v1.0.0"

  echo "-> Lancement containers"
docker compose -f docker-compose.prod.yml --env-file .env down || true
docker compose -f docker-compose.prod.yml --env-file .env up -d

  echo "-> Containers actifs"
  docker ps
EOF

echo "=== Déploiement terminé ✅ ==="
