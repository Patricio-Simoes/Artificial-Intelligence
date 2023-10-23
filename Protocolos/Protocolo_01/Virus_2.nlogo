globals [path-color internal-color external-color lake-center-x lake-center-y lake-size lake-radius healthy-color infected-color incub-color vaccinated-color imune-color total-infections incubations imune-prob death-prob deaths agents-cured agents-imune spread-radius weather-status weather-prob v-prog v-rate v-flag]
breed [humans human]
breed [dogs dog]
breed [cats cat]
breed [weathers weather]
humans-own [infected p_r0 imune virus p_inf cure_ticks vaccinated cure-length cure-prob incub-timer incub incub-limit immunity immunity-timer]
dogs-own [virus p_inf dog-death-prob incub-timer incub incub-limit]
cats-own [virus p_inf cat-death-prob incub-timer incub incub-limit]

; O setup inialiiza o mundo. Desenha o ambiente e posiciona o número inicial de pessoas definido pelo slider.
; O vírus em questão é o covid-19.
to setup
  clear-all
  set path-color white ; Cor do caminho onde os agentes se movem.
  set internal-color brown ; Cor do pavimento interior.
  set external-color gray ; Cor do pavimento exterior.
  set healthy-color green ; Cor de um agente saudável, (sem vírus).
  set infected-color red ; Cor de um agente infetado.
  set vaccinated-color blue ; Cor de um agente vacinado.
  set incub-color yellow ; Cor de incubação do vírus.
  set imune-color black ; Cor de um agente imune à doença.
  set lake-center-x 0 ; Coordenada x do centro do lago.
  set lake-center-y 0 ; Coordenada y do centro do lago.
  set lake-size 11 ; Diâmetro do loago no centro do mapa.
  set lake-radius lake-size / 2 ; Raio do lago no centro do mapa.
  set agents-cured 0 ; Número de curas totais.
  set agents-imune 0 ; Número de agentes imunes à doença.
  set spread-radius 2 ; Raio de infeção de cada agente.
  set weather-status "Sol" ; Representa o estado atual do clima.
  set weather-prob 0.35 ; Probabilidade de infeção afetada pelo tempo, (Peso total de 40% no cálculo final). (Começa com 0.35 porque o estado inicial é clima quente).
  set imune-prob 0.20 ; Probabilidade de um agente curado se tornar imune à doença.
  set total-infections 0 ; Número total de infeções.
  set death-prob 0.10 ; Probabilidade de morrer da doença. (0.15 quando sol e 0.20 quando chuva).
  set deaths 0 ; Número total de mortes.
  set v-prog 0 ; Progresso da vacina.
  set v-rate 5 ; Taxa de incremento do progresso da vacina a cada tick.
  set v-flag false ; Flag que é acionada quando são detetados 5 agentes infetados para começar a produção da vacina.
  set incubations 0

  ; Cria um lago no centro do mapa.
  ask patches[
    if(pxcor = lake-center-x and pycor = lake-center-y)[
      ; O parâmetro passado é o diâmetro do lago.
      create-lake
    ]
  ]
  ; À volta lago coloca terra e relva num espaço de 4 patches.
  fill-nearby
  ; Desenha os caminhos por onde os agentes se movimentam.
  draw-paths
  ; Coloriza os restantes patches.
  fill-left
  ; Desenha a área onde é representado o estado de tempo atual.
  draw-weather-box
  ; Atualiza o estado inicial do tempo.
  update-weather weather-status
  ; Dá spawn ao número de humanos inicial selecionado na interface gráfica.
  spawn-people
  ; Dá spawn ao número de animais inicial selecionado na interface gráfica.
  spawn-animal
  reset-ticks
end

to create-lake
  let lake-color blue

  ask patches in-radius lake-radius [
    set pcolor lake-color
    ; Aleatóriamente gera um lily pad, (15% chance).
    let number random-float 1.0
    if(number <= 0.15)[
      sprout 1[set shape "lily pad" set color green]
    ]
  ]
end

