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
  title: "Timing Analysis of TSN-Enabled OPC UA PubSub",
  authors: "Patrick Denzler, Thomas Frühwirth, Daniel Scheuchenstuhl, Martin Schoeberl and Wolfgang Kastner",
  info: [Tópicos Especiais em Computação Inteligente I],
  back-color: rgb("#e5ffe0")
)

#table-of-contents(title: "Sumário")

#title-slide(back-color: rgb("#88d38d"))[
  Introdução
]

#slide[
  == O Contexto da Indústria 4.0 e a Convergência OT/TI
  - *Objetivo:* Migrar a automação industrial tradicional (pirâmide vertical com barramentos proprietários como EtherCAT ou PROFINET) para uma arquitetura plana e interconectada baseada em IP.
  - *O Abismo Histórico:* 
    - *OT (Tecnologia Operacional):* Sensores, atuadores e CLPs focados em determinismo estrito e prazos fixos (_deadlines_).
    - *TI (Tecnologia da Informação):* Sistemas MES e ERP rodando em hardware comercial (_COTS_) focados em desempenho médio, sem restrições temporais determinísticas.
]

#slide[
  == As Tecnologias de Convergência e o Problema Central
  - *Ferramentas:* Combinação de *OPC UA PubSub* (comunicação padronizada e de baixo *overhead*) com redes *TSN (Time-Sensitive Networking)* para transporte determinístico na camada de enlace.
  - *O Vazio Científico:* Embora o TSN garanta o transporte pontual na rede, *a maioria dos sistemas finais (endpoints) não é compatível com TSN*, e *o comportamento temporal do software OPC UA PubSub nos nós finais é totalmente desconhecido*.
  - *Solução do Artigo:* Estender a pilha open-source `open62541` para análise de WCET (_Worst-Case Execution Time_) e introduzir a tag VLAN IEEE 802.1q.
]

#title-slide(back-color: rgb("#88d38d"))[
  Background
]

#slide[
  == A. Análise de WCET e Ferramentas
  #grid(
    columns: (1fr, 1fr),
    gutter: 20pt,
    [
      - *WCET e BCET:* Limites superior e inferior do tempo de execução de um programa @kulkarni2016.
      - *Análise Estática vs. Medição:* Testes empíricos perdem caminhos críticos. A análise estática avalia matematicamente sem executar o código @kulkarni2016:
        1. *Análise de Fluxo:* Identifica caminhos, limites máximos de loops e caminhos inviáveis no CFG.
        2. *Análise de Baixo Nível:* Modela o impacto de hardwares modernos (caches, pipelines, execução *out-of-order*).
        3. *Cálculo:* Aplica programação linear ou árvores para acotar o WCET.
    ],
    [
      #align(center + horizon)[
        #figure(
          image("img/figure1.png", width: 100%),
          caption: [Noções básicas de análise temporal. Fonte @Denzler],
        )
      ]
    ]
  )
]

#slide[
  == B. Plataformas Previsíveis no Tempo (T-CREST)
  - *O Problema do Hardware Comercial:* Processadores x86/ARM possuem caches LRU dinâmicas e execução fora de ordem, tornando a análise estática imprevisível ou excessivamente pessimista.
  - *A Solução (T-CREST / Patmos):* Arquitetura de hardware desenvolvida especificamente para previsibilidade temporal:
    - *Caches de Métodos (*Method Caches*):* Carregam métodos inteiros em blocos previsíveis.
    - *Controlador de Memória Previsível:* Acessos à RAM rigorosamente determinísticos.
]

#slide[
  == C. OPC UA e TSN (IEEE 802.1Qbv)
  #grid(
    columns: (1fr, 1fr),
    gutter: 20pt,
    [
      #align(center + horizon)[
        #figure(
          image("img/figure2.png", width: 100%),
          caption: [Layout do quadro Ethernet com tag VLAN  . Fonte @Denzler],
        )
      ]
    ],
    [
      - *OPC UA PubSub:* Focado em minimizar o *overhead* de comunicação para a troca cíclica de dados de processo em tempo de execução (pilha `open62541`).
      - *TSN (IEEE 802.1Qbv):* Utiliza modeladores conscientes do tempo (*Time-Aware Shaper*) e marcações VLAN para isolar e priorizar o tráfego crítico na Camada 2 (Data Link).
    ]
  )
]

