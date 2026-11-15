# ==============================================================================
# PROJETO: Consultoria e Análises Ambientais em R
# SCRIPT: Dissimilaridade Ecológica (Jaccard e Bray-Curtis) e Agrupamento Hierárquico
#
# BASE TEÓRICA E METODOLÓGICA:
#   - DA SILVA, F. R. et al. Análises ecológicas no R. Recife: Nupeea; 
#     São Paulo: Canal 6, 2022. Capítulo 9: Análises Multidimensionais.
#   - LEGENDRE, P.; LEGENDRE, L. Numerical Ecology. 3. ed. Amsterdam: Elsevier, 2012.
#   - SOKAL, R. R.; ROHLF, F. J. The comparison of dendrograms by objective methods. 
#     Taxon, v. 11, n. 2, p. 33-40, 1962. (Correlação Cofenética)
#
# AUTOR: Lucas Aosf
# ==============================================================================

# 1. CARREGAMENTO SEGURO DE PACOTES -------------------------------------------
pacotes_necessarios <- c("vegan", "readxl", "cluster", "dendextend", "ggplot2", "viridis")

for (p in pacotes_necessarios) {
  if (!requireNamespace(p, quietly = TRUE)) {
    install.packages(p, dependencies = TRUE)
  }
  library(p, character.only = TRUE)
}

