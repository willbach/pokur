/-  *pokur
/+  *test, *pokur-game-logic
|%
::
::  Tests for a cash table.
::
::  Starts with two players. Two more join in. One leaves.
::  Then a new player joins. A player runs out of chips and leaves.
::  Another player runs out of chips, but buys back in.
::  The three remaining players leave, one by one.
::
++  game-state-4
  ^-  host-game-state
  =/  player-list=(list @p)
    ~[~zod ~nec]
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
          :*  %cash
              min-buy=1.000
              max-buy=1.000
              buy-ins=(malt ~[[~zod 1.000] [~bus 1.000]])
              chips-per-token=1.000
              small-blind=5
              big-blind=10
              tokens-in-bond=0
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
  ~(initialize-hand guts game-state-4)
++  test-z-initial-state  ^-  tang
  =/  state=host-game-state  game-state-4
  =/  expected-state
    %=    state
        players.game
      :~  [~zod 990 10 %.n %.n %.n]
          [~nec 995 5 %.n %.n %.n]
      ==
        current-bet.game  10
        last-bet.game     10
        whose-turn.game   ~nec
        dealer.game       ~nec
        small-blind.game  ~nec
        big-blind.game    ~zod
    ==
  %+  expect-eq
    !>(game.expected-state)
  !>(game:state-z)
::
::  ~bud joins mid-hand, while ~zod and ~nec play to the turn.
::
++  state-y
  =+  (need (~(process-player-action guts state-z) ~nec [%bet *@da 5]))
  =+  (need (~(process-player-action guts -) ~zod [%check *@da ~]))
  ::  flop
  =+  (need (~(process-player-action guts -) ~zod [%check *@da ~]))
  ::  ~bud joins
  =+  (~(add-player guts -) ~bud 1.000)
  (need (~(process-player-action guts -) ~nec [%check *@da ~]))
