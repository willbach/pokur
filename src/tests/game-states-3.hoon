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
  !>(game:state-z)
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
        pots.game            ~
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
  ;:  weld
    %+  expect-eq
      !>(game.expected-state)
    !>(game:state-w)
    %+  expect-eq
      !>(%.y)
    !>(hand-is-over:state-w)
  ==
::
::  now have one player "out" but not "left". let's have one
::  player next to ~bud also get out.
::
++  state-v
  =+  state-w
  ~(initialize-hand guts -(deck (shuffle deck:state-w 1)))
++  test-v-next-hand
  =/  expected-state
    =+  state-w
    %=    -
        players.game
      :~  [~zod 980 0 %.n %.n %.n]
          [~nec 980 0 %.n %.n %.n]
          [~bud 0 0 %.y %.y %.n]
          [~wes 980 0 %.n %.n %.n]
          [~sev 970 10 %.n %.n %.n]
          [~per 960 20 %.n %.n %.n]
          [~sut 980 0 %.n %.n %.n]
          [~let 2.140 0 %.n %.n %.n]
          [~ful 980 0 %.n %.n %.n]
      ==
        pots.game
      ~[[0 ~[~zod ~nec ~wes ~sev ~per ~sut ~let ~ful]]]
        current-bet.game     20
        last-bet.game        20
        board.game           ~
        last-action.game     ~
        last-aggressor.game  ~
        whose-turn.game      ~sut
        dealer.game          ~wes
        small-blind.game     ~sev
        big-blind.game       ~per
    ==
  %+  expect-eq
    !>(game.expected-state)
  !>(game:state-v)
::
++  state-u
  =+  (need (~(process-player-action guts state-v) ~sut [%fold *@da ~]))
  =+  (need (~(process-player-action guts -) ~let [%bet *@da 20]))
  =+  (need (~(process-player-action guts -) ~ful [%fold *@da ~]))
  =+  (need (~(process-player-action guts -) ~zod [%fold *@da ~]))
  =+  (need (~(process-player-action guts -) ~nec [%bet *@da 20]))
  =+  (need (~(process-player-action guts -) ~wes [%bet *@da 20]))
  =+  (need (~(process-player-action guts -) ~sev [%fold *@da ~]))
  (need (~(process-player-action guts -) ~per [%check *@da ~]))
