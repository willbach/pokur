/-  pokur
/+  pokur
=,  pokur
|%
++  test-determine-winner-tie-1
  ^-  tang
  =/  test-game-state
    [
      game-id=~2021.7.28..18.17.52..1849
      host=~zod
      type=%cash
      turn-time-limit=~s1
      time-limit-seconds=1
      players=~[~zod ~bus]
      paused=%.n
      update-message=""
      hands-played=0
      chips=~[[~zod 1.000 0 %.n %.n %.n] [~bus 1.000 0 %.n %.n %.n]]
      pots=~[[100 ~[~zod ~bus]]]
      current-bet=0
      min-bet=40
      last-bet=0
      board=~[[%10 %spades] [%king %spades] [%ace %spades] [%jack %spades] [%queen %spades]]
      my-hand=~
      whose-turn=~bus
      dealer=~bus
      small-blind=~bus
      big-blind=~zod
    ]
  =/  state
    [
      game=test-game-state
      hands=~[[~zod ~[[%jack %clubs] [%jack %hearts]]] [~bus ~[[%2 %spades] [%3 %spades]]]]
      deck=generate-deck
      hand-is-over=%.y
      turn-timer=~
    ]
  =/  winners
    (~(determine-winner modify-state state) hands.state)
  ?>  =((lent winners) 2)
  ~
++  test-determine-winner-tie-2
  ^-  tang
  =/  test-game-state
    [
      game-id=~2021.7.28..18.17.52..1849
      host=~zod
      type=%cash
      turn-time-limit=~s1
      time-limit-seconds=1
      players=~[~zod ~bus]
      paused=%.n
      update-message=""
      hands-played=0
      chips=~[[~zod 500 0 %.n %.n %.n] [~bus 1.000 0 %.n %.n %.n]]
      pots=~[[100 ~[~zod ~bus]]]
      current-bet=0
      min-bet=40
      last-bet=0
      board=~[[%jack %spades] [%king %hearts] [%ace %spades] [%jack %clubs] [%queen %spades]]
      my-hand=~
      whose-turn=~bus
      dealer=~bus
      small-blind=~bus
      big-blind=~zod
    ]
  =/  state
    [
      game=test-game-state
      hands=~[[~zod ~[[%jack %hearts] [%10 %hearts]]] [~bus ~[[%2 %hearts] [%10 %spades]]]]
      deck=generate-deck
      hand-is-over=%.y
      turn-timer=~
    ]
  =/  winners
    (~(determine-winner modify-state state) hands.state)
  ::~&  >>  winners
  =/  new-state 
    (~(process-win modify-state state) winners)
  ?>  =((lent winners) 2)
  ?>  =(-.-.pots.game.new-state 0)
  ?>  =(-.+.-.chips.game.new-state 550)
  ?>  =(-.+.-.+.chips.game.new-state 1.050)
  ~
++  test-determine-winner-1
  ^-  tang
  =/  test-game-state
    [
      game-id=~2021.7.28..18.17.52..1849
      host=~zod
      type=%cash
      turn-time-limit=~s1
      time-limit-seconds=1
      players=~[~zod ~bus]
      paused=%.n
      update-message=""
      hands-played=0
      chips=~[[~zod 1.000 0 %.n %.n %.n] [~bus 1.000 0 %.n %.n %.n]]
      pots=~[[100 ~[~zod ~bus]]]
      current-bet=0
      min-bet=40
      last-bet=0
      board=~[[%10 %spades] [%jack %clubs] [%jack %hearts] [%jack %spades] [%queen %spades]]
      my-hand=~
      whose-turn=~bus
      dealer=~bus
      small-blind=~bus
      big-blind=~zod
    ]
  =/  state
    [
      game=test-game-state
      hands=~[[~zod ~[[%king %spades] [%ace %spades]]] [~bus ~[[%2 %spades] [%3 %spades]]]]
      deck=generate-deck
      hand-is-over=%.y
      turn-timer=~
    ]
  =/  winner
    (~(determine-winner modify-state state) hands.state)
  ?>  =(-.-.winner ~zod)
  ~
