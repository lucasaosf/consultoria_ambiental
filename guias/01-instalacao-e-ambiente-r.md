# Guia 01: Instalação e Configuração do Ambiente R para Análises Ecológicas

> **Base Teórica:** DA SILVA, F. R. et al. *Análises ecológicas no R*. Nupeea; Canal 6, 2022. Capítulo 3: Pré-requisitos & Capítulo 4: Introdução ao R.

---

## 1. Instalação do R e RStudio Desktop

Para rodar com estabilidade todos os scripts estatísticos e ecológicos deste repositório, recomenda-se a instalação das versões mais recentes:

1. **R Language (CRAN):**  
   Baixe e instale a versão oficial para Windows em: [cran.r-project.org](https://cran.r-project.org/bin/windows/base/) (versão $\ge 4.2.0$).
2. **RStudio Desktop (IDE):**  
   Ambiente integrado gratuito desenvolvido pela Posit: [posit.co/download/rstudio-desktop](https://posit.co/download/rstudio-desktop/).
3. **RTools (Compilador para Windows):**  
   Essencial para compilar pacotes C/C++ como `vegan` e `iNEXT`: [cran.r-project.org/bin/windows/Rtools](https://cran.r-project.org/bin/windows/Rtools/).

---

## 2. Instalação em Lote dos Pacotes Ecológicos Fundamentais

Abra o console do RStudio e execute o seguinte comando:

```r
pacotes_essenciais <- c(
  # Ecologia numérica e diversidade
  "vegan", "iNEXT", "cluster", "dendextend",
  # Manipulação e Tidyverse
  "tidyverse", "readxl", "openxlsx",
  # Visualização científica de dados
  "ggplot2", "viridis", "ggrepel", "patchwork"
)

install.packages(pacotes_essenciais, dependencies = TRUE)
```