to fill-nearby
  let dirt-distance 3
  let green-distance 10

  ask patches [
    ; Numa distância de 6 patches coloriza o caminho.
    if distance (patch lake-center-x lake-center-y) <= lake-radius + green-distance and distance (patch lake-center-x lake-center-y) >= lake-radius + dirt-distance[
      set pcolor path-color
      ;sprout 1 [set shape "tile stones" set color tile-color]
    ]
    ; Numa distância de 2 patches coloriza o interior entre o caminho e o lago.
    if distance (patch lake-center-x lake-center-y) <= lake-radius + dirt-distance and distance (patch lake-center-x lake-center-y) >= lake-radius[
      set pcolor internal-color
    ]
  ]
end

to draw-paths
  ask patches[
    if(pcolor = 0 and pxcor < 3 and pxcor > -3)[
      set pcolor path-color
      ;sprout 1 [set shape "tile stones" set color tile-color]
    ]
    if(pcolor = 0 and pycor < 3 and pycor > -3)[
      set pcolor path-color
      ;sprout 1 [set shape "tile stones" set color tile-color]
    ]
  ]
end

to fill-left
  ask patches[
    ; Coloriza os patches com a cor externa.
    if(pcolor = 0)[
      set pcolor external-color
    ]
  ]
end

to spawn-people
  ; Apenas gera humanos nos patches cuja cor é igual à cor do caminho.
  create-humans population[
    set virus "saudável"
    set p_inf random-float 1
    set shape "person"
    set size 1
    set color healthy-color
    set cure_ticks 0
    set imune false
    set infected 0
    set p_r0 0
    set vaccinated false
    set cure-length 14
    set cure-prob 0.30
    set incub-limit 5
    set incub-timer 0
    set incub false
    set immunity false
    set immunity-timer 0
    let spawn-patch one-of patches with [pcolor = path-color]
    ; Se o patch for branco, posiciona o agente nas coordenadas desse patch.
    if spawn-patch != nobody [
      setxy [pxcor] of spawn-patch [pycor] of spawn-patch
    ]
  ]
end

to draw-weather-box
  ask patches[
    if (pxcor <= 16 and pxcor >= 14 and pycor <= 16 and pycor >= 14)[
      set pcolor black
    ]
  ]
  create-weathers 1[
    setxy 15 15
    set shape "sun"
    set color yellow
    set size 3
  ]
end

to update-weather [option]
  ask weathers[
    ; Clima: Sol.
    if(option = "Sol")[
      set weather-status "Sol"
      set weather-prob 0.35
      set death-prob 0.10
      set shape "sun"
      set color yellow
    ]
    ; Clima: Chuva.

    if(option = "Chuva")[
      set weather-status "Chuva"
      set weather-prob 0.60
      set death-prob 0.20
      set shape "drop"
      set color blue
    ]
  ]
end


; A função go_once faz com que todos os humanos avancem um patch.
; Os humanos apenas avanças se o patch diretamente à sua frente for branco, caso contrário, entram num ciclo que os faz mudar de direção até que esta condição seja satisfeita.
to go_once
  ; Aleatóriamente altera o estado atual do clima entre "Sol" e "Chuva".
  ifelse(random-float 1 <= 0.50)[
    update-weather "Sol"
  ]
  [
    update-weather "Chuva"
  ]
  ask humans[
    ; Uma vez que o mundo tem fronteiras, é preciso verificar se o patch-ahead é de facto um patch.
    let next-patch patch-ahead 1
    ; Verifica se é patch.
    ifelse is-patch? next-patch[
      ; Verifica se a cor é branca e pode avançar.
      ifelse ([pcolor] of next-patch = white)[
        forward 1
      ]
      ; A cor não é branca. Muda de direção.
      [
        ; Muda de direção para trás num raio de 180º.
        set heading random 360
      ]
    ]
    [
      ; Não é patch.
      ; Muda de direção.
      set heading random 360
    ]
  ]
  ask dogs[
    ; Uma vez que o mundo tem fronteiras, é preciso verificar se o patch-ahead é de facto um patch.
    let next-patch patch-ahead 1
    ; Verifica se é patch.
    ifelse is-patch? next-patch[
      ; Verifica se a cor é branca e pode avançar.
      ifelse ([pcolor] of next-patch = white)[
        forward 1
      ]
      ; A cor não é branca. Muda de direção.
      [
        ; Muda de direção para trás num raio de 180º.
        set heading random 360
      ]
    ]
    [
      ; Não é patch.
      ; Muda de direção.
      set heading random 360
    ]
  ]
  ask cats[
    ; Uma vez que o mundo tem fronteiras, é preciso verificar se o patch-ahead é de facto um patch.
    let next-patch patch-ahead 1
    ; Verifica se é patch.
    ifelse is-patch? next-patch[
      ; Verifica se a cor é branca e pode avançar.
      ifelse ([pcolor] of next-patch = white)[
        forward 1
      ]
      ; A cor não é branca. Muda de direção.
      [
        ; Muda de direção para trás num raio de 180º.
        set heading random 360
      ]
    ]
    [
      ; Não é patch.
      ; Muda de direção.
      set heading random 360
    ]
  ]
  ; Chama a função infect de modo a infetar outros agentes caso as condições o permitam.
  infect
  ; Chama a função cure de modo a curar os agentes ao fim de cure-length ticks.
  cure
  ; Chama a funçao kill a cada 3 ticks de modo a matar agentes infetados com base na probabilidade associada.
  if(ticks mod 3 = 0)[
    kill
  ]
  ; Sinaliza que a produção da vacina pode começar quando existem 5 ou mais agentes infetados.
  if(total-infections >= 5)[
    set v-flag true
  ]
  ; Avança o progesso da vacina em v-rate % a cada tick.
  if(v-flag = true)[
    make-vaccine
  ]
  ; Assim que a vacina estiver pronta, começa a vacinar os humanos ainda não vacinados.
  if(v-prog = 100)[
    vaccinate-humans
  ]
  ; Avança 1 tick na incubação dos agentes com vírus.
  incubate
  ; Gere os períodos temporários de imunidade.
  recover
  tick
