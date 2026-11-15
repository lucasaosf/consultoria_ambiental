# Guia 07: Padronização e Boas Práticas em Matrizes Ecológicas

> **Base Teórica:** DA SILVA, F. R. et al. *Análises ecológicas no R*. Nupeea; Canal 6, 2022. Capítulo 5: Tidyverse & Capítulo 9: Análises Multidimensionais.

---

## 1. Estrutura Padrão de Matrizes de Comunidade

No ecossistema estatístico do R (especialmente no pacote `vegan`), as matrizes ecológicas devem seguir estritamente o formato tabular:

* **Linhas:** Correspondem às **Unidades Amostrais** (Sítios, Pontos de Escuta, Parcelas, Transectos ou Campanhas);
* **Colunas:** Correspondem aos **Táxons / Espécies**;
* **Células:** Contêm valores numéricos representando abundância (contagem de indivíduos), biomassa ou presença/ausência (1/0).

> ⚠️ **ATENÇÃO (Formato do iNEXT):**  
> Para o pacote `iNEXT`, a convenção usual de entrada inverte a orientação quando analisamos abundâncias por área: as **linhas** representam as espécies e as **colunas** representam as comunidades/pontos. Nossos scripts realizam essa transposição e adequação automaticamente.

---

## 2. Regras de Higienização de Dados em Consultoria

1. **Evitar Células Vazias (*NA*):** Espécies não registradas em determinada unidade amostral devem ser codificadas como `0`, e não como `NA` ou traço `-`.
2. **Nomenclatura Binomial Estrita:** Padronizar nomes de espécies de acordo com listas taxonômicas oficiais (ex: CBRO para aves, SBH para herpetofauna). Evitar caracteres especiais e espaços duplicados.
3. **Exclusão de Táxons Indeterminados:** Indivíduos identificados apenas em nível de família ou ordem devem ser excluídos de análises de diversidade alfa e rarefação para não gerar vieses metodológicos.
