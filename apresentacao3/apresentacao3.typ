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
  title: "Improving TSN Simulation Accuracy in OMNET++: A Hardware-Aligned Approach",
  authors: "H.-H. Liu, S. Senk, M. Ulbricht, H. K. Nazari, T. Scheinert, M. Reisslein, G. T. Nguyen e F. H. P. Fitzek",
  info: [Tópicos Especiais em Computação Inteligente I],
  back-color: rgb("#e5ffe0"),
)

#table-of-contents(title: "Sumário")

#title-slide(back-color: rgb("#88d38d"))[
  Introdução
]

#slide[
  == O Contexto e a Relevância do TSN

  - *Objetivo:* Garantir desempenho quase determinístico (*jitter* e latência limitados) em redes com fio, viabilizando aplicações críticas como Indústria 4.0, V2X e Internet Tátil.

  - *O Desafio do Hardware:* Acessibilidade limitada e alto custo de hardware TSN tornam a *simulação* indispensável para validar projetos em larga escala.

  - *O Papel do OMNET++:* Cerca de 53% das simulações TSN utilizam o OMNET++ (majoritariamente integradas com a biblioteca *INET*).

  - *O Problema Central:* O INET modela recursos TSN, mas *raramente é validado com hardware real*, exibindo discrepâncias graves de sincronização, latência e suporte a recursos combinados.
]

#slide[
  == Contribuições Principais do Artigo

  - *Validação Experimental Rigorosa:* Comparação direta entre simulações do INET e uma bancada de hardware real (*TSN-FlexTest*) com switches comerciais (Kontron D10 MMT e FibroLAN Falcon-RX/G).

  - *Identificação de Falhas no INET:*
    + Dinâmicas de sincronização *gPTP* incorretas (saltos de degrau).
    + Subestimação severa das latências de comutação *Store-and-Forward* (SF) e *Cut-Through* (CT).
    + Incompatibilidade estrutural ao combinar CT com Preempção de Quadros (FP).

  - *Abordagem Alinhada ao Hardware:* Proposta de modificações estruturais na biblioteca INET e disponibilização do código-fonte modificado.
]

#title-slide(back-color: rgb("#88d38d"))[
  Background e Conceitos do TSN
]

#slide[
  == Os 4 Pilares do TSN no Escopo do Estudo

  - *gPTP (IEEE 802.1AS):* Sincronização de tempo precisa baseada na camada de enlace (arquitetura mestre-escravo e compensação de osciladores).

  - *Comutação Cut-Through (CT):* Encaminhamento imediato do quadro antes da recepção completa, reduzindo a latência em relação ao *Store-and-Forward* (SF).

  - *Time-Aware Shaper (TAS - IEEE 802.1Qbv):* Isolamento de tráfego crítico (ST) através de janelas temporais baseadas em uma Lista de Controle de Portas (GCL).

  - *Preempção de Quadros (FP - IEEE 802.3br / 802.1Qbu):* Interrupção de tráfego de fundo não crítico para dar passagem imediata a pacotes urgentes (com suporte opcional ao mecanismo *Hold-Release*).
]

#title-slide(back-color: rgb("#88d38d"))[
  Modificações na Estrutura de Simulação (INET)
]

#slide[
  == A. Modelagem de Atrasos (SF e CT)

  - *Store-and-Forward (SF):* O INET original considerava apenas o atraso de transmissão ($d_t$). O artigo introduziu uma constante de atraso $beta_(upright("sf"))$ para modelar o processamento real do switch e o trânsito no *fabric*.

  - *Cut-Through (CT):* O INET original ignorava o comportamento real dependente do tamanho do quadro. O novo modelo implementa uma função linear com limite de saturação (*plateau*):

  $
    d_(upright("ct")) = cases(
      alpha_(upright("ct")) f + beta_(upright("ct")), quad "se" quad f <= F_T,
      alpha_(upright("ct")) F_T + beta_(upright("ct")), quad "se" quad f > F_T
    )
  $

  *Figura 4:* Modificações na interface Ethernet para suporte a CT.
]

