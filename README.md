
---
<h1 align="center">
  🚀 SCRAP 🚀
</h1>
<br>


# 💻 O Projeto

**SCRAP** é uma ferramenta web para scraping e gerenciamento de perfis do GitHub. A aplicação permite que usuários cadastrem perfis do GitHub, extraia informações automaticamente (seguidores, estrelas, contribuições, etc.) e fornece uma API RESTful para acesso a esses dados.

## 🎯 Funcionalidades Principais

- ✅ **Web Scraping** de perfis do GitHub (HTML + API GraphQL)
- ✅ **Encurtamento de URLs** para perfis do GitHub
- ✅ **API RESTful** com autenticação por token
- ✅ **Interface Web** para gerenciamento de perfis
- ✅ **Paginação** e busca de perfis
- ✅ **Testes automatizados** com RSpec

## 🚀 Acesso a aplicação (deploy): 
* https://scrap-840t.onrender.com/

Obs. As vezes a aplicação é encerrada, ao acessar a URL ele sobe o ambiente novamente.

<br>


# 📦 Instalação ambiente local (dev)

### 1. Clone o repositório

```bash
git clone https://github.com/GUIFRE88/scrap.git
cd scrap
```

### 2. Configure variáveis de ambiente

Crie um arquivo `.env` na raiz do projeto:

```bash
cp .env.example .env
```

Edite o arquivo `.env` e adicione seu token do GitHub:

```env
API_TOKEN=seu_token_github_aqui
```

**Como obter um token do GitHub:**
1. Acesse: https://github.com/settings/tokens
2. Clique em "Generate new token (classic)"
3. Selecione as permissões necessárias (pelo menos `public_repo` e `read:user`)
4. Copie o token e cole no arquivo `.env`

### 3. Configure o ambiente

#### Opção A: Usando Docker (Recomendado)

```bash
# Construir e iniciar os containers
make build
make start

# Ou usando docker-compose diretamente
docker-compose up --build
```

### 4. Abrir o bash para rodar as migrations


```bash
# Entra no bash
make bash

# Rode os 2 comandos
rails db:create
rails db:migrate
```

### 5. Rodar os teste no Rspec

```bash
make rspec
```

<br>



# 🏗️ Arquitetura e Design sobre o projeto

## 📐 Domain-Driven Design (DDD)

O projeto segue os princípios de **DDD** com separação clara de camadas:

### Camada de Domínio (`app/models/`, `app/services/`)

- **Entidades**: `Profile`, `User` - Representam conceitos do domínio
- **Services**: Encapsulam lógica de negócio complexa
  - `Profiles::Create` - Criação de perfis
  - `Profiles::Update` - Atualização de perfis
  - `Profiles::ScrapeAndUpdate` - Scraping e atualização
  - `Github::ProfileScraper` - Extração de dados do GitHub
  - `Github::ContributionsClient` - Consulta à API GraphQL
  - `Shortener::EncodeUrl` - Geração de URLs curtas

### Camada de Aplicação (`app/controllers/`)

- **Controllers**: Apenas orquestram, delegando para services
  - `ProfilesController` - Interface web
  - `Api::ProfilesController` - API RESTful
  - `Api::AuthController` - Autenticação da API

## 🧹 Clean Code

### Princípios Aplicados

1. **Nomes Expressivos**
   ```ruby
   # ✅ Bom
   Profiles::DashboardList.call(user: current_user, query: params[:q])
   
   # ❌ Ruim
   @profiles = current_user.profiles.search(@q).order(:created_at).paginate(...)
   ```

2. **Funções Pequenas e Focadas**
   - Cada service tem uma única responsabilidade
   - Métodos curtos e legíveis
   - Fácil de testar e manter

3. **Separação de Responsabilidades**
   ```
   Controller → Service → Repository → Model
   ```

4. **Código Auto-Explicativo**
   - Sem comentários desnecessários
   - Nomes que explicam a intenção
   - Estrutura clara e organizada

## 🔄 DRY (Don't Repeat Yourself)

### Estratégias de Reutilização

1. **Services Reutilizáveis**
   ```ruby
   # Lógica de paginação centralizada
   Api::Profiles::List.call(user: current_user, page: 1, per_page: 10)
   ```

2. **Concerns para Lógica Compartilhada**
   ```ruby
   # app/controllers/concerns/profile_responses.rb
   module ProfileResponses
     def handle_create_success(result)
       # Lógica reutilizável
     end
   end
   ```

3. **Repository Pattern**
   ```ruby
   # Abstração de acesso a dados
   ProfileRepository.new.user_profiles(user)
   ```

4. **Constantes para Valores Mágicos**
   ```ruby
   DEFAULT_PER_PAGE = 10
   MAX_PER_PAGE = 100
   ```

# 🔧 Técnicas Utilizadas

## Web Scraping

### Nokogiri (HTML Parsing)
- Extração de dados estáticos da página do GitHub
- Seletores CSS para encontrar elementos específicos
- WebScraping: Para realizar a busca dos valores na página do <b>GITHUB</b> utilizei a gem <b>nokogiri</b>, porém a informação de <b>contribuições</b> era carregada de maneira dinamica, portanto foi necessário fazer a consulta pe <b>API</b> do <b>GITHUB</b> para busca dessa informação, portanto para busca total das informações foi necessário utilizar esses 2 métodos.

Obs. É necessário criar o arquivo `.env` na raiz do projeto com o seguinte conteúdo:

### GitHub GraphQL API
- Consulta de contribuições (dados dinâmicos)
- Autenticação via Personal Access Token
- Tratamento de erros e fallbacks

## Encurtamento de URL

- Geração de códigos únicos (`short_code`)
- Redirecionamento para URL original do GitHub
- Armazenamento no banco de dados

