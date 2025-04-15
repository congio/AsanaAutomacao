# Documentação do Script - Nome do Projeto no Asana

## Descrição Geral

Este script foi desenvolvido para interagir com a API do **Asana**, extrair informações sobre as tarefas de um projeto específico, processá-las e gerar um relatório em formato **Excel**. O script foi projetado para ser compilado como um executável (`.exe`), o que permite que ele seja executado em máquinas sem a necessidade de instalar o Python ou bibliotecas adicionais.

O script pode ser usado para **qualquer projeto do Asana**, desde que você configure corretamente as variáveis necessárias, como o **Token de Acesso do Asana** e o **ID do Projeto**.

---

## Pré-requisitos

Antes de executar o script, você precisa garantir que alguns itens estão configurados corretamente. Aqui está uma lista do que é necessário:

### 1. Dependências de Bibliotecas

O script utiliza as seguintes bibliotecas Python:

- **`altgraph`**
- **`asana`**
- **`certifi`**
- **`charset-normalizer`**
- **`contourpy`**
- **`cycler`**
- **`et_xmlfile`**
- **`fonttools`**
- **`idna`**
- **`kiwisolver`**
- **`matplotlib`**
- **`numpy`**
- **`openpyxl`**
- **`packaging`**
- **`pandas`**
- **`pefile`**
- **`pillow`**
- **`pyinstaller-hooks-contrib`**
- **`pyparsing`**
- **`python-dateutil`**
- **`python-dotenv`**
- **`pytz`**
- **`pywin32-ctypes`**
- **`requests`**
- **`schedule`**
- **`setuptools`**
- **`six`**
- **`tzdata`**
- **`urllib3`**

As bibliotecas podem ser instaladas através do `requeriments.txt` com o seguinte comando:

```bash
pip install -r requeriments.txt
```

### 2. Arquivo `.env`

O script depende de um arquivo `.env` para carregar variáveis de ambiente. Este arquivo deve conter as seguintes variáveis:

- **`ASANA_ACCESS_TOKEN`**: Token de acesso pessoal do Asana, necessário para autenticar a conexão com a API do Asana.
- **`GEO_GID`**: O **ID do Projeto** no Asana do qual as tarefas serão extraídas.

O arquivo `.env` deve estar no mesmo diretório onde o script é executado ou deve ser configurado para ser carregado corretamente.

---

## Como o Script Funciona

### Passo 1: Carregamento das Variáveis de Ambiente

O script começa carregando as variáveis de ambiente do arquivo `.env`, que contém as credenciais e parâmetros necessários para interagir com a API do Asana. As variáveis **`ASANA_ACCESS_TOKEN`** e **`GEO_GID`** são essenciais para que o script saiba qual projeto acessar e como autenticar a requisição.

### Passo 2: Definindo o Caminho do Arquivo `.env`

O script verifica se está sendo executado a partir de um **executável** (compilado com PyInstaller) ou diretamente a partir do código-fonte. Dependendo disso, ele define o caminho correto para localizar o arquivo `.env`:

- Se o script estiver rodando como **executável** (`.exe`), ele buscará o arquivo `.env` dentro do diretório temporário gerado pelo PyInstaller.
- Se estiver em ambiente de desenvolvimento, o script buscará o arquivo `.env` no mesmo diretório onde o código está localizado.

### Passo 3: Conexão com a API do Asana

Com as variáveis carregadas, o script utiliza o **token de acesso** para configurar a conexão com a API do Asana. Ele usa a biblioteca `asana` para autenticar e acessar os dados do projeto. A partir daí, o script começa a interagir com o Asana para extrair informações detalhadas sobre as tarefas.

### Passo 4: Extração de Dados das Tarefas

O script realiza uma consulta à API do Asana para obter informações detalhadas sobre as tarefas de um projeto específico, conforme o **ID do Projeto** (`GEO_GID`). Ele busca dados como:

- Nome da tarefa
- Status de conclusão (se está ou não concluída)
- Data de conclusão
- Responsável pela tarefa
- Data de criação
- Seção a qual a tarefa pertence
- Entre outros detalhes

### Passo 5: Organização das Informações

O script organiza as informações extraídas das tarefas em um formato estruturado usando o **Pandas DataFrame**. Para cada tarefa, ele armazena dados como:

- **Responsável** pela tarefa
- **Status** (Concluído ou Pendente)
- **Data de Conclusão**
- **Data de Criação**
- **Previsão de Conclusão**
- **Link** para a tarefa no Asana
- **Seção** da tarefa
- **Tags** atribuídas à tarefa
- **Situação** da tarefa, que é determinada com base na posição da seção em que a tarefa se encontra (por exemplo: "Em Execução", "A Realizar", "Finalizado", etc.).

A **Situação** da tarefa é um dos campos calculados com base na seção em que a tarefa está localizada, o que ajuda a categorizar o progresso da tarefa.

### Passo 6: Exportação para Excel

Após a organização dos dados, o script exporta as informações para um arquivo **Excel** (`.xlsx`). O arquivo é salvo no diretório especificado pelo caminho:

```bash
output_path = "//Servidor/dashboard/Fonte de dados interna/GEO-INCRA_tarefas.xlsx"
```

Esse arquivo pode ser aberto no Excel e contém um relatório detalhado de todas as tarefas do projeto no Asana, conforme os critérios definidos.

### Passo 7: Paginação (Se Necessário)
Caso haja muitas tarefas no projeto, a API do Asana pode retornar os resultados em várias "páginas". O script lida com a paginação automaticamente, garantindo que todas as tarefas sejam recuperadas, mesmo que o número de tarefas seja grande.

## Como Executar

### Ambiente de Desenvolvimento
Se você estiver executando o script diretamente (não como executável), siga as etapas abaixo:

1. **Instale as dependências necessárias. Você pode usar o pip para instalar as bibliotecas**:

```bash
pip install asana python-dotenv pandas openpyxl
```

Crie um arquivo `.env` no mesmo diretório que o script com as seguintes informações:

```bash
ASANA_ACCESS_TOKEN=seu_token_aqui
GEO_GID=id_do_projeto_aqui
```

Execute o script com Python:

python seu_script.py

### Como Executável
Se você compilou o script como um executável (`.exe`) usando o PyInstaller:

Coloque o executável na pasta desejada.

Garanta que o arquivo `.env` esteja no mesmo diretório do executável.

Execute o arquivo `.exe`.

Local do Relatório
O relatório será gerado no caminho especificado no código. Certifique-se de que o diretório de destino existe e que o script tem permissões de escrita nesse local.

### Tratamento de Erros
O script possui tratamento de erros para garantir que, caso algo dê errado, uma mensagem clara seja exibida. Existem dois tipos principais de erros tratados:

Erros da API do Asana: Caso a API do Asana retorne algum erro (por exemplo, token de acesso inválido), o script exibirá uma mensagem de erro específica.

Erros gerais: Qualquer outro erro inesperado (como problemas de rede ou permissão de escrita) será capturado e uma mensagem de erro genérica será exibida.

### Conclusão
Este script fornece uma maneira automatizada e eficiente de extrair informações detalhadas sobre tarefas de um projeto no Asana e gerar um relatório consolidado. Ele pode ser usado para qualquer projeto no Asana, bastando apenas alterar as variáveis de configuração. A flexibilidade e a facilidade de uso fazem deste script uma ferramenta útil para gerenciar e analisar o progresso das tarefas no Asana.

Essa documentação é bastante detalhada e explica claramente cada etapa do processo. Qualquer pessoa, mesmo sem experiência prévia, pode entender o fluxo do script e como utilizá-lo para o projeto no Asana.