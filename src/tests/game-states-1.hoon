/-  *pokur
/+  *test, *pokur-game-logic
|%
++  game-state-1
  ^-  host-game-state
  :*  hands=~
      (shuffle generate-deck 0)  ::  eny=0
      hand-is-over=%.n
      turn-timer=*@da
      tokenized=~
      placements=~
      :*  id=*@da
          game-is-over=%.n
          :*  %sng
              starting-stack=1.000
              *@dr
              blind-schedule=~[[1 2] [3 4]]
              current-round=0
              round-is-over=%.n
              payouts=~[100]
          ==
          turn-time-limit=*@dr
          turn-start=*@da
          :~  [~tes 1.000 0 %.n %.n %.n]
              [~bus 1.000 0 %.n %.n %.n]
              [~dev 1.000 0 %.n %.n %.n]
          ==
          pots=~[[0 ~[~tes ~bus ~dev]]]
          current-bet=0
          last-bet=0
          last-action=~
          last-aggressor=~
          board=~
          my-hand=~
          whose-turn=~tes
          dealer=~tes
          small-blind=~tes
          big-blind=~bus
          spectators-allowed=%.y
          spectators=~
          hands-played=0
          update-message=''
          revealed-hands=~
      ==
  ==
::
::  with eny=0, the above game will have hands and board as follows:
::
++  state-1-hands
  ^-  (map ship pokur-deck)
  %-  ~(gas by *(map ship pokur-deck))
  :~  [~tes ~[[%3 %hearts] [%ace %hearts]]]
      [~bus ~[[%king %diamonds] [%4 %spades]]]
      [~dev ~[[%8 %diamonds] [%8 %clubs]]]
  ==
::
++  state-1-flop
  ^-  pokur-deck
  :~  [%ace %clubs]
      [%2 %clubs]
      [%3 %diamonds]
  ==
::
++  state-1-turn
  ^-  pokur-deck
  (snoc state-1-flop [%king %clubs])
::
++  state-1-river
  ^-  pokur-deck
  (snoc state-1-turn [%ace %diamonds])
::
::  this sequence is the bare minimum -- test of a simple hand
::
++  test-z-fold  ^-  tang
  =/  state  ~(initialize-hand guts game-state-1)
  =/  new-state
    (need (~(process-player-action guts state) ~bus [%fold *@da ~]))
  =/  expected-state
    %=    state
        pots.game        ~[[0 ~[~tes ~dev]]]
        whose-turn.game  ~dev
        last-action.game  `%fold
        update-message.game  '~bus folded. '
    ::
        players.game
      :~  [~tes 998 2 %.n %.n %.n]
          [~bus 1.000 0 %.y %.y %.n]
          [~dev 999 1 %.n %.n %.n]
      ==
    ==
  %+  expect-eq
    !>(game.expected-state)
  !>(game.new-state)
::
++  test-y-call  ^-  tang
  =/  state  ~(initialize-hand guts game-state-1)
  =/  last-state
    (need (~(process-player-action guts state) ~bus [%fold *@da ~]))
  =/  new-state
    (need (~(process-player-action guts last-state) ~dev [%bet *@da 1]))
  =/  expected-state
    %=    last-state
        whose-turn.game  ~tes
        last-action.game  `%call
        update-message.game  ''
    ::
        players.game
      :~  [~tes 998 2 %.n %.n %.n]
          [~bus 1.000 0 %.y %.y %.n]
          [~dev 998 2 %.y %.n %.n]
      ==
    ==
  %+  expect-eq
    !>(game.expected-state)
  !>(game.new-state)
::
::  version where ~tes shoves pre-flop and ~dev calls
::
++  test-yz-shove
  =/  state  ~(initialize-hand guts game-state-1)
  =/  last-state
    =+  (need (~(process-player-action guts state) ~bus [%fold *@da ~]))
    (need (~(process-player-action guts -) ~dev [%bet *@da 1]))
  =/  new-state
    (need (~(process-player-action guts last-state) ~tes [%bet *@da 998]))
  =/  expected-state
    %=    last-state
        whose-turn.game  ~dev
        last-action.game  `%raise
        last-aggressor.game  `~tes
        current-bet.game  1.000
        last-bet.game  998
        update-message.game  '~tes is all-in. '
    ::
        players.game
      :~  [~tes 0 1.000 %.y %.n %.n]
          [~bus 1.000 0 %.y %.y %.n]
          [~dev 998 2 %.y %.n %.n]
      ==
    ==
  %+  expect-eq
    !>(game.expected-state)
  !>(game.new-state)
