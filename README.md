![CI](https://github.com/USERNAME/REPOSITORY/workflows/RSpec%20Tests/badge.svg)

## API para Consumo por Aplicação Mobile

### Rotas disponíveis

- **GET `/api/profiles`**: retorna lista paginada de perfis.
  - Aceita query params: `?page=1&per_page=10`.
- **GET `/api/profiles/:id`**: retorna os dados de um perfil específico.

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

