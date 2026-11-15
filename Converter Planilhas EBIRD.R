# ==============================================================================
# PROJETO: Consultoria e Análises Ambientais em R
# SCRIPT: Pipeline Tidyverse para Dados do eBird e Estruturação de Matrizes Ecológicas
#
# BASE TEÓRICA E METODOLÓGICA:
#   - DA SILVA, F. R. et al. Análises ecológicas no R. Recife: Nupeea; 
#     São Paulo: Canal 6, 2022. Capítulo 5: Tidyverse e Manipulação de Dados.
#   - SULLIVAN, B. L. et al. The eBird: A citizen-based bird observation network 
#     in the biological sciences. Biological Conservation, v. 142, p. 2282-2292, 2009.
#   - WICKHAM, H. et al. Welcome to the Tidyverse. Journal of Open Source Software, 
#     v. 4, n. 43, p. 1686, 2019.
#
# AUTOR: Lucas Aosf
# ==============================================================================

# 1. CARREGAMENTO SEGURO DE PACOTES (TIDYVERSE & OPENXLSX) ---------------------
pacotes_necessarios <- c("dplyr", "tidyr", "readr", "stringr", "openxlsx")

for (p in pacotes_necessarios) {
  if (!requireNamespace(p, quietly = TRUE)) {
    install.packages(p, dependencies = TRUE)
  }
  library(p, character.only = TRUE)
}

