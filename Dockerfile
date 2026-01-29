# Use a imagem oficial do Ruby
FROM ruby:3.2

# Instalar dependências do sistema
RUN apt-get update -qq && apt-get install -y \
    build-essential \
    libpq-dev \
    nodejs \
    npm \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Configurar diretório de trabalho
WORKDIR /app

# Copiar Gemfile e Gemfile.lock (se existir)
COPY Gemfile Gemfile.lock* ./

# Instalar gems
RUN bundle install

# Copiar script de entrada
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Copiar o resto da aplicação
COPY . .

RUN chmod +x bin/rails-entrypoint docker-entrypoint.sh

# Expor a porta padrão do Rails
EXPOSE 3000

# Script de entrada
ENTRYPOINT ["bash", "/usr/local/bin/docker-entrypoint.sh"]