++  test-y-turn
  =/  expected-state
    =+  state-z
    %=    -
        players.game
      :~  [~zod 990 0 %.n %.n %.n]
          ::  joining player is inserted behind dealer
          [~bud 1.000 0 %.n %.y %.n]
          [~nec 990 0 %.n %.n %.n]
      ==
        pots.game
      ~[[20 ~[~zod ~nec]]]
        current-bet.game     0
        last-bet.game        0
        board.game           ~[[%ace %clubs] [%2 %clubs] [%3 %diamonds] [%king %clubs]]
        last-action.game     `%check
        last-aggressor.game  ~
        whose-turn.game      ~zod
        update-message.game  ''
    ==
  %+  expect-eq
    !>(game.expected-state)
  !>(game:state-y)
::
::  ~zod and ~nec finish out their hand, and the next one initializes with ~bud
::
++  state-x
  =+  (need (~(process-player-action guts state-y) ~zod [%bet *@da 20]))
  =+  (need (~(process-player-action guts -) ~nec [%bet *@da 20]))
  ::  river
  =+  (need (~(process-player-action guts -) ~zod [%check *@da ~]))
  =+  (need (~(process-player-action guts -) ~nec [%check *@da ~]))
  ~(initialize-hand guts -(deck (shuffle deck.- 1)))
++  test-x-next-hand
  =/  expected-state
    =+  state-y
    %=    -
        players.game
      :~  [~zod 1.030 0 %.n %.n %.n]
          ::  joining player is inserted behind dealer
          [~bud 995 5 %.n %.n %.n]
          [~nec 960 10 %.n %.n %.n]
      ==
        pots.game
      ~[[0 ~[~zod ~bud ~nec]]]
        current-bet.game     10
        last-bet.game        10
        board.game           ~
        last-action.game     ~
        last-aggressor.game  ~
        whose-turn.game      ~zod
        dealer.game          ~zod
        small-blind.game     ~bud
        big-blind.game       ~nec
        hands-played.game    1
        update-message.game  '~zod wins pot of 60 with hand Two Pair.  '
        revealed-hands.game  ~[[~zod ~[[%king %diamonds] [%4 %spades]]]]
    ==
  %+  expect-eq
    !>(game.expected-state)
  !>(game:state-x)
::
::  the three players check their way through a hand, and right after showdown,
::  new player ~wes joins.
::
++  state-w
  =+  (need (~(process-player-action guts state-x) ~zod [%bet *@da 10]))
  =+  (need (~(process-player-action guts -) ~bud [%bet *@da 5]))
  =+  (need (~(process-player-action guts -) ~nec [%check *@da ~]))
  ::  flop
  =+  (need (~(process-player-action guts -) ~bud [%bet *@da 10]))
  =+  (need (~(process-player-action guts -) ~nec [%bet *@da 10]))
  =+  (need (~(process-player-action guts -) ~zod [%fold *@da ~]))
  ::  turn
  =+  (need (~(process-player-action guts -) ~bud [%bet *@da 10]))
  =+  (need (~(process-player-action guts -) ~nec [%bet *@da 10]))
  ::  river
  =+  (need (~(process-player-action guts -) ~bud [%check *@da ~]))
  ::  join, showdown
  =+  (~(add-player guts -) ~wes 1.000)
  (need (~(process-player-action guts -) ~nec [%check *@da ~]))
++  test-w-join-at-showdown
  =/  expected-state
    =+  state-x
    %=    -
        players.game
      :~  [~wes 1.000 0 %.n %.n %.n]
          [~zod 1.020 0 %.n %.n %.n]
          [~bud 1.040 0 %.n %.n %.n]
          [~nec 940 0 %.n %.n %.n]
      ==
        pots.game            ~
        current-bet.game     0
        last-bet.game        0
        board.game           ~[[%jack %diamonds] [%ace %hearts] [%jack %hearts] [%jack %spades] [%8 %clubs]]
        last-action.game     `%check
        last-aggressor.game  `~bud
        whose-turn.game      ~nec
        hands-played.game    2
        update-message.game  '~bud wins pot of 70 with hand Full House.  '
        revealed-hands.game  ~[[~bud ~[[%8 %spades] [%5 %spades]]]]
    ==
  %+  expect-eq
    !>(game.expected-state)
  !>(game:state-w)
::
::  structure of host means that showdown goes *straight* to next hand init.
::  forgot to shuffle here but it's fine
::
++  state-v
  ~(initialize-hand guts state-w)
++  test-v-next-hand
  =/  expected-state
    =+  state-w
    %=    -
        players.game
      :~  [~wes 990 10 %.n %.n %.n]
          [~zod 1.020 0 %.n %.n %.n]
          [~bud 1.040 0 %.n %.n %.n]
          [~nec 935 5 %.n %.n %.n]
      ==
        pots.game            ~[[0 ~[~wes ~zod ~bud ~nec]]]
        current-bet.game     10
        last-bet.game        10
        board.game           ~
        last-action.game     ~
        last-aggressor.game  ~
        whose-turn.game      ~zod
        dealer.game          ~bud
        small-blind.game     ~nec
        big-blind.game       ~wes
        update-message.game  '~bud wins pot of 70 with hand Full House.  '
        revealed-hands.game  ~[[~bud ~[[%8 %spades] [%5 %spades]]]]
    ==
  %+  expect-eq
    !>(game.expected-state)
  !>(game:state-v)
::
::  now the 4some plays a hand. Right after showdown,
::  ~x leaves with their winnings. very rude.
::
++  state-u
  =+  (need (~(process-player-action guts state-v) ~zod [%fold *@da ~]))
  =+  (need (~(process-player-action guts -) ~bud [%bet *@da 10]))
  =+  (need (~(process-player-action guts -) ~nec [%fold *@da ~]))
  =+  (need (~(process-player-action guts -) ~wes [%check *@da ~]))
  ::  flop
  =+  (need (~(process-player-action guts -) ~wes [%bet *@da 10]))
  =+  (need (~(process-player-action guts -) ~bud [%bet *@da 10]))
  ::  turn
  =+  (need (~(process-player-action guts -) ~wes [%check *@da ~]))
  =+  (need (~(process-player-action guts -) ~bud [%bet *@da 20]))
  =+  (need (~(process-player-action guts -) ~wes [%bet *@da 20]))
  ::  river
  =+  (need (~(process-player-action guts -) ~wes [%check *@da ~]))
  =+  (need (~(process-player-action guts -) ~bud [%check *@da ~]))
  ::  forgot to shuffle here but it's fine
  ~(initialize-hand guts -)
++  test-u-showdown
  =/  expected-state
    =+  state-v
    %=    -
        players.game
      :~  [~wes 1.040 5 %.n %.n %.n]
          [~zod 1.010 10 %.n %.n %.n]
          [~bud 1.000 0 %.n %.n %.n]
          [~nec 935 0 %.n %.n %.n]
      ==
        pots.game            ~[[0 ~[~wes ~zod ~bud ~nec]]]
        current-bet.game     10
        last-bet.game        10
        board.game           ~
        last-action.game     ~
        last-aggressor.game  ~
        whose-turn.game      ~bud
        dealer.game          ~nec
        small-blind.game     ~wes
        big-blind.game       ~zod
        hands-played.game    3
        update-message.game  '~wes wins pot of 85 with hand Flush.  '
        revealed-hands.game  ~[[~bud ~[[%10 %diamonds] [%9 %diamonds]]] [~wes ~[[%ace %diamonds] [%king %diamonds]]]]
    ==
  %+  expect-eq
    !>(game.expected-state)
  !>(game:state-u)
::
++  state-t
  (~(remove-player guts state-u) ~wes)
++  test-t-wes-left
  =/  expected-state
    =+  state-u
    %=    -
        players.game
      :~  [~wes 1.040 5 %.y %.y %.y]
          [~zod 1.010 10 %.n %.n %.n]
          [~bud 1.000 0 %.n %.n %.n]
          [~nec 935 0 %.n %.n %.n]
      ==
        pots.game            ~[[0 ~[~zod ~bud ~nec]]]
        current-bet.game     10
        last-bet.game        10
        board.game           ~
        last-action.game     ~
        last-aggressor.game  ~
        whose-turn.game      ~bud
        dealer.game          ~nec
        small-blind.game     ~wes
        big-blind.game       ~zod
        hands-played.game    3
        update-message.game  '~wes left the game. '
        revealed-hands.game  ~[[~bud ~[[%10 %diamonds] [%9 %diamonds]]] [~wes ~[[%ace %diamonds] [%king %diamonds]]]]
    ==
  %+  expect-eq
    !>(game.expected-state)
  !>(game:state-t)
::
::  the flop plays out
::
++  state-s
  =+  (need (~(process-player-action guts state-t) ~bud [%fold *@da ~]))
  =+  (need (~(process-player-action guts -) ~nec [%bet *@da 10]))
  (need (~(process-player-action guts -) ~zod [%check *@da ~]))
++  test-s-flop
  =/  expected-state
    =+  state-t
    %=    -
        players.game
      :~  [~wes 1.040 0 %.n %.y %.y]
          [~zod 1.010 0 %.n %.n %.n]
          [~bud 1.000 0 %.n %.y %.n]
          [~nec 925 0 %.n %.n %.n]
      ==
        pots.game            ~[[25 ~[~zod ~nec]]]
        current-bet.game     0
        last-bet.game        0
        board.game           ~[[%5 %diamonds] [%4 %diamonds] [%3 %diamonds]]
        last-action.game     `%check
        last-aggressor.game  ~
        whose-turn.game      ~zod
        update-message.game  ''
        revealed-hands.game  ~
    ==
  %+  expect-eq
    !>(game.expected-state)
  !>(game:state-s)
