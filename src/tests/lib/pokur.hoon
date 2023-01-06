/-  *pokur
/+  *test, *pokur-game-logic
|%
::
::  random tests
::
++  test-send-all-in  ^-  tang
  ::  ~tes has 80 chips left
  ::  ~bus wants to send ~tes all-in
  ::  big blind is 100
  ::  ~bus should be able to bet 80
  =/  state=host-game-state
    :*  %-  ~(gas by *(map ship pokur-deck))
        :~  [~bus ~[[%5 %spades] [%ace %spades]]]
            [~tes ~[[%2 %spades] [%3 %spades]]]
        ==
        generate-deck
        hand-is-over=%.n
        turn-timer=*@da
        tokenized=~
        placements=~[~tes ~bus]
        :*  id=*@da
            game-is-over=%.n
            :*  %sng
                1.000
                *@dr
                ~[[50 100]]
                0
                %.n
                ~[100]
            ==
            turn-time-limit=*@dr
            turn-start=*@da
            ::  RELEVANT
            :~  [~tes 80 0 %.n %.n %.n]
                [~bus 800 0 %.n %.n %.n]
            ==
            ::  RELEVANT
            pots=~[[200 ~[~tes ~bus]]]
            current-bet=0
            last-bet=0
            last-action=`%call
            last-aggressor=~
            :~  [%king %diamonds]
                [%queen %diamonds]
                [%jack %diamonds]
            ==
            my-hand=~
            whose-turn=~bus
            dealer=~tes
            small-blind=~tes
            big-blind=~bus
            spectators-allowed=%.y
            spectators=~
            hands-played=10
            update-message=''
            revealed-hands=~
        ==
    ==
  =/  new-state
    (need (~(process-player-action guts state) ~bus [%bet *@da 80]))
  =/  expected-state
    %=    state
        whose-turn.game  ~tes
        last-aggressor.game  `~bus
        current-bet.game  80
        last-bet.game  80
        last-action.game  `%raise
        update-message.game  ''
    ::
        players.game
      :~  [~tes 80 0 %.n %.n %.n]
          [~bus 720 80 %.y %.n %.n]
      ==
    ==
  %+  expect-eq
    !>(game.expected-state)
  !>(game.new-state)
::
++  test-folded-pot  ^-  tang
  ::  ~tes bet 100
  ::  then, ~bus raised the bet to 200.
  ::  ~dev called 200, but ~tes folded.
  ::  this should create 1 pot with 500 chips
  =/  state=host-game-state
    :*  %-  ~(gas by *(map ship pokur-deck))
        :~  [~bus ~[[%5 %spades] [%ace %spades]]]
            [~tes ~[[%2 %spades] [%3 %spades]]]
            [~dev ~[[%king %spades] [%jack %spades]]]
        ==
        generate-deck
        hand-is-over=%.n
        turn-timer=*@da
        tokenized=~
        placements=~[~tes ~bus ~dev]
        :*  id=*@da
            game-is-over=%.n
            :*  %sng
                1.000
                *@dr
                ~[[1 2] [3 4]]
                0
                %.n
                ~[100]
            ==
            turn-time-limit=*@dr
            turn-start=*@da
            ::  RELEVANT
            :~  [~tes 100 100 %.y %.n %.n]
                [~bus 800 200 %.y %.n %.n]
                [~dev 1.800 200 %.y %.n %.n]
            ==
            ::  RELEVANT
            pots=~[[0 ~[~tes ~bus ~dev]]]
            current-bet=200
            last-bet=100
            last-action=`%call
            last-aggressor=`~bus
            board=~
            my-hand=~
            whose-turn=~tes
            dealer=~tes
            small-blind=~bus
            big-blind=~dev
            spectators-allowed=%.y
            spectators=~
            hands-played=10
            update-message=''
            revealed-hands=~
        ==
    ==
  =/  new-state
    (need (~(process-player-action guts state) ~tes [%fold *@da ~]))
  =/  expected-state
    %=    state
        whose-turn.game  ~bus
        last-aggressor.game  `~bus
        current-bet.game  0
        last-bet.game  0
        last-action.game  `%fold
        update-message.game  '~tes folded. '
        board.game
      :~  [%king %diamonds]
          [%queen %diamonds]
          [%jack %diamonds]
      ==
    ::
        players.game
      :~  [~tes 100 0 %.n %.y %.n]
          [~bus 800 0 %.n %.n %.n]
          [~dev 1.800 0 %.n %.n %.n]
      ==
    ::  RELEVANT
        pots.game
      ~[[500 ~[~tes ~bus ~dev]]]
    ==
  %+  expect-eq
    !>(game.expected-state)
  !>(game.new-state)
::
++  test-side-pot  ^-  tang
  ::  ~tes went all in with 100 chips.
  ::  then, ~bus raised the bet to 200.
  ::  ~dev is about to call 200, which will
  ::  initiate the flop and create 2 pots:
  ::  300 available to all, and 200 available to ~bus and ~dev.
  =/  state=host-game-state
    :*  %-  ~(gas by *(map ship pokur-deck))
        :~  [~bus ~[[%5 %spades] [%ace %spades]]]
            [~tes ~[[%2 %spades] [%3 %spades]]]
            [~dev ~[[%king %spades] [%jack %spades]]]
        ==
        generate-deck
        hand-is-over=%.n
        turn-timer=*@da
        tokenized=~
        placements=~[~tes ~bus ~dev]
        :*  id=*@da
            game-is-over=%.n
            :*  %sng
                1.000
                *@dr
                ~[[1 2] [3 4]]
                0
                %.n
                ~[100]
            ==
            turn-time-limit=*@dr
            turn-start=*@da
            ::  RELEVANT
            :~  [~tes 0 100 %.y %.n %.n]
                [~bus 800 200 %.y %.n %.n]
                [~dev 2.000 0 %.n %.n %.n]
            ==
            ::  RELEVANT
            pots=~[[0 ~[~tes ~bus ~dev]]]
            current-bet=200
            last-bet=100
            last-action=`%raise
            last-aggressor=`~bus
            board=~
            my-hand=~
            whose-turn=~dev
            dealer=~tes
            small-blind=~bus
            big-blind=~dev
            spectators-allowed=%.y
            spectators=~
            hands-played=10
            update-message='~tes is all-in. '
            revealed-hands=~
        ==
    ==
  =/  new-state
    (need (~(process-player-action guts state) ~dev [%bet *@da 200]))
  =/  expected-state
    %=    state
        whose-turn.game  ~bus
        last-aggressor.game  `~bus
        current-bet.game  0
        last-bet.game  0
        last-action.game  `%call
        update-message.game  ''
        board.game
      :~  [%king %diamonds]
          [%queen %diamonds]
          [%jack %diamonds]
      ==
    ::
        players.game
      :~  [~tes 0 0 %.n %.n %.n]
          [~bus 800 0 %.n %.n %.n]
          [~dev 1.800 0 %.n %.n %.n]
      ==
    ::  RELEVANT
        pots.game
      ~[[300 ~[~tes ~bus ~dev]] [200 ~[~bus ~dev]]]
    ==
  %+  expect-eq
    !>(game.expected-state)
  !>(game.new-state)
::
++  test-award-side-pot  ^-  tang
  ::  side pots have been created
  ::  tes has a small one, dev and bus compete for big one
  ::  action is final check of game, so pots should be awarded
  ::  tes wins their side pot, bus wins the main pot
  =/  state=host-game-state
    :*  %-  ~(gas by *(map ship pokur-deck))
        :~  [~bus ~[[%king %spades] [%king %clubs]]]
            [~tes ~[[%2 %spades] [%3 %spades]]]
            [~dev ~[[%king %diamonds] [%jack %spades]]]
        ==
        generate-deck
        hand-is-over=%.n
        turn-timer=*@da
        tokenized=~
        placements=~[~tes ~bus ~dev]
        :*  id=*@da
            game-is-over=%.n
            :*  %sng
                1.000
                *@dr
                ~[[1 2] [3 4]]
                0
                %.n
                ~[100]
            ==
            turn-time-limit=*@dr
            turn-start=*@da
            ::  RELEVANT
            :~  [~tes 0 0 %.y %.n %.n]
                [~bus 800 0 %.y %.n %.n]
                [~dev 1.800 0 %.n %.n %.n]
            ==
            ::  RELEVANT
            pots=~[[300 ~[~tes ~bus ~dev]] [200 ~[~bus ~dev]]]
            current-bet=0
            last-bet=0
            last-action=`%check
            last-aggressor=`~bus
            ::  board
            :~  [%2 %clubs]  [%2 %diamonds]
                [%3 %clubs]  [%7 %spades]
                [%queen %hearts]
            ==
            my-hand=~
            whose-turn=~dev
            dealer=~tes
            small-blind=~bus
            big-blind=~dev
            spectators-allowed=%.y
            spectators=~
            hands-played=10
            update-message='~tes is all-in. '
            revealed-hands=~
        ==
    ==
  =/  new-state
    (need (~(process-player-action guts state) ~dev [%check *@da ~]))
  =/  expected-state
    %=    state
        whose-turn.game  ~dev
        last-aggressor.game  `~bus
        hands-played.game  11
        current-bet.game  0
        last-bet.game  0
        board.game  ~[[%2 %clubs] [%2 %diamonds] [%3 %clubs] [%7 %spades] [%queen %hearts]]
        last-action.game  `%check
        update-message.game
      '~tes wins pot of 300 with hand Full House.  ~bus wins pot of 200 with hand Two Pair.  '
        revealed-hands.game
      ~[[~bus ~[[%king %spades] [%king %clubs]]] [~tes ~[[%2 %spades] [%3 %spades]]]]
    ::
        players.game
      :~  [~tes 300 0 %.n %.n %.n]
          [~bus 1.000 0 %.n %.n %.n]
          [~dev 1.800 0 %.n %.n %.n]
      ==
    ::  RELEVANT
        pots.game
      ~[[amount=0 in=~[~tes ~bus ~dev]]]
    ==
  %+  expect-eq
    !>(game.expected-state)
  !>(game.new-state)
::
++  test-side-pot-2  ^-  tang
  ::  ~tes went all in with 100 chips.
  ::  then, ~bus raised the bet by going all-in with 200.
  ::  ~dev is about to raise to 400, which will
  ::  initiate the flop and create 3 pots:
  ::  300 available to all,
  ::  200 to ~bus and ~dev,
  ::  200 to ~dev alone.
  =/  state=host-game-state
    :*  %-  ~(gas by *(map ship pokur-deck))
        :~  [~bus ~[[%5 %spades] [%ace %spades]]]
            [~tes ~[[%2 %spades] [%3 %spades]]]
            [~dev ~[[%king %spades] [%jack %spades]]]
        ==
        generate-deck
        hand-is-over=%.n
        turn-timer=*@da
        tokenized=~
        placements=~[~tes ~bus ~dev]
        :*  id=*@da
            game-is-over=%.n
            :*  %sng
                1.000
                *@dr
                ~[[1 2] [3 4]]
                0
                %.n
                ~[100]
            ==
            turn-time-limit=*@dr
            turn-start=*@da
            ::  RELEVANT
            :~  [~tes 0 100 %.y %.n %.n]
                [~bus 0 200 %.y %.n %.n]
                [~dev 2.000 0 %.n %.n %.n]
            ==
            ::  RELEVANT
            pots=~[[0 ~[~tes ~bus ~dev]]]
            current-bet=200
            last-bet=100
            last-action=`%raise
            last-aggressor=`~bus
            board=~
            my-hand=~
            whose-turn=~dev
            dealer=~tes
            small-blind=~bus
            big-blind=~dev
            spectators-allowed=%.y
            spectators=~
            hands-played=10
            update-message='~bus is all-in. '
            revealed-hands=~
        ==
    ==
  =/  new-state
    (need (~(process-player-action guts state) ~dev [%bet *@da 400]))
  =/  expected-state
    %=    state
        whose-turn.game  ~dev
        last-aggressor.game  `~dev
        current-bet.game  0
        last-bet.game  0
        last-action.game  `%raise
        hands-played.game  11
        update-message.game  '~dev, ~bus, ~tes, split pot of 300 with hand Flush.  ~dev, ~bus, split pot of 200 with hand Flush.  ~dev wins pot of 200 with hand Flush.  '
        board.game
      ~[[%king %diamonds] [%queen %diamonds] [%jack %diamonds] [%9 %diamonds] [%7 %diamonds]]
        revealed-hands.game
      :~  [~dev ~[[%king %spades] [%jack %spades]]]
          [~tes ~[[%2 %spades] [%3 %spades]]]
          [~bus ~[[%5 %spades] [%ace %spades]]]
      ==
        players.game
      :~  [~tes 100 0 %.n %.n %.n]
          [~bus 200 0 %.n %.n %.n]
          [~dev 2.000 0 %.n %.n %.n]
      ==
        pots.game
      ~[[0 ~[~tes ~bus ~dev]]]
    ==
  %+  expect-eq
    !>(game.expected-state)
  !>(game.new-state)
::
::  determine-winner tests
::
++  test-winner-1  ^-  tang
  ::  this should have ~bus and ~dev both win with straight on board
  =/  board
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
  !>((determine-winner board hands))
::
++  test-winner-2  ^-  tang
  ::  this should have ~bus win
  =/  board
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
  !>((determine-winner board hands))
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