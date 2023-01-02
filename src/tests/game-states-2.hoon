/-  *pokur
/+  *test, *pokur-game-logic
|%
++  game-state-2
  ^-  host-game-state
  :*  %-  ~(gas by *(map ship pokur-deck))
      :~  [~zod ~[[%2 %clubs] [%3 %clubs]]]
          [~bus ~[[%jack %clubs] [%ace %spades]]]
      ==
      (shuffle generate-deck 0)  ::  eny=0
      hand-is-over=%.n
      turn-timer=*@da
      tokenized=~
      placements=~
      :*  id=*@da
          game-is-over=%.n
          :*  %sng
              starting-stack=1.500
              *@dr
              blind-schedule=~[[small=10 big=20] [small=15 big=30] [small=25 big=50] [small=50 big=100] [small=100 big=200] [small=200 big=400]]
              current-round=0
              round-is-over=%.n
              payouts=~[100]
          ==
          turn-time-limit=*@dr
          turn-start=*@da
          :~  [~zod 2.680 0 %.n %.n %.n]
              [~bus 0 320 %.y %.n %.n]
          ==
          pots=~[[0 ~[~zod ~bus]]]
          current-bet=320
          last-bet=320
          last-action=`%raise
          last-aggressor=`~bus
          board=~
          my-hand=~
          whose-turn=~zod
          dealer=~bus
          small-blind=~bus
          big-blind=~zod
          spectators-allowed=%.y
          spectators=~
          hands-played=4
          update-message=''
          revealed-hands=~
      ==
  ==
::
++  state-2-flop
  ^-  pokur-deck
  ~[[%ace %hearts] [%king %diamonds] [%4 %spades]]
::
++  state-2-turn
  ^-  pokur-deck
  (snoc state-2-flop [%8 %clubs])
::
++  state-2-river
  ^-  pokur-deck
  (snoc state-2-turn [%ace %clubs])
::
::  version where zod calls and loses
::
++  test-z-call  ^-  tang
  =/  state  game-state-2
  =/  new-state
    (need (~(process-player-action guts state) ~zod [%bet *@da 320]))
  =/  next-hand-init
    ~(initialize-hand guts new-state(deck (shuffle deck.new-state 1)))
  =/  expected-state
    %=    state
        current-bet.game  0
        last-bet.game  0
        whose-turn.game  ~zod
        last-action.game  `%call
        board.game  state-2-river
        hands-played.game  5
        update-message.game
      '~bus wins pot of 640 with hand Three of a Kind.  '
        revealed-hands.game
      ~[[~zod ~[[%2 %clubs] [%3 %clubs]]] [~bus ~[[%jack %clubs] [%ace %spades]]]]
    ::
        players.game
      :~  [~zod 2.360 0 %.n %.n %.n]
          [~bus 640 0 %.n %.n %.n]
      ==
    ==
  %+  expect-eq
    !>(game.expected-state)
  !>(game.new-state)
::
::  version where zod calls and wins, ending game
::
++  test-y-call  ^-  tang
  =/  state  game-state-2
  =.  hands.state
    (~(put by hands.state) ~zod ~[[%ace %diamonds] [%king %spades]])
  =/  new-state
    (need (~(process-player-action guts state) ~zod [%bet *@da 320]))
  =/  expected-state
    %=    state
        game-is-over.game  %.y
        current-bet.game  0
        last-bet.game  0
        whose-turn.game  ~zod
        last-action.game  `%call
        board.game  state-2-river
        hands-played.game  5
        update-message.game
      '~zod wins pot of 640 with hand Full House.  '
        revealed-hands.game
      ~[[~zod ~[[%ace %diamonds] [%king %spades]]] [~bus ~[[%jack %clubs] [%ace %spades]]]]
    ::
        players.game
      :~  [~zod 3.000 0 %.n %.n %.n]
          [~bus 0 0 %.y %.y %.n]
      ==
        pots.game
      ~[[0 ~[~zod]]]
    ==
  %+  expect-eq
    !>(game.expected-state)
  !>(game.new-state)
--