![CI](https://github.com/USERNAME/REPOSITORY/workflows/RSpec%20Tests/badge.svg)

## Autenticação da API

A API utiliza autenticação por token simples. Cada usuário possui um token único que deve ser enviado no header `Authorization` de todas as requisições.

### Como obter seu token de API

#### Método 1: Via endpoint de autenticação (Recomendado)

Faça uma requisição POST para `/api/auth/login` com email e senha:

```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "usuario@exemplo.com",
    "password": "senha123"
  }'
```

**Resposta de sucesso**:
```json
{
  "token": "abc123def456...",
  "user": {
    "id": 1,
    "email": "usuario@exemplo.com"
  }
}
```

**Resposta de erro**:
```json
{
  "error": "Credenciais inválidas"
}
```

#### Método 2: Via console Rails

```ruby
# rails console
user = User.find_by(email: "seu@email.com")
user.api_token  # Retorna o token atual
user.regenerate_api_token!  # Gera um novo token
```

### Como usar o token

Após obter o token, envie-o no header `Authorization` com o prefixo `Bearer` em todas as requisições:

```bash
curl -H "Authorization: Bearer SEU_TOKEN_AQUI" \
  http://localhost:3000/api/profiles
```

### Exemplo completo

```bash
# 1. Obter o token via API
TOKEN=$(curl -s -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"usuario@exemplo.com","password":"senha123"}' \
  | grep -o '"token":"[^"]*' | cut -d'"' -f4)

# 2. Usar o token nas requisições
curl -H "Authorization: Bearer $TOKEN" \
  http://localhost:3000/api/profiles
```

**Nota**: Novos usuários recebem automaticamente um token ao se cadastrarem. Se você já tinha uma conta antes desta implementação, pode gerar um novo token usando o endpoint de login ou `user.regenerate_api_token!` no console Rails.

## API para Consumo por Aplicação Mobile

### Rotas disponíveis

#### Autenticação
- **POST `/api/auth/login`**: autentica o usuário e retorna o token de API.
  - Body (JSON): `{ "email": "usuario@exemplo.com", "password": "senha123" }`
  - Resposta: `{ "token": "...", "user": { "id": 1, "email": "..." } }`

#### Perfis
- **GET `/api/profiles`**: retorna lista paginada de perfis (requer autenticação).
  - Aceita query params: `?page=1&per_page=10`.
  - Header: `Authorization: Bearer TOKEN`
- **GET `/api/profiles/:id`**: retorna os dados de um perfil específico (requer autenticação).
  - Header: `Authorization: Bearer TOKEN`

### Formato de resposta

As respostas seguem o formato:

```json
{
  "data": [
    {
      "id": 1,
      "name": "Yukihiro Matsumoto",
      "github_username": "matz",
      "short_github_url": "https://bit.ly/xyz",
      "followers": 7700,
      "following": 1,
      "stars": 7,
      "contributions_last_year": 663,
      "avatar_url": "https://avatars.githubusercontent.com/u/30733",
      "location": "Matsue, Japan",
      "organizations": ["Ruby Association", "Heroku"]
    }
  ],
  "meta": {
    "current_page": 1,
    "per_page": 10,
    "total_pages": 3,
    "total_count": 25
  }
}
```

### Serialização (JBuilder)

A serialização é feita com **JBuilder** (`app/views/api/profiles/*.json.jbuilder`), escolhido por:
- Já fazer parte do stack padrão do Rails.
- Sintaxe simples para montar JSON.
- Fácil de manter e evoluir junto com as views da API.

### Paginação (will_paginate)

A paginação é implementada com **will_paginate**, por:
- API simples (`Model.paginate(page:, per_page:)`).
- Integração direta com ActiveRecord.
- Metadados de paginação fáceis de expor (`current_page`, `total_pages`, `total_entries`).

### Campos retornados

Para cada perfil, os campos retornados são:
- **id**: ID interno do perfil.
- **name**: Nome da pessoa.
- **github_username**: Usuário no GitHub.
- **short_github_url**: URL encurtada para o perfil (baseada em `short_code`).
- **followers**: Quantidade de seguidores.
- **following**: Quantidade de perfis seguidos.
- **stars**: Quantidade de estrelas.
- **contributions_last_year**: Contribuições no último ano.
- **avatar_url**: URL do avatar do GitHub.
- **location**: Localização.
- **organizations**: Array de organizações. Internamente o modelo possui um campo `organization` simples, que é exposto como array para atender ao contrato do Mobile.