++  test-u-flop
  =/  expected-state
    =+  state-v
    %=    -
        players.game
      :~  [~zod 980 0 %.n %.y %.n]
          [~nec 960 0 %.n %.n %.n]
          [~bud 0 0 %.n %.y %.n]
          [~wes 960 0 %.n %.n %.n]
          [~sev 970 0 %.n %.y %.n]
          [~per 960 0 %.n %.n %.n]
          [~sut 980 0 %.n %.y %.n]
          [~let 2.120 0 %.n %.n %.n]
          [~ful 980 0 %.n %.y %.n]
      ==
        pots.game
      ~[[90 ~[~nec ~wes ~per ~let]]]
        current-bet.game     0
        last-bet.game        0
        board.game           ~[[%2 %clubs] [%4 %spades] [%3 %clubs]]
        last-action.game     `%check
        last-aggressor.game  ~
        whose-turn.game      ~per
        update-message.game  ''
        revealed-hands.game  ~
    ==
  %+  expect-eq
    !>(game.expected-state)
  !>(game:state-u)
::
::  three-way pot, ~let has extra chips
::
++  state-t
  =+  (need (~(process-player-action guts state-u) ~per [%check *@da ~]))
  =+  (need (~(process-player-action guts -) ~let [%bet *@da 20]))
  =+  (need (~(process-player-action guts -) ~nec [%bet *@da 960]))
  =+  (need (~(process-player-action guts -) ~wes [%bet *@da 960]))
  =+  (need (~(process-player-action guts -) ~per [%fold *@da ~]))
  (need (~(process-player-action guts -) ~let [%bet *@da 940]))
++  test-t-hand-over
  =/  expected-state
    =+  state-u
    %=    -
        players.game
      :~  [~zod 980 0 %.n %.n %.n]
          [~nec 0 0 %.y %.y %.n]
          [~bud 0 0 %.y %.y %.n]
          [~wes 0 0 %.y %.y %.n]
          [~sev 970 0 %.n %.n %.n]
          [~per 960 0 %.n %.n %.n]
          [~sut 980 0 %.n %.n %.n]
          [~let 4.130 0 %.n %.n %.n]
          [~ful 980 0 %.n %.n %.n]
      ==
        pots.game            ~
        current-bet.game     0
        last-bet.game        0
        board.game           ~[[%2 %clubs] [%4 %spades] [%3 %clubs] [%6 %clubs] [%jack %clubs]]
        last-action.game     `%call
        last-aggressor.game  `~nec
        whose-turn.game      ~let
        hands-played.game    2
        update-message.game  '~let wins pot of 2.970 with hand Flush.  '
        revealed-hands.game
      ~[[~let ~[[%5 %diamonds] [%8 %clubs]]] [~nec ~[[%8 %spades] [%5 %spades]]] [~wes ~[[%4 %hearts] [%9 %hearts]]]]
    ==
  ;:  weld
    %+  expect-eq
      !>(game.expected-state)
    !>(game:state-t)
    %+  expect-eq
      !>(%.y)
    !>(hand-is-over:state-t)
  ==
::
::  ensure hand init works after many players out
::
++  state-s
  =+  state-t
  ~(initialize-hand guts -(deck (shuffle deck:state-t 2)))
++  test-s-next-hand
  =/  expected-state
    =+  state-t
    %=    -
        players.game
      :~  [~zod 980 0 %.n %.n %.n]
          [~nec 0 0 %.y %.y %.n]
          [~bud 0 0 %.y %.y %.n]
          [~wes 0 0 %.y %.y %.n]
          [~sev 970 0 %.n %.n %.n]
          [~per 950 10 %.n %.n %.n]
          [~sut 960 20 %.n %.n %.n]
          [~let 4.130 0 %.n %.n %.n]
          [~ful 980 0 %.n %.n %.n]
      ==
        pots.game
      ~[[0 ~[~zod ~sev ~per ~sut ~let ~ful]]]
        current-bet.game     20
        last-bet.game        20
        board.game           ~
        last-action.game     ~
        last-aggressor.game  ~
        whose-turn.game      ~let
        dealer.game          ~sev
        small-blind.game     ~per
        big-blind.game       ~sut
    ==
  %+  expect-eq
    !>(game.expected-state)
  !>(game:state-s)
::
++  state-r
  =+  (need (~(process-player-action guts state-s) ~let [%bet *@da 20]))
  =+  (need (~(process-player-action guts -) ~ful [%fold *@da ~]))
  =+  (need (~(process-player-action guts -) ~zod [%fold *@da ~]))
  =+  (need (~(process-player-action guts -) ~sev [%bet *@da 20]))
  =+  (need (~(process-player-action guts -) ~per [%bet *@da 10]))
  (need (~(process-player-action guts -) ~sut [%check *@da ~]))
++  test-r-flop
  =/  expected-state
    =+  state-s
    %=    -
        players.game
      :~  [~zod 980 0 %.n %.y %.n]
          [~nec 0 0 %.n %.y %.n]
          [~bud 0 0 %.n %.y %.n]
          [~wes 0 0 %.n %.y %.n]
          [~sev 950 0 %.n %.n %.n]
          [~per 940 0 %.n %.n %.n]
          [~sut 960 0 %.n %.n %.n]
          [~let 4.110 0 %.n %.n %.n]
          [~ful 980 0 %.n %.y %.n]
      ==
        pots.game
      ~[[80 ~[~sev ~per ~sut ~let]]]
        current-bet.game     0
        last-bet.game        0
        board.game           ~[[%jack %diamonds] [%3 %diamonds] [%king %clubs]]
        last-action.game     `%check
        last-aggressor.game  ~
        whose-turn.game      ~per
        update-message.game  ''
        revealed-hands.game  ~
    ==
  %+  expect-eq
    !>(game.expected-state)
  !>(game:state-r)
::
++  state-q
  =+  (need (~(process-player-action guts state-r) ~per [%check *@da ~]))
  =+  (need (~(process-player-action guts -) ~sut [%check *@da ~]))
  =+  (need (~(process-player-action guts -) ~let [%bet *@da 40]))
  =+  (need (~(process-player-action guts -) ~sev [%fold *@da ~]))
  =+  (need (~(process-player-action guts -) ~per [%bet *@da 40]))
  (need (~(process-player-action guts -) ~sut [%fold *@da ~]))
