
---
<h1 align="center">
  🚀 SCRAP 🚀
</h1>
<br>


# 💻 Projeto

É uma ferramenta para Scraping de informações do GITHUB.

# 🚀 Subir ambiente desenvolvimento (local): 

# 🚀 Acesso a aplicação (deploy): 
* https://scrap-840t.onrender.com/

Obs. As vezes a aplicação é encerrada, ao acessar a URL ele sobe o ambiente novamente.

# 🚀 Pontuações técnicas sobre o projeto:

* WebScraping: Para realizar a busca dos valores na página do <b>GITHUB</b> utilizei a gem <b>nokogiri</b>, porém a informação
de <b>contribuições</b> era carregada de maneira dinamica, portanto foi necessário fazer a consulta pe <b>API</b> do <b>GITHUB</b> para busca dessa informação, portanto para busca total das informações foi necessário utilizar esses 2 métodos.

Obs. É necessário criar o arquivo `.env` na raiz do projeto com o seguinte conteúdo:

```
API_TOKEN=seu_token_github_aqui
```

Para obter um token do GitHub, acesse: https://github.com/settings/tokens

* Encurtamento de URL: Para realizar o encurtamento da url eu gero um <b>token</b> que será salvo no campo <b>short_code</b> da tabela <b>Profiles</b>, quando o endereço por exemplo: `http://localhost:3000/p/Kl1D2ogg` eu faço um redirect para a url real do <b>GITHUB</b>.

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









