#import "meu-template.typ": *

#set text(lang: "pt", region: "BR")

#show: meu-template.with(
  ratio: "16-9",
  theme: rgb("#016521"),
  font: "Jetbrains Monaspace",
  font-size: 18pt,
  link-style: "color",
  show-progress: true,
  show-kicker: true,
)

#front-slide(
  title: "Avaliação do Impacto do Time-Aware Shaping na Latência de Tráfego Crítico Modelado a partir de OPC UA PubSub: um Estudo Simulado no INET",
  authors: "Lucas Silva de Oliveira",
  info: [Tópicos Especiais em Computação Inteligente I],
  back-color: rgb("#e5ffe0"),
)

#table-of-contents(title: "Sumário")

#title-slide(back-color: rgb("#88d38d"))[
  Introdução
]

#slide[
  == Contexto e Motivação

  - *Convergência OPC UA + TSN:* O OPC UA PubSub é o padrão emergente para comunicação industrial; o TSN fornece os mecanismos de rede para entrega determinística.

  - *O Gap de Configuração (OPC-10000-14):* O PubSub define parâmetros de aplicação (`PublishingInterval - 6.2.6.2`, `PriorityLabel - 5.4.6.4`), mas não prescreve como mapeá-los para classes de tráfego TSN.

  - *O Problema:* Sem mapeamento explícito, tráfego crítico de controle pode ser classificado como best-effort, violando requisitos de latência e jitter.

  - *Objetivo*: Modelar o perfil de tráfego que o PubSub gera (periódico para controle, esporádico para monitoramento) e avaliar o efeito do TAS sobre ele via simulação no INET.
]

#slide[
  == O que é o OMNeT++ e o INET?

  #grid(
    columns: (1.5fr, 1fr),
    gutter: 1pt,
    [
      - *OMNeT++:* Biblioteca e framework de simulação C++ extensível, modular e baseado em componentes, voltado para a construção de simuladores de rede (comunicação com fio, sem fio, redes em chip, filas, etc.) @omnetpp_manual.

      - *INET:* Biblioteca de modelos de código aberto para o ambiente OMNeT++, mantida pela equipe do OMNeT++ para a comunidade. Fornece protocolos, agentes e modelos para redes de comunicação, sendo especialmente útil para projetar e validar novos protocolos ou explorar cenários complexos @meszaros2019inet.

      - *Relação:* O INET é considerado a biblioteca padrão de modelos de protocolo do OMNeT++, contendo modelos para a pilha Internet (TCP, UDP, IPv4, IPv6), Ethernet, IEEE 802.11, entre outros.
    ],
    [
      #align(center + horizon)[
        #figure(
          image("img/omnet-inet.png", width: 50%),
          caption: [OMNeT++. Fonte: OMNeT++ Documentation @omnetpp_manual.],
        )
      ]
    ],
  )
]

#slide[
  == Pergunta e Escopo

  - *Pergunta:* O Time-Aware Shaper (TAS) consegue isolar um fluxo crítico, com características de `PublishingInterval` curto do OPC UA PubSub, da interferência de tráfego best-effort concorrente?

  - *Escopo Delimitado:*
    + *Não* implementa o stack OPC UA real (integração `open62541` + OMNeT++).
    + *Modela-se* o padrão temporal do tráfego PubSub com `UdpSourceApp` no INET.
    + *Avalia-se* latência e jitter do fluxo crítico com e sem TAS.

  - O foco está no comportamento temporal da rede, não na semântica dos dados.
]

#title-slide(back-color: rgb("#88d38d"))[
  Metodologia
]

#slide[
  == Modelo de Tráfego e Topologia

  - *Fluxo Crítico (Controle):*
    + `packetLength` ≈ 72 B 
    + `productionInterval` = 1 ms 
    +  ≈ 0,576 Mbps
    + `pcp` = 4 (alta prioridade)

  - *Fluxo Best-Effort (Monitoramento):*
    + `packetLength` ≈ 1500 B
    + `productionInterval` = `exponential(200us)`
    +  ≈ 60 Mbps
    + `pcp` = 0 (best-effort)

  - *Topologia:* Rede linear com um switch TSN, adaptada do showcase `timeawareshaper` do INET 4.6.
]