::
++  test-yy-call
  =/  state  ~(initialize-hand guts game-state-1)
  =/  last-state
    =+  (need (~(process-player-action guts state) ~bus [%fold *@da ~]))
    =+  (need (~(process-player-action guts -) ~dev [%bet *@da 1]))
    (need (~(process-player-action guts -) ~tes [%bet *@da 998]))
  =/  new-state
    (need (~(process-player-action guts last-state) ~dev [%bet *@da 998]))
  =/  next-hand-init
    ~(initialize-hand guts new-state(deck (shuffle deck.new-state 1)))
  =/  expected-state
    %=    last-state
        whose-turn.game  ~tes
        dealer.game  ~tes
        small-blind.game  ~tes
        big-blind.game  ~bus
        last-action.game  ~
        last-aggressor.game  ~
        current-bet.game  2
        last-bet.game  2
        board.game  ~
        hands-played.game  1
        update-message.game
      '~dev is all-in. ~tes wins pot of 2.000 with hand Full House.  '
        revealed-hands.game
      ~[[~tes ~[[%3 %hearts] [%ace %hearts]]] [~dev ~[[%8 %diamonds] [%8 %clubs]]]]
    ::
        players.game
      :~  [~tes 1.999 1 %.n %.n %.n]
          [~bus 998 2 %.n %.n %.n]
          [~dev 0 0 %.y %.y %.n]
      ==
    ::
        pots.game  ~[[0 ~[~tes ~bus]]]
    ==
  %+  expect-eq
    !>(game.expected-state)
  !>(game.next-hand-init)
