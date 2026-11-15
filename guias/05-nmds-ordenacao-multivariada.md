# Guia 05: Ordenação por Escalonamento Multidimensional Não-Métrico (NMDS)

> **Base Teórica:** DA SILVA, F. R. et al. *Análises ecológicas no R*. Nupeea; Canal 6, 2022. Capítulo 9: Análises Multidimensionais.  
> **Referência Clássica:** CLARKE, K. R. Non-parametric multivariate analyses of changes in community structure. *Australian Journal of Ecology*, v. 18, n. 1, p. 117-143, 1993.

---

## 1. O que é o NMDS e por que utilizá-lo?

O **Escalonamento Multidimensional Não-Métrico (NMDS)** é uma técnica de ordenação não-linear e livre de premissas paramétricas (como linearidade ou normalidade multivariada), amplamente considerada a mais robusta para dados ecológicos de comunidades biológicas.

O algoritmo do NMDS busca projetar as unidades amostrais em um espaço de poucas dimensões (geralmente 2D) preservando ao máximo a **ordem dos postos (*ranks*)** das dissimilaridades originais (calculadas via Bray-Curtis ou Jaccard).

---

## 2. Diagnóstico de Confiabilidade: O Valor de Estresse (*Stress*)

A qualidade do ajuste da ordenação é quantificada pela métrica de **Estresse (*Stress*)**, definida por Kruskal e Clarke:

| Faixa de Stress | Classificação Metodológica (Silva et al. 2022) | Recomendação Técnica para Laudos |
| :---: | :---: | :--- |
| **$< 0.05$** | **Excelente** | Representação 2D perfeita; praticamente sem distorção. |
| **$0.05 \text{ a } 0.10$** | **Boa** | Ordenação sólida e altamente confiável para tomada de decisão. |
| **$0.10 \text{ a } 0.20$** | **Razoável / Aceitável** | Válida para conclusões gerais; pontos periféricos devem ser avaliados com cautela. |
| **$> 0.20$** | **Inadequada / Pobre** | Alto risco de conclusões espúrias. Recomenda-se rodar em 3 dimensões ($k = 3$). |

---

## 3. Boas Práticas Recomendadas pelo Livro:

1. **Evitar Mínimos Locais (`trymax = 100`):** O algoritmo deve realizar múltiplas tentativas aleatórias para assegurar que a solução encontrada é o mínimo global de stress.
2. **Diagrama de Shepard (`stressplot`):** Plota as dissimilaridades observadas contra as distâncias ordinais no espaço reduzido. Valores de correlação não-métrica ($R^2 > 0.95$) comprovam aderência estrita.
3. **Elipses de Confiança de 95% (`stat_ellipse`):** Demonstram estatisticamente se diferentes áreas (ex: Cerrado vs. Mata Atlântica; Área de Supressão vs. Reserva Legal) possuem sobreposição ou segregação de nicho comunitário.
