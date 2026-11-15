# Guia 09: Integração de Resultados em Laudos Técnicos e EIA/RIMA

> **Conformidade Normativa:** Diretrizes CONAMA 001/86, IN IBAMA 03/2014 e manuais estaduais (CETESB, INEA, IAT).

---

## 1. Estruturação do Capítulo de Fauna / Meio Biótico

Ao redigir o diagnóstico ou relatório de monitoramento ambiental, os resultados estatísticos gerados pelos scripts em R devem ser inseridos de forma coerente e autoexplicativa:

1. **Esforço Amostral e Suficiência:**
   - Inserir a curva de rarefação/extrapolação (`Grafico_Rarefacao_Extrapolacao_Tipo1.png`) acompanhada do gráfico de cobertura amostral (`Grafico_Cobertura_Amostral_Tipo2.png`).
   - Apresentar a tabela de estimadores não-paramétricos comprovando que a eficiência amostral ultrapassou o limiar de 85% a 90%.
2. **Composição e Estrutura da Comunidade:**
   - Apresentar a tabela de índices de diversidade alfa (Riqueza, Shannon, Simpson, Equabilidade de Pielou) comparando fitofisionomias ou pontos amostrais.
3. **Similaridade e Impacto Espaço-Temporal:**
   - Inserir a ordenação por NMDS (`NMDS_Ordenacao_Comunidade_300dpi.png`) evidenciando a segregação ou agrupamento entre áreas de controle e áreas de influência direta (AID/ADA).
   - Reportar no texto o valor exato do estresse (*stress*) e sua classificação conforme Silva et al. (2022).
   - Apresentar os dendrogramas de similaridade (Jaccard ou Bray-Curtis) acompanhados do coeficiente de correlação cofenética ($r$).

---

## 2. Padrões de Exportação Visual

Todos os gráficos são renderizados com resolução de **300 DPI** e paletas perceptualmente uniformes (`viridis`), garantindo leitura clara tanto em relatórios impressos quanto em arquivos digitais em PDF submetidos aos órgãos fiscalizadores.
