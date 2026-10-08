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
  
  title: "OPC UA Over TSN (Time Sensitive Network) for Vertical and Machine to Machine Communication",
  subtitle: "Sistemas de Numeração",
  authors: "Abdollah Moshiri e Ali Mohammad Afshin Hemmatyar",
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
  - OPC UA (Open Platform Communications - Unified Architecture)  associado ao TSN (Time-Sensitive Network - IEEE 802.1) na camada 2 para suprir a necessidade de comunicação determinística e de baixo jitter na manufatura inteligente
  - *Objetivo: * superar a dependência de barramentos de campo proprietários e fragmentados, permitindo a comunicação vertical (do campo/sensores até a nuvem) e horizontal (máquina a máquina / M2M) em uma única rede baseada em hardware Ethernet padrão e de baixo custo.

]

#slide[
  - A Ethernet não dispõe de mecanismos para o reconhecimento de frames recebidos, tornando-a um meio conhecido como não confiável. As confirmações têm de ser implementadas nas camadas superiores. Além disso, o padrão Ethernet impôs restrições tanto nos comprimentos mínimo como máximo de um frame, conforme pode ser visto na Figura 13.5.
  - Em OT, o *PROFINET* é o padrão de comunicação de _Ethernet_ Industrial para conectar dispositivos de automoação, como CLPs sensores e IHMs (Nível de Campo).
  - OPC UA é aplicado no nível de controle. 

  #figure(
    image("img/figure1.png", width: 80%),
    caption: [Comprimentos mínimo e máximo de um frame. Fonte @forouzan2008],
  )
  
]
#slide[
  - OT gerencia processos físicos em tempo real diferentemente de TI.
  - Malhas de controle não podem utilizar _ack_ _packet by packet_ na camada de transporte comum, vide que o tempo de espera e retransmissão gera variações imprevisíveis (_jitter_) e inválida a transmissão em tempo real.
  - Em OT um quadro com comandos de controle for perdido sem um mecanismo     adequado, robôs ou atuadores podem falhar na execução ou perder o sincronismo.
  
]

#title-slide(back-color: rgb("#88d38d"))[
  Tecnologias e Padrões
]

#slide[
   _Time Sensitive Networking_ (TSN) surge para preencher essa lacuna e de acordo com @s22041638 suas características são:

   1. Sincronizaçao de tempo: Grandmaster Clock;
   2. Latência baixa e garantida (Bounded Low Latency - BLL): Agendamento de tráfego usando o IEEE 802.1Qbv e classes de prioridade no trafego;
   3. Ultraconfiabilidade: Usa IEEE 802.1CB, o padrão duplica as mensagens quadrado a quadra e envia por faminnhos físicos separados;
   4. Gerenciamento de recursos: Utiliza IEEE 802.1Qcc para configurar e reservar os recursos da rede.
]

#slide[
 
  #figure(
    image("img/figure2.png", width: 80%),
    caption: [OPC UA sobre TSN mapeado nas camadas do modelo OSI. Fonte @10506350],
  )
]

#slide[

  #figure(
    image("img/figure3.png", width:50%),
    caption: [Componentes básicos do OPC UA e projetos importantes do padrão TSN. Fonte @10506350],
  )
]

#slide[

   - Na *Camada de Enlace/TSN*, na *Camada de Transporte e Aplicação*, emprega *Pub/Sub* e formato de dados UADP (_Unified Access Data Plane_) para tranmissão cíclica ded dados de controle em _real time_;
  - Configuração entr outros usa o modelo _Client/Server_ e TCP/IP;

    #figure(
    image("img/figure4.png", width:50%),
    caption: [Componentes básicos do OPC UA e projetos importantes do padrão TSN. Fonte @10506350],
  )
]
#slide[

  #figure(
    image("img/figure5.png", width:50%),
    caption: [O modelo centralizado Qcc concluído, incluindo aplicações de OPC UA, Fonte @10506350],
  )
  
]
#title-slide(back-color: rgb("#88d38d"))[
  Arquitetura OPC UA TSN para plataforma de manufatura discreta
]
#slide[
  - Para demonstrar a viabilidade do sistema, o artigo detalha um modelo de execução composto por três níveis:
  1. Camada de Nuvem da Fábrica (Factory Cloud Layer): Executa um cliente OPC UA sobre sistema Linux em um mini-PC;
  2. Camada Edge: Utiliza uma plataforma IoT/Linux rodando um Servidor de Agregação OPC UA (OPC UA Aggregation Server);
  3. Camada de Campo (Field Layer): Integra subsistemas heterogêneos, combinando tecnologias industriais legadas (como transportadores usando Powerlink) com subsistemas críticos baseados em robótica e controlados via TSN.

  #figure(
    image("img/figure6.png", width:50%),
    caption: [O layout de comunicação do OPC UA baseado em TSN para um sistema de manufatura discreta. CP significa Perfil de Comunicação; PL significa Powerlink., Fonte @10506350],
  )

  #figure(
    image("img/figure7.png", width:50%),
    caption: [O mecanismo de produção experimental concebido como estrutura, Fonte @10506350],
  )
]
#title-slide(back-color: rgb("#88d38d"))[
  Execução do sistema OPC UA TSN E Conclusões
]

#slide[
  - O trabalho calcula matematicamente as latências de transmissão $tau$ e retardo de propagação $Gamma$, comparando o OPC UA TSN com tecnologias tradicionais (Profinet IRT, EtherCAT, Powerlink, EtherNet/IP, SERCOS III e Modbus/TCP) em topologias de até 100 nós.
  - Em infraestruturas Gigabit Ethernet (1 Gbps), o OPC UA TSN reduz drasticamente os tempos de ciclo e o tempo de encaminhamento (forwarding latency para 780 ns), superando o desempenho de barramentos tradicionais de 100 Mbps por um fator de até 18 vezes
  - OPC UA sobre TSN é a solução mais promissora para a Indústria 4.0.
]

// Bibliografia
#let bib = bibliography("bibliography.bib")
#bibliography-slide(bib, title: "Referências")
