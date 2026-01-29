#!/bin/bash
set -e

# Remove um possível PID antigo
rm -f tmp/pids/server.pid

# Sempre verifica e instala gems se necessário
if ! bundle check; then
  echo "Instalando gems faltantes..."
  bundle install
fi

# Executa migrations (apenas em produção)
if [ "$RAILS_ENV" = "production" ]; then
  echo "Executando migrations..."
  bundle exec rails db:migrate || echo "Aviso: Erro ao executar migrations (pode ser normal se já foram executadas)"
fi

# Pré-compila assets em produção
if [ "$RAILS_ENV" = "production" ]; then
  echo "Pré-compilando assets..."
  bundle exec rails assets:precompile || echo "Aviso: Erro ao pré-compilar assets"
fi

# Executa o servidor usando Puma (conforme Procfile)
exec bundle exec puma -C config/puma.rb