end

; A função go_n basicamente chama a função go_once n vezes mediante o valor do slider.
to go_n
  let n 0
  while[n < n_ticks][
    go_once
    set n n + 1
  ]
end

; A função go chama a função go_once de forma contínua.
to go
  go_once
end

; A função spread seleciona um dos agentes saudáveis e infeta-o.
to spread
  ; Verifica se ainda há agentes saudáveis.
  if (any? humans with [virus = "saudável" and imune = false])[
    ask one-of humans[
      ifelse (virus = "saudável")[
        set virus "com virus"
        set color infected-color
        set total-infections total-infections + 1
      ]
      ; Chamada recursiva até que um agente saudável seja encontrado.
      [
        spread
      ]
    ]
  ]
end

; A função infect é chamada dentro da função go_once e é esta a função encarregue de infetar outros agentes.
; A equação que traduz a probabilidade que um agente tem de infetar outro é a seguinte:
; P(x) = P(R0) * 0.60 + P(C) * 0.40
to infect
  ; A probabilidade de infeção é calculada com base na fórmula apresentada acima:
  ; A probabilidade do tempo é controlada pela variável weather-prob na função update-weather.
  ask humans with [virus = "com virus"][
    ; Cálculo da probabilidade de infeção com base no número total de infetados pelo agente, (p_r0):
    if(infected < 2)[
      ; A probabilidade de infeção é muito maior quando o número total de infetados se situa abaixo de 2.
      set p_r0 0.75
    ]
    if(infected >= 2 and infected < 3)[
      ; A probabilidade de infeção é mediana quando neste intervalo.
      set p_r0 0.50
    ]
    if(infected >= 3)[
      ; A probabilidade de infeção é muito menor quando o número de infetados se encontra acima de 3.
      set p_r0 0.15
    ]
    ; Uma vez que a variável weather-prob é controlada fora desta função, podemos aplicar diretamente a fórmula:
    set p_inf (p_r0 * 0.35 + weather-prob * 0.65)
    ; Caso a probabilidade seja maior ou igual que um número gerado aleatóriamente, procedemos para a infeção de outros agentes.
    ; No entanto, caso o humano-alvo esteja vacinado, a probabilidade de infeção é reduzida em 50%.
    let prob-aux random-float 1
    if(prob-aux <= p_inf)[
      ; Um agente afeta outros agentes quando estes se encontram num raio de spread-radius patches).
      if any? other humans in-radius spread-radius[
        ask other humans in-radius spread-radius[
          ; Os outros humanos apenas são infetados se não forem imunes à doença.
          if(imune = false and virus = "saudável")[
            ; Está vacinado.
            ifelse(vaccinated = true)[
              if(prob-aux <= p_inf / 2)[
                set color incub-color
                set incub true
                set incubations incubations + 1
              ]
            ]
            ; Não está vacinado.
            [
              set color incub-color
              set incub true
              set incubations incubations + 1
            ]

          ]
        ]
      ]
      if any? other dogs in-radius spread-radius[
        ask other dogs in-radius spread-radius[
          if(virus = "saudável")[
            set color incub-color
            set incub true
            set incubations incubations + 1
          ]
        ]
      ]
      if any? other cats in-radius spread-radius[
        ask other humans in-radius spread-radius[
          if(virus = "saudável")[
            set color incub-color
            set incub true
            set incubations incubations + 1
          ]
        ]
      ]
    ]
  ]
  ; A probabilidade de um cão infetar outro agente é muito baixa, no entanto o raio de contágio é muito maior do que de humano para humano.
  ask dogs with [virus = "com virus"][
    let prob-aux random-float 1
    let dogs-spread spread-radius + 10
    set p_inf (0.05 + weather-prob * 0.65)
    ; Caso a probabilidade seja maior ou igual que um número gerado aleatóriamente, procedemos para a infeção de outros agentes:
    if(prob-aux <= p_inf)[
      if any? other humans in-radius dogs-spread[
        ask other humans in-radius spread-radius[
          ; Os outros humanos apenas são infetados se não forem imunes à doença.
          if(imune = false and virus = "saudável")[
            ; Está vacinado.
            ifelse(vaccinated = true)[
              if(prob-aux <= p_inf / 2)[
                set color incub-color
                set incub true
                set incubations incubations + 1
              ]
            ]
            ; Não está vacinado.
            [
              set color incub-color
              set incub true
              set incubations incubations + 1
            ]
          ]
        ]
      ]
      ; Da mesma forma, um cão pode infetar outro cão ou um gato.
      if any? other dogs in-radius dogs-spread[
        ask other dogs in-radius dogs-spread[
          if(virus = "saudável")[
            set color incub-color
            set incub true
            set incubations incubations + 1
          ]
        ]
      ]
      if any? other cats in-radius dogs-spread[
        ask other cats in-radius dogs-spread[
          if(virus = "saudável")[
            set color incub-color
            set incub true
            set incubations incubations + 1
          ]
        ]
      ]
    ]
  ]
  ; Já um gato, tem uma probabilidade muito alta de infetar outros agentes e um raio muito curto.
  ; A probabilidade de um cão infetar outro agente é muito baixa, no entanto o raio de contágio é muito maior do que de humano para humano.
  ask cats with [virus = "com virus"][
    let prob-aux random-float 1
    let cats-spread 1
    set p_inf (0.35 + weather-prob * 0.65)
    ; Caso a probabilidade seja maior ou igual que um número gerado aleatóriamente, procedemos para a infeção de outros agentes:
    if(prob-aux <= p_inf)[
      if any? other humans in-radius cats-spread[
        ask other humans in-radius spread-radius[
          ; Os outros humanos apenas são infetados se não forem imunes à doença.
          if(imune = false and virus = "saudável")[
            ; Está vacinado.
            ifelse(vaccinated = true)[
              if(prob-aux <= p_inf / 2)[
                set color incub-color
                set incub true
                set incubations incubations + 1
              ]
            ]
            ; Não está vacinado.
            [
              set color incub-color
              set incub true
              set incubations incubations + 1
            ]
          ]
        ]
      ]
      ; Da mesma forma, um cão pode infetar outro cão ou um gato.
      if any? other dogs in-radius cats-spread[
        ask other dogs in-radius cats-spread[
          if(virus = "saudável" and incub = false)[
            set color incub-color
            set incub true
            set incubations incubations + 1
          ]
        ]
      ]
      if any? other cats in-radius cats-spread[
        ask other cats in-radius cats-spread[
          if(virus = "saudável")[
            set color incub-color
            set incub true
            set incubations incubations + 1
          ]
        ]
      ]
    ]
  ]