++  test-determine-winner-2
  ^-  tang
  =/  test-game-state
    [
      game-id=~2021.7.28..18.17.52..1849
      host=~zod
      type=%cash
      turn-time-limit=~s1
      time-limit-seconds=1
      players=~[~zod ~bus]
      paused=%.n
      update-message=""
      hands-played=0
      chips=~[[~zod 1.000 0 %.n %.n %.n] [~bus 1.000 0 %.n %.n %.n]]
      pots=~[[100 ~[~zod ~bus]]]
      current-bet=0
      min-bet=40
      last-bet=0
      board=~[[%2 %spades] [%2 %clubs] [%jack %hearts] [%6 %spades] [%queen %clubs]]
      my-hand=~
      whose-turn=~bus
      dealer=~bus
      small-blind=~bus
      big-blind=~zod
    ]
  =/  state
    [
      game=test-game-state
      hands=~[[~zod ~[[%jack %spades] [%6 %clubs]]] [~bus ~[[%jack %diamonds] [%queen %spades]]]]
      deck=generate-deck
      hand-is-over=%.y
      turn-timer=~
    ]
  =/  winner
    (~(determine-winner modify-state state) hands.state)
  ?>  =(-.-.winner ~bus)
  ~
++  test-determine-winner-3
  ^-  tang
  =/  test-game-state
    [
      game-id=~2021.7.28..18.17.52..1849
      host=~zod
      type=%cash
      turn-time-limit=~s1
      time-limit-seconds=1
      players=~[~zod ~bus]
      paused=%.n
      update-message=""
      hands-played=0
      chips=~[[~zod 1.000 0 %.n %.n %.n] [~bus 1.000 0 %.n %.n %.n]]
      pots=~[[100 ~[~zod ~bus]]]
      current-bet=0
      min-bet=40
      last-bet=0
      board=~[[%2 %hearts] [%3 %clubs] [%3 %hearts] [%jack %spades] [%queen %spades]]
      my-hand=~
      whose-turn=~bus
      dealer=~bus
      small-blind=~bus
      big-blind=~zod
    ]
  =/  state
    [
      game=test-game-state
      hands=~[[~zod ~[[%2 %spades] [%2 %clubs]]] [~bus ~[[%2 %diamonds] [%3 %spades]]]]
      deck=generate-deck
      hand-is-over=%.y
      turn-timer=~
    ]
  =/  winner
    (~(determine-winner modify-state state) hands.state)
  ?>  =(-.-.winner ~bus)
  ~
++  test-determine-winner-4
  ^-  tang
  =/  test-game-state
    [
      game-id=~2021.7.28..18.17.52..1849
      host=~zod
      type=%cash
      turn-time-limit=~s1
      time-limit-seconds=1
      players=~[~zod ~bus ~nec]
      paused=%.n
      update-message=""
      hands-played=0
      chips=~[[~zod 1.000 0 %.n %.n %.n] [~bus 1.000 0 %.n %.n %.n] [~nec 1.000 0 %.n %.n %.n]]
      pots=~[[100 ~[~zod ~bus]]]
      current-bet=0
      min-bet=40
      last-bet=0
      board=~[[%8 %hearts] [%3 %spades] [%3 %hearts] [%jack %spades] [%queen %spades]]
      my-hand=~
      whose-turn=~bus
      dealer=~bus
      small-blind=~bus
      big-blind=~zod
    ]
  =/  state
    [
      game=test-game-state
      hands=~[[~zod ~[[%king %spades] [%7 %spades]]] [~bus ~[[%2 %spades] [%4 %spades]]] [~nec ~[[%8 %diamonds] [%3 %clubs]]]]
      deck=generate-deck
      hand-is-over=%.y
      turn-timer=~
    ]
  =/  winner
    (~(determine-winner modify-state state) hands.state)
  ?>  =(-.-.winner ~nec)
  ~
