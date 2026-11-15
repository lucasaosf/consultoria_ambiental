# Guia 02: Curvas de Rarefação e Extrapolação (iNEXT e Números de Hill)

> **Base Teórica:** DA SILVA, F. R. et al. *Análises ecológicas no R*. Nupeea; Canal 6, 2022. Capítulo 10: Rarefação.  
> **Referência Clássica:** CHAO, A. et al. Rarefaction and extrapolation with Hill numbers: a framework for sampling and estimation in species diversity studies. *Ecological Monographs*, v. 84, n. 1, p. 45-67, 2014.

---

## 1. Por que usar Rarefação em Consultoria Ambiental?

Em levantamentos de fauna e flora para licenciamento ambiental (EIA/RIMA, PCA, RCA, Monitoramento), o número bruto de espécies registradas em um ponto ou campanha amostral é fortemente dependente do **esforço amostral** e do **número total de indivíduos contabilizados**.

A simples comparação de riqueza observada ($S_{obs}$) entre áreas com números díspares de capturas gera conclusões enviesadas. A **rarefação** permite padronizar a riqueza a um tamanho amostral comum (subamostragem), enquanto a **extrapolação** estende a curva para prever a riqueza assintótica que seria encontrada com maior esforço.

---

## 2. A Família dos Números de Hill (Série de Hill)

O pacote `iNEXT` unifica a quantificação da diversidade biológica por meio dos números de Hill ($^qD$), parametrizados pela ordem $q$:

| Ordem $q$ | Índice Equivalente | Interpretação Ecológica | Sensibilidade |
| :---: | :---: | :--- | :--- |
| **$q = 0$** | Riqueza de Espécies ($S$) | Contagem total de espécies observadas | Pondera igualmente raras e comuns |
| **$q = 1$** | Exponencial de Shannon ($\exp(H')$) | Diversidade de espécies abundantes/típicas | Pondera espécies pela sua frequência |
| **$q = 2$** | Inverso de Simpson ($1/D$) | Diversidade de espécies altamente dominantes | Desconsidera espécies raras |

---

## 3. Os Três Gráficos Metodológicos do Livro (Silva et al. 2022)

O livro preconiza a geração e interpretação conjunta de três curvas:

1. **Tipo 1: Tamanho Amostral vs. Diversidade:**  
   Mostra como a riqueza ou diversidade aumenta com o acréscimo de indivíduos (interpolação sólida e extrapolação pontilhada com intervalos de confiança de 95%).
2. **Tipo 2: Tamanho Amostral vs. Cobertura da Amostra (*Sample Completeness*):**  
   Avalia a suficiência amostral ($\hat{C}_m$). Em consultoria, uma cobertura amostral $\ge 90\%$ (ou $0.90$) indica que a grande maioria dos indivíduos na comunidade pertence a espécies já catalogadas.
3. **Tipo 3: Cobertura da Amostra vs. Diversidade:**  
   Permite a comparação justa entre áreas com históricos ou fitofisionomias distintas, padronizando a diversidade no mesmo percentual de cobertura amostral.
