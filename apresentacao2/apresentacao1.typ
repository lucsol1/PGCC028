#import "meu-template.typ": *

#set text(lang: "pt", region: "BR")
#show: meu-template.with(
  ratio: "16-9",
  theme: rgb("#016521"),
  font: "Jetbrains Monaspace",
  font-size: 18pt,
  link-style: "color",
  show-progress: true,
  show-kicker: true,          //O: mostra o nome da seção no topo de todo slide
  // back-image: "img/fundo.png",  // <- descomente para um fundo de imagem em TODOS os slides
)

#front-slide(
  
  title: "Timing Analysis of TSN-Enabled OPC UA PubSub",
  authors: "Patrick Denzler, Thomas Fruhwirth†, Daniel Scheuchenstuhl, Martin Schoeberl and Wolfgang Kastner",
  info: [Tópicos Especiais em Computação Inteligente I],
  // date: auto é o padrão -> hoje, formatada em pt-BR automaticamente
  // date: "Agosto de 2026",    // <- ou passe uma data/texto fixo
  // back-image: "img/capa.png", // <- fundo de imagem só na capa
  back-color: rgb("#e5ffe0")
)

#table-of-contents(title: "Sumário")

#title-slide(back-color: rgb("#88d38d"))[
  Introdução
]


#slide[
  - Objetivo da Pesquisa: Integrar OPC UA PubSub a redes TSN, analisando o comportamento temporal por meio do pior tempo de execução (WCET).
  - Cenário Atual: A Automação (OT) usa barramentos rígidos e determinísticos (PROFINET, EtherCAT), enquanto o Corporativo (TI) usa redes IP de melhor esforço (best-effort).
  - Indústria 4.0: Busca unificar essas camadas em uma rede IP única, permitindo a comunicação direta do sensor à nuvem.
  - O Conflito: TI prioriza a vazão média (throughput) com componentes comerciais. OT exige latência estrita, jitter determinístico e prazos fixos (deadlines).
  - Solução:
	  - OPC UA PubSub: Transmissão cíclica por multicast/broadcast que elimina o peso do modelo cliente-servidor tradicional, reduzindo o overhead.
	  - TSN (IEEE 802.1): Atua na Camada 2 para garantir isolamento de tráfego, priorização e sincronização temporal via Time-Aware Shaper.
  - Embora o TSN garanta o determinismo na rede, os sistemas finais (endpoints) têm comportamento temporal desconhecido. Sem um limite matemático para o software (WCET), a garantia de ponta a ponta (end-to-end) colapsa.
]


#title-slide(back-color: rgb("#88d38d"))[
  Background
]

#slide[

]

#slide[
 
  // #figure(
  //   image("img/figure2.png", width: 80%),
  //   caption: [OPC UA sobre TSN mapeado nas camadas do modelo OSI. Fonte @10506350],
  // )
]

#slide[

  // #figure(
  //   image("img/figure3.png", width:50%),
  //   caption: [Componentes básicos do OPC UA e projetos importantes do padrão TSN. Fonte @10506350],
  // )
]

#slide[

   - Na *Camada de Enlace/TSN*, na *Camada de Transporte e Aplicação*, emprega *Pub/Sub* e formato de dados UADP (_Unified Access Data Plane_) para tranmissão cíclica ded dados de controle em _real time_;
  - Configuração entr outros usa o modelo _Client/Server_ e TCP/IP;

  //   #figure(
  //   image("img/figure4.png", width:50%),
  //   caption: [Componentes básicos do OPC UA e projetos importantes do padrão TSN. Fonte @10506350],
  // )
]
#slide[

  // #figure(
  //   image("img/figure5.png", width:50%),
  //   caption: [O modelo centralizado Qcc concluído, incluindo aplicações de OPC UA, Fonte @10506350],
  // )
  
]
#title-slide(back-color: rgb("#88d38d"))[
  Trabalhos Relacionados
]
#slide[
  - Para demonstrar a viabilidade do sistema, o artigo detalha um modelo de execução composto por três níveis:
  1. Camada de Nuvem da Fábrica (Factory Cloud Layer): Executa um cliente OPC UA sobre sistema Linux em um mini-PC;
  2. Camada Edge: Utiliza uma plataforma IoT/Linux rodando um Servidor de Agregação OPC UA (OPC UA Aggregation Server);
  3. Camada de Campo (Field Layer): Integra subsistemas heterogêneos, combinando tecnologias industriais legadas (como transportadores usando Powerlink) com subsistemas críticos baseados em robótica e controlados via TSN.

  // #figure(
  //   image("img/figure6.png", width:50%),
  //   caption: [O layout de comunicação do OPC UA baseado em TSN para um sistema de manufatura discreta. CP significa Perfil de Comunicação; PL significa Powerlink., Fonte @10506350],
  // )

  // #figure(
  //   image("img/figure7.png", width:50%),
  //   caption: [O mecanismo de produção experimental concebido como estrutura, Fonte @10506350],
  // )
]
#title-slide(back-color: rgb("#88d38d"))[
  Latência ponta a ponta do OPC UA PubSub via TSN
]

#slide[
  - O trabalho calcula matematicamente as latências de transmissão $tau$ e retardo de propagação $Gamma$, comparando o OPC UA TSN com tecnologias tradicionais (Profinet IRT, EtherCAT, Powerlink, EtherNet/IP, SERCOS III e Modbus/TCP) em topologias de até 100 nós.
  - Em infraestruturas Gigabit Ethernet (1 Gbps), o OPC UA TSN reduz drasticamente os tempos de ciclo e o tempo de encaminhamento (forwarding latency para 780 ns), superando o desempenho de barramentos tradicionais de 100 Mbps por um fator de até 18 vezes
  - OPC UA sobre TSN é a solução mais promissora para a Indústria 4.0.
]

#title-slide(back-color: rgb("#88d38d"))[
  Configuração do Publisher e do Subscriber OPC UA
]

#title-slide(back-color: rgb("#88d38d"))[
  Avaliação
]

#title-slide(back-color: rgb("#88d38d"))[
  Discussão e Conclusão
]

// Bibliografia
#let bib = bibliography("bibliography.bib")
#bibliography-slide(bib, title: "Referências")
