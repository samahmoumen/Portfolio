#!/bin/bash
set -e

echo "=== Déploiement sur $VM_HOST ==="

ssh -p "$VM_PORT" -o StrictHostKeyChecking=no "$VM_USER@$VM_HOST" "
set -e

echo '-> Projet directory: $PROJECT_DIR'
mkdir -p \"$PROJECT_DIR\"
cd \"$PROJECT_DIR\"

echo '-> Clonage ou mise à jour du repo (main)'
if [ -d .git ]; then
    git fetch origin main
    git reset --hard origin/main
else
    echo '-> Dossier vide : Clonage du repo'
    git clone -b main \"$REPO_URL\" .
fi

echo '-> Création du fichier .env'
echo \"$ENV_FILE\" > .env

echo '-> Login Docker Hub'
echo \"$DOCKERHUB_TOKEN\" | docker login -u \"$DOCKERHUB_USERNAME\" --password-stdin

echo '-> Pull image Docker'
docker pull \"$DOCKERHUB_USERNAME/$DOCKERHUB_IMAGE:v2.0.0\"

echo '-> Lancement containers'
docker compose -f docker-compose.prod.yml --env-file .env down || true
docker compose -f docker-compose.prod.yml --env-file .env up -d

docker ps
"