## API RESTful

- **Autenticação**: Token-based (Bearer Token)
- **Serialização**: JBuilder para JSON
- **Paginação**: Will Paginate
- **Validação**: Parâmetros normalizados e validados

## Testes

- **RSpec**: Framework de testes
- **Factory Bot**: Criação de dados de teste
- **SimpleCov**: Cobertura de código (~99%)
- **Shoulda Matchers**: Testes de validações


# 🚀 Acesso da API: 

Rota da API: 

`http://localhost:3000/api/auth/login`

Body:
```
{
    "email": "teste@teste.com.br",
    "password": "123456"
  }
```

Retorno:
```
{
    "token": "82067b1261f58944a7ffa74b69e4dba439c2e5ca26cb7c4e4c674db5bfcb1525",
    "user": {
        "id": 100,
        "email": "teste@teste.com.br"
    }
}

```

<br>
Autenticação da API:

![alt text](https://github.com/GUIFRE88/scrap/blob/main/prints/api1.png)


Para a autenticação é feita de maneira manual, após a autenticação do usuário é retornado o token do usuário que o mesmo é utilizado para permitir o acesso da API. A API apresentará apenas usuários que foram cadastrados por ele.

Rora da API:

`http://localhost:3000/api/profiles?per_page=2`

<br>
Retorno:

```
{
    "data": [
        {
            "id": 128,
            "name": "dasdas",
            "github_username": "GUIFRE88",
            "short_github_url": "http://localhost:3000/p/LouyFk9u",
            "followers": 21,
            "following": 14,
            "stars": 4,
            "contributions_last_year": 1463,
            "avatar_url": "https://avatars.githubusercontent.com/u/36928790?s=64&v=4",
            "location": "Joinville/SC",
            "organizations": [
                "Euax"
            ]
        },
        {
            "id": 151,
            "name": "Guilherme",
            "github_username": "GUIFRE88",
            "short_github_url": "http://localhost:3000/p/Kl1D2ogg",
            "followers": 21,
            "following": 14,
            "stars": 4,
            "contributions_last_year": 1481,
            "avatar_url": "https://avatars.githubusercontent.com/u/36928790?s=64&v=4",
            "location": "Joinville/SC",
            "organizations": [
                "Euax"
            ]
        }
    ],
    "meta": {
        "current_page": 1,
        "per_page": 2,
        "total_pages": 1,
        "total_count": 2
    }
}
```

<br>
Exemplo:

![alt text](https://github.com/GUIFRE88/scrap/blob/main/prints/api2.png)

<br>


`http://localhost:3000/api/profiles/128`

<br>
Exemplo:

![alt text](https://github.com/GUIFRE88/scrap/blob/main/prints/api3.png)

<br>


Para serialização utilizei a <b>JBuilder</b>, pois é a gem que tenho mais contato e ela atendia bem a necessidade da API. 

Para paginação utilizei a gem <b>will_paginate</b>.


# 💻 Prints de telas:


<br>
Tela de login:

![alt text](https://github.com/GUIFRE88/scrap/blob/main/prints/tela_de_login.png)

<br>
Tela de cadastro:

![alt text](https://github.com/GUIFRE88/scrap/blob/main/prints/tela_de_cadastro.png)

<br>
Tela inicial:

![alt text](https://github.com/GUIFRE88/scrap/blob/main/prints/listagem.png)


<br>
Cadastro de perfil:

![alt text](https://github.com/GUIFRE88/scrap/blob/main/prints/cadastro_de_profile.png)


<br>
Perfil cadastrado:

![alt text](https://github.com/GUIFRE88/scrap/blob/main/prints/perfil.png)

<br>
CI do github:

![alt text](https://github.com/GUIFRE88/scrap/blob/main/prints/ci.png)

<br>
Testes do Rspec:

![alt text](https://github.com/GUIFRE88/scrap/blob/main/prints/rspec.png)


---

# 📝 Estrutura do Projeto

```
scrap/
├── app/
│   ├── controllers/        # Controllers (orquestração)
│   ├── models/             # Entidades do domínio
│   ├── services/           # Lógica de negócio (DDD)
│   ├── repositories/        # Acesso a dados
│   ├── views/              # Templates ERB e JBuilder
│   └── helpers/            # Helpers de view
├── config/                 # Configurações do Rails
├── db/                     # Migrations e schema
├── spec/                   # Testes RSpec
├── docker-compose.yml      # Configuração Docker
└── README.md               # Este arquivo
```

---

# 🔍 Pontos de Melhoria

## 1. Cache de Dados do GitHub
- **Problema**: Cada consulta faz scraping/API call
- **Solução**: Implementar cache (Redis) para reduzir chamadas externas
- **Benefício**: Melhor performance e menor uso de rate limits

## 2. Background Jobs
- **Problema**: Scraping bloqueia a requisição HTTP
- **Solução**: Mover scraping para background jobs (Sidekiq/ActiveJob)
- **Benefício**: Resposta mais rápida e melhor experiência do usuário

## 3. Rate Limiting
- **Problema**: Sem controle de rate limits da API do GitHub
- **Solução**: Implementar throttling e retry com backoff
- **Benefício**: Evitar bloqueios e melhorar confiabilidade

## 4. Tratamento de Erros Mais Robusto
- **Problema**: Alguns erros são genéricos
- **Solução**: Erros específicos e mensagens mais claras
- **Benefício**: Melhor debugging e experiência do usuário

---

# 📄 Licença

Este projeto está sob a licença MIT.

---

# 👤 Autor

**Guilherme Freudenburg**

- GitHub: [@GUIFRE88](https://github.com/GUIFRE88)

---