:: tie breaking tests
++  test-tie-break-1
  ^-  tang
  =/  hand1
    :-  0 :: high card
      :~  [%ace %spades] 
          [%2 %clubs] 
          [%3 %hearts] 
          [%4 %spades] 
          [%queen %spades] 
        ==
  =/  hand2
    :-  0
      :~  [%10 %spades] 
          [%jack %clubs] 
          [%5 %hearts] 
          [%6 %spades] 
          [%queen %spades] 
        ==
  ?>  (break-ties hand1 hand2)
  ~
++  test-tie-break-2
  ^-  tang
  =/  hand1
    :-  1 :: pair
      :~  [%2 %spades] 
          [%2 %clubs] 
          [%3 %hearts] 
          [%4 %spades] 
          [%queen %spades] 
        ==
  =/  hand2
    :-  1
      :~  [%10 %spades] 
          [%queen %clubs] 
          [%5 %hearts] 
          [%6 %spades] 
          [%queen %spades] 
        ==
  ?>  (break-ties hand2 hand1)
  ~
++  test-tie-break-3
  ^-  tang
  =/  hand1
    :-  1 :: pair
      :~  [%king %spades] 
          [%king %clubs] 
          [%ace %hearts] 
          [%4 %spades] 
          [%queen %spades] 
        ==
  =/  hand2
    :-  1
      :~  [%ace %spades] 
          [%queen %clubs] 
          [%5 %hearts] 
          [%6 %spades] 
          [%queen %spades] 
        ==
  ?>  (break-ties hand1 hand2)
  ~
:: testing kicker on 1 pair
++  test-tie-break-4
  ^-  tang
  =/  hand1
    :-  1 :: pair
      :~  [%king %spades] 
          [%2 %clubs] 
          [%queen %hearts] 
          [%4 %spades] 
          [%queen %spades] 
        ==
  =/  hand2
    :-  1
      :~  [%ace %spades] 
          [%2 %clubs] 
          [%queen %hearts] 
          [%6 %spades] 
          [%queen %spades] 
        ==
  ?>  (break-ties hand2 hand1)
  ~
++  test-tie-break-5
  ^-  tang
  =/  hand1
    :-  4 :: straight with 5 cards
      :~  [%2 %spades] 
          [%3 %spades] 
          [%4 %hearts] 
          [%5 %clubs] 
          [%6 %spades] 
        ==
  =/  hand2
    :-  4
      :~  [%3 %spades] 
          [%4 %hearts] 
          [%5 %clubs] 
          [%6 %spades] 
          [%7 %hearts] 
        ==
  ?>  (break-ties hand2 hand1)
  ~
:: 7-card hand evaluation tests
++  test-eval1
  ^-  tang
  =/  hand
    :~  [%10 %spades] 
        [%jack %clubs] 
        [%jack %hearts] 
        [%jack %spades] 
        [%queen %spades] 
        [%king %spades] 
        [%ace %spades]
      ==
  ?>  =(9 -:(evaluate-hand hand))
  ~
++  test-eval2
  ^-  tang
  =/  hand
    :~  [%10 %spades] 
        [%10 %clubs] 
        [%jack %hearts] 
        [%jack %spades] 
        [%queen %spades] 
        [%king %hearts] 
        [%king %diamonds]
      ==
  ?>  =(2 -:(evaluate-hand hand))
  ~
++  test-eval3
  ^-  tang
  =/  hand
    :~  [%2 %clubs] 
        [%3 %clubs] 
        [%4 %clubs] 
        [%jack %spades] 
        [%queen %spades] 
        [%ace %diamonds] 
        [%ace %spades]
      ==
  ?>  =(1 -:(evaluate-hand hand))
  ~
++  test-eval4
  ^-  tang
  =/  hand
    :~  [%10 %spades] 
        [%jack %clubs] 
        [%2 %hearts] 
        [%3 %hearts] 
        [%6 %spades] 
        [%king %spades] 
        [%ace %spades]
      ==
  ?>  =(0 -:(evaluate-hand hand))
  ~