end

; A função cure é chamada dentro da função go_onde e é esta a função que cura os agentes ao fim de cure-length ticks.
to cure
  ; Com o passar de cada tick, incrementa a variável cure_ticks de cada agente infetado. Ao chegar a cure-length ticks, o agente em questão é capaz de se curar.
  ask humans with [virus = "com virus"][
    ; Passado o período mínimo de cura, o agente tem uma chance de se auto-curar.
    ifelse(cure_ticks >= cure-length)[
      ; Um agente auto-cura-se.
      ifelse(random-float 1 <= cure-prob)[
        set immunity true
        set immunity-timer 3
        set color healthy-color
        set virus "saudável"
        set cure_ticks 0
        set p_inf random-float 1
        set agents-cured agents-cured + 1
        ; Se o agente em questão estiver vacinado, aumenta as chances deste se auto-curar da próxima vez que apanhar o vírus
        if(vaccinated = true)[
          ; O período mínimo nunca excede os 3 ticks.
          if(cure-length >= 6)[
            set cure-length cure-length - 3
          ]
          ; A probabilidade de cura nunca excede os 75%.
          if(cure-prob <= 0.65)[
            set cure-prob cure-prob + 0.10
          ]
          ; Em adição, a cor de um agente vacinado curado nunca voltará a ser verde.
          set color vaccinated-color
        ]
        ; Um agente que se auto-cure tem uma chance mínima de se tornar imune à doença
        if(random-float 1 <= imune-prob)[
          set color imune-color
          set imune true
          set immunity-timer 3
          set agents-imune agents-imune + 1
        ]
      ]
      ; Um agente não se consegue auto-curar.
      []
    ]
    ; Caso ainda não tenham passado 7 ticks, incrementa em 1.
    [
      set cure_ticks cure_ticks + 1
    ]
  ]
