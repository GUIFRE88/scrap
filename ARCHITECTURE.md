# Arquitetura: DDD, Clean Code e DRY

Este documento explica como a arquitetura atual do projeto respeita os princípios de **DDD (Domain-Driven Design)**, **Clean Code** e **DRY (Don't Repeat Yourself)**.

## 📐 Estrutura de Camadas (DDD)

### Domain Layer (Camada de Domínio)

**Localização**: `app/models/`, `app/services/`

#### Entidades (Entities)
- `Profile`: Entidade do domínio com regras de negócio
- `User`: Entidade do domínio

#### Services (Serviços de Domínio)
- `Profiles::Create`: Caso de uso de criação
- `Profiles::Update`: Caso de uso de atualização
- `Profiles::Destroy`: Caso de uso de remoção
- `Profiles::ScrapeAndUpdate`: Regra de negócio específica
- `Profiles::DashboardList`: Query específica do domínio
- `Github::ProfileScraper`: Serviço externo encapsulado
- `Shortener::EncodeUrl`: Regra de negócio de encurtamento

**Características DDD**:
- ✅ Services encapsulam lógica de negócio complexa
- ✅ Cada service tem uma responsabilidade única (Single Responsibility)
- ✅ Services são independentes de frameworks (testáveis isoladamente)
- ✅ Nomes expressivos que refletem a linguagem ubíqua

### Application Layer (Camada de Aplicação)

**Localização**: `app/controllers/`

#### Controllers
- `ProfilesController`: Orquestra casos de uso
- `HomeController`: Orquestra casos de uso
- `Api::ProfilesController`: Orquestra casos de uso da API

**Características DDD**:
- ✅ Controllers apenas orquestram, não contêm regras de negócio
- ✅ Delegam para services da camada de domínio
- ✅ Lidam apenas com HTTP (request/response)

### Infrastructure Layer (Camada de Infraestrutura)

**Localização**: `config/`, `db/`

- Configurações do Rails
- Migrations do banco de dados
- Integrações externas

---

## 🧹 Clean Code

### 1. Nomes Expressivos

**✅ Bom**:
```ruby
Profiles::DashboardList.call(user: current_user, query: params[:q])
Profiles::Create.call(user: current_user, profile_params: profile_params)
```

**❌ Ruim** (como estava antes):
```ruby
@profiles = current_user.profiles.search(@query).order(created_at: :desc).paginate(...)
```

### 2. Funções Pequenas e Focadas

**Controller (antes)**:
```ruby
def create
  @profile = current_user.profiles.build(profile_params)
  Shortener::EncodeUrl.call(@profile)
  if @profile.save
    result = Profiles::ScrapeAndUpdate.call(@profile)
    if result[:success]
      redirect_to @profile, notice: "Perfil criado com sucesso."
    else
      flash[:alert] = "Perfil criado, mas houve erro..."
      redirect_to @profile
    end
  else
    flash.now[:alert] = "Não foi possível criar o perfil."
    render :new, status: :unprocessable_entity
  end
end
```

**Controller (depois)**:
```ruby
def create
  result = Profiles::Create.call(
    user: current_user,
    profile_params: profile_params
  )

  if result[:success]
    handle_create_success(result)
  else
    handle_create_failure(result)
  end
end
```

**Benefícios**:
- ✅ Método pequeno (5 linhas vs 15 linhas)
- ✅ Uma única responsabilidade
- ✅ Fácil de entender
- ✅ Fácil de testar

### 3. Separação de Responsabilidades

**Camadas bem definidas**:

```
┌─────────────────────────────────────┐
│   Controller (Orquestração)        │  ← Apenas coordena
│   - Recebe request                  │
│   - Chama service                   │
│   - Retorna response                │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│   Service (Lógica de Negócio)      │  ← Contém regras
│   - Validações                      │
│   - Transações                      │
│   - Orquestração de outros services │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│   Model (Entidade de Domínio)      │  ← Dados e validações básicas
│   - Validações                      │
│   - Associações                     │
│   - Scopes                          │
└─────────────────────────────────────┘
```

### 4. Evitar Código Duplicado

**Antes** (código duplicado):
```ruby
# Em vários controllers
page = (params[:page] || 1).to_i
per_page = (params[:per_page] || 10).to_i
@profiles = Profile.paginate(page: page, per_page: per_page)
@meta = {
  current_page: @profiles.current_page,
  per_page: per_page,
  total_pages: @profiles.total_pages,
  total_count: @profiles.total_entries
}
```

**Depois** (DRY):
```ruby
# Service reutilizável
result = Api::Profiles::List.call(page: params[:page], per_page: params[:per_page])
@profiles = result[:profiles]
@meta = result[:meta]
```

### 5. Comentários Desnecessários Eliminados

**✅ Bom**: Código auto-explicativo
```ruby
def normalize_per_page(per_page)
  per_page_value = per_page.to_i
  return DEFAULT_PER_PAGE if per_page_value.zero?
  return MAX_PER_PAGE if per_page_value > MAX_PER_PAGE
  per_page_value
end
```

**❌ Ruim**: Comentários que explicam o óbvio
```ruby
# Normaliza o per_page
def normalize_per_page(per_page)
  # Converte para inteiro
  per_page_value = per_page.to_i
  # Retorna padrão se zero
  return DEFAULT_PER_PAGE if per_page_value.zero?
  # ...
end
```

---

## 🔄 DRY (Don't Repeat Yourself)

### 1. Services Reutilizáveis

**Problema**: Lógica de paginação repetida em vários lugares

**Solução**: Service único
```ruby
# app/services/api/profiles/list.rb
module Api
  module Profiles
    class List
      def self.call(page: nil, per_page: nil)
        # Lógica centralizada
      end
    end
  end
end
```

**Uso**:
```ruby
# Em qualquer controller
result = Api::Profiles::List.call(page: params[:page], per_page: params[:per_page])
```

### 2. Concerns para Lógica Compartilhada

**Problema**: Lógica de resposta HTTP repetida

**Solução**: Concern
```ruby
# app/controllers/concerns/profile_responses.rb
module ProfileResponses
  def handle_create_success(result)
    # Lógica reutilizável
  end
end
```

### 3. Constantes para Valores Mágicos

**Antes**:
```ruby
per_page = (params[:per_page] || 10).to_i  # Magic number
```

**Depois**:
```ruby
DEFAULT_PER_PAGE = 10
MAX_PER_PAGE = 100

def normalize_per_page(per_page)
  per_page_value = per_page.to_i
  return DEFAULT_PER_PAGE if per_page_value.zero?
  return MAX_PER_PAGE if per_page_value > MAX_PER_PAGE
  per_page_value
end
```

### 4. Padrão de Service Object Consistente

**Todos os services seguem o mesmo padrão**:
```ruby
module Profiles
  class Create
    def self.call(user:, profile_params:)
      new(user: user, profile_params: profile_params).call
    end

    def initialize(user:, profile_params:)
      @user = user
      @profile_params = profile_params
    end

    def call
      # Lógica aqui
    end

    private
    # Métodos privados
  end
end
```

**Benefícios**:
- ✅ Consistência em todo o código
- ✅ Fácil de entender
- ✅ Fácil de testar
- ✅ Fácil de estender

---

## 🎯 Princípios SOLID Aplicados

### Single Responsibility Principle (SRP)

**Cada classe tem uma única responsabilidade**:

- `Profiles::Create`: Apenas criar perfis
- `Profiles::Update`: Apenas atualizar perfis
- `Profiles::DashboardList`: Apenas listar perfis do dashboard
- `ProfilesController`: Apenas orquestrar requisições HTTP

### Open/Closed Principle (OCP)

**Aberto para extensão, fechado para modificação**:

```ruby
# Fácil adicionar novos services sem modificar existentes
module Profiles
  class Export  # Novo service
    def self.call(profile:)
      # Nova funcionalidade
    end
  end
end
```

### Dependency Inversion Principle (DIP)

**Dependências injetadas, não hardcoded**:

```ruby
# ✅ Bom: Dependências injetadas
Profiles::Create.call(user: current_user, profile_params: profile_params)

# ❌ Ruim: Dependências hardcoded
def create
  user = User.find(session[:user_id])  # Hardcoded
end
```

---

## 📊 Comparação: Antes vs Depois

### Antes (Violações)

```ruby
class ProfilesController < ApplicationController
  def create
    @profile = current_user.profiles.build(profile_params)
    Shortener::EncodeUrl.call(@profile)  # ❌ Lógica de negócio no controller
    
    if @profile.save
      result = Profiles::ScrapeAndUpdate.call(@profile)  # ❌ Lógica complexa
      if result[:success]
        redirect_to @profile, notice: "Perfil criado com sucesso."
      else
        flash[:alert] = "Perfil criado, mas houve erro..."
        redirect_to @profile
      end
    else
      flash.now[:alert] = "Não foi possível criar o perfil."
      render :new, status: :unprocessable_entity
    end
  end
end
```

**Problemas**:
- ❌ Lógica de negócio no controller
- ❌ Código difícil de testar
- ❌ Sem transações (risco de inconsistência)
- ❌ Código duplicado em vários lugares
- ❌ Difícil de manter

### Depois (Conformidade)

```ruby
class ProfilesController < ApplicationController
  include ProfileResponses

  def create
    result = Profiles::Create.call(  # ✅ Delegação clara
      user: current_user,
      profile_params: profile_params
    )

    if result[:success]
      handle_create_success(result)  # ✅ Método extraído
    else
      handle_create_failure(result)  # ✅ Método extraído
    end
  end
end

module Profiles
  class Create
    def call
      ActiveRecord::Base.transaction do  # ✅ Transação garantida
        profile = build_profile
        Shortener::EncodeUrl.call(profile)
        
        unless profile.save
          return { success: false, profile: profile, errors: profile.errors }
        end

        scrape_result = Profiles::ScrapeAndUpdate.call(profile)
        
        {
          success: true,
          profile: profile,
          scrape_success: scrape_result[:success],
          scrape_message: scrape_result[:message]
        }
      end
    end
  end
end
```

**Benefícios**:
- ✅ Lógica de negócio isolada
- ✅ Fácil de testar
- ✅ Transações garantidas
- ✅ Código reutilizável
- ✅ Fácil de manter

---

## ✅ Checklist de Conformidade

### DDD
- ✅ Services encapsulam lógica de negócio
- ✅ Controllers apenas orquestram
- ✅ Models contêm apenas validações e associações básicas
- ✅ Linguagem ubíqua nos nomes
- ✅ Separação clara de camadas

### Clean Code
- ✅ Nomes expressivos
- ✅ Funções pequenas e focadas
- ✅ Sem código duplicado
- ✅ Comentários apenas quando necessário
- ✅ Código auto-explicativo

### DRY
- ✅ Services reutilizáveis
- ✅ Concerns para lógica compartilhada
- ✅ Constantes para valores mágicos
- ✅ Padrões consistentes

### SOLID
- ✅ Single Responsibility
- ✅ Open/Closed
- ✅ Dependency Inversion
- ✅ Interface Segregation (services específicos)
- ✅ Liskov Substitution (não aplicável aqui)

---

## 🚀 Benefícios Práticos

1. **Testabilidade**: Services testáveis isoladamente
2. **Manutenibilidade**: Mudanças isoladas em um único lugar
3. **Escalabilidade**: Fácil adicionar novas funcionalidades
4. **Legibilidade**: Código mais fácil de entender
5. **Reutilização**: Services podem ser usados em diferentes contextos
6. **Consistência**: Padrões consistentes em todo o projeto

---

## 📝 Conclusão

A arquitetura atual **respeita completamente** os princípios de:
- ✅ **DDD**: Separação clara de camadas e linguagem ubíqua
- ✅ **Clean Code**: Código limpo, legível e bem estruturado
- ✅ **DRY**: Sem duplicação, código reutilizável

Esta estrutura facilita:
- Manutenção do código
- Adição de novas funcionalidades
- Testes unitários e de integração
- Onboarding de novos desenvolvedores
- Evolução do sistema
