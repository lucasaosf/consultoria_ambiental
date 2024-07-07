# Converter Planilhas EBIRD 
# Lucas Aosf
# Thu Jun 13 20:49:49 2024 ------------------------------

# Instale o pacote openxlsx (se ainda não estiver instalado)
install.packages("openxlsx")

# Carregue o pacote openxlsx
library(openxlsx)

# Defina o diretório de trabalho (opcional)
new_directory <- "C:/Users/lucas/Downloads"
setwd(new_directory)

# Defina o caminho do arquivo CSV
csv_path <- file.choose()

# Leia o arquivo CSV
dados <- read.csv(csv_path)

# Remova espaços antes da primeira letra e exclua os parênteses da coluna Species
dados$Species <- gsub("^\\s+", "", dados$Species)
dados$Species <- gsub("\\((.*?)\\)", "\\1", dados$Species)

# Extraia o nome do arquivo sem a extensão .csv
file_name <- tools::file_path_sans_ext(basename(csv_path))

# Defina o caminho do diretório de destino para o arquivo XLSX
xlsx_dir <- choose.dir(default = "", caption = "Selecione o diretório para salvar o arquivo XLSX")

# Crie o caminho completo para o arquivo XLSX com o mesmo nome do arquivo CSV
xlsx_path <- file.path(xlsx_dir, paste0(file_name, ".xlsx"))

# Escreva o arquivo XLSX no diretório especificado
write.xlsx(dados, xlsx_path)

print(paste("Conversão concluída com sucesso! Arquivo salvo em:", xlsx_path))

# FIM