++  test-eval5
  ^-  tang
  =/  hand
    :~  [%queen %spades] 
        [%jack %hearts] 
        [%2 %hearts] 
        [%10 %hearts] 
        [%6 %hearts] 
        [%king %hearts] 
        [%ace %spades]
      ==
  ?>  =(5 -:(evaluate-hand hand))
  ~
++  test-eval6
  ^-  tang
  =/  hand
    :~  [%6 %hearts] 
        [%king %hearts] 
        [%2 %hearts] 
        [%10 %hearts] 
        [%ace %spades]
        [%queen %spades] 
        [%jack %hearts] 
      ==
  ?>  =(5 -:(evaluate-hand hand))
  ~
++  test-eval7
  ^-  tang
  =/  hand
  ~[[%jack %hearts] [%10 %hearts] [%jack %spades] [%king %hearts] [%ace %spades] [%jack %clubs] [%queen %spades]] 
  ?>  =(4 -:(evaluate-hand hand))
  ~
++  test-eval8
  ^-  tang
  =/  hand
  ~[[%2 %hearts] [%10 %hearts] [%4 %spades] [%king %hearts] [%ace %spades] [%jack %clubs] [%queen %spades]] 
  ?>  =(4 -:(evaluate-hand hand))
  ~
:: 5-card hand evaluation tests
++  test-eval-royal
  ^-  tang
  =/  hand
    ~[[%10 %spades] [%jack %spades] [%queen %spades] [%king %spades] [%ace %spades]]
  ?>  =(9 (eval-5-cards hand))
  ~
++  test-eval-straight-flush
  =/  hand  
    ~[[%2 %spades] [%3 %spades] [%4 %spades] [%5 %spades] [%6 %spades]]
  ?>  =(8 (eval-5-cards hand))
  ~
++  test-eval-4-of-a-kind
  =/  hand  
    ~[[%2 %spades] [%2 %hearts] [%2 %clubs] [%2 %diamonds] [%6 %spades]]
  ?>  =(7 (eval-5-cards hand))
  ~
++  test-eval-full-house
  =/  hand  
    ~[[%2 %spades] [%2 %hearts] [%2 %clubs] [%6 %spades] [%6 %diamonds]]
  ?>  =(6 (eval-5-cards hand))
  ~
++  test-eval-flush
  =/  hand  
    ~[[%ace %spades] [%3 %spades] [%4 %spades] [%5 %spades] [%8 %spades]]
  ?>  =(5 (eval-5-cards hand))
  ~
++  test-eval-straight
  =/  hand  
    ~[[%2 %hearts] [%3 %diamonds] [%4 %spades] [%5 %spades] [%6 %spades]]
  ?>  =(4 (eval-5-cards hand))
  =/  wheel-straight 
    ~[[%ace %hearts] [%2 %diamonds] [%3 %spades] [%4 %spades] [%5 %spades]]
  ?>  =(4 (eval-5-cards wheel-straight))
  ~
++  test-eval-3-of-a-kind
  =/  hand  
    ~[[%3 %spades] [%3 %clubs] [%3 %diamonds] [%5 %spades] [%6 %spades]]
  ?>  =(3 (eval-5-cards hand))
  ~
++  test-eval-2-pair
  =/  hand  
    ~[[%3 %spades] [%3 %clubs] [%4 %spades] [%6 %hearts] [%6 %spades]]
  ?>  =(2 (eval-5-cards hand))
  ~
++  test-eval-pair
  =/  hand  
    ~[[%3 %spades] [%3 %clubs] [%4 %spades] [%10 %hearts] [%6 %spades]]
  ?>  =(1 (eval-5-cards hand))
  ~
++  test-eval-high-card
  =/  hand  
    ~[[%3 %spades] [%king %clubs] [%4 %spades] [%queen %hearts] [%6 %spades]]
  ?>  =(0 (eval-5-cards hand))
  ~
--