end

; A função kill é chamada dentro da função go_once e mediante o estado atual do clima e da probabilidade gerada, mata um agente infetado.
to kill
  ask humans with [virus = "com virus"][
    if(random-float 1 <= death-prob)[
      set deaths deaths + 1
      die
    ]
  ]
  ask dogs with [virus = "com virus"][
    ; Um cão dura no máximo 10 ticks sem morrer.
    ifelse(random-float 1 <= dog-death-prob / 10)[
      set deaths deaths + 1
      die
    ]
    [
      set dog-death-prob dog-death-prob + 0.10
    ]
  ]
  ask cats with [virus = "com virus"][
    ; Um gato dura no máximo 10 ticks sem morrer.
    ifelse(random-float 1 <= cat-death-prob / 10)[
      set deaths deaths + 1
      die
    ]
    [
      set cat-death-prob cat-death-prob + 0.10
    ]
  ]
end

; A função spawn-animal gera um animal com uma probabilidade de 35% a cada tick.
to spawn-animal
  create-dogs n_dogs[
    set shape "dog"
    set color healthy-color
    set virus "saudável"
    set size 1
    set p_inf 0
    set dog-death-prob 0.10
    set incub-timer 0
    set incub-limit 3
    set incub false
    ; Se o patch for branco, posiciona o agente nas coordenadas desse patch.
    let spawn-patch one-of patches with [pcolor = path-color]
    if spawn-patch != nobody [
      setxy [pxcor] of spawn-patch [pycor] of spawn-patch
    ]
  ]
  create-cats n_cats[
    set shape "cat"
    set color healthy-color
    set virus "saudável"
    set size 1
    set p_inf 0
    set cat-death-prob 0.10
    set incub-timer 0
    set incub false
    set incub-limit 2
    ; Se o patch for branco, posiciona o agente nas coordenadas desse patch.
    let spawn-patch one-of patches with [pcolor = path-color]
    if spawn-patch != nobody [
      setxy [pxcor] of spawn-patch [pycor] of spawn-patch
    ]
  ]
end

; A função make-vaccine está encarregue de avançar o progresso da vacina a cada tick.
to make-vaccine
  if(v-prog <= 95)[
    set v-prog v-prog + v-rate
  ]
end

; A função vaccinate-humans está encarregue de vacinar humanos ainda não vacinados.
; Um máximo de 10 humanos são vacinados a cada tick
to vaccinate-humans
  let i random(10)
  while[i > 0][
    if (any? humans with [vaccinated = false and virus = "saudável"])[
      ask one-of humans with [vaccinated = false and virus = "saudável"][
        set color vaccinated-color
        set vaccinated true
      ]
    ]
    set i i - 1
  ]
