ssh -p "$VM_PORT" -o StrictHostKeyChecking=no "$VM_USER@$VM_HOST" \
  DOCKERHUB_USERNAME="$DOCKERHUB_USERNAME" \
  DOCKERHUB_IMAGE="$DOCKERHUB_IMAGE" \
  DOCKERHUB_TOKEN="$DOCKERHUB_TOKEN" \
  ENV_FILE="$ENV_FILE" \
  PROJECT_DIR="$PROJECT_DIR" \
'#!/bin/bash
set -e

echo "-> Création du dossier projet"
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

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
