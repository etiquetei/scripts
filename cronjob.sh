#!/bin/bash

SERVICE_NAME="etiquetei"
UPDATE_SCRIPT_PATH="/etc/etiquetei/scripts/update.sh"
CRON_FILE="/tmp/cronfile"
DEFAULT_FREQUENCY="*/15 * * * *"

# Função para verificar se o cronjob já existe
check_cronjob_exists() {
  crontab -l | grep -v '^#' | grep -q "$UPDATE_SCRIPT_PATH"
}

# Função para configurar o cronjob
setup_cronjob() {
  local frequency=$1

  # Cria um novo arquivo de cron temporário
  crontab -l > $CRON_FILE 2>/dev/null

  # Remove o cronjob existente se houver
  sed -i "\|$UPDATE_SCRIPT_PATH|d" $CRON_FILE

  # Adiciona o novo cronjob
  echo "$frequency $UPDATE_SCRIPT_PATH" >> $CRON_FILE

  # Instala o novo cronjob
  crontab $CRON_FILE
  rm $CRON_FILE

  echo "Cronjob has been set up with frequency: '$frequency'"
}

# Função principal para configurar o cronjob
main() {
  if check_cronjob_exists; then
    read -p "Cronjob already exists. Do you want to create it again? (yes to recreate, press Enter to keep existing) " response
    if [[ "$response" =~ ^(yes|y)$ ]]; then
      setup_new_cronjob
    else
      echo "Keeping the existing cronjob."
    fi
  else
    setup_new_cronjob
  fi
}

# Função para configurar um novo cronjob
setup_new_cronjob() {
  read -p "Enter the frequency for the cronjob (press Enter for default '*/15 * * * *'): " frequency
  if [ -z "$frequency" ]; then
    frequency="$DEFAULT_FREQUENCY"
    echo "Using default frequency: '$DEFAULT_FREQUENCY'"
  fi
  setup_cronjob "$frequency"
}

# Executa a função principal
main