# 2. FUNÇÃO PRINCIPAL DE CONVERSÃO E LIMPEZA ECOLÓGICA ------------------------
processar_planilha_ebird <- function(caminho_csv = NULL, diretorio_saida = NULL) {
  
  # Seleção interativa de arquivo se não for fornecido caminho
  if (is.null(caminho_csv)) {
    message(">>> Selecione o arquivo CSV exportado do eBird...")
    caminho_csv <- file.choose()
  }
  
  if (!file.exists(caminho_csv)) {
    stop("Arquivo CSV especificado não foi encontrado!")
  }
  
  message(sprintf(">>> Lendo planilha eBird: %s", basename(caminho_csv)))
  
  # Leitura flexível com detecção automática de delimitador
  dados_brutos <- suppressMessages(readr::read_csv(caminho_csv, guess_max = 5000))
  if (ncol(dados_brutos) <= 1) {
    dados_brutos <- suppressMessages(readr::read_delim(caminho_csv, delim = ";", guess_max = 5000))
  }
  
  # Normalização dos nomes das colunas
  nomes_cols <- tolower(names(dados_brutos))
  names(dados_brutos) <- gsub("[^a-z0-9_]", "_", nomes_cols)
  
  # Identificação das colunas-chave do eBird (taxonomia, contagem e localidade)
  col_especie <- grep("scientific_name|scientific|especie|species", names(dados_brutos), value = TRUE)[1]
  if (is.na(col_especie)) col_especie <- grep("common_name|nome_comum|taxon", names(dados_brutos), value = TRUE)[1]
  
  col_contagem <- grep("count|abundancia|total|number", names(dados_brutos), value = TRUE)[1]
  col_amostra  <- grep("submission_id|checklist_id|locality|location|protocol_id|ponto", names(dados_brutos), value = TRUE)[1]
  col_data     <- grep("date|data", names(dados_brutos), value = TRUE)[1]
  
  if (is.na(col_especie)) {
    stop("Não foi possível identificar a coluna de espécies/táxons na planilha!")
  }
  
  # Cria identificador da unidade amostral se não houver coluna direta
  if (is.na(col_amostra)) {
    dados_brutos$unidade_amostral <- if (!is.na(col_data)) {
      paste0("Amostra_", as.character(dados_brutos[[col_data]]))
    } else {
      "Campanha_Geral"
    }
    col_amostra <- "unidade_amostral"
  }
  
  # 3. LIMPEZA TAXONÔMICA E TRATAMENTO DE CONTAGENS ----------------------------
  dados_limpos <- dados_brutos %>%
    rename(
      Taxon = all_of(col_especie),
      Amostra = all_of(col_amostra)
    ) %>%
    mutate(
      # Limpa caracteres especiais, parênteses e espaços redundantes
      Taxon = stringr::str_trim(as.character(Taxon)),
      Taxon = stringr::str_replace_all(Taxon, "\\(.*?\\)", ""), # Remove parênteses e nomes em inglês
      Taxon = stringr::str_squish(Taxon),
      Amostra = stringr::str_trim(as.character(Amostra))
    ) %>%
    # Filtra registros indefinidos ou nulos
    filter(!is.na(Taxon), Taxon != "", !stringr::str_detect(Taxon, "(?i)sp\\.|slash|hybrid"))
  
  # Tratamento do campo de contagem (eBird frequentemente usa 'X' para presença sem contagem)
  if (!is.na(col_contagem)) {
    dados_limpos <- dados_limpos %>%
      rename(Contagem_Bruta = all_of(col_contagem)) %>%
      mutate(
        Contagem = case_when(
          is.na(Contagem_Bruta) ~ 1,
          as.character(Contagem_Bruta) %in% c("X", "x", "") ~ 1,
          TRUE ~ suppressWarnings(as.numeric(as.character(Contagem_Bruta)))
        ),
        Contagem = ifelse(is.na(Contagem) | Contagem <= 0, 1, Contagem)
      )
  } else {
    dados_limpos$Contagem <- 1
  }
  
  # 4. CRIAÇÃO DAS MATRIZES ECOLÓGICAS (SILVA ET AL. 2022) ---------------------
  
  # 4.1. Matriz de Abundância (Linhas = Amostras/Pontos, Colunas = Espécies)
  matriz_abundancia <- dados_limpos %>%
    group_by(Amostra, Taxon) %>%
    summarise(Abundancia = sum(Contagem), .groups = "drop") %>%
    pivot_wider(names_from = Taxon, values_from = Abundancia, values_fill = 0) %>%
    arrange(Amostra)
  
  # 4.2. Matriz Binária de Presença/Ausência (0/1 para Jaccard e Índices de Similaridade)
  matriz_binaria <- matriz_abundancia %>%
    mutate(across(-Amostra, ~ ifelse(. > 0, 1, 0)))
  
  # 4.3. Lista Taxonômica Consolidada com Frequência e Total de Registros
  total_amostras <- nrow(matriz_abundancia)
  resumo_taxonomico <- dados_limpos %>%
    group_by(Taxon) %>%
    summarise(
      Abundancia_Total = sum(Contagem),
      Amostras_Ocorrencia = n_distinct(Amostra),
      Frequencia_Ocorrencia_Pct = round((n_distinct(Amostra) / total_amostras) * 100, 2),
      .groups = "drop"
    ) %>%
    arrange(desc(Abundancia_Total))
  
  # 5. EXPORTAÇÃO ESTRUTURADA EM EXCEL (.XLSX) MULTI-ABAS ----------------------
  if (is.null(diretorio_saida)) {
    diretorio_saida <- dirname(caminho_csv)
  }
  
  nome_base <- tools::file_path_sans_ext(basename(caminho_csv))
  caminho_xlsx <- file.path(diretorio_saida, paste0(nome_base, "_Matriz_Ecologica.xlsx"))
  
  wb <- createWorkbook()
  
  # Estilo de cabeçalho profissional
  estilo_cabecalho <- createStyle(
    fontName = "Segoe UI", fontSize = 11, fontColour = "#FFFFFF",
    fgFill = "#2E7D32", textDecoration = "Bold", halign = "center"
  )
  
  # Adiciona as abas essenciais para o laudo ambiental
  addWorksheet(wb, "Matriz_Abundancia")
  writeData(wb, "Matriz_Abundancia", matriz_abundancia, headerStyle = estilo_cabecalho)
  setColWidths(wb, "Matriz_Abundancia", cols = 1:ncol(matriz_abundancia), widths = "auto")
  
  addWorksheet(wb, "Matriz_Presenca_Ausencia")
  writeData(wb, "Matriz_Presenca_Ausencia", matriz_binaria, headerStyle = estilo_cabecalho)
  setColWidths(wb, "Matriz_Presenca_Ausencia", cols = 1:ncol(matriz_binaria), widths = "auto")
  
  addWorksheet(wb, "Resumo_Taxonomico")
  writeData(wb, "Resumo_Taxonomico", resumo_taxonomico, headerStyle = estilo_cabecalho)
  setColWidths(wb, "Resumo_Taxonomico", cols = 1:ncol(resumo_taxonomico), widths = "auto")
  
  addWorksheet(wb, "Dados_Brutos_Limpos")
  writeData(wb, "Dados_Brutos_Limpos", dados_limpos, headerStyle = estilo_cabecalho)
  
  saveWorkbook(wb, caminho_xlsx, overwrite = TRUE)
  
  cat("\n==================================================================\n")
  cat(sprintf(" CONVERSÃO CONCLUÍDA COM SUCESSO!\n"))
  cat(sprintf(" - Total de Unidades Amostrais (Linhas): %d\n", nrow(matriz_abundancia)))
  cat(sprintf(" - Total de Táxons Identificados (Colunas): %d\n", ncol(matriz_abundancia) - 1))
  cat(sprintf(" - Arquivo Excel exportado: %s\n", caminho_xlsx))
  cat("==================================================================\n")
  
  return(invisible(list(abundancia = matriz_abundancia, binaria = matriz_binaria, resumo = resumo_taxonomico)))
}

# 6. EXECUÇÃO DEMONSTRATIVA OU INTERATIVA -------------------------------------
# Se executado diretamente no RStudio:
if (interactive()) {
  resultado <- processar_planilha_ebird()
} else {
  message(">>> Função 'processar_planilha_ebird(caminho_csv)' pronta para uso no pipeline!")
}

# ==============================================================================
# FIM DO SCRIPT
# ==============================================================================
