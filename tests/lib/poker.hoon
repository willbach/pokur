/-  poker
/+  poker
=,  poker
|%
:: 7-card hand evaluation tests
++  test-eval-royal
  ^-  tang
  =/  hand
    ~[[%10 %spades] [%jack %clubs] [%jack %spades] [%queen %spades] [%king %spades] [%ace %spades]]
  ?>  =(%royal-flush (evaluate-hand hand))
  ~
:: 5-card hand evaluation tests
++  test-eval-royal
  ^-  tang
  =/  hand
    ~[[%10 %spades] [%jack %spades] [%queen %spades] [%king %spades] [%ace %spades]]
  ?>  =(%royal-flush (eval-5-cards hand))
  ~
++  test-eval-straight-flush
  =/  hand  
    ~[[%2 %spades] [%3 %spades] [%4 %spades] [%5 %spades] [%6 %spades]]
  ?>  =(%straight-flush (eval-5-cards hand))
  ~
++  test-eval-4-of-a-kind
  =/  hand  
    ~[[%2 %spades] [%2 %hearts] [%2 %clubs] [%2 %diamonds] [%6 %spades]]
  ?>  =(%four-of-a-kind (eval-5-cards hand))
  ~
++  test-eval-full-house
  =/  hand  
    ~[[%2 %spades] [%2 %hearts] [%2 %clubs] [%6 %spades] [%6 %diamonds]]
  ?>  =(%full-house (eval-5-cards hand))
  ~
++  test-eval-flush
  =/  hand  
    ~[[%ace %spades] [%3 %spades] [%4 %spades] [%5 %spades] [%8 %spades]]
  ?>  =(%flush (eval-5-cards hand))
  ~
++  test-eval-straight
  =/  hand  
    ~[[%2 %hearts] [%3 %diamonds] [%4 %spades] [%5 %spades] [%6 %spades]]
  ?>  =(%straight (eval-5-cards hand))
  =/  wheel-straight 
    ~[[%ace %hearts] [%2 %diamonds] [%3 %spades] [%4 %spades] [%5 %spades]]
  ?>  =(%straight (eval-5-cards wheel-straight))
  ~
++  test-eval-3-of-a-kind
  =/  hand  
    ~[[%3 %spades] [%3 %clubs] [%3 %diamonds] [%5 %spades] [%6 %spades]]
  ?>  =(%three-of-a-kind (eval-5-cards hand))
  ~
++  test-eval-2-pair
  =/  hand  
    ~[[%3 %spades] [%3 %clubs] [%4 %spades] [%6 %hearts] [%6 %spades]]
  ?>  =(%two-pair (eval-5-cards hand))
  ~
++  test-eval-pair
  =/  hand  
    ~[[%3 %spades] [%3 %clubs] [%4 %spades] [%10 %hearts] [%6 %spades]]
  ?>  =(%pair (eval-5-cards hand))
  ~
++  test-eval-high-card
  =/  hand  
    ~[[%3 %spades] [%king %clubs] [%4 %spades] [%queen %hearts] [%6 %spades]]
  ?>  =(%high-card (eval-5-cards hand))
  ~
--