::
::  ~zod takes the hand after a new player joins.
::
++  state-r
  =+  (~(add-player guts state-s) ~sev 1.000)
  =+  (need (~(process-player-action guts -) ~zod [%bet *@da 50]))
  =+  (need (~(process-player-action guts -) ~nec [%fold *@da ~]))
  ~(initialize-hand guts -(deck (shuffle generate-deck 3)))
++  test-r-new-hand
  =/  expected-state
    =+  state-s
    %=    -
        players.game
      :~  [~zod 1.035 0 %.n %.n %.n]
          [~bud 995 5 %.n %.n %.n]
          [~sev 990 10 %.n %.n %.n]
          [~nec 925 0 %.n %.n %.n]
      ==
        pots.game            ~[[0 ~[~zod ~bud ~sev ~nec]]]
        current-bet.game     10
        last-bet.game        10
        board.game           ~
        last-action.game     ~
        last-aggressor.game  ~
        whose-turn.game      ~nec
        dealer.game          ~zod
        small-blind.game     ~bud
        big-blind.game       ~sev
        hands-played.game    4
        update-message.game  '~nec folded. ~zod wins pot of 75. '
        revealed-hands.game  ~
    ==
  %+  expect-eq
    !>(game.expected-state)
  !>(game:state-r)
::
::  ~nec goes all-in against ~sev and leaves with 0 chips.
::
++  state-q
  =+  (need (~(process-player-action guts state-r) ~nec [%bet *@da 925]))
  =+  (need (~(process-player-action guts -) ~zod [%fold *@da ~]))
  =+  (need (~(process-player-action guts -) ~bud [%fold *@da ~]))
  =+  (need (~(process-player-action guts -) ~sev [%bet *@da 915]))
  =+  ~(initialize-hand guts -)
  (~(remove-player guts -) ~nec)
++  test-q-next-hand
  =/  expected-state
    =+  state-r
    %=    -
        players.game
      :~  [~zod 1.025 10 %.n %.n %.n]
          [~bud 995 0 %.n %.n %.n]
          [~sev 1.925 5 %.n %.n %.n]
          [~nec 0 0 %.y %.y %.y]
      ==
        pots.game            ~[[0 ~[~zod ~bud ~sev]]]
        current-bet.game     10
        last-bet.game        10
        board.game           ~
        last-action.game     ~
        last-aggressor.game  ~
        whose-turn.game      ~bud
        dealer.game          ~bud
        small-blind.game     ~sev
        big-blind.game       ~zod
        hands-played.game    5
        update-message.game  '~nec left the game. '
        revealed-hands.game  ~[[~sev ~[[%5 %clubs] [%5 %spades]]] [~nec ~[[%2 %hearts] [%ace %clubs]]]]
    ==
  %+  expect-eq
    !>(game.expected-state)
  !>(game:state-q)
::
::  TODO: finish
::
--