# ==============================================================================
# PROJETO: Consultoria e Análises Ambientais em R
# SCRIPT: Estimadores de Riqueza (Chao/Jackknife) e Índices de Diversidade Alfa
#
# BASE TEÓRICA E METODOLÓGICA:
#   - DA SILVA, F. R. et al. Análises ecológicas no R. Recife: Nupeea; 
#     São Paulo: Canal 6, 2022. 
#       * Capítulo 11: Estimadores de Riqueza.
#       * Capítulo 12: Diversidade Taxonômica.
#   - CHAO, A. Nonparametric estimation of the number of classes in a population. 
#     Scandinavian Journal of Statistics, v. 11, p. 265-270, 1984.
#   - MAGURRAN, A. E. Measuring Biological Diversity. Oxford: Blackwell Publishing, 2004.
#
# AUTOR: Lucas Aosf
# ==============================================================================

# 1. CARREGAMENTO SEGURO DE PACOTES -------------------------------------------
pacotes_necessarios <- c("vegan", "readxl", "dplyr", "tidyr", "ggplot2", "viridis")

for (p in pacotes_necessarios) {
  if (!requireNamespace(p, quietly = TRUE)) {
    install.packages(p, dependencies = TRUE)
  }
  library(p, character.only = TRUE)
}

# 2. FUNÇÃO DE ENTRADA DE DADOS ECOLÓGICOS ------------------------------------
carregar_dados_diversidade <- function(caminho = NULL, sheet = 1) {
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
  
  if (!is.numeric(df[, 1])) {
    nomes_amostras <- df[, 1]
    matriz <- df[, -1, drop = FALSE]
    rownames(matriz) <- make.unique(as.character(nomes_amostras))
  } else {
    matriz <- df
  }
  
  matriz[] <- lapply(matriz, function(col) {
    v <- suppressWarnings(as.numeric(col))
    v[is.na(v)] <- 0
    return(v)
  })
  
  return(as.data.frame(matriz))
}

# 3. CARREGAMENTO DOS DADOS DO USUÁRIO ----------------------------------------
caminho_arquivo <- NULL

if (interactive() && is.null(caminho_arquivo)) {
  matriz_fauna <- carregar_dados_diversidade()
} else if (!is.null(caminho_arquivo) && file.exists(caminho_arquivo)) {
  matriz_fauna <- carregar_dados_diversidade(caminho_arquivo)
} else {
  message(">>> Usando matriz de comunidade ecológica de demonstração (BCI do pacote vegan)...")
  data(BCI)
  matriz_fauna <- BCI[1:10, ] # Primeiros 10 pontos amostrais
}

cat(sprintf("Comunidade carregada: %d unidades amostrais x %d espécies\n",
            nrow(matriz_fauna), ncol(matriz_fauna)))

# 4. CÁLCULO DOS ÍNDICES DE DIVERSIDADE ALFA (SILVA ET AL. 2022 - CAP. 12) ----
# Riqueza (S), Abundância Total (N), Shannon (H'), Exponencial de Shannon (exp(H')),
# Simpson (1-D), Inverso de Simpson (1/D), Equabilidade de Pielou (J')

riqueza_s      <- specnumber(matriz_fauna)
abundancia_n   <- rowSums(matriz_fauna)
shannon_h      <- diversity(matriz_fauna, index = "shannon", base = exp(1))
shannon_exp    <- exp(shannon_h) # Números de Hill q = 1
simpson_d      <- diversity(matriz_fauna, index = "simpson") # 1 - D (Gini-Simpson)
inv_simpson    <- diversity(matriz_fauna, index = "invsimpson") # Números de Hill q = 2
pielou_j       <- ifelse(riqueza_s > 1, shannon_h / log(riqueza_s), 1) # Equabilidade

tabela_alfa <- data.frame(
  Ponto_Amostral     = rownames(matriz_fauna),
  Riqueza_S          = riqueza_s,
  Abundancia_N       = abundancia_n,
  Shannon_H          = round(shannon_h, 3),
  Shannon_Exp        = round(shannon_exp, 3),
  Simpson_1_D        = round(simpson_d, 3),
  Inv_Simpson        = round(inv_simpson, 3),
  Pielou_J           = round(pielou_j, 3),
  stringsAsFactors   = FALSE
)

cat("\n=== TABELA DE DIVERSIDADE ALFA POR PONTO AMOSTRAL ===\n")
print(tabela_alfa)

