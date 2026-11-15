# ==============================================================================
# PROJETO: Consultoria e Análises Ambientais em R
# SCRIPT: Curvas de Rarefação e Extrapolação com Números de Hill (iNEXT)
#
# BASE TEÓRICA E METODOLÓGICA:
#   - DA SILVA, F. R. et al. Análises ecológicas no R. Recife: Nupeea; 
#     São Paulo: Canal 6, 2022. Capítulo 10: Rarefação.
#   - CHAO, A. et al. Rarefaction and extrapolation with Hill numbers: a framework
#     for sampling and estimation in species diversity studies. 
#     Ecological Monographs, v. 84, n. 1, p. 45-67, 2014.
#   - HSIEH, T. C.; MA, K. H.; CHAO, A. iNEXT: an R package for rarefaction and 
#     extrapolation of species diversity (Hill numbers). 
#     Methods in Ecology and Evolution, v. 7, n. 12, p. 1451-1456, 2016.
#
# AUTOR: Lucas Aosf
# ==============================================================================

# 1. CARREGAMENTO SEGURO DE PACOTES -------------------------------------------
pacotes_necessarios <- c("iNEXT", "ggplot2", "readxl", "dplyr", "tidyr", "patchwork", "viridis")

for (p in pacotes_necessarios) {
  if (!requireNamespace(p, quietly = TRUE)) {
    install.packages(p, dependencies = TRUE)
  }
  library(p, character.only = TRUE)
}

# 2. FUNÇÃO DE ENTRADA E LIMPEZA DE DADOS -------------------------------------
carregar_dados_ecologicos <- function(caminho = NULL, sheet = 1) {
  if (is.null(caminho)) {
    message(">>> Selecione o arquivo de dados (.xlsx, .csv, .txt ou .tsv)...")
    caminho <- file.choose()
  }
  
  extensao <- tolower(tools::file_ext(caminho))
  
  if (extensao %in% c("xlsx", "xls")) {
    df <- as.data.frame(readxl::read_excel(caminho, sheet = sheet))
  } else if (extensao == "csv") {
    # Tenta detectar separador decimal e de coluna (BR vs US)
    df <- tryCatch(
      read.csv2(caminho, header = TRUE, stringsAsFactors = FALSE),
      error = function(e) read.csv(caminho, header = TRUE, stringsAsFactors = FALSE)
    )
    if (ncol(df) == 1) {
      df <- read.csv(caminho, header = TRUE, stringsAsFactors = FALSE)
    }
  } else {
    df <- read.table(caminho, header = TRUE, sep = "\t", stringsAsFactors = FALSE)
  }
  
  # Se a primeira coluna for identificação de espécies ou pontos, organiza:
  if (!is.numeric(df[, 1])) {
    nomes_linhas <- df[, 1]
    matriz <- df[, -1, drop = FALSE]
    rownames(matriz) <- make.unique(as.character(nomes_linhas))
  } else {
    matriz <- df
  }
  
  # Converte valores para numérico e substitui NAs por 0 (ausência de registro)
  matriz[] <- lapply(matriz, function(col) {
    val <- suppressWarnings(as.numeric(col))
    val[is.na(val)] <- 0
    return(val)
  })
  
  return(as.data.frame(matriz))
}

# 3. CARREGAMENTO DOS DADOS DO USUÁRIO ----------------------------------------
# NOTA: Altere 'caminho_arquivo' para o arquivo da sua amostragem
# Se deixar NULL, uma janela de seleção interativa será aberta.
caminho_arquivo <- NULL 

if (interactive() && is.null(caminho_arquivo)) {
  dados_comunidade <- carregar_dados_ecologicos(caminho = NULL)
} else if (!is.null(caminho_arquivo) && file.exists(caminho_arquivo)) {
  dados_comunidade <- carregar_dados_ecologicos(caminho_arquivo)
} else {
  message(">>> Usando dados ecológicos de demonstração do pacote iNEXT (spider)...")
  data(spider)
  dados_comunidade <- spider
}

cat("Estrutura da matriz ecológica carregada:\n")
cat(sprintf(" - Número de táxons (linhas): %d\n", nrow(dados_comunidade)))
cat(sprintf(" - Unidades amostrais/pontos (colunas): %d\n", ncol(dados_comunidade)))
print(head(dados_comunidade))

# 4. ANÁLISE DE RAREFAÇÃO E EXTRAPOLAÇÃO COM NÚMEROS DE HILL -------------------
# Conforme Silva et al. (2022, Cap. 10):
# q = 0: Riqueza de espécies (pondera igualmente todas as espécies)
# q = 1: Diversidade de Shannon (exponencial de H', pondera abundâncias típicas)
# q = 2: Diversidade de Simpson (inverso de D, pondera espécies dominantes)

message(">>> Executando análise iNEXT com 50 boots para intervalos de confiança...")
resultado_inext <- iNEXT(
  x = dados_comunidade,
  q = c(0, 1, 2),            # Todos os números de Hill fundamentais
  datatype = "abundance",    # Dados de contagem/abundância
  endpoint = NULL,           # Extrapolação padronizada até 2x o tamanho amostral
  knots = 40,
  nboot = 50                 # Número de bootstraps (50 para teste rápido, 200+ para laudo final)
)

