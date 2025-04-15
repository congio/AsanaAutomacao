let
    TodosOsProjetos = Table.Combine({#"GEO-INCRA"}),

    // Extrai apenas os números da OS (sem "OS")
    ExtrairNúmeroOS = Table.AddColumn(
        TodosOsProjetos, 
        "Números", 
        each 
            let
                tagText = if [Tags] = null then "" else [Tags],
                splitTags = Text.Split(tagText, ","),
                trimmedTags = List.Transform(splitTags, Text.Trim),
                osEntries = List.Select(trimmedTags, each Text.Contains(_, "OS ", Comparer.OrdinalIgnoreCase)),
                firstOS = if List.Count(osEntries) > 0 then osEntries{0} else null,
                osNumber = if firstOS <> null then 
                    Text.Combine(
                        List.Select(
                            Text.ToList(firstOS),
                            each _ >= "0" and _ <= "9"
                        )
                    )
                    else null,
                finalResult = if osNumber = "" or osNumber = null then "Não Atribuído" else osNumber
            in
                finalResult,
        type text
    ),

    // Adiciona "OS " antes dos números
    FormatarNúmeroOS = Table.AddColumn(
        ExtrairNúmeroOS,
        "Número OS",
        each if [Números] = "Não Atribuído" 
             then "Não Atribuído" 
             else "OS " & [Números],
        type text
    ),

    // Extrai o valor da META
    ExtrairMeta = Table.AddColumn(
    FormatarNúmeroOS, 
    "Meta", 
    each 
        let
            tagText = if [Tags] = null then "" else [Tags],  
            splitTags = Text.Split(tagText, ","),           
            trimmedTags = List.Transform(splitTags, Text.Trim), 
            osEntries = List.Select(trimmedTags, each Text.Contains(_, "META", Comparer.OrdinalIgnoreCase)), 
            firstMeta = if List.Count(osEntries) > 0 then osEntries{0} else null,
            extractedText = if firstMeta <> null then 
                Text.Middle(firstMeta, Text.PositionOf(firstMeta, "META ") + 5, 7) 
                else null,
            monthPart = if extractedText <> null then Number.FromText(Text.Start(extractedText, 2)) else null,
            yearPart = if extractedText <> null then Number.FromText(Text.End(extractedText, 4)) else null,
            nextMonth = if monthPart = 12 then 1 else monthPart + 1,
            nextYear = if monthPart = 12 then yearPart + 1 else yearPart,
            firstOfNextMonth = if monthPart <> null and yearPart <> null then 
                #date(nextYear, nextMonth, 1) else null,
            lastDayOfMonth = if firstOfNextMonth <> null then 
                Date.AddDays(firstOfNextMonth, -1) else null
        in
            lastDayOfMonth,
    type date
    ),

    IncluirTagCliente = Table.AddColumn(ExtrairMeta, "Cliente", each 
        let
            nomeTarefa = [Tarefa],
            delimitador = {" [", " |", " | ", "|", "| ", " -", " - ", "-", "- ", "_"},
            
            // Procurar a posição de cada delimitador na string
            positions = List.Transform(delimitador, each Text.PositionOf(nomeTarefa, _)),
            
            // Filtrar as posições válidas (maiores ou iguais a 0)
            validPositions = List.Select(positions, each _ >= 0),
            
            // Se encontrarmos algum delimitador, pegamos a posição do primeiro delimitador
            firstDelimiterPosition = if List.Count(validPositions) > 0 then List.Min(validPositions) else null,
            
            // Se encontrarmos um delimitador, extraímos o nome antes dele, senão mantemos o nome completo
            result = if firstDelimiterPosition <> null then 
                        Text.Start(nomeTarefa, firstDelimiterPosition) 
                    else 
                        nomeTarefa
        in
            result
    ),

    // Adiciona uma cópia da coluna Tarefa e verifica o padrão
    AdicionarTarefaTratada = Table.AddColumn(
        IncluirTagCliente,
        "Tarefa Tratada",
        each 
            let 
                tarefa = [Tarefa]?,
                padroesCorretos = {
                    " | Imóvel:",
                    " | Lote n°",
                    " | Gleba n°",
                    " | Colônia",
                    " | Matrícula n°",
                    " | Município:"
                },
                contemErro = List.AnyTrue(
                    List.Transform(padroesCorretos, 
                        each Text.Contains(tarefa, Text.Replace(_, " |", ""), Comparer.OrdinalIgnoreCase) 
                        and not Text.Contains(tarefa, _, Comparer.OrdinalIgnoreCase)
                    )
                ),
                resultado = if tarefa <> null and contemErro then "Formato Inválido" else tarefa
            in
                resultado,
        type text
    ),

    // Lista de padrões corretos (sem "|")
    PadroesCorretos = {
        "Imóvel",
        "Lote",
        "Gleba",
        "Colônia",
        "Matrícula",
        "Município"
    },

    // Função para extrair o conteúdo após o padrão sem o prefixo
    ExtrairEntrePipes = (texto as nullable text, padrao as text) as nullable text =>
    let
        partes = if texto <> null then Text.Split(texto, "|") else {},
        valores = List.Select(partes, each Text.Contains(_, padrao, Comparer.OrdinalIgnoreCase)),
        resultado = if List.Count(valores) > 0 then 
            let
                valorComPrefixo = valores{0},
                valorLimpo = Text.Trim(Text.Replace(valorComPrefixo, padrao, ""))
            in
                valorLimpo
        else
            "Não Atribuído"
    in
        resultado,
        
    // Adicionar colunas para cada padrão correto
    AdicionarColunas = List.Accumulate(
        PadroesCorretos,
        AdicionarTarefaTratada,
        (tabela, padrao) => Table.AddColumn(
            tabela,
            padrao,
            each if [Tarefa Tratada] = "Formato Inválido" then "Formato Inválido" else ExtrairEntrePipes([Tarefa Tratada], padrao),
            type text
        )
    ),

    // Define os padrões de substituição para cada coluna
    Substituicoes = {
        {"Imóvel", {{": ", ""}}},
        {"Lote", {{": ", ""}, {"n° ", ""}, {"nº ", ""}}},
        {"Gleba", {{"  ", " "}, {"n° ", ""}, {"nº ", ""}}},
        {"Matrícula", {{": ", ""}, {"  ", ""}, {"n° ", ""}, {"nº ", ""}, {"n°", ""}}},
        {"Município", {{": ", ""}}}
    },

    // Aplica todas as substituições
    TabelaTransformada = List.Accumulate(
        Substituicoes,
        AdicionarColunas,
        (tabela, coluna) => 
            let
                nomeColuna = coluna{0},
                padroes = coluna{1},
                tabelaAtualizada = List.Accumulate(
                    padroes,
                    tabela,
                    (estado, padrao) => Table.ReplaceValue(
                        estado,
                        padrao{0},
                        padrao{1},
                        Replacer.ReplaceText,
                        {nomeColuna}
                    )
                )
            in
                tabelaAtualizada
    ),

    // Separa da coluna Município o nome do município e o estado cada um para a sua coluna
    CorrigirMunicipioEUF = Table.TransformColumns(
        Table.AddColumn(
            TabelaTransformada,
            "UF",
            each 
                let
                    texto = [Município],
                    partes = if texto = null or texto = "Formato Inválido" then {} else Text.Split(texto, "-"),
                    uf = if List.Count(partes) > 1 then Text.Upper(Text.Trim(partes{1})) else 
                        if texto = "Formato Inválido" then "Formato Inválido" else "Não Atribuído"
                in
                    uf,
            type text
        ),
        {
            {
                "Município", 
                each 
                    let 
                        partes = if _ = null or _ = "Formato Inválido" then {} else Text.Split(_, "-"),
                        cidade = if List.Count(partes) > 0 then Text.Trim(partes{0}) else _
                    in 
                        cidade,
                type text
            }
        }
    )
in
    CorrigirMunicipioEUF