write.csv(tabela_alfa, "Tabela_Diversidade_Alfa_Por_Ponto.csv", row.names = FALSE)
message(">>> Tabela salva: Tabela_Diversidade_Alfa_Por_Ponto.csv")

# 5. ESTIMADORES NÃO-PARAMÉTRICOS DE RIQUEZA (SILVA ET AL. 2022 - CAP. 11) ---
# Em consultoria ambiental, órgãos ambientais exigem estimadores para comprovar 
# se o esforço de campo foi suficiente para registrar a fauna/flora regional.

# 5.1. Estimadores baseados em Amostras / Incidência (Chao 2, Jackknife 1 e 2, Bootstrap)
estimadores_pool <- specpool(matriz_fauna)

s_observado <- estimadores_pool$Species
chao2_val   <- estimadores_pool$chao
chao2_se    <- estimadores_pool$chao.se
jack1_val   <- estimadores_pool$jack1
jack1_se    <- estimadores_pool$jack1.se
jack2_val   <- estimadores_pool$jack2
boot_val    <- estimadores_pool$boot
boot_se     <- estimadores_pool$boot.se

# Eficiência Amostral (% de completude capturada pela amostragem de campo)
eficiencia_chao2 <- round((s_observado / chao2_val) * 100, 1)
eficiencia_jack1 <- round((s_observado / jack1_val) * 100, 1)

tabela_estimadores <- data.frame(
  Metrica = c(
    "Riqueza Observada (S.obs)",
    "Chao 2 (Incidência)",
    "Jackknife 1ª Ordem",
    "Jackknife 2ª Ordem",
    "Bootstrap"
  ),
  Estimativa = round(c(s_observado, chao2_val, jack1_val, jack2_val, boot_val), 1),
  Erro_Padrao = c(NA, round(chao2_se, 2), round(jack1_se, 2), NA, round(boot_se, 2)),
  Eficiencia_Amostral_Pct = c(100.0, eficiencia_chao2, eficiencia_jack1, 
                              round((s_observado / jack2_val) * 100, 1),
                              round((s_observado / boot_val) * 100, 1)),
  stringsAsFactors = FALSE
)

cat("\n=== ESTIMATIVAS DE RIQUEZA TOTAL E EFICIÊNCIA AMOSTRAL ===\n")
print(tabela_estimadores)

write.csv(tabela_estimadores, "Tabela_Estimadores_Riqueza_Total.csv", row.names = FALSE)
message(">>> Tabela salva: Tabela_Estimadores_Riqueza_Total.csv")

# 6. GRÁFICO COMPARATIVO DE RIQUEZA OBSERVADA VS ESTIMADA ----------------------
df_grafico_est <- tabela_estimadores %>%
  filter(!is.na(Estimativa)) %>%
  mutate(Metrica = factor(Metrica, levels = rev(Metrica)))

grafico_estimadores <- ggplot(df_grafico_est, aes(x = Estimativa, y = Metrica, fill = Metrica)) +
  geom_col(width = 0.65, show.legend = FALSE, fill = "#1E88E5", alpha = 0.85) +
  geom_errorbarh(aes(xmin = ifelse(is.na(Erro_Padrao), Estimativa, Estimativa - Erro_Padrao),
                     xmax = ifelse(is.na(Erro_Padrao), Estimativa, Estimativa + Erro_Padrao)),
                 height = 0.25, color = "black") +
  geom_text(aes(label = sprintf("%.1f esp. (%.1f%%)", Estimativa, Eficiencia_Amostral_Pct)),
            hjust = -0.15, size = 3.6, fontface = "bold") +
  scale_x_continuous(expand = expansion(mult = c(0, 0.25))) +
  labs(
    title = "Riqueza Observada vs. Estimadores Não-Paramétricos",
    subtitle = sprintf("Eficiência Amostral pelo estimador Chao 2: %.1f%% (Silva et al. 2022)", eficiencia_chao2),
    x = "Número Estimado de Espécies",
    y = "Estimador Metodológico"
  ) +
  theme_bw(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 13),
    panel.grid.minor = element_blank()
  )

print(grafico_estimadores)
ggsave("Grafico_Estimadores_Riqueza_300dpi.png", grafico_estimadores, width = 8, height = 5, dpi = 300)

message(">>> Análise concluída com sucesso! Tabelas e gráficos prontos para relatórios ambientais.")

# ==============================================================================
# FIM DO SCRIPT
# ==============================================================================