end

; A função incubate está encarregue de gerir o período de incubação de um agente e no final de o infetar com o vírus.
to incubate
  ask humans[
    if(incub = true)[
      ; O vírus está em incubação.
      ifelse(incub-timer < incub-limit)[
        set incub-timer incub-timer + 1
      ]
      ; O período de incubação terminou e o agente é infetado.
      [
        set incub false
        set color infected-color
        set virus "com virus"
        set total-infections total-infections + 1
        set incub-timer 0
      ]
    ]
  ]
  ask dogs[
    if(incub = true)[
      ; O vírus está em incubação.
      ifelse(incub-timer < incub-limit)[
        set incub-timer incub-timer + 1
      ]
      ; O período de incubação terminou e o agente é infetado.
      [
        set incub false
        set color infected-color
        set virus "com virus"
        set total-infections total-infections + 1
        set incub-timer 0
      ]
    ]
  ]
  ask cats[
    if(incub = true)[
      ; O vírus está em incubação.
      ifelse(incub-timer < incub-limit)[
        set incub-timer incub-timer + 1
      ]
      ; O período de incubação terminou e o agente é infetado.
      [
        set incub false
        set color infected-color
        set virus "com virus"
        set total-infections total-infections + 1
        set incub-timer 0
      ]
    ]
  ]
end

