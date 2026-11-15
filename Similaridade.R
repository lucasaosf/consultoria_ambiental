# ==============================================================================
# PROJETO: Consultoria e Análises Ambientais em R
# SCRIPT: Ordenação Multidimensional Não-Métrica (NMDS) e Diagnóstico de Estresse
#
# BASE TEÓRICA E METODOLÓGICA:
#   - DA SILVA, F. R. et al. Análises ecológicas no R. Recife: Nupeea; 
#     São Paulo: Canal 6, 2022. Capítulo 9: Análises Multidimensionais (NMDS).
#   - CLARKE, K. R. Non-parametric multivariate analyses of changes in community 
#     structure. Australian Journal of Ecology, v. 18, n. 1, p. 117-143, 1993.
#   - LEGENDRE, P.; GALLAGHER, E. D. Ecologically meaningful transformations for 
#     ordination of species data. Oecologia, v. 129, p. 271-280, 2001.
#
# AUTOR: Lucas Aosf
# ==============================================================================

# 1. CARREGAMENTO SEGURO DE PACOTES -------------------------------------------
pacotes_necessarios <- c("vegan", "ggplot2", "readxl", "dplyr", "viridis", "ggrepel")

for (p in pacotes_necessarios) {
  if (!requireNamespace(p, quietly = TRUE)) {
    install.packages(p, dependencies = TRUE)
  }
  library(p, character.only = TRUE)
}

# 2. FUNÇÃO DE ENTRADA E TRATAMENTO DA MATRIZ ECOLÓGICA -----------------------
carregar_dados_nmds <- function(caminho = NULL, sheet = 1) {
  if (is.null(caminho)) {
    message(">>> Selecione o arquivo Excel (.xlsx) ou texto (.csv)...")
    caminho <- file.choose()
  }
  
  ext <- tolower(tools::file_ext(caminho))
  if (ext %in% c("xlsx", "xls")) {
    df <- as.data.frame(readxl::read_excel(caminho, sheet = sheet))
  } else if (ext == "csv") {
    df <- tryCatch(
      read.csv2(caminho, header = TRUE, stringsAsFactors = FALSE),
      error = function(e) read.csv(caminho, header = TRUE, stringsAsFactors = FALSE)
    )
    if (ncol(df) == 1) df <- read.csv(caminho, header = TRUE, stringsAsFactors = FALSE)
  } else {
    df <- read.table(caminho, header = TRUE, sep = "\t", stringsAsFactors = FALSE)
  }
  
  # A primeira coluna é tratada como identificador dos pontos / unidades amostrais
  grupos <- df[, 1]
  matriz_especies <- df[, -1, drop = FALSE]
  rownames(matriz_especies) <- make.unique(as.character(grupos))
  
  # Substitui NAs por 0 e converte para numérico
  matriz_especies[] <- lapply(matriz_especies, function(col) {
    v <- suppressWarnings(as.numeric(col))
    v[is.na(v)] <- 0
    return(v)
  })
  
  # Remove amostras completamente vazias (soma zero de espécies)
  soma_amostras <- rowSums(matriz_especies)
  if (any(soma_amostras == 0)) {
    message(sprintf("Aviso: %d amostra(s) sem nenhum registro foram removidas.", sum(soma_amostras == 0)))
    matriz_especies <- matriz_especies[soma_amostras > 0, , drop = FALSE]
    grupos <- grupos[soma_amostras > 0]
  }
  
  return(list(matriz = as.data.frame(matriz_especies), grupos = as.factor(grupos)))
}

# 3. CARREGAMENTO DOS DADOS DO USUÁRIO ----------------------------------------
caminho_arquivo <- NULL

if (interactive() && is.null(caminho_arquivo)) {
  dados <- carregar_dados_nmds()
  matriz_especies <- dados$matriz
  grupos_amostrais <- dados$grupos
} else if (!is.null(caminho_arquivo) && file.exists(caminho_arquivo)) {
  dados <- carregar_dados_nmds(caminho_arquivo)
  matriz_especies <- dados$matriz
  grupos_amostrais <- dados$grupos
} else {
  message(">>> Usando dados ecológicos de demonstração (dune e dune.env do pacote vegan)...")
  data(dune)
  data(dune.env)
  matriz_especies <- dune
  grupos_amostrais <- dune.env$Management
}

cat(sprintf("Comunidade carregada: %d unidades amostrais x %d espécies\n",
            nrow(matriz_especies), ncol(matriz_especies)))

# 4. EXECUÇÃO DO NMDS (SILVA ET AL. 2022 - CAPÍTULO 9) ------------------------
# NOTA METODOLÓGICA FUNDAMENTAL:
# Silva et al. (2022) alertam categoricamente: a distância euclidiana direta é 
# estatisticamente inadequada para matrizes brutas de espécies (problema das duplas ausências).
# Utiliza-se 'bray' (Bray-Curtis) para abundância ou 'jaccard' para presença/ausência.

set.seed(42) # Reprodutibilidade científica
message(">>> Executando NMDS iterativo com distância de Bray-Curtis (trymax = 100)...")

nmds_resultado <- metaMDS(
  comm = matriz_especies,
  distance = "bray",       # Bray-Curtis (padrão-ouro para abundância)
  k = 2,                  # 2 dimensões para visualização em plano cartesiano
  trymax = 100,           # Múltiplas reinicializações para evitar mínimos locais
  autotransform = FALSE   # Mantém os dados sem transformações automáticas não supervisionadas
)

