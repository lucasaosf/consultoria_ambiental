# Similaridade
# Lucas Aosf
# Sat Feb  3 22:37:14 2024 ------------------------------

# Instalar pacotes

install.packages("cluster")
install.packages("ape")
install.packages("readxl")
install.packages("vegan")

# Carregar pacotes
library(cluster) 
library(ape)
library(readxl)
library(vegan)

# Carregar os dados do arquivo excel (Colocar seu diretório específico)
caminho_arquivo <- file.choose()

# Ler o arquivo Excel
dados_excel <- read_excel(caminho_arquivo, sheet = 2) # Colocar sua aba específica (Sheet)

# Visualizar os dados
print(dados_excel)

# Calcular a matriz de similaridade (usando distância euclidiana)

matriz_similaridade <- dist(dados_excel)

# Criar o dendrograma usando hclust

dendrograma <- hclust(matriz_similaridade)

# Converter o dendrograma em um objeto de árvore para plotagem

arvore <- as.phylo(dendrograma)

# Plotar o dendrograma

plot(arvore, main = "Similaridade de Espécies entre os Pontos")

# Wed Jul  3 13:17:44 2024 ------------------------------
# NMDS (Non-metric Multidimensional Scaling)

# Carregar os dados do arquivo excel (Colocar seu diretório específico)
caminho_arquivo <- file.choose()

# Ler o arquivo Excel
dados_excel <- read_excel(caminho_arquivo, sheet = 2) # Colocar sua aba específica (Sheet)
dados_excel <- as.data.frame(dados_excel) # Converter para data.frame se necessário

# Visualizar os dados
print(dados_excel)

# Remover a coluna de IDs (assumindo que é a primeira coluna)
ids <- dados_excel[[1]]
dados_numericos <- dados_excel[, -1]

# Definir cores para cada ponto (substitua com as cores desejadas)
grupos <- as.factor(ids)  # Assumindo que os IDs representam grupos
cores <- rainbow(length(unique(grupos)))  # Utiliza um gradiente de cores
cores_pontos <- cores[as.numeric(grupos)]

# Calcular o NMDS usando a matriz de similaridade
nmds <- metaMDS(dados_numericos, distance = "euclidean", k = 2)

# Plotar o NMDS com cores
plot(nmds, main = "Similaridade de Espécies entre os Pontos", type = "n")
points(nmds, display = "sites", col = cores_pontos, pch = 19)

# Adicionar legenda ao gráfico
legend("topright", legend = levels(grupos), col = cores, pch = 19, title = "Pontos")

# FIM