++  test-q-turn
  =/  expected-state
    =+  state-r
    %=    -
        players.game
      :~  [~zod 980 0 %.n %.y %.n]
          [~nec 0 0 %.n %.y %.n]
          [~bud 0 0 %.n %.y %.n]
          [~wes 0 0 %.n %.y %.n]
          [~sev 950 0 %.n %.y %.n]
          [~per 900 0 %.n %.n %.n]
          [~sut 960 0 %.n %.y %.n]
          [~let 4.070 0 %.n %.n %.n]
          [~ful 980 0 %.n %.y %.n]
      ==
        pots.game
      ~[[160 ~[~per ~let]]]
        current-bet.game     0
        last-bet.game        0
        board.game           ~[[%jack %diamonds] [%3 %diamonds] [%king %clubs] [%2 %clubs]]
        last-action.game     `%fold
        last-aggressor.game  `~let
        whose-turn.game      ~per
        update-message.game  '~sut folded. '
    ==
  %+  expect-eq
    !>(game.expected-state)
  !>(game:state-q)
::
::  now, ~bud is going to leave the game.
::  ~zod will follow, even though he still has chips
::
++  state-p
  (~(remove-player guts state-q) ~bud)
++  test-p-left-player
  =/  expected-state
    =+  state-q
    %=    -
        players.game
      :~  [~zod 980 0 %.n %.y %.n]
          [~nec 0 0 %.n %.y %.n]
          [~bud 0 0 %.y %.y %.y]
          [~wes 0 0 %.n %.y %.n]
          [~sev 950 0 %.n %.y %.n]
          [~per 900 0 %.n %.n %.n]
          [~sut 960 0 %.n %.y %.n]
          [~let 4.070 0 %.n %.n %.n]
          [~ful 980 0 %.n %.y %.n]
      ==
        update-message.game  '~bud left the game. '
    ==
  %+  expect-eq
    !>(game.expected-state)
  !>(game:state-p)
::
++  state-o
  (need (~(process-player-action guts state-p) ~per [%check *@da ~]))
++  test-o-check
  =/  expected-state
    =+  state-p
    %=    -
        players.game
      :~  [~zod 980 0 %.n %.y %.n]
          [~nec 0 0 %.n %.y %.n]
          [~bud 0 0 %.y %.y %.y]
          [~wes 0 0 %.n %.y %.n]
          [~sev 950 0 %.n %.y %.n]
          [~per 900 0 %.y %.n %.n]
          [~sut 960 0 %.n %.y %.n]
          [~let 4.070 0 %.n %.n %.n]
          [~ful 980 0 %.n %.y %.n]
      ==
        last-action.game     `%check
        whose-turn.game      ~let
        update-message.game  ''
    ==
  %+  expect-eq
    !>(game.expected-state)
  !>(game:state-o)
::
++  state-n
  =+  (~(remove-player guts state-o) ~zod)
  (need (~(process-player-action guts -) ~let [%check *@da ~]))
++  test-n-river
  =/  expected-state
    =+  state-o
    %=    -
        players.game
      :~  [~zod 980 0 %.n %.y %.y]
          [~nec 0 0 %.n %.y %.n]
          [~bud 0 0 %.n %.y %.y]
          [~wes 0 0 %.n %.y %.n]
          [~sev 950 0 %.n %.y %.n]
          [~per 900 0 %.n %.n %.n]
          [~sut 960 0 %.n %.y %.n]
          [~let 4.070 0 %.n %.n %.n]
          [~ful 980 0 %.n %.y %.n]
      ==
        last-action.game     `%check
        board.game           ~[[%jack %diamonds] [%3 %diamonds] [%king %clubs] [%2 %clubs] [%5 %spades]]
        whose-turn.game      ~per
        update-message.game  ''
    ==
  %+  expect-eq
    !>(game.expected-state)
  !>(game:state-n)
::
++  state-m
  =+  (need (~(process-player-action guts state-n) ~per [%check *@da ~]))
  (need (~(process-player-action guts -) ~let [%check *@da ~]))