; A função recover é a função encarregue de gerir os períodos de imunidade temporários que um agente humano recebe ao se curar do vírus.
to recover
  ask humans with [immunity = true][
    ifelse(immunity-timer > 0)[
      set immunity-timer immunity-timer - 1
    ]
    [
      set immunity false
    ]
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
427
10
831
415
-1
-1
12.0
1
10
1
1
1
0
0
0
1
-16
16
-16
16
0
0
1
ticks
120.0

BUTTON
9
10
112
64
Inicializar
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
128
10
300
43
population
population
1
500
100.0
1
1
NIL
HORIZONTAL

BUTTON
9
68
111
122
Go_Once
go_once
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
9
127
112
181
Go_N
go_n
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
128
128
300
161
n_ticks
n_ticks
0
100
10.0
1
1
NIL
HORIZONTAL

BUTTON
9
186
111
239
Go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
9
245
112
299
Spread
spread
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
865
121
1109
315
Humanos saudáveis
Ticks
Número Total
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -10899396 true "" "plot count humans with [virus = \"saudável\"]"

PLOT
1130
121
1374
315
Humanos infetados
Ticks
Número Total
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -2674135 true "" "plot count humans with [virus = \"com virus\"]"

MONITOR
865
64
1109
109
Humanos Saudáveis
count humans with [virus = \"saudável\"]
17
1
11

MONITOR
1130
64
1374
109
Humanos Infetados
count humans with [virus = \"com virus\"]
17
1
11

MONITOR
1400
64
1644
109
Nº total de curas
agents-cured
17
1
11

PLOT
1401
121
1645
318
Número de Curas
Ticks
Número Total
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot agents-cured"

MONITOR
865
10
1002
55
Clima atual
weather-status
17
1
11

MONITOR
1400
334
1646
379
Humanos Imunes à Doença
agents-imune
17
1
11

PLOT
1401
387
1645
580
Humanos imunes
Ticks
Número Total
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot agents-imune"

MONITOR
1400
10
1645
55
Número total de infeções
total-infections
17
1
11

MONITOR
1131
334
1375
379
Total de Mortes
deaths
17
1
11

PLOT
1131
386
1375
580
Número de Mortes
Ticks
Número Total
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot deaths"

MONITOR
709
425
830
470
Nº Cães
count dogs
17
1
11

MONITOR
582
424
702
469
Nº Gatos
count cats
17
1
11

SLIDER
127
48
299
81
n_cats
n_cats
0
50
10.0
1
1
NIL
HORIZONTAL

SLIDER
127
87
299
120
n_dogs
n_dogs
0
50
10.0
1
1
NIL
HORIZONTAL

MONITOR
580
529
832
574
Progresso da vacina (%)
v-prog
17
1
11

MONITOR
710
474
831
519
Nº Cães Infetados
count dogs with [virus = \"com virus\"]
17
1
11

MONITOR
582
473
702
518
Nº Gatos Infetados
count cats with [virus = \"com virus\"]
17
1
11

PLOT
866
387
1110
582
Humanos Vacinados
Ticks
Número Total
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -13345367 true "" "plot count humans with [vaccinated = true]"

MONITOR
865
589
1112
634
Humanos Vacinados Infetados
count humans with [virus = \"com virus\" and vaccinated = true]
17
1
11

MONITOR
866
330
1111
375
Total de Humanos Vacinados
count humans with [vaccinated = true]
17
1
11

MONITOR
865
640
1112
685
Humanos Vacinados Saudáveis
count humans with [virus = \"saudável\" and vaccinated = true]
17
1
11

MONITOR
1130
10
1374
55
Nº de Incubações
incubations
17
1
11

MONITOR
1400
585
1646
630
Humanos Temporariamente Imunes
count humans with [immunity = true]
17
1
11

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

building institution
false
0
Rectangle -7500403 true true 0 60 300 270
Rectangle -16777216 true false 130 196 168 256
Rectangle -16777216 false false 0 255 300 270
Polygon -7500403 true true 0 60 150 15 300 60
Polygon -16777216 false false 0 60 150 15 300 60
Circle -1 true false 135 26 30
Circle -16777216 false false 135 25 30
Rectangle -16777216 false false 0 60 300 75
Rectangle -16777216 false false 218 75 255 90
Rectangle -16777216 false false 218 240 255 255
Rectangle -16777216 false false 224 90 249 240
Rectangle -16777216 false false 45 75 82 90
Rectangle -16777216 false false 45 240 82 255
Rectangle -16777216 false false 51 90 76 240
Rectangle -16777216 false false 90 240 127 255
Rectangle -16777216 false false 90 75 127 90
Rectangle -16777216 false false 96 90 121 240
Rectangle -16777216 false false 179 90 204 240
Rectangle -16777216 false false 173 75 210 90
Rectangle -16777216 false false 173 240 210 255
Rectangle -16777216 false false 269 90 294 240
Rectangle -16777216 false false 263 75 300 90
Rectangle -16777216 false false 263 240 300 255
Rectangle -16777216 false false 0 240 37 255
Rectangle -16777216 false false 6 90 31 240
Rectangle -16777216 false false 0 75 37 90
Line -16777216 false 112 260 184 260
Line -16777216 false 105 265 196 265

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

cat
false
0
Line -7500403 true 285 240 210 240
Line -7500403 true 195 300 165 255
Line -7500403 true 15 240 90 240
Line -7500403 true 285 285 195 240
Line -7500403 true 105 300 135 255
Line -16777216 false 150 270 150 285
Line -16777216 false 15 75 15 120
Polygon -7500403 true true 300 15 285 30 255 30 225 75 195 60 255 15
Polygon -7500403 true true 285 135 210 135 180 150 180 45 285 90
Polygon -7500403 true true 120 45 120 210 180 210 180 45
Polygon -7500403 true true 180 195 165 300 240 285 255 225 285 195
Polygon -7500403 true true 180 225 195 285 165 300 150 300 150 255 165 225
Polygon -7500403 true true 195 195 195 165 225 150 255 135 285 135 285 195
Polygon -7500403 true true 15 135 90 135 120 150 120 45 15 90
Polygon -7500403 true true 120 195 135 300 60 285 45 225 15 195
Polygon -7500403 true true 120 225 105 285 135 300 150 300 150 255 135 225
Polygon -7500403 true true 105 195 105 165 75 150 45 135 15 135 15 195
Polygon -7500403 true true 285 120 270 90 285 15 300 15
Line -7500403 true 15 285 105 240
Polygon -7500403 true true 15 120 30 90 15 15 0 15
Polygon -7500403 true true 0 15 15 30 45 30 75 75 105 60 45 15
Line -16777216 false 164 262 209 262
Line -16777216 false 223 231 208 261
Line -16777216 false 136 262 91 262
Line -16777216 false 77 231 92 261

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dog
false
0
Polygon -7500403 true true 300 165 300 195 270 210 183 204 180 240 165 270 165 300 120 300 0 240 45 165 75 90 75 45 105 15 135 45 165 45 180 15 225 15 255 30 225 30 210 60 225 90 225 105
Polygon -16777216 true false 0 240 120 300 165 300 165 285 120 285 10 221
Line -16777216 false 210 60 180 45
Line -16777216 false 90 45 90 90
Line -16777216 false 90 90 105 105
Line -16777216 false 105 105 135 60
Line -16777216 false 90 45 135 60
Line -16777216 false 135 60 135 45
Line -16777216 false 181 203 151 203
Line -16777216 false 150 201 105 171
Circle -16777216 true false 171 88 34
Circle -16777216 false false 261 162 30

dot
false
0
Circle -7500403 true true 90 90 120

drop
false
0
Circle -7500403 true true 73 133 152
Polygon -7500403 true true 219 181 205 152 185 120 174 95 163 64 156 37 149 7 147 166
Polygon -7500403 true true 79 182 95 152 115 120 126 95 137 64 144 37 150 6 154 165

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

house colonial
false
0
Rectangle -7500403 true true 270 75 285 255
Rectangle -7500403 true true 45 135 270 255
Rectangle -16777216 true false 124 195 187 256
Rectangle -16777216 true false 60 195 105 240
Rectangle -16777216 true false 60 150 105 180
Rectangle -16777216 true false 210 150 255 180
Line -16777216 false 270 135 270 255
Polygon -7500403 true true 30 135 285 135 240 90 75 90
Line -16777216 false 30 135 285 135
Line -16777216 false 255 105 285 135
Line -7500403 true 154 195 154 255
Rectangle -16777216 true false 210 195 255 240
Rectangle -16777216 true false 135 150 180 180

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

lily pad
false
0
Polygon -7500403 true true 148 151 137 37 119 25 111 36 78 54 40 99 30 137 32 175 56 223 87 251 137 275 157 275 213 250 239 221 257 178 262 137 244 91 210 53 172 37 160 22 154 36
Line -13840069 false 154 151 207 97
Circle -13840069 false false 133 148 26
Line -13840069 false 52 122 134 157
Line -13840069 false 133 171 89 196
Line -13840069 false 147 193 147 254
Line -13840069 false 157 171 205 233
Line -13840069 false 161 161 204 163
Line -13840069 false 141 149 111 72

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

sun
false
0
Circle -7500403 true true 75 75 150
Polygon -7500403 true true 300 150 240 120 240 180
Polygon -7500403 true true 150 0 120 60 180 60
Polygon -7500403 true true 150 300 120 240 180 240
Polygon -7500403 true true 0 150 60 120 60 180
Polygon -7500403 true true 60 195 105 240 45 255
Polygon -7500403 true true 60 105 105 60 45 45
Polygon -7500403 true true 195 60 240 105 255 45
Polygon -7500403 true true 240 195 195 240 255 255

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tile stones
false
0
Polygon -7500403 true true 0 240 45 195 75 180 90 165 90 135 45 120 0 135
Polygon -7500403 true true 300 240 285 210 270 180 270 150 300 135 300 225
Polygon -7500403 true true 225 300 240 270 270 255 285 255 300 285 300 300
Polygon -7500403 true true 0 285 30 300 0 300
Polygon -7500403 true true 225 0 210 15 210 30 255 60 285 45 300 30 300 0
Polygon -7500403 true true 0 30 30 0 0 0
Polygon -7500403 true true 15 30 75 0 180 0 195 30 225 60 210 90 135 60 45 60
Polygon -7500403 true true 0 105 30 105 75 120 105 105 90 75 45 75 0 60
Polygon -7500403 true true 300 60 240 75 255 105 285 120 300 105
Polygon -7500403 true true 120 75 120 105 105 135 105 165 165 150 240 150 255 135 240 105 210 105 180 90 150 75
Polygon -7500403 true true 75 300 135 285 195 300
Polygon -7500403 true true 30 285 75 285 120 270 150 270 150 210 90 195 60 210 15 255
Polygon -7500403 true true 180 285 240 255 255 225 255 195 240 165 195 165 150 165 135 195 165 210 165 255

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.3.0
@#$#@#$#@
@#$#@#$#@
1.0
    org.nlogo.sdm.gui.AggregateDrawing 1
        org.nlogo.sdm.gui.StockFigure "attributes" "attributes" 1 "FillColor" "Color" 225 225 182 218 47 60 40
            org.nlogo.sdm.gui.WrappedStock "" "" 0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
