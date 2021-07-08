/-  poker
/+  poker
=,  poker
|%
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