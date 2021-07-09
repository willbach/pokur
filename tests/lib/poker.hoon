/-  poker
/+  poker
=,  poker
|%
++  test-determine-winner-1
  ^-  tang
  =/  test-game-state
    [
      game-id=1
      host=~zod
      type=%cash
      players=~[~zod ~bus]
      paused=%.n
      hands-played=0
      chips=~[[~zod 1.000 0 %.n] [~bus 1.000 0 %.n]]
      pot=0
      current-bet=0
      min-bet=40
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
    ]
  =/  winner
    ~(determine-winner modify-state state)
  ?>  =(winner ~zod)
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
  ?>  =(9 (evaluate-hand hand))
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
  ?>  =(2 (evaluate-hand hand))
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
  ?>  =(1 (evaluate-hand hand))
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
  ?>  =(0 (evaluate-hand hand))
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
  ?>  =(5 (evaluate-hand hand))
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
  ?>  =(5 (evaluate-hand hand))
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