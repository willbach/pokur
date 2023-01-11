/-  *pokur
/+  *test, *pokur-game-logic
|%
::
::  a big game of pokur, played all the way through
::  players leave, run out of chips, etc, etc.
::
++  game-state-3
  ^-  host-game-state
  =/  player-list=(list @p)
    ~[~zod ~nec ~bud ~wes ~sev ~per ~sut ~let ~ful]
  =/  [hans=(list [@p pokur-deck]) dek=pokur-deck]
    %^    spin
        player-list
      (shuffle generate-deck 0)
    |=  [p=@p dek=pokur-deck]
    =+  (draw 1 dek)
    [[p hand.-] rest.-]
  :*  (~(gas by *(map ship pokur-deck)) hans)
      dek
      hand-is-over=%.n
      turn-timer=*@da
      tokenized=~
      placements=~
      :*  id=*@da
          game-is-over=%.n
          :*  %sng
              starting-stack=1.000
              *@dr
              blind-schedule=~[[small=10 big=20] [small=15 big=30] [small=25 big=50] [small=50 big=100] [small=100 big=200] [small=200 big=400]]
              current-round=0
              round-is-over=%.n
              payouts=~[100]
          ==
          turn-time-limit=*@dr
          turn-start=*@da
          %+  turn  player-list
          |=(p=@p [p 1.000 0 %.n %.n %.n])
          pots=~[[0 player-list]]
          current-bet=0
          last-bet=0
          last-action=~
          last-aggressor=~
          board=~
          my-hand=~
          whose-turn=~zod
          dealer=~zod
          small-blind=~zod
          big-blind=~zod
          spectators-allowed=%.y
          spectators=~
          hands-played=0
          update-message=''
          revealed-hands=~
      ==
  ==
::
::  beginning a fresh game
::
++  state-z
  ~(initialize-hand guts game-state-3)
++  test-z-initial-state  ^-  tang
  =/  state=host-game-state  game-state-3
  =/  new-state
    ~(initialize-hand guts state)
  =/  expected-state
    %=    state
        players.game
      :~  [~zod 1.000 0 %.n %.n %.n]
          [~nec 1.000 0 %.n %.n %.n]
          [~bud 990 10 %.n %.n %.n]
          [~wes 980 20 %.n %.n %.n]
          [~sev 1.000 0 %.n %.n %.n]
          [~per 1.000 0 %.n %.n %.n]
          [~sut 1.000 0 %.n %.n %.n]
          [~let 1.000 0 %.n %.n %.n]
          [~ful 1.000 0 %.n %.n %.n]
      ==
        current-bet.game  20
        last-bet.game     20
        whose-turn.game   ~sev
        dealer.game       ~nec
        small-blind.game  ~bud
        big-blind.game    ~wes
    ==
  %+  expect-eq
    !>(game.expected-state)
  !>(game.new-state)
::
::  everyone sees the flop
::
++  state-y
  =+  (need (~(process-player-action guts state-z) ~sev [%bet *@da 20]))
  =+  (need (~(process-player-action guts -) ~per [%bet *@da 20]))
  =+  (need (~(process-player-action guts -) ~sut [%bet *@da 20]))
  =+  (need (~(process-player-action guts -) ~let [%bet *@da 20]))
  =+  (need (~(process-player-action guts -) ~ful [%bet *@da 20]))
  =+  (need (~(process-player-action guts -) ~zod [%bet *@da 20]))
  =+  (need (~(process-player-action guts -) ~nec [%bet *@da 20]))
  =+  (need (~(process-player-action guts -) ~bud [%bet *@da 10]))
  (need (~(process-player-action guts -) ~wes [%check *@da ~]))
