#!/bin/bash

SERVICE_NAME="etiquetei"
USER=$(whoami)
EXECUTABLE_PATH="/home/$USER/${SERVICE_NAME}-application"
REPO_PATH="$EXECUTABLE_PATH"
INI_FILE="$EXECUTABLE_PATH/etiquetei.ini"

# Função para obter a tag atual do repositório local
get_local_tag() {
  git -C "$REPO_PATH" tag | sort -V | tail -n 1
}

# Função para obter a tag atual do repositório remoto
get_remote_tag() {
  git -C "$REPO_PATH" ls-remote --tags origin | awk '{print $2}' | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -n 1
}

# Função para atualizar o repositório e reiniciar o serviço
update_repository() {
  echo "Stopping the service..."
  sudo systemctl stop $SERVICE_NAME

  echo "Pulling latest changes from the repository..."
  git -C "$REPO_PATH" fetch --tags
  git -C "$REPO_PATH" checkout "$REMOTE_TAG"

  echo "Creating INI file with version $REMOTE_TAG..."
  echo "[app]" > "$INI_FILE"
  echo "version=$REMOTE_TAG" >> "$INI_FILE"

  echo "Starting the service..."
  sudo systemctl start $SERVICE_NAME

  echo "Service $SERVICE_NAME has been updated to version $REMOTE_TAG and restarted successfully."
}

# Obtém a tag atual do repositório local e remoto
LOCAL_TAG=$(get_local_tag)
REMOTE_TAG=$(get_remote_tag)

# Verifica se há uma versão mais recente no repositório remoto
if [ "$LOCAL_TAG" != "$REMOTE_TAG" ]; then
  echo "New version available: $REMOTE_TAG (current version: $LOCAL_TAG)"
  update_repository
else
  echo "Already up-to-date with version: $LOCAL_TAG"
fi