#title-slide(back-color: rgb("#88d38d"))[
  Trabalhos Relacionados
]

#slide[
  == Panorama da Literatura
  - *Escassez:* Estudos sobre OPC UA PubSub em ambientes distribuídos de tempo real de ponta a ponta ainda são raros.
  - *Abordagens Anteriores:* Uso de interrupções de hardware em RTOS, TSN na camada de aplicação, reconfiguração via SDN e simulações de campo baseadas em IP (*best-effort*).
  - *Diferencial deste Artigo:* A pilha open-source `open62541` é amplamente utilizada, mas este trabalho pioneiramente a integra a análises formais de WCET em uma arquitetura de hardware previsível.
]

#title-slide(back-color: rgb("#88d38d"))[
  Latência Ponta a Ponta do OPC UA PubSub via TSN
]

#slide[
  == Modelagem de Atrasos (Figura 3 do Artigo)
   #grid(
    columns: (1fr, 1fr),
    gutter: 20pt,
    [
      #align(center + horizon)[
        #figure(
          image("img/figure3.png", width: 100%),
          caption: [Diagrama de latência ponta a ponta do OPC UA PubSub via TSN. Fonte @Denzler],
        )
      ]
    ],
    [
      - *TaskSchedulingDelay:* Atraso entre a alteração do sinal físico e o disparo cíclico da tarefa.
      - *Encode & UdpSend (Publisher):* Serialização do sinal (Partes 6 e 14 do OPC UA), encapsulamento UDP/IP/Ethernet e injeção da tag VLAN 802.1q (analisável para WCET).
      - *EthSend & Transmit:* Envio físico pelo controlador MAC e trânsito na rede TSN com priorização em switches.
      - *EthRec, UdpRec & Decode (Subscriber):* Recepção de hardware e processamento de software analisável para WCET.
    ]
  )
  #figure(
    image("img/figure4.png"),
    caption: [Configuração de avaliação com três configurações de rede diferentes. Fonte @Denzler]
  )
]

#title-slide(back-color: rgb("#88d38d"))[
  Ajustes do Publisher e Subscriber OPC UA
]

#slide[
  == Modificações Críticas na Pilha `open62541`
  - *Injeção da Tag VLAN (802.1q):* Implementada diretamente na função `sendto` dos arquivos de arquitetura do Patmos.
  - *O Calcanhar de Aquiles (Gerenciamento de Memória no Subscriber):*
    - O subscriber original usava `malloc` e `free` dinâmicos para mensagens de tamanho desconhecido.
    - *O Problema:* Alocações de heap genéricas possuem complexidade temporal imprevisível, destruindo o WCET.
    - *A Solução:* Eliminação do `malloc` padrão e criação de um alocador estático customizado limitado a *32 blocos fixos de 256 bytes cada* (preservando a assinatura da API C).
]

#title-slide(back-color: rgb("#88d38d"))[
  Avaliação
]

#slide[
  
  == A. Configuração Experimental
  #grid(
    columns: (1fr, 1fr),
    gutter: 20pt,
    [
      - *Hardware:* Duas FPGAs Altera DE2-115 (Cyclone IV a 80 MHz) rodando o Patmos.
      - *Instrumentação:* Analisador lógico *Saleae Logic Pro 8* (500 MHz) acoplado a pinos GPIO para medição nanométrica.
      - *Topologias:* Conexão ponto a ponto direta, 1 switch TSN e 2 switches TSN em cascata (NERVE MFN100 a 100 Mbit/s).
    ],
    [
      == Tabela I: Limites de WCET e Latência de Ponta a Ponta
      #set text(size: 14pt) 
      #table(
        columns: (2.2fr, 1.2fr, 1.2fr),
        align: (left, center, center),
        table.header(
          [*Componente SW / HW*], 
          [*Upper bound (Sem Tag VLAN)*], 
          [*Upper bound (Com Tag VLAN)*]
        ),
        [PublishCallback], [249 µs], [271 µs],
        [-- Dois `uint32` /msg], [--], [342 µs],
        [-- Três `uint32` /msg], [--], [435 µs],
        [-- Quatro `uint32` /msg], [--], [528 µs],
        [SubscribeCallback], [15.149,5 µs], [15.503,4 µs],
        [End-To-End Latency + NetworkDelay], [15.398,5 µs], [15.774,4 µs],

      )
    ]
  )

]