#slide[
  == B. Sincronização gPTP e C. Combinação CT + FP

  - *Ajuste gPTP Modificado:* Substituição do salto de degrau instantâneo (*step jump*) por um controle gradual da frequência do oscilador e introdução de parâmetros de ponderação para aproximar o comportamento do *Linux-PTP*.

  - *Resolução de Conflito (CT + FP):* O INET original impedia o uso simultâneo de CT e FP devido a incompatibilidades entre as camadas MAC e PHY. Os autores criaram novas camadas híbridas (`EthernetFragmentingThroughMacLayer` e `EthernetPreemptingThroughPhyLayer`).
]

#title-slide(back-color: rgb("#88d38d"))[
  Avaliação Experimental e Resultados
]

#slide[
  == 1. Desvio de Clock (gPTP)

  #grid(
    columns: (1fr, 1fr),
    gutter: 2pt,
    [
      - *O Problema:* A versão original do INET gerava saltos artificiais no desvio de clock.

      - *A Solução:* A "Modificação 2" proposta alinhou a simulação ao comportamento dos switches físicos (Kontron e FibroLAN).

      - Maior frequência de mensagens `Sync` (ex.: 128 mensagens/s) estabiliza o desvio abaixo de aproximadamente 10 ns.
    ],
    [
      #align(center + horizon)[
        #figure(
          image("img/figure1.png", width: 100%),
          caption: [Noções básicas de análise temporal. Fonte @10549887],
        )
      ]
    ],
  )
]

#slide[
  == 2. Latência de Encaminhamento (SF vs. CT)

  #grid(
    columns: (1fr, 1fr),
    gutter: 2pt,
    [
      - *Store-and-Forward:* A adição de $beta_(upright("sf"))$ corrigiu a subestimação do INET original.

      - *Cut-Through:* O INET modificado reproduziu com precisão o crescimento linear inicial e o *plateau* característico do hardware real.

      - Para quadros de 1514 B, o INET modificado atinge latência CT de 4,86 µs, próxima aos 4,99 µs da FibroLAN.
    ],
    [
      #align(center + horizon)[
        #figure(
          image("img/figure2.png", width: 95%),
          caption: [Noções básicas de análise temporal. Fonte @10549887],
        )
      ]
    ],
  )
]

#slide[
  == 3. Desempenho do TAS e Preempção de Quadros (FP)

  #grid(
    columns: (1fr, 1fr),
    gutter: 20pt,
    [
      - *TAS:* A aplicação do agendamento temporal eliminou o *jitter*, gerando distribuições quase verticais (altamente determinísticas) consistentes com o hardware.

      - *FP Combinado:* O INET original apresentava erros de aproximadamente 10 µs ao combinar CT e FP. Com a nova arquitetura híbrida, o erro caiu para menos de 1 µs, alcançando precisão submicrossegundo.
    ],
    [
      #align(center + horizon)[
        #figure(
          image("img/figure3.png", width: 95%),
          caption: [Noções básicas de análise temporal. Fonte @10549887],
        )
      ]
    ],
  )
]

#title-slide(back-color: rgb("#88d38d"))[
  Conclusão e Trabalhos Futuros
]

#slide[
  == Conclusões Principais

  - *Simulação Fiel:* As modificações propostas eliminaram as principais lacunas entre o OMNET++/INET e o hardware TSN comercial.

  - *Código Aberto:* As melhorias foram integradas e disponibilizadas publicamente para a comunidade científica, facilitando análises escaláveis de redes TSN.

  - *Importância da Combinação:* Validou-se que a união de TAS, CT e FP eleva o determinismo da rede de forma expressiva.
]

#slide[
  == Direções para Futuras Pesquisas

  + Expandir a avaliação de sincronização *gPTP* para *redes de múltiplos saltos* (*multi-hop*).
  + Integrar outros modeladores e mecanismos TSN, como *Credit-Based Shaper* (CBS), *Asynchronous Traffic Shaper* (ATS) e FRER.
  + Combinar as simulações TSN com modelos de *redes sem fio 5G/6G* de código aberto.
  + Desenvolver componentes de plano de controle centralizado (CUC/CNC) no INET.
]

#let bib = bibliography("bibliography.bib")
#bibliography-slide(bib, title: "Referências")
