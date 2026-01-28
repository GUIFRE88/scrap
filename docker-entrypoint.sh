#!/bin/bash
set -e

# Remove um possível PID antigo
rm -f tmp/pids/server.pid

# Verifica se a aplicação Rails já existe
if [ ! -f config/application.rb ]; then
  echo "Aplicação Rails não encontrada. Inicializando..."
  
  # Salva o Gemfile existente se houver
  if [ -f Gemfile ]; then
    cp Gemfile Gemfile.backup
  fi
  
  # Inicializa a aplicação Rails
  rails new . --database=postgresql --force --skip-git --skip-bundle
  
  # Restaura o Gemfile se foi sobrescrito
  if [ -f Gemfile.backup ]; then
    mv Gemfile.backup Gemfile
    echo "Gemfile restaurado. Instalando gems..."
    bundle install
  fi
  
  echo "Aplicação Rails criada com sucesso!"
fi

# Sempre verifica e instala gems se necessário (útil quando Gemfile.lock está desatualizado)
if bundle check; then
  echo "Todas as gems estão instaladas."
else
  echo "Instalando gems faltantes..."
  bundle install
fi

# Executa o servidor Rails
exec rails server -b 0.0.0.0
