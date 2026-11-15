# Guia 08: Métodos de Amostragem em Campo para Fauna Silvestre

> **Base Metodológica:** Diretrizes do ICMBio, Instruções Normativas do IBAMA e Silva et al. (2022).

---

## 1. Métodos Padronizados por Grupo Faunístico

### Avifauna:
- **Pontos de Escuta (*Point Counts*):** Raios fixos (ex: 50m ou 100m) e tempo definido (10 a 15 minutos por ponto) nas primeiras horas da manhã e entardecer.
- **Transectos Lineares:** Caminhadas em velocidade constante para registro visual e bioacústico.
- **Redes de Neblina (*Mist-nets*):** Padronização em horas-rede (m²·h) para captura de sub-bosque.

### Herpetofauna (Anfíbios e Répteis):
- **Busca Ativa Visual e Auditiva (BAVA):** Vistorias em corpos d'água, serapilheira e margens de mata.
- **Armadilhas de Interceptação e Queda (*Pitfall Traps* com cerca-guia):** Baldes plásticos de 60L enterrados em linhas de 30 a 50 metros.

### Mastofauna (Mamíferos):
- **Armadilhas Fotográficas (*Camera Traps*):** Esforço amostral em armadilhas-dia (ex: 20 câmeras por 30 dias = 600 armadilhas-dia).
- **Armadilhas de Captura Viva (*Sherman* e *Tomahawk*):** Para pequenos mamíferos não-voadores.
- **Levantamento de Pegadas e Vestígios:** Parcelas de areia com isca e busca em estradas e trilhas.

---

## 2. Tradução do Esforço de Campo para o R

Cada método gera dados de incidência (dias/amostras com presença) ou dados de abundância (número total de indivíduos capturados). Nossos scripts diferenciam adequadamente esses dois tipos de dados nas rotinas de rarefação (`datatype = "abundance"` vs `datatype = "incidence_freq"` no `iNEXT`).
