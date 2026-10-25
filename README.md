# Consultoria ambiental — scripts em R

Scripts em R usados em relatórios de consultoria ambiental para analisar dados de levantamento de fauna.
**Lucas Aøsf** · Pesquisa & Soluções Ambientais

## Scripts

| Arquivo | O que faz | Pacotes |
|---|---|---|
| `Comparação de Riq e Abu por pnt.R` | Curvas de rarefação e extrapolação da riqueza (iNEXT) por ponto de amostragem ou por ano, com gráfico | `iNEXT`, `ggplot2`, `readxl` |
| `Similaridade com índice jaccard e bray-curties.R` | Similaridade de Jaccard (presença/ausência) e Bray-Curtis (abundância) com dendrogramas | `vegan`, `readxl` |
| `Similaridade.R` | Dendrograma por distância euclidiana e NMDS colorido por ponto | `vegan`, `cluster`, `ape`, `readxl` |
| `Converter Planilhas EBIRD.R` | Converte a exportação do eBird (.csv) em planilha Excel e limpa os nomes das espécies | `openxlsx` |

## Como usar

1. Abra o script no **RStudio**.
2. Instale os pacotes da tabela (as linhas `install.packages()` estão no começo de cada script).
3. Rode o script: uma janela pede para escolher a planilha de dados (`file.choose()`).
4. Ajuste o número da aba (`sheet = …`) conforme a sua planilha.

Os dados de entrada são matrizes de espécies × pontos (ou anos), com as espécies na primeira coluna.
