# Consultoria Ambiental — Scripts em R para Ecologia de Comunidades

[![License: MIT](https://img.shields.io/badge/License-MIT-emerald.svg)](LICENSE)
[![R](https://img.shields.io/badge/Language-R-blue.svg)](https://www.r-project.org/)
[![Livro: Silva et al. 2022](https://img.shields.io/badge/Metodologia-Silva_et_al._2022-brightgreen.svg)](https://analises-ecologicas.com/)
[![Status](https://img.shields.io/badge/Status-Ativo_e_Atualizado-success.svg)](#)

Coleção de scripts em linguagem R desenvolvidos e padronizados para aplicação em **diagnósticos ambientais, estudos de impacto (EIA/RIMA, PCA, RCA, PRAD) e programas de monitoramento de fauna silvestre** (Herpetofauna, Avifauna, Mastofauna e Ictiofauna).

Todos os métodos estatísticos e gráficos foram revisados e alinhados com o livro **"Análises Ecológicas no R" (Silva et al. 2022)**, garantindo rigor analítico, reprodutibilidade e conformidade com as diretrizes de órgãos ambientais (IBAMA, CETESB, IAT, INEA, etc.).

**Lucas Aøsf** · Pesquisa & Soluções Ambientais

---

## 📚 Metodologia e Scripts Disponíveis

| Script | Capítulo do Livro | O que faz | Pacotes Principais |
| :--- | :--- | :--- | :--- |
| **`Comparação de Riq e Abu por pnt.R`** | **Capítulo 10**<br>*(Rarefação e Extrapolação)* | Curvas de rarefação baseadas em indivíduos e cobertura com **Série de Números de Hill** ($q=0$: Riqueza, $q=1$: Shannon, $q=2$: Simpson), intervalos de 95% e 3 gráficos de publicação | `iNEXT`, `ggplot2`, `patchwork`, `viridis` |
| **`Similaridade com índice jaccard e bray-curties.R`** | **Capítulo 9**<br>*(Análises Multidimensionais)* | Matrizes de dissimilaridade de **Jaccard** (binário) e **Bray-Curtis** (abundância), agrupamento hierárquico (UPGMA / Ward) e **validação cofenética obrigatória** | `vegan`, `dendextend`, `cluster`, `readxl` |
| **`Similaridade.R`** | **Capítulo 9**<br>*(Análises Multidimensionais)* | Ordenação **NMDS** com Bray-Curtis, cálculo e diagnóstico formal de **Stress**, Diagrama de Shepard (`stressplot`) e gráfico com elipses de 95% | `vegan`, `ggplot2`, `ggrepel`, `viridis` |
| **`Converter Planilhas EBIRD.R`** | **Capítulo 5**<br>*(Tidyverse)* | Pipeline automatizado de higienização de listas do eBird e transformação em **Matrizes de Comunidade Ecológica** (abundância e presença/ausência em `.xlsx`) | `dplyr`, `tidyr`, `readr`, `openxlsx` |
| **`Estimadores de Riqueza e Diversidade Alfa.R`** | **Capítulos 11 e 12**<br>*(Estimadores & Diversidade)* | Cálculo de Shannon, Simpson, Equabilidade de Pielou, **Estimadores Chao 1/2, Jackknife 1/2 e Bootstrap**, e cálculo da **% de Eficiência Amostral** | `vegan`, `readxl`, `dplyr`, `ggplot2` |

---

## 🚀 Como Executar os Scripts

1. Abra o projeto ou o script desejado no **RStudio**;
2. Todos os scripts possuem rotina de **carregamento seguro e automático** de pacotes (`requireNamespace` + `install.packages`);
3. Ao executar (`Ctrl + Shift + Enter`), o script solicita interativamente a planilha de dados através de janela de seleção (`file.choose()`) — suportando `.xlsx`, `.csv` e `.txt`;
4. Caso não selecione nenhum arquivo, os scripts contam com **conjuntos de dados ecológicos de demonstração embutidos** para que você possa visualizar o funcionamento imediatamente;
5. Tabelas consolidadas e gráficos em **alta resolução (300 DPI)** são salvos automaticamente no diretório de trabalho.

---

## 📖 Guias Técnicos e Documentação

O repositório inclui 10 guias aprofundados na pasta [`guias/`](guias/):

* [Guia 01: Instalação e Ambiente R](guias/01-instalacao-e-ambiente-r.md)
* [Guia 02: Curvas de Rarefação e Extrapolação (iNEXT)](guias/02-curvas-rarefacao-inext.md)
* [Guia 03: Coeficiente de Similaridade de Jaccard](guias/03-indice-similaridade-jaccard.md)
* [Guia 04: Coeficiente de Dissimilaridade de Bray-Curtis](guias/04-indice-bray-curtis.md)
* [Guia 05: Ordenação por NMDS e Diagnóstico de Estresse](guias/05-nmds-ordenacao-multivariada.md)
* [Guia 06: Pipeline Tidyverse para eBird](guias/06-conversao-planilhas-ebird.md)
* [Guia 07: Padronização de Matrizes Ecológicas](guias/07-padronizacao-matrizes-ecologicas.md)
* [Guia 08: Métodos de Amostragem em Campo](guias/08-metodos-levantamento-fauna.md)
* [Guia 09: Integração de Resultados em Laudos e EIA/RIMA](guias/09-laudos-e-relatorios-ambientais.md)
* [Guia 10: Referências Bibliográficas Fundamentais](guias/10-referencias-bibliograficas.md)

---

## 📚 Referência Central

> DA SILVA, F. R.; GONÇALVES-SOUZA, T.; PATERNO, G. B.; PROVETE, D. B.; VANCINE, M. H. **Análises ecológicas no R**. 1. ed. Recife: Nupeea; São Paulo: Canal 6, 2022. 640 p.  
> Obra de livre acesso disponível em: [https://analises-ecologicas.com/](https://analises-ecologicas.com/)

---

## Citation

Se você utilizar estes scripts, matrizes ecológicas ou rotinas analíticas em relatórios técnicos, laudos ambientais (EIA/RIMA, PCA, RCA) ou publicações acadêmicas, cite como:

```bibtex
@misc{ferreira2026consultoriaambiental,
  title={Scripts em R para Consultoria e Análises Ambientais},
  author={Lucas Aosf},
  year={2026},
  publisher={GitHub},
  journal={GitHub repository},
  howpublished={\url{https://github.com/lucasaosf/consultoria_ambiental}},
  url={https://github.com/lucasaosf/consultoria_ambiental}
}
```

Para citar a obra metodológica de referência:

```bibtex
@book{silva2022analises,
  title={Análises ecológicas no R},
  author={da Silva, Fernando Rodrigues and Gonçalves-Souza, Thiago and Paterno, Gustavo Brant and Provete, Diogo Borges and Vancine, Maurício Humberto},
  year={2022},
  edition={1},
  pages={640},
  publisher={Nupeea; Canal 6},
  address={Recife; São Paulo},
  isbn={978-65-87511-14-6},
  url={https://analises-ecologicas.com/}
}
```

---

## 📄 Licença

Distribuído sob a licença [MIT](LICENSE).