::
::  version where ~tes checks and hand plays out normally
::
++  test-x-flop  ^-  tang
  =/  state  ~(initialize-hand guts game-state-1)
  =/  last-state
    =+  (need (~(process-player-action guts state) ~bus [%fold *@da ~]))
    (need (~(process-player-action guts -) ~dev [%bet *@da 1]))
  =/  new-state
    (need (~(process-player-action guts last-state) ~tes [%check *@da ~]))
  =/  expected-state
    %=    last-state
        pots.game        ~[[4 ~[~tes ~dev]]]
        whose-turn.game  ~dev
        last-action.game  `%check
        current-bet.game  0
        last-bet.game  0
        board.game  state-1-flop
    ::
        players.game
      :~  [~tes 998 0 %.n %.n %.n]
          [~bus 1.000 0 %.n %.y %.n]
          [~dev 998 0 %.n %.n %.n]
      ==
    ==
  %+  expect-eq
    !>(game.expected-state)
  !>(game.new-state)
::
++  test-w-check  ^-  tang
  =/  state  ~(initialize-hand guts game-state-1)
  =/  last-state
    =+  (need (~(process-player-action guts state) ~bus [%fold *@da ~]))
    =+  (need (~(process-player-action guts -) ~dev [%bet *@da 1]))
    (need (~(process-player-action guts -) ~tes [%check *@da ~]))
  =/  new-state
    (need (~(process-player-action guts last-state) ~dev [%check *@da ~]))
  =/  expected-state
    %=    last-state
        whose-turn.game  ~tes
    ::
        players.game
      :~  [~tes 998 0 %.n %.n %.n]
          [~bus 1.000 0 %.n %.y %.n]
          [~dev 998 0 %.y %.n %.n]
      ==
    ==
  %+  expect-eq
    !>(game.expected-state)
  !>(game.new-state)
::
::  version where ~tes leaves on their turn, triggering ~dev winning hand
::  and new hand starting with only ~bus and ~dev
::
++  test-vz-tes-leave
  =/  state  ~(initialize-hand guts game-state-1)
  =/  last-state
    =+  (need (~(process-player-action guts state) ~bus [%fold *@da ~]))
    =+  (need (~(process-player-action guts -) ~dev [%bet *@da 1]))
    =+  (need (~(process-player-action guts -) ~tes [%check *@da ~]))
    (need (~(process-player-action guts -) ~dev [%check *@da ~]))
  =/  new-state
    (~(remove-player guts last-state) ~tes)
  =/  next-hand-init
    ~(initialize-hand guts new-state(deck (shuffle deck.new-state 1)))
  =/  expected-state
    %=    last-state
        pots.game        ~
        whose-turn.game  ~tes
        hands-played.game  1
        update-message.game  '~tes left the game. ~dev wins pot of 4. '
    ::
        players.game
      :~  [~tes 998 0 %.n %.n %.y]
          [~bus 1.000 0 %.n %.n %.n]
          [~dev 1.002 0 %.n %.n %.n]
      ==
    ==
  %+  expect-eq
    !>(game.expected-state)
  !>(game.new-state)
::
::  version where ~bus leaves out of turn, while folded, leading to hand
::  playing out normally with ~tes and ~dev
::
++  test-vy-bus-leave
  =/  state  ~(initialize-hand guts game-state-1)
  =/  last-state
    =+  (need (~(process-player-action guts state) ~bus [%fold *@da ~]))
    =+  (need (~(process-player-action guts -) ~dev [%bet *@da 1]))
    =+  (need (~(process-player-action guts -) ~tes [%check *@da ~]))
    (need (~(process-player-action guts -) ~dev [%check *@da ~]))
  =/  new-state
    (~(remove-player guts last-state) ~bus)
  =/  expected-state
    %=    last-state
        whose-turn.game  ~tes
        update-message.game  '~bus left the game. '
        players.game
      :~  [~tes 998 0 %.n %.n %.n]
          [~bus 1.000 0 %.y %.y %.y]
          [~dev 998 0 %.y %.n %.n]
      ==
    ==
  %+  expect-eq
    !>(game.expected-state)
  !>(game.new-state)
::
::  version where ~dev leaves out of turn, triggering ~tes winning hand
::  and new hand starting with only ~tes and ~bus
::
++  test-vx-dev-leave
  =/  state  ~(initialize-hand guts game-state-1)
  =/  last-state
    =+  (need (~(process-player-action guts state) ~bus [%fold *@da ~]))
    =+  (need (~(process-player-action guts -) ~dev [%bet *@da 1]))
    =+  (need (~(process-player-action guts -) ~tes [%check *@da ~]))
    (need (~(process-player-action guts -) ~dev [%check *@da ~]))
  =/  new-state
    (~(remove-player guts last-state) ~dev)
  =/  next-hand-init
    ~(initialize-hand guts new-state(deck (shuffle deck.new-state 1)))
  =/  expected-state
    %=    last-state
        pots.game        ~
        whose-turn.game  ~tes
        hands-played.game  1
        update-message.game  '~dev left the game. ~tes wins pot of 4. '
    ::
        players.game
      :~  [~tes 1.002 0 %.n %.n %.n]
          [~bus 1.000 0 %.n %.n %.n]
          [~dev 998 0 %.n %.n %.y]
      ==
    ==
  %+  expect-eq
    !>(game.expected-state)
  !>(game.new-state)
::
::  version where ~tes checks and hand plays out
::
++  test-vw-check  ^-  tang
  =/  state  ~(initialize-hand guts game-state-1)
  =/  last-state
    =+  (need (~(process-player-action guts state) ~bus [%fold *@da ~]))
    =+  (need (~(process-player-action guts -) ~dev [%bet *@da 1]))
    =+  (need (~(process-player-action guts -) ~tes [%check *@da ~]))
    (need (~(process-player-action guts -) ~dev [%check *@da ~]))
  =/  new-state
    (need (~(process-player-action guts last-state) ~tes [%check *@da ~]))
  =/  expected-state
    %=    last-state
        whose-turn.game  ~dev
        board.game  state-1-turn
    ::
        players.game
      :~  [~tes 998 0 %.n %.n %.n]
          [~bus 1.000 0 %.n %.y %.n]
          [~dev 998 0 %.n %.n %.n]
      ==
    ==
  %+  expect-eq
    !>(game.expected-state)
  !>(game.new-state)
::
++  test-u-bet  ^-  tang
  =/  state  ~(initialize-hand guts game-state-1)
  =/  last-state
    =+  (need (~(process-player-action guts state) ~bus [%fold *@da ~]))
    =+  (need (~(process-player-action guts -) ~dev [%bet *@da 1]))
    =+  (need (~(process-player-action guts -) ~tes [%check *@da ~]))
    =+  (need (~(process-player-action guts -) ~dev [%check *@da ~]))
    (need (~(process-player-action guts -) ~tes [%check *@da ~]))
  =/  new-state
    (need (~(process-player-action guts last-state) ~dev [%bet *@da 4]))
  =/  expected-state
    %=    last-state
        whose-turn.game  ~tes
        last-action.game  `%raise
        last-aggressor.game  `~dev
        current-bet.game  4
        last-bet.game  4
    ::
        players.game
      :~  [~tes 998 0 %.n %.n %.n]
          [~bus 1.000 0 %.n %.y %.n]
          [~dev 994 4 %.y %.n %.n]
      ==
    ==
  %+  expect-eq
    !>(game.expected-state)
  !>(game.new-state)
::
++  test-t-failed-check
  =/  state  ~(initialize-hand guts game-state-1)
  =/  last-state
    =+  (need (~(process-player-action guts state) ~bus [%fold *@da ~]))
    =+  (need (~(process-player-action guts -) ~dev [%bet *@da 1]))
    =+  (need (~(process-player-action guts -) ~tes [%check *@da ~]))
    =+  (need (~(process-player-action guts -) ~dev [%check *@da ~]))
    =+  (need (~(process-player-action guts -) ~tes [%check *@da ~]))
    (need (~(process-player-action guts -) ~dev [%bet *@da 4]))
  =/  new-state
    (~(process-player-action guts last-state) ~tes [%check *@da ~])
  %+  expect-eq
    !>(~)
  !>(new-state)
::
++  test-s-failed-raise
  =/  state  ~(initialize-hand guts game-state-1)
  =/  last-state
    =+  (need (~(process-player-action guts state) ~bus [%fold *@da ~]))
    =+  (need (~(process-player-action guts -) ~dev [%bet *@da 1]))
    =+  (need (~(process-player-action guts -) ~tes [%check *@da ~]))
    =+  (need (~(process-player-action guts -) ~dev [%check *@da ~]))
    =+  (need (~(process-player-action guts -) ~tes [%check *@da ~]))
    (need (~(process-player-action guts -) ~dev [%bet *@da 4]))
  =/  new-state
    (~(process-player-action guts last-state) ~tes [%bet *@da 5])
  %+  expect-eq
    !>(~)
  !>(new-state)
::
++  test-r-raise  ^-  tang
  =/  state  ~(initialize-hand guts game-state-1)
  =/  last-state
    =+  (need (~(process-player-action guts state) ~bus [%fold *@da ~]))
    =+  (need (~(process-player-action guts -) ~dev [%bet *@da 1]))
    =+  (need (~(process-player-action guts -) ~tes [%check *@da ~]))
    =+  (need (~(process-player-action guts -) ~dev [%check *@da ~]))
    =+  (need (~(process-player-action guts -) ~tes [%check *@da ~]))
    (need (~(process-player-action guts -) ~dev [%bet *@da 4]))
  =/  new-state
    (need (~(process-player-action guts last-state) ~tes [%bet *@da 8]))
  =/  expected-state
    %=    last-state
        whose-turn.game  ~dev
        last-action.game  `%raise
        last-aggressor.game  `~tes
        current-bet.game  8
        last-bet.game  4
    ::
        players.game
      :~  [~tes 990 8 %.y %.n %.n]
          [~bus 1.000 0 %.n %.y %.n]
          [~dev 994 4 %.y %.n %.n]
      ==
    ==
  %+  expect-eq
    !>(game.expected-state)
  !>(game.new-state)
::
++  test-q-call  ^-  tang
  =/  state  ~(initialize-hand guts game-state-1)
  =/  last-state
    =+  (need (~(process-player-action guts state) ~bus [%fold *@da ~]))
    =+  (need (~(process-player-action guts -) ~dev [%bet *@da 1]))
    =+  (need (~(process-player-action guts -) ~tes [%check *@da ~]))
    =+  (need (~(process-player-action guts -) ~dev [%check *@da ~]))
    =+  (need (~(process-player-action guts -) ~tes [%check *@da ~]))
    =+  (need (~(process-player-action guts -) ~dev [%bet *@da 4]))
    (need (~(process-player-action guts -) ~tes [%bet *@da 8]))
  =/  new-state
    (need (~(process-player-action guts last-state) ~dev [%bet *@da 4]))
  =/  expected-state
    %=    last-state
        whose-turn.game  ~dev
        last-action.game  `%call
        last-aggressor.game  `~tes
        current-bet.game  0
        last-bet.game  0
        board.game  state-1-river
    ::
        players.game
      :~  [~tes 990 0 %.n %.n %.n]
          [~bus 1.000 0 %.n %.y %.n]
          [~dev 990 0 %.n %.n %.n]
      ==
    ::
        pots.game
      ~[[20 ~[~tes ~dev]]]
    ==
  %+  expect-eq
    !>(game.expected-state)
  !>(game.new-state)
::
++  test-p-all-in  ^-  tang
  =/  state  ~(initialize-hand guts game-state-1)
  =/  last-state
    =+  (need (~(process-player-action guts state) ~bus [%fold *@da ~]))
    =+  (need (~(process-player-action guts -) ~dev [%bet *@da 1]))
    =+  (need (~(process-player-action guts -) ~tes [%check *@da ~]))
    =+  (need (~(process-player-action guts -) ~dev [%check *@da ~]))
    =+  (need (~(process-player-action guts -) ~tes [%check *@da ~]))
    =+  (need (~(process-player-action guts -) ~dev [%bet *@da 4]))
    =+  (need (~(process-player-action guts -) ~tes [%bet *@da 8]))
    (need (~(process-player-action guts -) ~dev [%bet *@da 4]))
  =/  new-state
    (need (~(process-player-action guts last-state) ~dev [%bet *@da 990]))
  =/  expected-state
    %=    last-state
        whose-turn.game  ~tes
        last-action.game  `%raise
        last-aggressor.game  `~dev
        current-bet.game  990
        last-bet.game  990
        board.game  state-1-river
        update-message.game  '~dev is all-in. '
    ::
        players.game
      :~  [~tes 990 0 %.n %.n %.n]
          [~bus 1.000 0 %.n %.y %.n]
          [~dev 0 990 %.y %.n %.n]
      ==
    ==
  %+  expect-eq
    !>(game.expected-state)
  !>(game.new-state)
::
++  test-o-call-all-in  ^-  tang
  =/  state  ~(initialize-hand guts game-state-1)
  =/  last-state
    =+  (need (~(process-player-action guts state) ~bus [%fold *@da ~]))
    =+  (need (~(process-player-action guts -) ~dev [%bet *@da 1]))
    =+  (need (~(process-player-action guts -) ~tes [%check *@da ~]))
    =+  (need (~(process-player-action guts -) ~dev [%check *@da ~]))
    =+  (need (~(process-player-action guts -) ~tes [%check *@da ~]))
    =+  (need (~(process-player-action guts -) ~dev [%bet *@da 4]))
    =+  (need (~(process-player-action guts -) ~tes [%bet *@da 8]))
    =+  (need (~(process-player-action guts -) ~dev [%bet *@da 4]))
    (need (~(process-player-action guts -) ~dev [%bet *@da 990]))
  =/  new-state
    (need (~(process-player-action guts last-state) ~tes [%bet *@da 990]))
  =/  next-hand-init
    ~(initialize-hand guts new-state(deck (shuffle deck.new-state 1)))
  =/  expected-state
    %=    last-state
        whose-turn.game  ~tes
        dealer.game  ~tes
        small-blind.game  ~tes
        big-blind.game  ~bus
        last-action.game  ~
        last-aggressor.game  ~
        current-bet.game  2
        last-bet.game  2
        board.game  ~
        hands-played.game  1
        update-message.game
      '~tes is all-in. ~tes wins pot of 2.000 with hand Full House.  '
        revealed-hands.game
      ~[[~tes ~[[%3 %hearts] [%ace %hearts]]] [~dev ~[[%8 %diamonds] [%8 %clubs]]]]
    ::
        players.game
      :~  [~tes 1.999 1 %.n %.n %.n]
          [~bus 998 2 %.n %.n %.n]
          [~dev 0 0 %.y %.y %.n]
      ==
    ::
        pots.game  ~[[0 ~[~tes ~bus]]]
    ==
  %+  expect-eq
    !>(game.expected-state)
  !>(game.next-hand-init)
--