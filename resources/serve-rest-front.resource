*** Settings ***
Library     Browser
...         enable_presenter_mode=${True}   
#função que ativa o Record seletor se não encontrar o elemento apenas localmente qundo subir coloca false
Library     FakerLibrary
Library     String
Library     DateTime

*** Variable ***
${BROWSER}            chromium
${HEADLESS}           ${false}
${SITE_SERVE_REST}    https://front.serverest.dev/ 

*** Keywords ***
Abrir o navegador
    New Browser    browser=${BROWSER}
    ...            headless=${HEADLESS}

    ${TRACE_NAME}    FakerLibrary.Uuid 4                #faker de identificacao unico
    ${NOW}           Get Current Date  result_format=%d-%m-%Y_%H%M%S
    New Context      viewport={'width': 1200, 'height': 800}
    # historico de execução do teste  visualizar em trace.playwright.dev
    # ...              tracing=${OUTPUT_DIR}/resources/Evidencias/traces/${NOW}/${TRACE_NAME}.zip    
    # ...              recordVideo={'dir':'${EXECDIR}${/}resources\\Evidencias\\videos\\${NOW}'}                     

Ir para o site Serve Rest Front
    New Page       url=${SITE_SERVE_REST}

    ## Conferindo o título da página
    ${title}       Get Title  ==  Front - ServeRest

Preencher os dados do novo usuário e cadastrar
    Click    css=.btn-link
    # Click    text="Cadastre-se"

    ${EMAIL}       FakerLibrary.Email
    Set Suite Variable    ${EMAIL}      

    Click             css=\#nome
    Fill Text         css=input[data-testid='nome']        Augusto Oliveira
    Click             css=\#email    
    Fill Text         css=input[data-testid='email']       ${EMAIL}       
    Click             css=\#password
    Fill Text         css=input[data-testid='password']    123456    
    Check Checkbox    css=input[data-testid='checkbox']
    Click             css=button[data-testid='cadastrar']
    ## Seletor em cascata
    # Click    xpath=//*[@id="root"]//button >> text="Cadastrar"

## Conferências de elementos
Conferir usuário cadastrado com sucesso
    Wait For Elements State    h1    visible
    Get Text                   h1  ==  Bem Vindo Augusto Oliveira

    Get Element States         css=button[data-testid='logout']  validate  value & visible
    #Record Selector

Cadastrar novo usuário
    Abrir o navegador
    Ir para o site Serve Rest Front
    Preencher os dados do novo usuário e cadastrar
    Conferir usuário cadastrado com sucesso

Acessar a lista de usuários
    Click             css=a[data-testid='listarUsuarios']

Conferir se o usuário aparece na lista de usuários
    ${elemento}  Get Table Cell Element    css=table    "Nome"    "${EMAIL}"
    ${nome}      Get Text     ${elemento}  ==  Augusto Oliveira
    Highlight Elements    ${elemento}
    Take Screenshot

Cadastrar um novo produto
    Acessar a tela de cadatro de Produtos
    Preencher os dados do novo produto

Acessar a tela de cadatro de Produtos
    Click             css=a[data-testid='cadastrarProdutos']

Preencher os dados do novo produto
    ${produto}         FakerLibrary.City
    Set Suite Variable    ${produto}    
    ${preço_prod}=    Evaluate    str(random.randint(10, 9999))
    Set Suite Variable     ${preço_prod}
    ${quant_prod}=    Evaluate    str(random.randint(100, 999))
    Set Suite Variable     ${quant_prod}
    
    Click             css=\#nome
    Fill Text         css=input[data-testid='nome']         ${produto}
    Click             css=\#price
    Fill Text         css=input[data-testid='preco']        ${preço_prod}
    Click             css=\#description
    Fill Text         css=textarea[data-testid='descricao']    Texto criado para o produto ${produto}
    Click             css=\#quantity
    Fill Text         css=input[data-testid='quantity']     ${quant_prod} 
    Take Screenshot    ${EXECDIR}${/}resources\\Evidencias\\${produto}.png
    Upload File By Selector       css=input[data-testid='imagem']    ${EXECDIR}${/}resources\\Evidencias\\${produto}.png 
    #Record Selector
    Click             css=.btn-primary    
        
Conferir que o produto aparece na "Lista de Produtos"
    #Acessar a lista de produtos   #ao cadastrar já é direcionado par a tela de Lista dos produtos
    Conferir que o produto aparece na listagem

# Acessar a lista de produtos
#     Click             css=a[data-testid='listarProdutos']    

Conferir que o produto aparece na listagem
    ${elemento}  Get Table Cell Element    css=table    "Nome"    "${produto}"
    ${nome}      Get Text     ${elemento}  ==  ${produto}
    Highlight Elements    ${elemento}
    Take Screenshot       fullPage=${true}

# REQUISIÇÃO VIA HTTP
Criar usuário via API
    ${EMAIL}       FakerLibrary.Email
    Set Suite Variable      ${EMAIL}    
    ${resposta}    Http    url=https://serverest.dev/usuarios
    ...            method=POST
    ...            body={"nome": "Augusto Oliveira","email": "${EMAIL}","password": "123456","administrador": "true"}
    Should Be Equal As Integers    ${resposta["status"]}    201

Logar com o usuário cadastrado via API
    ${resposta}    Http    url=https://serverest.dev/login
    ...            method=POST
    ...            body={"email": "${EMAIL}","password": "123456"}
    Should Be Equal As Integers    ${resposta["status"]}    200

#Local Storage
    LocalStorage Set Item    serverest/userEmail    ${EMAIL}
    LocalStorage Set Item    serverest/userToken    ${resposta["body"]["authorization"]}
    LocalStorage Set Item    serverest/userNome     Augusto Oliveira
    
    Go To    url=https://front.serverest.dev/admin/home
    Take Screenshot

Cadastrar Usuário e Logar
    New Browser
    New Page       url=${SITE_SERVE_REST}
    Criar usuário via API
    Logar com o usuário cadastrado via API
    ${STORAGE_FILE}      Save Storage State        #salvando os dados de acesso em json criado
    Set Suite Variable   ${STORAGE_FILE}     

Abrir o site Serve Rest Front logado
    New Browser    browser=${BROWSER}
    ...            headless=${HEADLESS}
    New Context      viewport={'width': 1200, 'height': 800}
    ...              storageState=${STORAGE_FILE}
    New Page         url=https://front.serverest.dev/admin/home
    Get Text         h1  ==  Bem Vindo Augusto Oliveira
    Take Screenshot

    


    


