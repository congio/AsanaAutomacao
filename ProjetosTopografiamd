# 📊 Documentação Completa do Código Power Query – Projetos Topografia

Este documento descreve passo a passo o funcionamento do script Power Query presente no arquivo `ProjetosTopografia.m`. O objetivo principal é consolidar, tratar e organizar os dados de diferentes projetos de topografia, estruturando informações úteis como número da OS, data da meta, cliente, informações do imóvel, matrícula, município e estado.

---

## 🔁 1. Combinação de Tabelas
```powerquery
TodosOsProjetos = Table.Combine({
    #"GEO-INCRA",
    #"UNIFICACAO",
    #"USUCAPICAO",
    #"ESTREMACAO"
})
```
Agrupa todas as tabelas relacionadas a projetos em uma única tabela chamada `TodosOsProjetos`, consolidando as linhas dos quatro conjuntos de dados.

---

## 🔢 2. Extração do Número da OS
Adiciona a coluna `Números`, que extrai o número da OS a partir da coluna `Tags`. O código:
- Separa as tags por vírgula;
- Filtra aquelas que contêm "OS ";
- Extrai apenas os números;
- Se não encontrar, retorna "Não Atribuído".

📌 **Exemplo**:
`Tags = "META 042025, OS 1234"` ⟶ `Números = 1234`

---

## 🆔 3. Formatação do Número da OS
Cria a coluna `Número OS`, prefixando o número encontrado com "OS ". Se não houver número, permanece "Não Atribuído".

📌 Exemplo:
`Números = 1234` ⟶ `Número OS = OS 1234`

---

## 📅 4. Extração da Data da Meta
A partir de `Tags`, procura por valores como `META 042025`, indicando mês e ano. Com isso, calcula o último dia do mês correspondente (ex: abril de 2025 ⟶ 30/04/2025).

📌 Exemplo:
`Tags = "META 042025"` ⟶ `Meta = 30/04/2025`

---

## 👤 5. Extração do Nome do Cliente
A partir da coluna `Tarefa`, extrai o nome do cliente até o primeiro delimitador (como " -", " |", etc.).

📌 Exemplo:
`Tarefa = "José Silva - Imóvel: Sítio Bela Vista"` ⟶ `Cliente = José Silva`

---

## 🔍 6. Verificação de Formato da Tarefa
Cria a coluna `Tarefa Tratada`, que avalia se os padrões obrigatórios como `| Imóvel:`, `| Matrícula n°`, etc. estão corretamente formatados. Caso contrário, define como `Formato Inválido`.

---

## 📊 7. Extração de Campos por Padrão
A partir da `Tarefa Tratada`, são extraídos os seguintes campos:
- `Imóvel`
- `Lote`
- `Gleba`
- `Colônia`
- `Matrícula`
- `Município`

O código divide o texto da tarefa em partes com base no caractere `|`, encontra o campo correspondente e remove o prefixo do padrão.

📌 Exemplo:
`Tarefa = "Cliente | Imóvel: Fazenda Bela Vista | Matrícula: 123456"`
- `Imóvel = Fazenda Bela Vista`
- `Matrícula = 123456`

---

## 🧹 8. Limpeza dos Campos
Aplica substituições nos campos extraídos:
- Remove `: `, `n° `, `nº `, etc.
- Elimina espaços desnecessários.

Exemplo:
`Matrícula = "nº 123456"` ⟶ `Matrícula = 123456`

---

## 🌍 9. Separação de Município e UF
A coluna `Município` pode conter dados como `Uberlândia - MG`. O código:
- Separa o nome da cidade e do estado (UF);
- Cria a nova coluna `UF` com a sigla do estado;
- Remove a UF da coluna `Município` original.

📌 Exemplo:
`Município = "Uberlândia - MG"` ⟶ `Município = Uberlândia`, `UF = MG`

---

## ✅ Resultado Final
Ao final do processo, temos uma tabela limpa e padronizada com colunas como:
- `Número OS`
- `Meta` (último dia do mês)
- `Cliente`
- `Imóvel`, `Lote`, `Gleba`, `Colônia`, `Matrícula`, `Município`, `UF`
- `Tarefa Tratada` (com ou sem formatação válida)

Essa estrutura facilita análises, cruzamento de dados e geração de relatórios confiáveis e claros.

