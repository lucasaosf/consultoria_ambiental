# Guia 04: Índice de Dissimilaridade de Bray-Curtis (Dados Quantitativos)

> **Base Teórica:** DA SILVA, F. R. et al. *Análises ecológicas no R*. Nupeea; Canal 6, 2022. Capítulo 9: Análises Multidimensionais.  
> **Referência Clássica:** BRAY, J. R.; CURTIS, J. T. An ordination of the upland forest communities of southern Wisconsin. *Ecological Monographs*, v. 27, p. 325-349, 1957.

---

## 1. O que é o Índice de Bray-Curtis?

O **Índice de Bray-Curtis ($BC$)** é o coeficiente quantitativo padrão-ouro na ecologia de comunidades para avaliar a dissimilaridade estrutural entre amostras a partir de contagens de abundância:

$$BC_{jk} = \frac{\sum |y_{ij} - y_{ik}|}{\sum (y_{ij} + y_{ik})}$$

Onde $y_{ij}$ e $y_{ik}$ representam a abundância da espécie $i$ nos pontos $j$ e $k$.

### Propriedades Ecológicas:
1. Varia rigorosamente entre **0** (comunidades com idêntica distribuição de abundâncias) e **1** (comunidades que não compartilham nenhum indivíduo).
2. Não é afetado pela inclusão ou exclusão de espécies conjuntamente ausentes em ambos os sítios.
3. É sensível a mudanças na dominância ecológica, refletindo impactos antrópicos sutis (ex: declínio de espécies sensíveis acompanhado por aumento de espécies oportunistas).

---

## 2. Aplicação em Licenciamento e Monitoramento Ambiental

Em programas de monitoramento de fauna (BACI - *Before-After-Control-Impact*):
- Áreas de Controle (Florestas Conservadas) vs. Áreas de Impacto Direto (AID/ADA de mineradoras, hidrelétricas, rodovias);
- Dissimilaridades de Bray-Curtis elevadas ($BC > 0.70$) entre controle e impacto apontam alteração na estrutura da comunidade silvestre.