++  test-y-all-call  ^-  tang
  =/  expected-state
    =+  state-z
    %=    -
        players.game
      :~  [~zod 980 0 %.n %.n %.n]
          [~nec 980 0 %.n %.n %.n]
          [~bud 980 0 %.n %.n %.n]
          [~wes 980 0 %.n %.n %.n]
          [~sev 980 0 %.n %.n %.n]
          [~per 980 0 %.n %.n %.n]
          [~sut 980 0 %.n %.n %.n]
          [~let 980 0 %.n %.n %.n]
          [~ful 980 0 %.n %.n %.n]
      ==
        pots.game
      ~[[180 ~[~zod ~nec ~bud ~wes ~sev ~per ~sut ~let ~ful]]]
        current-bet.game  0
        last-bet.game     0
        last-action.game  `%check
        board.game
      ~[[%7 %clubs] [%king %hearts] [%queen %hearts]]
        whose-turn.game   ~bud
    ==
  %+  expect-eq
    !>(game.expected-state)
  !>(game:state-y)
::
::  ~bud goes all in after the flop
::
++  state-x
  (need (~(process-player-action guts state-y) ~bud [%bet *@da 980]))
++  test-x-bud-all-in  ^-  tang
  =/  expected-state
    =+  state-y
    %=    -
        players.game
      :~  [~zod 980 0 %.n %.n %.n]
          [~nec 980 0 %.n %.n %.n]
          [~bud 0 980 %.y %.n %.n]
          [~wes 980 0 %.n %.n %.n]
          [~sev 980 0 %.n %.n %.n]
          [~per 980 0 %.n %.n %.n]
          [~sut 980 0 %.n %.n %.n]
          [~let 980 0 %.n %.n %.n]
          [~ful 980 0 %.n %.n %.n]
      ==
        current-bet.game     980
        last-bet.game        980
        last-action.game     `%raise
        last-aggressor.game  `~bud
        whose-turn.game      ~wes
        update-message.game  '~bud is all-in. '
    ==
  %+  expect-eq
    !>(game.expected-state)
  !>(game:state-x)
::
::  everyone folds except ~let, who also goes all in
::
++  state-w
  =+  (need (~(process-player-action guts state-x) ~wes [%fold *@da ~]))
  =+  (need (~(process-player-action guts -) ~sev [%fold *@da ~]))
  =+  (need (~(process-player-action guts -) ~per [%fold *@da ~]))
  =+  (need (~(process-player-action guts -) ~sut [%fold *@da ~]))
  =+  (need (~(process-player-action guts -) ~let [%bet *@da 980]))
  =+  (need (~(process-player-action guts -) ~ful [%fold *@da ~]))
  =+  (need (~(process-player-action guts -) ~zod [%fold *@da ~]))
  (need (~(process-player-action guts -) ~nec [%fold *@da ~]))
++  test-w-let-call  ^-  tang
  =/  expected-state
    =+  state-x
    %=    -
        players.game
      :~  [~zod 980 0 %.n %.n %.n]
          [~nec 980 0 %.n %.n %.n]
          [~bud 0 0 %.y %.y %.n]
          [~wes 980 0 %.n %.n %.n]
          [~sev 980 0 %.n %.n %.n]
          [~per 980 0 %.n %.n %.n]
          [~sut 980 0 %.n %.n %.n]
          [~let 2.140 0 %.n %.n %.n]
          [~ful 980 0 %.n %.n %.n]
      ==
        pots.game
      ~[[0 ~[~zod ~nec ~wes ~sev ~per ~sut ~let ~ful]]]
        current-bet.game     0
        last-bet.game        0
        last-action.game     `%fold
        last-aggressor.game  `~bud
        board.game
      ~[[%7 %clubs] [%king %hearts] [%queen %hearts] [%jack %diamonds] [%2 %spades]]
        whose-turn.game      ~nec
        hands-played.game    1
        update-message.game
      '~nec folded. ~let wins pot of 2.140 with hand Pair.  '
        revealed-hands.game
      ~[[~bud ~[[%ace %diamonds] [%3 %spades]]] [~let ~[[%4 %diamonds] [%queen %diamonds]]]]
    ==
  %+  expect-eq
    !>(game.expected-state)
  !>(game:state-w)
--