#slide[
  == B. Resultados de WCET e C. Latência Ponto a Ponto
  - *Impacto do WCET:* A tag VLAN adicionou apenas 22 µs ao WCET do publisher. O publisher escala linearmente com o payload; o subscriber possui WCET maior e invariável (assume o pior caso do bloco fixo de 256 bytes).
  - *Latência Ponto a Ponto:* Valores medidos abaixo do WCET teórico (validando a segurança estática).
  - *A Anomalia de 128-bit:* Payloads de 128 bits exigiram um tempo de codificação (*Encode*) 4x maior devido a estouros de pilha (*stack-cache spill/fill*) no Patmos.

  #slide[
    == Tabela II: Medições de Tempo com Payloads Variáveis
    #set text(size: 11pt) 
    #table(
      columns: (2.5fr, 1fr, 1fr, 1fr, 1fr),
      align: (left, center, center, center, center),
      table.header(
        [*Componente SW / HW*], 
        [*32 bit*], 
        [*64 bit*], 
        [*96 bit*], 
        [*128 bit*]
      ),
      [TaskSchedulingDelay], [not rel.], [not rel.], [not rel.], [not rel.],
      [PublishCallback], [153.47 µs], [224.91 µs], [261.09 µs], [696.15 µs],
      [-- Encode], [57.45 µs], [125.01 µs], [159.10 µs], [569.91 µs],
      [-- UdpSend], [83.46 µs], [87.34 µs], [89.42 µs], [112.89 µs],
      [-- Pre- and Postprocessing], [12.56 µs], [12.56 µs], [12.56 µs], [13.35 µs],
      [EthSend + NetworkDelay + EthRec], [31.31 µs], [31.44 µs], [31.08 µs], [31.08 µs],
      [SubscribeCallback], [646.41 µs], [716.03 µs], [756.21 µs], [770.95 µs],
      [-- UdpRec], [19.71 µs], [24.59 µs], [27.03 µs], [56.28 µs],
      [-- Decode], [605.27 µs], [670.00 µs], [707.75 µs], [693.34 µs],
      [-- Pre- and Postprocessing], [21.43 µs], [21.44 µs], [21.43 µs], [21.34 µs],
      [*End-To-End Latency*], [*798.66 µs*], [*939.84 µs*], [*1015.85 µs*], [*1464.93 µs*],
    )
  ]
]

#slide[
  == D. Latência em Redes TSN
  - *Efeito dos Switches:* A mediana do atraso de rede subiu de 31,31 µs (ponto a ponto) para 50,37 µs (1 switch) e 57,34 µs (2 switches).
  - *Portas como Filtros Severos:* Janelas de tempo restritas nos *gates* forçaram mensagens perdidas a esperar o próximo ciclo. A ausência de sincronização de relógio entre os switches gerou picos severos de latência de cauda.
]

#title-slide(back-color: rgb("#88d38d"))[
  Discussão e Conclusão
]

#slide[
  == Discussão dos Achados
  - *O Foco nos Endpoints:* O elo crítico para o tempo real não é a rede TSN, mas sim o software do sistema final (*endpoint*) e seu gerenciamento de memória.
  - *Conflito na Porta Ethernet:* Impossibilidade atual de rodar OPC UA PubSub em concorrência com o modelo Cliente-Servidor na mesma interface de rede sem corromper as garantias determinísticas.
]

#slide[
  == Conclusão e Trabalhos Futuros
  - *Conclusão:* Viabilidade comprovada de estender a pilha `open62541` com VLAN 802.1q na plataforma T-CREST para limites confiáveis de WCET.
  - *Próximos Passos:*
    1. Integrar sincronização de relógio por hardware (IEEE 802.1AS).
    2. Desenvolver gerenciamento de buffer dinâmico previsível.
    3. Garantir acesso concorrente e sem bloqueios (*non-blocking*) à porta Ethernet e ao modelo de informação.
]

#let bib = bibliography("bibliography.bib")
#bibliography-slide(bib, title: "Referências")