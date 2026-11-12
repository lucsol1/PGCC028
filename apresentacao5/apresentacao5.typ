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
  Experimentos 1
]

#slide[
  == Cenários de Avaliação

  - *Cenário A — Baseline (sem TAS):*
    + `hasEgressTrafficShaping = false`
    + Fluxo crítico compete com best-effort pela mesma interface de saída
    + Espera-se: latência e jitter elevados sob carga

  - *Cenário B — Com TAS:*
    + `hasEgressTrafficShaping = true`
    + Gate schedule reserva janela fixa para o fluxo crítico (PCP 4)
    + Espera-se: latência estável e jitter mínimo, independentemente da carga best-effort

  - *Métricas:* latência fim-a-fim (`meanBitLifeTimePerPacket`, conferida com `packetLifeTime`) e jitter, definido como o desvio padrão da diferença entre latências consecutivas.
]


#slide[
  == Execução no INET

  - *Ambiente:* OMNeT++ 6.4.0 + INET 4.6.0, instalados via `opp_env` no Linux Fedora.

  - *Configurações executadas:*
    + `ScenarioA_NoTAS` — `extends = General`, `hasEgressTrafficShaping = false`
    + `ScenarioB_WithTAS` — `extends = TimeAwareShaping`, gate schedule de 20 µs (PCP 4) / 980 µs (PCP 0)

  - *Gravação de resultados:*
    + `**.vector-recording = true`
    + `**.server.app[*].meanBitLifeTimePerPacket.record = true`

  - *Duração:* `sim-time-limit = 1s`, uma execução por cenário (≈130 mil eventos no Cenário B; ~0,9 s de tempo real). Amostra: 1000 pacotes críticos por cenário.
]

#slide[
  == Rodando

  #figure(
        image("img/exp.png", width: 100%),
        caption: [Configuração],
      )
  #grid(
    columns: (1.2fr, 1fr),
    gutter: 12pt,
    [
      #figure(
        image("img/test1-cen1.png", width: 100%),
        caption: [Cenário A],
      )
    ],
    [
      #figure(
        image("img/test1-cen2.png", width: 100%),
        caption: [Cenário B],
      )
    ],
  )
]

#slide[
  == Latência do Fluxo Crítico ao Longo do Tempo

  #grid(
    columns: (1.2fr, 1fr),
    gutter: 12pt,
    [
      #figure(
        image("img/figura1.png", width: 100%),
        caption: [Série temporal da latência — A vs. B.],
      )
    ],
    [
      - *Cenário A:* latência varia de ≈11,6 µs até ≈144 µs; o limite superior é compatível com o bloqueio por um quadro best-effort de 1500 B (~120 µs a 100 Mbps).

      - *Cenário B:* latência constante em ≈11,62 µs, sem picos.

      - O mínimo de A coincide com o valor de B: o TAS não reduz a latência "base", ele elimina a espera.
    ],
  )
]

#slide[
  == Distribuição e Boxplot

  #grid(
    columns: (1.3fr, 1fr),
    gutter: 12pt,
    [
      #figure(
        image("img/figura2.png", width: 100%),
        caption: [ECDF e histograma da latência (B é um valor constante).],
      )
    ],
    [
      #figure(
        image("img/figura3.png", width: 100%),
        caption: [Boxplot comparativo por cenário.],
      )
    ],
  )
]

#slide[
  == Jitter e Estatísticas Descritivas

  #grid(
    columns: (1.1fr, 1fr),
    gutter: 12pt,
    [
      #figure(
        image("img/figura4.png", width: 100%),
        caption: [Variação entre latências consecutivas (jitter).],
      )
    ],
    [
      - *Cenário A:* média ≈ 47,8 µs, desvio ≈ 39,6 µs, jitter ≈ 56,4 µs. 

      - *Cenário B:* desvio e jitter iguais a zero; máximo = média = 11,62 µs.

      - A tabela (figura 8) resume `n`, média, desvio, mediana, mín/máx, p95, p99 e jitter.
    ],
  )
  #figure(
        image("img/figura5.png", width: 100%),
        caption: [Estatísticas básicas.],
      )
]

#slide[
  == Discussão dos Resultados

  - *Resultado:* neste cenário, o TAS eliminou a interferência do tráfego best-effort sobre o fluxo crítico.

  - *Mecanismo:* a janela de 20 µs a cada 1 ms (PCP 4) impede que o fluxo crítico espere a transmissão de um quadro de 1500 B.

  - *Impacto quantitativo:* desvio padrão de ≈39,6 µs para 0 e latência máxima de ≈144 µs para 11,62 µs.

  - *Ressalva principal:* o jitter nulo em B decorre de um cenário idealizado, com `productionInterval` (1 ms) sincronizado ao ciclo do gate (1 ms). Sem essa sincronização, o pacote pode perder a janela e esperar o próximo ciclo.
]

#slide[
  == Limitações
    + Uma única execução de 1 s por cenário (sem repetições/seeds nem intervalos de confiança).
 
    + Tráfego modelado, não gerado por publisher OPC UA real; topologia com um único switch.
]

#slide[
  == Trabalhos Futuros

  - Repetir com múltiplas seeds (`repeat`) e reportar intervalos de confiança.

  - Cenário C (TAS ativado + carga de fundo reduzida) para confirmar que o benefício é estrutural.

  - Tentar usar clientes OPC UA

  - Estender a topologia para múltiplos switches.

]