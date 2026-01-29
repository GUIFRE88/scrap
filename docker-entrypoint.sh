#!/bin/bash
set -e

# Sempre verifica e instala gems se necessário
if ! bundle check; then
  echo "Instalando gems faltantes..."
  bundle install
fi

# Usa o mesmo script de inicialização do Procfile
exec bin/rails-entrypoint