# 5. DIAGNÓSTICO ESTATÍSTICO DE ESTRESSE (STRESS) -----------------------------
valor_stress <- nmds_resultado$stress

classificacao_stress <- if (valor_stress < 0.05) {
  "Excelente representação em 2D (praticamente sem distorção)"
} else if (valor_stress < 0.10) {
  "Boa ordenação (confiável para conclusões ecológicas)"
} else if (valor_stress < 0.20) {
  "Razoável / Aceitável (interpretar com atenção aos detalhes)"
} else {
  "Inadequado em 2 dimensões (recomenda-se rodar com k = 3)"
}

cat("\n=========================================================\n")
cat(sprintf(" VALOR DE STRESS DO NMDS: %.4f\n", valor_stress))
cat(sprintf(" CLASSIFICAÇÃO (Clarke 1993 / Silva et al. 2022): %s\n", classificacao_stress))
cat("=========================================================\n")

# Diagrama de Shepard (Avaliação de Monotonicidade das Distâncias)
png("NMDS_Shepard_Diagram_Stressplot.png", width = 1800, height = 1500, res = 300)
stressplot(nmds_resultado, 
           main = sprintf("Diagrama de Shepard (Stress = %.3f)", valor_stress),
           l.col = "firebrick")
dev.off()
message(">>> Diagrama de Shepard exportado: NMDS_Shepard_Diagram_Stressplot.png")

# 6. ESTRUTURAÇÃO DE DADOS PARA VISUALIZAÇÃO COM GGPLOT2 ----------------------
# Extrai coordenadas dos sítios/amostras
scores_sitios <- as.data.frame(scores(nmds_resultado, display = "sites"))
scores_sitios$Amostra <- rownames(scores_sitios)
scores_sitios$Grupo   <- grupos_amostrais

# Extrai centróides das espécies mais representativas (para não poluir o gráfico)
scores_especies <- as.data.frame(scores(nmds_resultado, display = "species"))
scores_especies$Especie <- rownames(scores_especies)

# Seleciona as espécies mais abundantes para rotulagem
abundancia_total <- colSums(matriz_especies)
top_especies <- names(sort(abundancia_total, decreasing = TRUE))[1:min(10, ncol(matriz_especies))]
scores_especies_top <- scores_especies[scores_especies$Especie %in% top_especies, ]

# 7. GRÁFICO DE PUBLICAÇÃO DO NMDS (PADRÃO CONSULTORIA AMBIENTAL) -------------
grafico_nmds <- ggplot(scores_sitios, aes(x = NMDS1, y = NMDS2, color = Grupo, fill = Grupo)) +
  # Elipses de dispersão com intervalo de confiança de 95%
  stat_ellipse(geom = "polygon", alpha = 0.15, level = 0.95, show.legend = FALSE) +
  # Pontos das unidades amostrais
  geom_point(size = 3.5, alpha = 0.9) +
  # Rótulos dos sítios
  geom_text_repel(aes(label = Amostra), size = 3, show.legend = FALSE, max.overlaps = 15) +
  # Centróides das espécies indicadoras / abundantes
  geom_point(data = scores_especies_top, aes(x = NMDS1, y = NMDS2), 
             shape = 3, color = "gray20", size = 2.5, inherit.aes = FALSE) +
  geom_text_repel(data = scores_especies_top, aes(x = NMDS1, y = NMDS2, label = Especie),
                  color = "gray20", fontface = "italic", size = 3, inherit.aes = FALSE) +
  # Linhas de referência no zero
  geom_vline(xintercept = 0, linetype = "dashed", color = "gray80") +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray80") +
  # Paleta acessível e estética
  scale_color_viridis_d(option = "turbo", end = 0.9) +
  scale_fill_viridis_d(option = "turbo", end = 0.9) +
  # Anotação técnica do estresse conforme Silva et al. (2022)
  annotate("label", x = Inf, y = -Inf, 
           label = sprintf("Stress 2D = %.3f\nDistância: Bray-Curtis", valor_stress),
           hjust = 1.05, vjust = -0.2, size = 3.5, fontface = "italic", fill = "white", alpha = 0.8) +
  labs(
    title = "Ordenação Ecológica por Escalonamento Multidimensional Não-Métrico (NMDS)",
    subtitle = "Composição de espécies da comunidade e elipses de confiança (95%)",
    x = "NMDS Eixo 1",
    y = "NMDS Eixo 2",
    color = "Fitofisionomia / Grupo",
    fill = "Fitofisionomia / Grupo"
  ) +
  theme_bw(base_size = 12) +
  theme(
    legend.position = "right",
    plot.title = element_text(face = "bold", size = 13),
    panel.grid.minor = element_blank()
  )

print(grafico_nmds)

# 8. EXPORTAÇÃO EM ALTA RESOLUÇÃO PARA LAUDOS E EIA/RIMA -----------------------
ggsave("NMDS_Ordenacao_Comunidade_300dpi.png", grafico_nmds, width = 9, height = 6.5, dpi = 300)
ggsave("NMDS_Ordenacao_Comunidade.pdf", grafico_nmds, width = 9, height = 6.5)

message(">>> Gráfico do NMDS exportado em PNG (300 DPI) e PDF vetorial para laudos técnicos!")

# ==============================================================================
# FIM DO SCRIPT
# ==============================================================================
