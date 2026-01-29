#!/bin/bash
set -e

echo "=== Déploiement du portfolio sur $VM_HOST ==="

mkdir -p ~/.ssh
ssh-keyscan -H "$VM_HOST" >> ~/.ssh/known_hosts

# Run commands via SSH
ssh -p "$VM_PORT" -o StrictHostKeyChecking=no "$VM_USER@$VM_HOST" '
set -e

echo "-> Création du dossier projet"
mkdir -p "'"$PROJECT_DIR"'"
cd "'"$PROJECT_DIR"'"

echo "-> Création du fichier .env"
echo "'"$ENV_FILE"'" > .env

echo "-> Vérification Docker"
if ! docker version &> /dev/null; then
    sudo apt update
    sudo apt install -y docker.io
    sudo systemctl enable docker
    sudo systemctl start docker
fi

echo "-> Login Docker Hub"
echo "'"$DOCKERHUB_TOKEN"'" | docker login -u "'"$DOCKERHUB_USERNAME"'" --password-stdin

echo "-> Pull image Docker"
echo "'"$DOCKERHUB_USERNAME/$DOCKERHUB_IMAGE:v2.0.0"'"

docker pull "'"$DOCKERHUB_USERNAME/$DOCKERHUB_IMAGE:v2.0.0"'"

echo "-> Lancement containers"
docker compose -f docker-compose.prod.yml --env-file .env down || true
docker compose -f docker-compose.prod.yml --env-file .env up -d

echo "-> Containers actifs"
docker ps

echo "=== Déploiement terminé ✅ ==="
'
