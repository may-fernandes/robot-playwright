*** Settings ***
Resource          ../resources/serve-rest-front.resource
Suite Setup       Cadastrar Usuário e Logar
Suite Teardown    Close Browser  ALL

*** Test Cases ***
Cenario: Login com sucesso Serv Rest Front
    Abrir o navegador
    Ir para o site Serve Rest Front
    Preencher os dados do novo usuário e cadastrar
    Conferir usuário cadastrado com sucesso

Desafio: Conferir se o novo usuário está na "Lista de Usuários"
    #Cadastrar novo usuário        este fazia via front
    Abrir o site Serve Rest Front logado    
    Acessar a lista de usuários
    Conferir se o usuário aparece na lista de usuários

Desafio: Conferir se novo produto cadastrado está na "Lista de Produtos"
    #Cadastrar novo usuário        este fazia via front
    Abrir o site Serve Rest Front logado
    Cadastrar um novo produto
    Conferir que o produto aparece na "Lista de Produtos"

Exemplo utilizando requisições https
    Abrir o navegador
    Ir para o site Serve Rest Front
    Criar usuário via API
    Logar com o usuário cadastrado via API

Exemplo utilizando o Storage de Armazenamento no Contexto
    Abrir o site Serve Rest Front logado
    Acessar a lista de usuários

    

