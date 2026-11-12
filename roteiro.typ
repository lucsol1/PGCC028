#set page(
  paper: "a4",
  margin: (x: 2.5cm, y: 2.5cm),
  header: align(right)[
    #text(size: 9pt, fill: rgb("#666666"))[Roteiro de Apresentação — OPC UA PubSub & TSN]
  ],
  footer: [
    #set text(size: 9pt, fill: rgb("#666666"))
    #grid(
      columns: (1fr, 1fr),
      [Tópicos Especiais em Computação Inteligente I],
      align(right)[Página #context counter(page).display()]
    )
  ]
)

#set text(font: "Liberation Sans", size: 11pt, lang: "pt")
#set par(justify: true, leading: 0.8em)

#align(center)[
  #text(weight: "bold", size: 16pt)[Roteiro de Narração: Timing Analysis of TSN-Enabled OPC UA PubSub] \
  #v(0.3em)
  #text(size: 11pt, fill: rgb("#444444"))[Guia passo a passo para a apresentação de 15 minutos baseada nos slides]
]

#v(1.5em)

== Slide 1 a 3: Introdução e Contexto (0:00 – 2:00)
"Olá! Sejam muito bem-vindos. Hoje vamos destrinchar um artigo científico de ponta na área de sistemas embarcados e automação: o trabalho intitulado *'Timing Analysis of TSN-Enabled OPC UA PubSub'*.

Para começar, qual é o grande problema que motivou essa pesquisa? Se olharmos para a Indústria 4.0, o objetivo é claro: transformar a automação tradicional — aquela pirâmide vertical rígida com barramentos proprietários como EtherCAT ou PROFINET — em uma arquitetura plana e interconectada baseada em IP. 

O desafio histórico é fechar o abismo entre a Tecnologia Operacional (OT) do chão de fábrica, que exige determinismo estrito e prazos fixos, e a Tecnologia da Informação (TI), que usa redes comerciais focadas em desempenho médio. 

Para unir esses mundos, a indústria aposta na união do OPC UA PubSub — que otimiza a troca cíclica de dados sem o peso do modelo cliente-servidor — com redes TSN (Time-Sensitive Networking) na camada de enlace. Porém, há um buraco científico: embora o TSN garanta o trânsito na rede, o comportamento temporal do software OPC UA PubSub nos nós finais (*endpoints*) era totalmente desconhecido. Sem acotar esse tempo via software, as garantias de ponta a ponta colapsam."

#v(1em)

== Slide 4 a 6: Background (2:00 – 4:30)
"Indo para a fundamentação teórica, como medimos isso? Através da análise estática de WCET (Worst-Case Execution Time), que calcula o limite superior absoluto do tempo de execução de um programa sem precisar executá-lo. Processadores comerciais modernos (x86 ou ARM) usam caches LRU dinâmicas e execução fora de ordem, o que torna a análise estática imprevisível. 

Por isso, os autores utilizaram a plataforma previsível no tempo T-CREST e o processador Patmos — um processador RISC baseado em pilha equipado com *method caches* e um controlador de memória determinístico. Além disso, aplicaram o padrão TSN IEEE 802.1Qbv, que usa modeladores conscientes do tempo (*Time-Aware Shapers*) para isolar tráfego crítico."

#v(1em)

== Slide 7: Trabalhos Relacionados (4:30 – 5:30)
"Na literatura, a escassez de estudos sobre OPC UA PubSub em ambientes distribuídos de tempo real era evidente. Enquanto outros estudos focavam em RTOS genéricos ou simulações baseadas em IP, este artigo destaca-se por ser o primeiro a integrar formalmente a pilha open-source `open62541` a análises estáticas completas de WCET em hardware previsível."

#v(1em)

== Slide 8: Latência Ponta a Ponta (5:30 – 7:00)
"Modelando o fluxo de ponta a ponta (como ilustra a Figura 3 do artigo), o atraso engloba desde o disparo cíclico da tarefa (*TaskSchedulingDelay*), passando pela codificação e empacotamento UDP/IP/Ethernet com a injeção da tag VLAN 802.1q, até o trânsito físico na rede TSN e a recepção e decodificação no assinante."

#v(1em)

== Slide 9: Ajustes do Publisher e Subscriber (7:00 – 9:30)
"Para viabilizar isso, duas modificações estruturais foram feitas na pilha `open62541`:
1. Injeção da Tag VLAN: Inserida diretamente na função de envio do Patmos.
2. Gerenciamento de Memória no Subscriber: O código original usava `malloc` e `free` dinâmicos para mensagens de tamanho desconhecido. Como o heap dinâmico é imprevisível para o WCET, os autores o eliminaram e criaram um alocador estático customizado limitado estritamente a 32 blocos fixos de 256 bytes, preservando a assinatura da API C sem quebrar a pilha."

#pagebreak()

== Slide 10 a 12: Avaliação e Resultados (9:30 – 12:00)
"Passando para a avaliação experimental com duas FPGAs Cyclone IV rodando a 80 MHz e analisadores lógicos de 500 MHz:
*Resultados de WCET:* A tag VLAN adicionou um incremento marginal de apenas 22 microssegundos. O publisher escala linearmente com o payload, enquanto o subscriber possui WCET maior e invariável devido ao pior caso do bloco fixo.
*Latência Ponto a Ponto:* Os valores medidos ficaram confortavelmente abaixo do WCET teórico. Uma anomalia marcante ocorreu com payloads de 128 bits, cujo tempo de codificação disparou 4 vezes devido a estouros de pilha no Patmos.
*Redes TSN:* A inserção de switches elevou o atraso médio de rede. Com portas restritas agindo como filtros severos, a ausência de sincronização de relógio de hardware gerou saltos abruptos de latência de cauda."

#v(1em)

== Slide 13 e 14: Discussão e Conclusão (12:00 – 15:00)
"Para fechar, a grande lição do artigo é que o elo mais crítico para o tempo real não é a rede TSN, mas sim o software do endpoint e seu gerenciamento de memória. Além disso, há uma limitação crítica atual: é impossível rodar o OPC UA PubSub em concorrência com o modelo Cliente-Servidor na mesma interface de rede sem corromper as garantias determinísticas.

Como trabalhos futuros, os autores apontam a integração de sincronização de relógio por hardware (IEEE 802.1AS), o desenvolvimento de buffers dinâmicos previsíveis e drivers Ethernet não-bloqueantes. Muito obrigado pela atenção!"