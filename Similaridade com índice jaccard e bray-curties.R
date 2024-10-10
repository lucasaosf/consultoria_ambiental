# Indice de Jaccard, Bray-Curtis e Distância Euclidiana
# Lucas Aosf
# Thu Oct 10 15:40:21 2024 ------------------------------

# Instalar pacotes, se necessário
# install.packages("vegan")
# install.packages("readxl")

# Carregar pacotes
library(vegan)
library(readxl)

# Ler o arquivo Excel com file.choose()
file_path <- file.choose()  # O usuário escolhe o arquivo Excel
data <- read_excel(file_path)  # Carregar a planilha Excel

# Exibir os primeiros dados para verificação
print(head(data))

# Certifique-se de que os dados estão no formato adequado.
# Se for matriz de presença/ausência (0/1), utilize o índice de Jaccard.
# Se for matriz de abundância, utilize o índice de Bray-Curtis.

# 1. Para o índice de Jaccard (dados de presença/ausência)
jaccard_similarity <- vegdist(data, method = "jaccard")
print("Matriz de similaridade de Jaccard:")
print(jaccard_similarity)

# Realizar a análise de cluster hierárquico com o índice de Jaccard
hclust_jaccard <- hclust(jaccard_similarity, method = "average")

# Plotar o dendrograma de Jaccard com orientação para a direita
plot(as.dendrogram(hclust_jaccard), 
     horiz = TRUE,  # Orientação para a direita
     main = "Dendrograma - Similaridade de Jaccard",
     xlab = "Distância (Jaccard)",
     sub = "")

# 2. Para o índice de Bray-Curtis (dados de abundância)
bray_curtis_dissimilarity <- vegdist(data, method = "bray")
print("Matriz de dissimilaridade de Bray-Curtis:")
print(bray_curtis_dissimilarity)

# Realizar a análise de cluster hierárquico com o índice de Bray-Curtis
hclust_bray <- hclust(bray_curtis_dissimilarity, method = "average")

# Plotar o dendrograma de Bray-Curtis com orientação para a direita
plot(as.dendrogram(hclust_bray), 
     horiz = TRUE,  # Orientação para a direita
     main = "Dendrograma - Dissimilaridade de Bray-Curtis",
     xlab = "Distância (Bray-Curtis)",
     sub = "")

# FIM