# 2. FUNÇÃO DE ENTRADA E LIMPEZA DE DADOS -------------------------------------
carregar_matriz_comunidade <- function(caminho = NULL, sheet = 1) {
  if (is.null(caminho)) {
    message(">>> Selecione o arquivo Excel (.xlsx) ou texto (.csv/.txt)...")
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
  
  # Organiza nomes das amostras/linhas
  if (!is.numeric(df[, 1])) {
    nomes_amostras <- df[, 1]
    matriz <- df[, -1, drop = FALSE]
    rownames(matriz) <- make.unique(as.character(nomes_amostras))
  } else {
    matriz <- df
  }
  
  # Garante valores numéricos e preenche NAs com 0
  matriz[] <- lapply(matriz, function(col) {
    v <- suppressWarnings(as.numeric(col))
    v[is.na(v)] <- 0
    return(v)
  })
  
  return(as.data.frame(matriz))
}

# 3. CARREGAMENTO DOS DADOS ---------------------------------------------------
# NOTA: Altere 'caminho_arquivo' para os dados da sua consultoria
caminho_arquivo <- NULL

if (interactive() && is.null(caminho_arquivo)) {
  matriz_comunidade <- carregar_matriz_comunidade()
} else if (!is.null(caminho_arquivo) && file.exists(caminho_arquivo)) {
  matriz_comunidade <- carregar_matriz_comunidade(caminho_arquivo)
} else {
  message(">>> Usando matriz de comunidade ecológica de demonstração (dune do pacote vegan)...")
  data(dune)
  matriz_comunidade <- dune
}

cat(sprintf("Matriz carregada: %d amostras (linhas) e %d espécies (colunas)\n", 
            nrow(matriz_comunidade), ncol(matriz_comunidade)))
print(head(matriz_comunidade[, 1:min(6, ncol(matriz_comunidade))]))

# 4. ÍNDICE DE DISSIMILARIDADE DE JACCARD (PRESENÇA/AUSÊNCIA) -----------------
# Conforme Silva et al. (2022, Cap. 9):
# Jaccard mede a proporção de espécies não compartilhadas ignorando duplas ausências.
# binary = TRUE força a matriz para dados binários (0 = ausente, 1 = presente).

dist_jaccard <- vegdist(matriz_comunidade, method = "jaccard", binary = TRUE)

# Agrupamento Hierárquico UPGMA (Unweighted Pair Group Method with Arithmetic Mean)
hclust_jaccard_upgma <- hclust(dist_jaccard, method = "average")
hclust_jaccard_ward  <- hclust(dist_jaccard, method = "ward.D2")

# VALIDAÇÃO OBRIGATÓRIA: Coeficiente de Correlação Cofenética (Silva et al. 2022)
coph_jaccard_upgma <- cophenetic(hclust_jaccard_upgma)
r_coph_jaccard_upgma <- cor(dist_jaccard, coph_jaccard_upgma)

coph_jaccard_ward <- cophenetic(hclust_jaccard_ward)
r_coph_jaccard_ward <- cor(dist_jaccard, coph_jaccard_ward)

cat("\n=== DIAGNÓSTICO COFENÉTICO (JACCARD) ===\n")
cat(sprintf(" - UPGMA (Average): r = %.3f %s\n", r_coph_jaccard_upgma, 
            ifelse(r_coph_jaccard_upgma >= 0.70, "[ADEQUADO]", "[BAIXA REPRESENTAÇÃO]")))
cat(sprintf(" - Ward's D2:       r = %.3f %s\n", r_coph_jaccard_ward,
            ifelse(r_coph_jaccard_ward >= 0.70, "[ADEQUADO]", "[BAIXA REPRESENTAÇÃO]")))

# 5. ÍNDICE DE DISSIMILARIDADE DE BRAY-CURTIS (DADOS DE ABUNDÂNCIA) -----------
# Bray-Curtis quantifica diferenças de abundância relativa sem distorção por dupla ausência.

dist_bray <- vegdist(matriz_comunidade, method = "bray")

hclust_bray_upgma <- hclust(dist_bray, method = "average")
hclust_bray_ward  <- hclust(dist_bray, method = "ward.D2")

coph_bray_upgma <- cophenetic(hclust_bray_upgma)
r_coph_bray_upgma <- cor(dist_bray, coph_bray_upgma)

coph_bray_ward <- cophenetic(hclust_bray_ward)
r_coph_bray_ward <- cor(dist_bray, coph_bray_ward)

cat("\n=== DIAGNÓSTICO COFENÉTICO (BRAY-CURTIS) ===\n")
cat(sprintf(" - UPGMA (Average): r = %.3f %s\n", r_coph_bray_upgma, 
            ifelse(r_coph_bray_upgma >= 0.70, "[ADEQUADO]", "[BAIXA REPRESENTAÇÃO]")))
cat(sprintf(" - Ward's D2:       r = %.3f %s\n", r_coph_bray_ward,
            ifelse(r_coph_bray_ward >= 0.70, "[ADEQUADO]", "[BAIXA REPRESENTAÇÃO]")))

# 6. GERAÇÃO E EXPORTAÇÃO DOS DENDROGRAMAS EM ALTA RESOLUÇÃO ------------------

# Configuração da saída gráfica para laudo técnico (PNG 300 DPI)
png("Dendrograma_Jaccard_UPGMA.png", width = 2400, height = 1800, res = 300)
dend_j <- as.dendrogram(hclust_jaccard_upgma)
dend_j <- color_branches(dend_j, k = min(4, nrow(matriz_comunidade)))
plot(dend_j, horiz = TRUE, 
     main = "Dendrograma de Similaridade de Jaccard (UPGMA)",
     sub = sprintf("Correlação Cofenética: r = %.3f (Silva et al. 2022)", r_coph_jaccard_upgma),
     xlab = "Distância de Jaccard (Presença / Ausência)",
     cex.main = 1.1, cex.lab = 0.9)
dev.off()

png("Dendrograma_Bray_Curtis_UPGMA.png", width = 2400, height = 1800, res = 300)
dend_b <- as.dendrogram(hclust_bray_upgma)
dend_b <- color_branches(dend_b, k = min(4, nrow(matriz_comunidade)))
plot(dend_b, horiz = TRUE, 
     main = "Dendrograma de Dissimilaridade de Bray-Curtis (UPGMA)",
     sub = sprintf("Correlação Cofenética: r = %.3f (Silva et al. 2022)", r_coph_bray_upgma),
     xlab = "Dissimilaridade de Bray-Curtis (Abundância)",
     cex.main = 1.1, cex.lab = 0.9)
dev.off()

message(">>> Dendrogramas exportados com sucesso em alta resolução (300 DPI)!")
message("    - Dendrograma_Jaccard_UPGMA.png")
message("    - Dendrograma_Bray_Curtis_UPGMA.png")

# ==============================================================================
# FIM DO SCRIPT
# ==============================================================================