# 5. TABELA DE ESTIMATIVAS ASSINTÓTICAS DE DIVERSIDADE ------------------------
cat("\n=== ESTIMATIVAS ASSINTÓTICAS DE DIVERSIDADE (Asymptotic Estimates) ===\n")
estimativas_assintoticas <- resultado_inext$AsyEst
print(estimativas_assintoticas)

# Exporta a tabela formatada para uso direto no laudo técnico
write.csv(
  estimativas_assintoticas, 
  file = "Tabela_Estimativas_Assintoticas_iNEXT.csv", 
  row.names = FALSE
)
message(">>> Tabela salva em: Tabela_Estimativas_Assintoticas_iNEXT.csv")

# 6. GERAÇÃO DOS 3 TIPOS DE GRÁFICOS METODOLÓGICOS (SILVA ET AL. 2022) ---------

# TIPO 1: Curva de Rarefação e Extrapolação baseada em Indivíduos (Tamanho vs Diversidade)
grafico_tipo1 <- ggiNEXT(resultado_inext, type = 1, facet.var = "Order.q") +
  scale_linetype_discrete(labels = c("Interpolado (Rarefação)", "Extrapolado")) +
  scale_colour_viridis_d(option = "viridis", end = 0.85) +
  scale_fill_viridis_d(option = "viridis", end = 0.85) +
  labs(
    title = "Rarefação e Extrapolação Baseada em Indivíduos",
    subtitle = "Série de Números de Hill (q=0: Riqueza, q=1: Shannon, q=2: Simpson)",
    x = "Número de Indivíduos Amostrados",
    y = "Diversidade de Espécies",
    colour = "Ponto / Área",
    fill = "Ponto / Área",
    linetype = "Método"
  ) +
  theme_bw(base_size = 12) +
  theme(
    legend.position = "bottom",
    plot.title = element_text(face = "bold", size = 14),
    strip.background = element_rect(fill = "gray95"),
    strip.text = element_text(face = "bold")
  )

# TIPO 2: Curva de Cobertura Amostral (Sample Completeness)
# Mostra a proporção da comunidade total representada pela amostra
grafico_tipo2 <- ggiNEXT(resultado_inext, type = 2) +
  scale_linetype_discrete(labels = c("Interpolado", "Extrapolado")) +
  scale_colour_viridis_d(option = "viridis", end = 0.85) +
  scale_fill_viridis_d(option = "viridis", end = 0.85) +
  geom_hline(yintercept = 0.90, linetype = "dashed", color = "firebrick", alpha = 0.7) +
  annotate("text", x = 1, y = 0.92, label = "Assíntota de 90% (Suficiência Amostral)", 
           hjust = 0, size = 3.5, color = "firebrick") +
  labs(
    title = "Completude Amostral (Sample Coverage)",
    subtitle = "Avaliação da suficiência do esforço de campo em consultoria ambiental",
    x = "Número de Indivíduos Amostrados",
    y = "Cobertura da Amostra (Chat)",
    colour = "Ponto / Área",
    fill = "Ponto / Área",
    linetype = "Método"
  ) +
  theme_bw(base_size = 12) +
  theme(legend.position = "bottom", plot.title = element_text(face = "bold", size = 14))

# TIPO 3: Curva de Rarefação baseada em Cobertura Amostral
# Permite comparar áreas em um mesmo nível de cobertura sem viés de esforço
grafico_tipo3 <- ggiNEXT(resultado_inext, type = 3, facet.var = "Order.q") +
  scale_linetype_discrete(labels = c("Interpolado", "Extrapolado")) +
  scale_colour_viridis_d(option = "viridis", end = 0.85) +
  scale_fill_viridis_d(option = "viridis", end = 0.85) +
  labs(
    title = "Rarefação Baseada na Cobertura Amostral",
    subtitle = "Padronização pela representatividade da comunidade (Silva et al. 2022)",
    x = "Cobertura da Amostra (Sample Coverage)",
    y = "Diversidade de Espécies",
    colour = "Ponto / Área",
    fill = "Ponto / Área",
    linetype = "Método"
  ) +
  theme_bw(base_size = 12) +
  theme(
    legend.position = "bottom",
    plot.title = element_text(face = "bold", size = 14),
    strip.background = element_rect(fill = "gray95"),
    strip.text = element_text(face = "bold")
  )

# Exibe os gráficos
print(grafico_tipo1)
print(grafico_tipo2)
print(grafico_tipo3)

# 7. EXPORTAÇÃO DOS GRÁFICOS EM ALTA RESOLUÇÃO (300 DPI) -----------------------
ggsave("Grafico_Rarefacao_Extrapolacao_Tipo1.png", grafico_tipo1, width = 10, height = 6, dpi = 300)
ggsave("Grafico_Cobertura_Amostral_Tipo2.png", grafico_tipo2, width = 8, height = 5, dpi = 300)
ggsave("Grafico_Rarefacao_Cobertura_Tipo3.png", grafico_tipo3, width = 10, height = 6, dpi = 300)

message(">>> Gráficos em alta resolução (300 DPI) salvos com sucesso na pasta de trabalho!")

# ==============================================================================
# FIM DO SCRIPT
# ==============================================================================
