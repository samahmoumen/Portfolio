ssh -p "$VM_PORT" -o StrictHostKeyChecking=no "$VM_USER@$VM_HOST" \
  DOCKERHUB_USERNAME="$DOCKERHUB_USERNAME" \
  DOCKERHUB_IMAGE="$DOCKERHUB_IMAGE" \
  DOCKERHUB_TOKEN="$DOCKERHUB_TOKEN" \
  ENV_FILE="$ENV_FILE" \
  PROJECT_DIR="$PROJECT_DIR" \
  REPO_URL="$REPO_URL" \
'#!/bin/bash
set -e

if [[ -z "$PROJECT_DIR" || "$PROJECT_DIR" == "/" || "$PROJECT_DIR" == "$HOME" ]]; then
    echo "Error: PROJECT_DIR ($PROJECT_DIR) is unsafe or undefined!"
    exit 1
fi
echo "-> Création du dossier projet"
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"
[[ -z "$PROJECT_DIR" || "$PROJECT_DIR" == "/" ]] && echo "PROJECT_DIR is unsafe!" && exit 1

echo "-> Clonage du repo (main)"
if [ -d .git ]; then
    echo "Repo existant : Reset et Pull"
    git fetch origin main
    git reset --hard origin/main
elif [ -z "$(ls -A .)" ]; then
    echo "Dossier vide : Clonage du repo"
    git clone -b main "$REPO_URL" .
else
    echo "Dossier non vide et pas un dépôt Git. Aucune action effectuée."
fi


echo "-> Création du fichier .env"
echo "$ENV_FILE" > .env

echo "-> Login Docker Hub"
echo "$DOCKERHUB_TOKEN" | docker login -u "$DOCKERHUB_USERNAME" --password-stdin

echo "-> Pull image Docker"
echo "IMAGE = $DOCKERHUB_USERNAME/$DOCKERHUB_IMAGE:v2.0.0"
docker pull "$DOCKERHUB_USERNAME/$DOCKERHUB_IMAGE:v2.0.0"

echo "-> Lancement containers"
docker compose -f docker-compose.prod.yml --env-file .env down || true
docker compose -f docker-compose.prod.yml --env-file .env up -d

docker ps
'
