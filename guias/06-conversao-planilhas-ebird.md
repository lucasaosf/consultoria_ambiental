# Guia 06: Pipeline Tidyverse para Dados de Avifauna do eBird

> **Base Teórica:** DA SILVA, F. R. et al. *Análises ecológicas no R*. Nupeea; Canal 6, 2022. Capítulo 5: Tidyverse e Manipulação de Dados.  
> **Referência Técnica:** WICKHAM, H. et al. Welcome to the Tidyverse. *Journal of Open Source Software*, v. 4, n. 43, p. 1686, 2019.

---

## 1. O Desafio das Planilhas de Ciência Cidadã em Consultoria

O portal **eBird** tornou-se ferramenta corriqueira para ornitólogos e consultores ambientais organizarem suas listas de campo. No entanto, os arquivos exportados vêm no formato de registros planos (*long format*), com uma linha para cada observação de espécie em determinado ponto e data.

Para processar esses dados nos pacotes analíticos do R (`vegan`, `iNEXT`), o consultor precisa converter essa lista em uma **Matriz de Comunidade Ecológica** (*wide format*), onde:
- As **linhas** correspondem às unidades amostrais (pontos de escuta, listas ou campanhas);
- As **colunas** representam os táxons de aves;
- Os **valores nas células** contêm a abundância de indivíduos registrados ou valores binários de presença (1) e ausência (0).

---

## 2. Etapas do Pipeline Implementado no Script

1. **Leitura Flexível (`readr::read_csv`):** Detecta automaticamente delimitadores vírgula e ponto-e-vírgula comuns no padrão brasileiro.
2. **Higienização Taxonômica (`stringr`):**
   - Remove nomes vulgares em inglês que vêm entre parênteses no eBird;
   - Elimina espaços em branco no início e final das strings;
   - Filtra táxons de identificação incerta (`sp.`, `slash`, `hybrid`) para evitar inflação artificial de riqueza.
3. **Tratamento de Contagens Imprecisas:**
   - O eBird permite marcar a presença com a letra `X` quando o observador viu a espécie mas não contou os espécimes. O script converte `X` em contagem conservadora de `1` indivíduo.
4. **Pivotagem e Agregação (`tidyr::pivot_wider`):** Constrói a matriz ecológica com preenchimento automático de `0` para ausências.
5. **Workbook Formatado em Excel (`openxlsx`):**
   - Aba 1: `Matriz_Abundancia`;
   - Aba 2: `Matriz_Presenca_Ausencia`;
   - Aba 3: `Resumo_Taxonomico` (com abundância total e frequência percentual de ocorrência);
   - Aba 4: `Dados_Brutos_Limpos`.
