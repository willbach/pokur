/-  *pokur
/+  *test, *pokur-game-logic
|%
::
::  determine-winner tests
::
++  test-winner-1  ^-  tang
  ::  this should have ~bus and ~dev both win with straight on board
  =/  state  *host-game-state
  =.  board.game.state
    :~  [%ace %clubs]
        [%2 %clubs]
        [%3 %hearts]
        [%4 %hearts]
        [%5 %hearts]
    ==
  =/  hands
    :~  [~bus ~[[%5 %spades] [%ace %spades]]]
        [~dev ~[[%king %spades] [%jack %spades]]]
    ==
  %+  expect-eq
    !>
    :~  [~bus 4 ~[[%5 %spades] [%ace %spades] [%2 %clubs] [%3 %hearts] [%4 %hearts]]]
        [~dev 4 ~[[%ace %clubs] [%2 %clubs] [%3 %hearts] [%4 %hearts] [%5 %hearts]]]
    ==
  !>((~(determine-winner guts state) hands))
::
++  test-winner-2  ^-  tang
  ::  this should have ~bus win
  =/  state  *host-game-state
  =.  board.game.state
    :~  [%ace %clubs]
        [%2 %clubs]
        [%3 %hearts]
        [%4 %hearts]
        [%5 %hearts]
    ==
  =/  hands
    :~  [~bus ~[[%6 %spades] [%ace %spades]]]
        [~dev ~[[%king %spades] [%jack %spades]]]
    ==
  %+  expect-eq
    !>
    :~  [~bus 5 ~[[%6 %spades] [%2 %clubs] [%3 %hearts] [%4 %hearts] [%5 %hearts]]]
    ==
  !>((~(determine-winner guts state) hands))
::
::  tie breaking tests
::
++  test-tie-break-1  ^-  tang
  =/  hand1
    :-  0  ::  high card
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
  (expect-eq !>(%.y) !>((break-ties hand1 hand2)))
::
++  test-tie-break-2  ^-  tang
  =/  hand1
    :-  1  ::  pair
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
  (expect-eq !>(%.y) !>((break-ties hand2 hand1)))
++  test-tie-break-3  ^-  tang
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
  (expect-eq !>(%.y) !>((break-ties hand1 hand2)))
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
  (expect-eq !>(%.y) !>((break-ties hand2 hand1)))
++  test-tie-break-5
  ^-  tang
  =/  hand1
    :-  5 :: straight with 5 cards
    :~  [%2 %spades]
        [%3 %spades]
        [%4 %hearts]
        [%5 %clubs]
        [%6 %spades]
    ==
  =/  hand2
    :-  5
    :~  [%3 %spades]
        [%4 %hearts]
        [%5 %clubs]
        [%6 %spades]
        [%7 %hearts]
    ==
  (expect-eq !>(%.y) !>((break-ties hand2 hand1)))
::
++  test-tie-break-6
  ^-  tang
  =/  hand1
    :-  4  ::  wheel
    :~  [%2 %spades]
        [%3 %spades]
        [%4 %hearts]
        [%5 %clubs]
        [%ace %spades]
    ==
  =/  hand2
    :-  4
    :~  [%3 %spades]
        [%4 %hearts]
        [%5 %clubs]
        [%ace %spades]
        [%2 %hearts]
    ==
  (expect-eq !>(%.n) !>((break-ties hand2 hand1)))
::
:: 7-card hand evaluation tests
::
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
  (expect-eq !>(10) !>(-:(evaluate-7-card-hand hand)))
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
  (expect-eq !>(2) !>(-:(evaluate-7-card-hand hand)))
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
  (expect-eq !>(1) !>(-:(evaluate-7-card-hand hand)))
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
  (expect-eq !>(0) !>(-:(evaluate-7-card-hand hand)))
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
  (expect-eq !>(6) !>(-:(evaluate-7-card-hand hand)))
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
  (expect-eq !>(6) !>(-:(evaluate-7-card-hand hand)))
++  test-eval7
  ^-  tang
  =/  hand
    ~[[%jack %hearts] [%10 %hearts] [%jack %spades] [%king %hearts] [%ace %spades] [%jack %clubs] [%queen %spades]]
  (expect-eq !>(5) !>(-:(evaluate-7-card-hand hand)))
++  test-eval8
  ^-  tang
  =/  hand
    ~[[%2 %hearts] [%10 %hearts] [%4 %spades] [%king %hearts] [%ace %spades] [%jack %clubs] [%queen %spades]]
  (expect-eq !>(5) !>(-:(evaluate-7-card-hand hand)))
::
:: 6-card hand evaluation tests
::
++  test-eval9
  ^-  tang
  =/  hand
    ~[[%6 %hearts] [%10 %spades] [%8 %clubs] [%7 %clubs] [%8 %hearts] [%king %clubs]]
  (expect-eq !>(1) !>(-:(evaluate-6-card-hand hand)))
::
:: 5-card hand evaluation tests
::
++  test-eval-royal
  ^-  tang
  =/  hand
    ~[[%10 %spades] [%jack %spades] [%queen %spades] [%king %spades] [%ace %spades]]
  (expect-eq !>(10) !>((evaluate-5-card-hand hand)))
++  test-eval-straight-flush
  =/  hand
    ~[[%2 %spades] [%3 %spades] [%4 %spades] [%5 %spades] [%6 %spades]]
  (expect-eq !>(9) !>((evaluate-5-card-hand hand)))
++  test-eval-4-of-a-kind
  =/  hand
    ~[[%2 %spades] [%2 %hearts] [%2 %clubs] [%2 %diamonds] [%6 %spades]]
  (expect-eq !>(8) !>((evaluate-5-card-hand hand)))
++  test-eval-full-house
  =/  hand
    ~[[%2 %spades] [%2 %hearts] [%2 %clubs] [%6 %spades] [%6 %diamonds]]
  (expect-eq !>(7) !>((evaluate-5-card-hand hand)))
++  test-eval-flush
  =/  hand
    ~[[%ace %spades] [%3 %spades] [%4 %spades] [%5 %spades] [%8 %spades]]
  (expect-eq !>(6) !>((evaluate-5-card-hand hand)))
++  test-eval-straight
  =/  hand
    ~[[%2 %hearts] [%3 %diamonds] [%4 %spades] [%5 %spades] [%6 %spades]]
  =/  wheel-straight
    ~[[%ace %hearts] [%2 %diamonds] [%3 %spades] [%4 %spades] [%5 %spades]]
  ;:  weld
    (expect-eq !>(4) !>((evaluate-5-card-hand wheel-straight)))
    (expect-eq !>(5) !>((evaluate-5-card-hand hand)))
  ==
++  test-eval-3-of-a-kind
  =/  hand
    ~[[%3 %spades] [%3 %clubs] [%3 %diamonds] [%5 %spades] [%6 %spades]]
  (expect-eq !>(3) !>((evaluate-5-card-hand hand)))
++  test-eval-2-pair
  =/  hand
    ~[[%3 %spades] [%3 %clubs] [%4 %spades] [%6 %hearts] [%6 %spades]]
  (expect-eq !>(2) !>((evaluate-5-card-hand hand)))
++  test-eval-pair
  =/  hand
    ~[[%3 %spades] [%3 %clubs] [%4 %spades] [%10 %hearts] [%6 %spades]]
  (expect-eq !>(1) !>((evaluate-5-card-hand hand)))
++  test-eval-high-card
  =/  hand
    ~[[%3 %spades] [%king %clubs] [%4 %spades] [%queen %hearts] [%6 %spades]]
  (expect-eq !>(0) !>((evaluate-5-card-hand hand)))
--