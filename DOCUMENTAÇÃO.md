# 📘 Documentação do Sistema de Automação de Projetos Topográficos

## 👋 Introdução

Este sistema foi criado para **automatizar a coleta, filtragem e organização de projetos topográficos**, com dados originalmente gerenciados na plataforma Asana. A ideia é permitir que mesmo quem não tem conhecimento técnico consiga rodar e manter o sistema de forma simples e confiável.

---

## 🧠 Visão Geral

O sistema é composto por:

- Programas executáveis (`.exe`) que processam os dados.
- Scripts usados no Power BI para carregar e transformar as informações.
- Integração com o **Agendador de Tarefas do Windows**, permitindo **execuções automáticas**.
- Sincronização com o **Power BI Service** através do servidor de nuvem local,  que atualiza os dashboards na nuvem.

---

## 🔧 Componentes e Funções

### 🔹 1. `Asana.exe` (baseado no `Asana.py`)

- **Função principal:**  
  Atua como um **orquestrador de automações**.

- **O que ele faz?**
  - Não coleta nem processa dados diretamente.
  - Executa outros scripts automaticamente (por enquanto, apenas `GEO-INCRA.exe`).
  - Foi feito pensando na **expansão futura**, onde novos projetos terão seus próprios scripts.

- **Uso típico:**  
  É agendado no **Agendador de Tarefas do Windows** para rodar em horários específicos, sem intervenção humana.

---

### 🔹 2. `GEO-INCRA.exe` (baseado no `GEO-INCRA.py`)

- **Função principal:**  
  Extrai e organiza tarefas específicas do projeto "GEO-INCRA" no Asana.

- **O que ele faz?**
  - Acessa os dados do Asana.
  - Filtra apenas as tarefas relevantes do projeto GEO-INCRA.
  - Gera uma **planilha estruturada** com essas informações.

- **Objetivo:**  
  Fornecer uma base de dados limpa e organizada para uso em relatórios no Power BI.

---

## 📊 Parte Power BI (scripts `.m`)

### 🔸 3. `GEO.m`

- **Função:**  
  Carrega a planilha gerada por `GEO-INCRA.exe`.

- **Detalhes:**
  - Não realiza transformações complexas.
  - Serve como **fonte bruta de dados**.

---

### 🔸 4. `ProjetosTopografia.m`

- **Função:**  
  Realiza todas as **transformações, limpezas e junções** dos dados.

- **Por que ele é importante?**
  - Está preparado para **receber dados de diversos tipos de projeto**, além de GEO-INCRA.
  - Centraliza toda a lógica de tratamento e organização para os relatórios do Power BI.

---

## ▶️ Como usar o sistema

### 🔹 Executando Manualmente (modo local)

1. **Execute o programa `GEO-INCRA.exe`**
   - Ele acessa o Asana, filtra os dados e salva uma planilha com as tarefas GEO-INCRA.

2. **Abra o Power BI Desktop**
   - O script `GEO.m` carrega a planilha.
   - O script `ProjetosTopografia.m` trata e exibe os dados.

3. **Clique em “Atualizar” no Power BI**
   - Você verá os dados atualizados com base nas tarefas do Asana.

---

### 🔹 Executando Automaticamente (modo agendado)

#### ✅ Agendamento no Windows

1. **O `Asana.exe` é agendado no Agendador de Tarefas do Windows**
   - Ele roda diáriamente  às 06:55, 08:55, 11:25, 13:25, 15:25, 16:25, 17:55 e 23:55.
   - Ele chama internamente o `GEO-INCRA.exe` (e, futuramente, outros scripts).
   - Isso garante que a planilha esteja sempre atualizada com os dados mais recentes.

#### ☁️ Atualização via Power BI Service

2. **O Power BI Service (na nuvem) está configurado para atualizar os relatórios**
   - A atualização é feita **5 minutos após o agendamento do Asana.exe no Windows**.
   - Exemplo:
     - Se o Asana.exe roda às 06:55 → Power BI inicia a atualização às 07:00.
     - Isso garante que o Power BI pegue a planilha **já atualizada**.

**Importante!** Para que o Power BI Service atualize as planilhas no computador é preciso que o servidor `On-premises data gateway (personal mode)` esteja aberto e logado na conta do Power BI, para saber qual conta utilizar verifique a planilha `REDE-LOGIN.xlsx`

---

## 🧩 Fluxo de Trabalho Resumido

Agendador do Windows ↓ Executa Asana.exe ↓ Executa GEO-INCRA.exe ↓ Atualiza planilha com dados filtrados do Asana ↓ Power BI Service atualiza relatório (com 5 min de atraso)

## 🔮 Pensado para o Futuro

- O sistema foi criado com **expansibilidade em mente**.
- No futuro, outros scripts como `CAR.exe`, `USUCAPIAO.exe` poderão ser adicionados.
- O `Asana.exe` continuará sendo o ponto central, chamando cada script automaticamente.
- O Power BI Service continuará funcionando normalmente com as novas fontes de dados.

---


## ✅ Vantagens

- **Automatização completa** sem necessidade de interação manual.
- **Arquitetura modular** por tipo de projeto.
- **Fácil manutenção** e escalável.
- **Amigável para usuários não técnicos.**
- **Atualizações em nuvem (Power BI Service)** sincronizadas com os scripts locais.

---


## 📎 Resumo dos Arquivos

| Arquivo                 | Tipo         | Função                                                                 |
|------------------------|--------------|------------------------------------------------------------------------|
| `Asana.exe`            | Executável   | Orquestrador geral (usado com agendador do Windows)                   |
| `GEO-INCRA.exe`        | Executável   | Extrai dados filtrados do Asana (projetos GEO-INCRA)                  |
| `GEO.m`                | Power Query  | Carrega planilha de GEO-INCRA para o Power BI                         |
| `ProjetosTopografia.m` | Power Query  | Junta e transforma os dados de todos os projetos                      |