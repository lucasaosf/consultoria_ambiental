# Comparação de Riqueza e Abundância por Pontos
# Lucas Aosf
# Sun Jun  9 13:28:24 2024 ------------------------------

# install packages
install.packages("iNEXT")
install.packages("ggplot2")
install.packages("readxl")

# Carregar pacotes
library(iNEXT)
library(ggplot2)
library(readxl)

# Sun Jun  9 18:43:57 2024 ------------------------------

# Ler dados em arquivo .xlsx
rare <- file.choose() # Abre uma janela para escolher o arquivo
raref <- read_excel(rare, sheet = 6) # Ler o arquivo Excel. "sheet = X" -> lê a aba da planilha 

# Separar a primeira coluna (nomes e números de espécies)
especies <- raref[, 1] # Supondo que a primeira coluna contenha os nomes das espécies
dados_quantidade <- raref[, -1] # Todas as colunas, exceto a primeira

# Converter colunas para numéricas
dados_quantidade[] <- lapply(dados_quantidade, as.numeric)

# Garantir que dados_quantidade é um data frame
dados_quantidade <- as.data.frame(dados_quantidade)

# Verificar nome das colunas
print(colnames(dados_quantidade))

# Calcular riqueza de espécies
resultados <- iNEXT(dados_quantidade, q = 0, 
                    datatype = "abundance", endpoint = NULL)
# Código do Gráfico
cores <- c("darkorange", "darkorchid", "cyan4", "blue", "green", "red", "yellow", "pink")

ggiNEXT(resultados, type = 1) +
  scale_linetype_discrete(labels = c("Interpolado", "Extrapolado")) +
  scale_colour_manual(values = cores) +
  scale_fill_manual(values = cores) +
  labs(x = "Abundância", y = "Riqueza de espécies") +
  theme_minimal() +
  theme(axis.title.y = element_text(vjust = 1))

# FIM

####################################################################################

# Comparação de Riqueza por Amostra
# Lucas Aosf (Adaptado do Script da Analice)
# Sun Jun  9 19:14:54 2024 ------------------------------

# Ler dados em arquivo .txt
# Usar apenas a linha que vai ler o arquivo escolhido
rare <- file.choose() # Abre uma janela para escolher o arquivo
raref <- read.table(rare, header = T, sep = "\t", row.names = 1) # Ler arquivo .txt

# Verificar a alteração
print(colnames(raref))

# Alterar o nome da coluna (caso precise)
colnames(raref)[colnames(raref) == "X1.ANO"] <- "ANO_1"
colnames(raref)[colnames(raref) == "X2.ANO"] <- "ANO_2"
colnames(raref)[colnames(raref) == "X3.ANO"] <- "ANO_3"

# Verificar a alteração
print(colnames(raref))


# Calcular riqueza de espécies
resultados <- iNEXT(raref, q = 0, 
                    datatype = "abundance", endpoint = NULL)
# Código do gráfico
ggiNEXT(resultados, type = 1) +
  scale_linetype_discrete(labels = c("Interpolado", "Extrapolado")) +
  scale_colour_manual(values = c("darkorange", "darkorchid", "cyan4")) +
  scale_fill_manual(values = c("darkorange", "darkorchid", "cyan4")) +
  labs(x = "Abundância", y = " Riqueza de espécies")

# FIM