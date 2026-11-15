# Guia 03: Coeficiente de Similaridade de Jaccard e Dados Binários

> **Base Teórica:** DA SILVA, F. R. et al. *Análises ecológicas no R*. Nupeea; Canal 6, 2022. Capítulo 9: Análises Multidimensionais.  
> **Referência Clássica:** JACCARD, P. Nouvelles recherches sur la distribution florale. *Bulletin de la Société Vaudoise des Sciences Naturelles*, v. 44, p. 223-270, 1908.

---

## 1. Fundamentação do Índice de Jaccard

O **Índice de Jaccard ($C_J$)** é uma métrica de similaridade assimétrica projetada especificamente para matrizes binárias de **presença e ausência (0/1)**:

$$C_J = \frac{a}{a + b + c}$$

Onde:
- $a$: número de espécies presentes em ambas as áreas (co-ocorrência);
- $b$: número de espécies presentes apenas na Área 1;
- $c$: número de espécies presentes apenas na Área 2;
- $d$: número de espécies ausentes em ambas (dupla ausência — **desconsiderada pelo índice**).

### A Distância de Jaccard (Dissimilaridade)
No pacote `vegan`, a função `vegdist(x, method = "jaccard", binary = TRUE)` calcula a dissimilaridade ($D_J = 1 - C_J$), variando de 0 (comunidades idênticas) a 1 (comunidades sem nenhuma espécie em comum).

---

## 2. A Falácia da Distância Euclidiana em Matrizes de Espécies

Conforme detalhado no Capítulo 9 de Silva et al. (2022), a **distância euclidiana tradicional** considera duplas ausências ($d$) como indício de semelhança ecológica. Em biologia de campo, duas áreas não compartilham um anfíbio de topo de serra simplesmente porque ambas estão em altitude baixa; tratá-las como "similares" por não terem o bicho é um erro metodológico primário (o chamado *Paradoxo de Orlóci*). O índice de Jaccard resolve essa questão de forma matematicamente elegante.

---

## 3. Validação pelo Coeficiente de Correlação Cofenética

Ao construir um dendrograma com `hclust(dist_jaccard, method = "average")` (UPGMA), o relatório ambiental deve obrigatoriamente reportar a **correlação cofenética** (`cor(dist_jaccard, cophenetic(hclust))`):
- $r \ge 0.80$: Representação fidedigna da matriz original;
- $0.70 \le r < 0.80$: Representação aceitável;
- $r < 0.70$: O dendrograma distorce as distâncias originais e não deve ser usado isoladamente.