#slide[
  == Cenários de Avaliação

  - *Cenário A — Baseline (sem TAS):*
    + `hasEgressTrafficShaping = false`
    + Fluxo crítico compete com best-effort em fila única (prioridade simples)
    + Espera-se: latência e jitter elevados sob carga

  - *Cenário B — Com TAS:*
    + `hasEgressTrafficShaping = true`
    + Gate schedule reserva janela fixa para o fluxo crítico (PCP 4)
    + Espera-se: latência estável e jitter mínimo, imune à carga sem requisitos de tempo real

  - *Métricas:* Latência fim-a-fim e jitter do fluxo crítico.
]

#title-slide(back-color: rgb("#88d38d"))[
  Resultados Esperados e Contribuições
]

#slide[
  == Resultados Esperados

  - *Cenário A (sem TAS):* O fluxo crítico sofre interferência do tráfego best-effort; latência e jitter apresentam alta variabilidade.

  - *Cenário B (TAS ativado + carga sem requisitos de tempo real alta):* O TAS isola o fluxo crítico em janelas dedicadas; latência permanece estável e o jitter é reduzido a níveis desprezíveis, mesmo sob carga intensa de tráfego best-effort.

  // - *Cenário C (TAS ativado + carga sem requisitos de tempo real reduzida):* A latência e o jitter do fluxo crítico permanecem no mesmo nível baixo do Cenário B, ou apresentam melhora marginal. Isso confirma que o TAS já isolou efetivamente a interferência do tráfego de fundo, e que a estabilidade do fluxo crítico *não depende* da redução da carga concorrente.

]

#slide[
  == Contribuições e Limitações

  - *Contribuições:*
    + Demonstração quantitativa do benefício do TAS para um perfil de tráfego industrial típico.
    + Evidência de que o gap de configuração PubSub↔TSN tem impacto mensurável em latência e jitter.
    + Metodologia replicável usando apenas o INET, sem hardware TSN.

  - *Limitações:*
    + Tráfego modelado, não gerado por publisher OPC UA real.
    + Topologia simplificada.
    + Trabalho futuro: integração do stack `open62541` ao OMNeT++ para validação com tráfego real.
]

#hide[#cite(<inet_tas_showcase>)]
#let bib = bibliography("bibliography.bib")
#bibliography-slide(bib, title: "Referências")

// #slide[
//   == Cenários de Avaliação

//   - *Cenário A — Baseline (sem TAS):*
//     + `hasEgressTrafficShaping = false`
//     + Fluxo crítico compete com best-effort em fila única (prioridade simples)
//     + Espera-se: latência e jitter elevados sob carga

//   - *Cenário B — Com TAS (carga sem requisitos de tempo real alta):*
//     + `hasEgressTrafficShaping = true`
//     + Gate schedule reserva janela fixa para o fluxo crítico (PCP 4)
//     + Best-effort com `exponential(200us)` (~60 Mbps)
//     + Espera-se: latência estável e jitter mínimo, imune à carga sem requisitos de tempo real

//   - *Cenário C — Com TAS (carga sem requisitos de tempo real reduzida):*
//     + `hasEgressTrafficShaping = true` 
//     + Mesmo gate schedule do Cenário B
//     + Best-effort com `exponential(1ms)` (~12 Mbps)
//     + Espera-se: latência e jitter no mesmo nível do Cenário B, confirmando que o benefício do TAS é estrutural e não depende da carga

//   - *Métricas:* Latência fim-a-fim e jitter do fluxo crítico.
// ]

// #title-slide(back-color: rgb("#88d38d"))[
//   Resultados Esperados e Contribuições
// ]

// #slide[
//   == Resultados Esperados

//   - *Cenário A (sem TAS):* O fluxo crítico sofre interferência do tráfego best-effort; latência e jitter apresentam alta variabilidade.

//   - *Cenário B (TAS ativado + carga sem requisitos de tempo real alta):* O TAS isola o fluxo crítico em janelas dedicadas; latência permanece estável e o jitter é reduzido a níveis desprezíveis, mesmo sob carga intensa de tráfego best-effort.

//   - *Cenário C (TAS ativado + carga sem requisitos de tempo real reduzida):* A latência e o jitter do fluxo crítico permanecem no mesmo nível baixo do Cenário B. Confirmando que o TAS já isolou efetivamente a interferência do tráfego de fundo, e que a estabilidade do fluxo crítico *não depende* da redução da carga concorrente.

//   - *Conclusão Esperada:* O TAS é eficaz para o perfil de tráfego modelado a partir do OPC UA PubSub. O Cenário C demonstra que o benefício é estrutural (isolamento por janelas temporais), não um efeito de baixa carga — evidenciando o valor do mapeamento explícito entre parâmetros de aplicação e classes TSN.
// ]