++  test-m-showdown
  =/  expected-state
    =+  state-n
    %=    -
        players.game
      :~  [~zod 980 0 %.n %.n %.y]
          [~nec 0 0 %.y %.y %.n]
          [~bud 0 0 %.y %.y %.y]
          [~wes 0 0 %.y %.y %.n]
          [~sev 950 0 %.n %.n %.n]
          [~per 900 0 %.n %.n %.n]
          [~sut 960 0 %.n %.n %.n]
          [~let 4.230 0 %.n %.n %.n]
          [~ful 980 0 %.n %.n %.n]
      ==
        pots.game            ~
        last-action.game     `%check
        board.game           ~[[%jack %diamonds] [%3 %diamonds] [%king %clubs] [%2 %clubs] [%5 %spades]]
        whose-turn.game      ~let
        hands-played.game    3
        update-message.game  '~let wins pot of 160 with hand Pair.  '
        revealed-hands.game  ~[[~let ~[[%8 %hearts] [%2 %hearts]]]]
    ==
  ;:  weld
    %+  expect-eq
      !>(game.expected-state)
    !>(game:state-m)
    %+  expect-eq
      !>(%.y)
    !>(hand-is-over:state-m)
  ==
::
::  note: players are removed from player list in the next hand init
::  after they've left
::
++  state-l
  =+  state-m
  =+  ~(initialize-hand guts -(deck (shuffle deck:state-m 3)))
  =+  (need (~(process-player-action guts -) ~ful [%fold *@da ~]))
  =+  (need (~(process-player-action guts -) ~sev [%fold *@da ~]))
  =+  (need (~(process-player-action guts -) ~per [%bet *@da 900]))
  =+  (need (~(process-player-action guts -) ~sut [%bet *@da 890]))
  (need (~(process-player-action guts -) ~let [%bet *@da 880]))
++  test-l-flop
  =/  expected-state
    =+  state-m
    %=    -
        players.game
      :~  [~nec 0 0 %.n %.y %.n]
          [~wes 0 0 %.n %.y %.n]
          [~sev 950 0 %.n %.y %.n]
          [~per 0 0 %.n %.n %.n]
          [~sut 60 0 %.n %.n %.n]
          [~let 3.330 0 %.n %.n %.n]
          [~ful 980 0 %.n %.y %.n]
      ==
        pots.game
      ~[[2.700 ~[~per ~sut ~let]]]
        current-bet.game     0
        last-bet.game        0
        board.game           ~[[%9 %diamonds] [%2 %spades] [%5 %hearts]]
        last-action.game     `%call
        last-aggressor.game  `~per
        whose-turn.game      ~sut
        dealer.game          ~per
        small-blind.game     ~sut
        big-blind.game       ~let
        update-message.game  ''
        revealed-hands.game  ~
    ==
  %+  expect-eq
    !>(game.expected-state)
  !>(game:state-l)
::
::  sut goes all-in too, triggering a side pot for him and ~let
::
++  state-k
  =+  (need (~(process-player-action guts state-l) ~sut [%bet *@da 60]))
  (need (~(process-player-action guts -) ~let [%bet *@da 60]))
++  test-k-showdown
  =/  expected-state
    =+  state-l
    %=    -
        players.game
      :~  [~nec 0 0 %.y %.y %.n]
          [~wes 0 0 %.y %.y %.n]
          [~sev 950 0 %.n %.n %.n]
          [~per 2.700 0 %.n %.n %.n]
          [~sut 120 0 %.n %.n %.n]
          [~let 3.270 0 %.n %.n %.n]
          [~ful 980 0 %.n %.n %.n]
      ==
        pots.game            ~
        current-bet.game     0
        last-bet.game        0
        board.game           ~[[%9 %diamonds] [%2 %spades] [%5 %hearts] [%7 %diamonds] [%7 %clubs]]
        last-action.game     `%call
        last-aggressor.game  `~sut
        whose-turn.game      ~let
        hands-played.game    4
        update-message.game  '~per wins pot of 2.700 with hand Full House.  ~sut wins pot of 120 with hand Two Pair.  '
        revealed-hands.game  ~[[~let ~[[%8 %clubs] [%10 %spades]]] [~per ~[[%5 %clubs] [%5 %spades]]] [~sut ~[[%2 %hearts] [%ace %clubs]]]]
    ==
  %+  expect-eq
    !>(game.expected-state)
  !>(game:state-k)
::
::  TODO: handle all the way to end of game.
::
--