/-  *pokur
|%
++  parse-time-limit
  |=  tex=@t
  ^-  @dr
  ?>  (lth (slav %ud tex) 1.000)
  (slav %dr `@t`(cat 3 '~s' tex))
::
++  modify-table-state
  |_  state=host-table-state
  ::  checks if all players have acted or folded, and
  ::  committed the same amount of chips, OR,
  ::  if a player is all-in, i.e. has 0 in stack
  ++  is-betting-over
    ^-  ?
    %+  levy  players.table.state
    |=  [ship player-info]
    ?|  acted
        folded
        ?&  =(0 stack)
            =(committed current-bet.table.state)
    ==  ==
  ::  checks cards on table and either initiates flop,
  ::  turn, river, or determine-winner
  ++  next-betting-round
    ^-  host-table-state
    =/  n  (lent board.table.state)
    ?:  |(=(3 n) =(4 n))  turn-or-river
    ?.  =(5 n)            pokur-flop
    ::  handle end of hand
    %-  process-win
    %-  determine-winner
    %+  murn  players.table.state
    |=  [who=ship player-info]
    ?:  folded  ~
    [who (~(got by hands.state) who)]
  ::  **takes in a shuffled deck**
  ::  assign dealer, assign blinds, assign first action
  ::  to person left of BB (which is dealer in heads-up)
  ::  make sure to shuffle deck from outside with eny!!!
  ::  check for players who have left, remove them
  ++  initialize-hand
    |=  dealer=ship
    ^-  host-table-state
    =.  players.table.state
      %+  skip  players.table.state
      |=([ship player-info] left)
    =.  dealer.table.state
      %+  get-next-unfolded-player
        dealer
      players.table.state
    =.  state  assign-blinds
    =.  state  deal-hands
    =.  whose-turn.table.state
      %+  get-next-unfolded-player
        big-blind.table.state
      players.table.state
    =.  hand-is-over.state  %.n
    state
  ::  deals 2 cards from deck to each player in game
  ++  deal-hands
    ^-  host-table-state
    =|  new-hands=(map ship pokur-deck)
    =/  players  players.table.state
    |-
    ?~  players  state
    =/  drawn    (draw 2 deck.state)
    %=  $
      players      t.players
      deck.state   rest.drawn
      hands.state  [ship.i.players hand.drawn]^hands.state
    ==
  ::
  ++  pokur-flop
    ^-  host-table-state
    =.  state  committed-chips-to-pot
    (deal-to-board 3)
  ::
  ++  turn-or-river
    ^-  host-table-state
    =.  state  committed-chips-to-pot
    (deal-to-board 1)
  ::  draws n cards (after burning 1) from deck,
  ::  appends them to end of board, and sets action
  ::  to the next unfolded player left of dealer
  ++  deal-to-board  ::  TODO
    |=  n=@ud
    ^-  host-table-state
    =/  burn  (draw 1 deck.state)
    =/  turn  (draw n rest:burn)
    =.  deck.state
      rest:turn
    =.  board.table.state
      %+  weld
        board.table.state
      hand:turn
    ::  setting who goes first in betting round here
    =.  whose-turn.table.state
      dealer.table.state
    next-player-turn
  ::  sets whose-turn to next player in list **who hasn't folded**
  ::  if all players are folded, this means that everyone left..
  ++  next-player-turn
    ^-  host-table-state
    %=    state
        whose-turn.table.state
      %+  get-next-unfolded-player
        whose-turn.table.state
      players.table.state
    ==
  ::
  ++  get-next-unfolded-player
    |=  [current=ship =players]
    ^-  ship
    =/  unfolded-players
      %+  skip  players
      |=([ship player-info] folded)
    ?~  unfolded-players
      ::  everyone left, just return something so server can delete
      current
    %+  snag
      %+  mod
        +((need (find [current]~ players)))
      (lent unfolded-players)
    unfolded-players
  ::  sends chips from player's 'stack' to their
  ::  'committed' pile. used after a bet, call, raise
  ::  is made. committed chips don't go to pot until
  ::  round of betting is complete
  ::  if player doesn't have enough chips, put them all-in!
  ++  commit-chips
    |=  [who=ship amount=@ud]
    ^-  players
    %+  turn  players.table.state
    |=  [p=ship i=player-info]
    ?.  =(p who)  [p i]
    ?:  (gth amount stack)
      ::  all-in
      [p i(committed (add committed.i stack.i), stack 0)]
    [p i(committed (add committed.i amount), stack (sub stack.i amount))]
  ::
  ++  set-player-as-acted
    |=  who=ship
    ^-  players
    %+  turn  players.table.state
    |=  [p=ship i=player-info]
    ?.  =(p who)  [p i]
    [p i(acted %.y)]
  ::
  ++  set-player-as-folded
    |=  who=ship
    ^-  players
    %+  turn  players.table.state
    |=  [p=ship i=player-info]
    ?.  =(p who)  [p i]
    [p i(folded %.y)]
  ::
  ++  committed-chips-to-pot
    ^-  host-table-state
    =/  pot-to-update=@ud
      ::  grab from potential side-pots
      -:(rear pots.table.state)
    =^  players  pot-to-update
      %^  spin  players.table.state  -.pot-to-update
      |=  [p=ship i=player-info pot=@ud]
      [p i(committed 0, acted %.n) (add pot committed.i)]
    %=  state
      current-bet.table  0
      last-bet.table     0
      players.table      players
      pots.table  (snoc (snip pots.table.state) pot-to-update)
    ==
  ::  takes blinds from the two unfolded players left of dealer
  ::  (in heads up, dealer is small blind)
  ++  assign-blinds
    ^-  host-table-state
    =.  small-blind.table.state
      ?:  =((lent players.table.state) 2)
        dealer.table.state
      %+  get-next-unfolded-player
        dealer.table.state
      players.table.state
    ::
    =.  big-blind.table.state
      %+  get-next-unfolded-player
        small-blind.table.state
      players.table.state
    ::  if game type is %cash, use set blinds
    ::  if %tournament, set blinds based on round we're on
    =/  blinds=[small=@ud big=@ud]
      ?:  ?=(%cash -.game-type.table.state)
        [big-blind small-blind]:game-type.table.state
      %+  snag  current-round.table.state
      blinds-schedule.game-type.table.state
    =.  players.table.state
      (commit-chips small-blind.table.state small.blinds)
    %=  state
      current-bet.table  big.blinds
      last-bet.table     big.blinds
      players.table  (commit-chips big-blind.table.state big.blinds)
    ==
  ::  this gets called when a tournament round timer runs out
  ::  it tells us to increment when current hand is over
  ::  and sets an update message in the game state
  ++  increment-current-round
    ^-  host-table-state
    =/  blinds=[small=@ud big=@ud]
      ?:  ?=(%cash -.game-type.table.state)
        [big-blind small-blind]:game-type.table.state
      %+  snag  current-round.table.state
      blinds-schedule.game-type.table.state
    %=  state
      round-is-over.table  %.y
        update-message.table
      :_  ~
      """
      Round {<current-round.table.state>} beginning at next hand.
      New blinds: {<small.new-blinds>}/{<big.new-blinds>}
      """
    ==
  ++  award-pots
    |=  winners=(list ship)
    ^-  host-table-state
    ::  TODO create update message with side pot handling
    ?~  pots.table.state  state
    =*  pot  i.pots.table.state
    =/  winners-in-pot=(list ship)
      =-  ?^  -  -
      %+  skim  winners
      |=  =ship
      ?=(^ (find [ship]~ in.pot))
      ::  no winners in this pot, find the relative winner(s) present
      %-  determine-winner
      %+  skim  ~(tap by hands.state)
      |=  [=ship hand=pokur-deck]
      ?=(^ (find [ship]~ in.pot))
    %=  $
      pots.table.state  t.pots.table.state
        players.table.state
      ?:  =(1 (lent winners-in-pot))
        ::  award entire pot to single winner
        %+  turn  players.table.state
        |=  [p=ship player-info]
        ?.  =(p -.-.winners-in-pot)
          [p stack 0 %.n %.n left]
        [p (add stack amount.pot) 0 %.n %.n left]
      ::  split pot evenly between multiple winners
      =/  split  (div amount.pot (lent winners-in-pot))
      %+  turn  players.table.state
      |=  [p=ship player-info]
      ?~  (find [p]~ winners-in-pot)
        [p stack 0 %.n %.n left]
      [p (add stack split) 0 %.n %.n left]
    ==
  ::  given a list of [winner [rank hand]], send them the pot. prepare
  ::  for next hand by clearing board, hands and bets, reset fold status,
  ::  and incrementing hands-played.
  ++  process-win
    |=  winners=(list [ship [@ud pokur-deck]])
    ^-  host-table-state
    :: get ship names
    =/  winning-ships  (turn winners head)
    =/  winning-rank   -.+:(head winners)
    ::  sends any extra committed chips to pot
    =.  state  committed-chips-to-pot
    =.  state  award-pots
    %=  state
      board.table         ~
      current-bet.table   0
      last-bet.table      0
      deck                generate-deck
      hands-played.table  +(hands-played.table)
      pots.table  [[0 (turn players.table.state head)]]
    ::
        current-round.table
      ?.  round-is-over.table
        current-round.table.state
      +(current-round.table.state)
    ::
      round-is-over.table  %.n
      hand-is-over.table   %.y
    ::
        game-is-over.table
      =/  active-with-chips
        %-  lent
        %+  skip  players.table.state
        |=  [p=ship player-info]
        |(=(0 stack) left)
      ?|  =(1 active-with-chips)
          =(0 active-with-chips)
      ==
    ::
        players.table
      %+  turn  players.table.state
      |=  [p=ship i=player-info]
      ?.  =(0 stack.i)  [p i]
      [p i(acted %.y folded %.y)]
    ==
  ::  given a player and a pokur-action, handles the action.
  ::  currently checks for being given the wrong player (not their turn),
  ::  bad bet (2x existing bet, >BB, or matches current bet (call)),
  ::  and trying to check when there's a bet to respond to.
  ::  * if betting is complete, go right into flop/turn/river/determine-winner
  ::  * folds trigger win for last standing player
  ++  process-player-action
    |=  [who=ship action=game-action]
    ^-  host-table-state
    ?.  =(who whose-turn.table.state)
      :: error, wrong player making move
      !!
    ?-  -.action
      %check
    =/  committed
    committed:(get-player-chips who chips.table.state)
    ?:  (gth current-bet.table.state committed)
      :: error, player must match current bet
      !!
    ::  set checking player to 'acted'
    =.  state
      (set-player-as-acted who)
    ?.  is-betting-over
      next-player-turn
    next-betting-round
      %bet
    =/  stack
      in-stack:(get-player-chips who chips.table.state)
    =/  bet-plus-committed
      %+  add
        amount.action
      committed:(get-player-chips who chips.table.state)
    =/  current-min-bet
      %+  snag
        :: this will always be 0 in a cash game
        current-round.table.state
      min-bets.table.state
    :: ALL-IN logic here
    ?:  ?|  =(amount.action stack)
            (gth amount.action stack)
        ==
      :: if someone tries to bet more than their stack, count it as an all-in
      =.  last-bet.table.state
        :: same with last-bet, only update if raise
        ?:  (gth bet-plus-committed current-bet.table.state)
          (sub bet-plus-committed current-bet.table.state)
        last-bet.table.state
      =.  current-bet.table.state
        :: only update current bet if the all-in is a raise
        ?:  (gth bet-plus-committed current-bet.table.state)
          bet-plus-committed
        current-bet.table.state
      =.  players.table.state
        (commit-chips who stack)
      =.  state
        (set-player-as-acted who)
      =.  update-message.table.state
        ["{<who>} is all-in." ~]
      ?.  is-betting-over
        next-player-turn
      next-betting-round
    :: resume logic for not-all-in
    ?:  ?&
          =(current-bet.table.state 0)
          (lth bet-plus-committed current-min-bet)
        ==
      !!  :: this is a starting bet below min-bet
    ?:  =(bet-plus-committed current-bet.table.state)
      :: this is a call
      =.  players.table.state
      %+  commit-chips
        who
      amount.action
      =.  state
      (set-player-as-acted who)
      ?.  is-betting-over
        next-player-turn
      next-betting-round
    :: this is a raise attempt
    ?.  ?&
          (gte amount.action last-bet.table.state)
          (gte bet-plus-committed (add last-bet.table.state current-bet.table.state))
        ==
      :: error, raise must be >= amount of previous bet/raise
      !!
    :: process raise
    :: do this before updating current-bet
    =.  last-bet.table.state
      (sub bet-plus-committed current-bet.table.state)
    =.  current-bet.table.state
      bet-plus-committed
    =.  players.table.state
      (commit-chips who amount.action)
    =.  state
      (set-player-as-acted who)
    ?.  is-betting-over
      next-player-turn
    next-betting-round
      %fold
    =.  state
      (set-player-as-acted who)
    =.  state
      (set-player-as-folded who)
    :: if only one player hasn't folded, process win for them
    =/  players-left
      %+  turn
        %+  skip
          chips.table.state
        |=  [ship @ud @ud ? folded=? ?]
          folded
      |=  [s=ship @ud @ud ? ? ?]
        s
    ?:  =((lent players-left) 1)
      %-  process-win
      ~[[-.players-left [10 ~]]]
    :: otherwise continue game
    ?.  is-betting-over
      next-player-turn
    next-betting-round
    :: lib should never, ever see these :)
      %receive-msg
    !!
      %send-msg
    !!
    ==
  :: takes a list of hands and finds winning hand. This is only called
  :: when the board is full, so it deals with all 7-card hands.
  :: It returns a list of winning ships, which usually contains just
  :: the one, but can have up to n ships all tied.
  ++  determine-winner
    |=  hands=(list [ship pokur-deck])
    ^-  (list [ship [@ud pokur-deck]])
    =/  eval-each-hand
      |=  [who=ship hand=pokur-deck]
      =/  hand
        (weld hand board.table.state)
      [who (evaluate-7-card-hand hand)]
    =/  hand-ranks  (turn hands eval-each-hand)
    :: return player with highest hand rank
    =/  player-ranks
      %+  sort
        hand-ranks
      |=  [a=[p=ship [r=@ud h=pokur-deck]] b=[p=ship [r=@ud h=pokur-deck]]]
      (gth r.a r.b)
    :: check for tie(s) and break before returning winner
    ?:  =(-.+.-.player-ranks -.+.+<.player-ranks)
      =/  player-ranks
      %+  sort
        player-ranks
      |=  [a=[p=ship [r=@ud h=pokur-deck]] b=[p=ship [r=@ud h=pokur-deck]]]
      ^-  ?
      (break-ties +.a +.b)
      :: then check for identical hands, in which case pot must be split.
      =/  winning-players
        %+  skim
          player-ranks
        |=  a=[p=ship [r=@ud h=pokur-deck]]
        (hands-equal h.a +.+:(head player-ranks))
      ?:  %+  gth
            (lent winning-players)
          1
        winning-players
      ~[(head player-ranks)]
    ~[(head player-ranks)]
  ::
  ++  remove-player
    |=  who=ship
    ^-  host-table-state
    :: set player to folded+acted+left
    :: if it was their turn, go to next player's turn
    =.  players.table.state
      %+  turn  players.table.state
      |=  [p=ship i=player-info]
      ?.  =(p who)  [p i]
      [p i(acted %.y, folded %.y, left %.y)]
    ?.  =(who whose-turn.table.state)  state
    ?.  is-betting-over
      next-player-turn
    next-betting-round
  --
::
::  Hand evaluation and sorted helper arms
::
::  +evaluate-7-card-hand: returns a cell of [hierarchy-number hand]
::  where hand is the *strongest possible 5 card hand*.
++  evaluate-7-card-hand
  |=  hand=pokur-deck
  ^-  [@ud pokur-deck]
  =/  removal-pairs=(list [@ud @ud])
    :~  [0 1]  [0 2]  [0 3]  [0 4]  [0 5]  [0 6]
        [1 2]  [1 3]  [1 4]  [1 5]  [1 6]
        [2 3]  [2 4]  [2 5]  [2 6]
        [3 4]  [3 5]  [3 6]
        [4 5]  [4 6]
        [5 6]
    ==
  =/  rank-sorted-5-card-hands=(list [@ud pokur-deck])
    %-  sort
    :_  |=([a=[@ud *] b=[@ud *]] (gth -.a -.b))
    =|  ranked-hands=(list [@ud pokur-deck])
    |-
    ?~  removal-pairs  ranked-hands
    =+  %+  oust  [-.i.removal-pairs 1]
        (oust [+.i.removal-pairs 1] hand)
    $(ranked-hands [[(evaluate-5-cards -) -] ranked-hands])
  ::  elimate any hand without a score that matches top hand
  ::  if there are multiple, sort them by break-ties
  =/  best-hand-rank  -.-.rank-sorted-5-card-hands
  =/  best-5-card-hands
    %+  skim  rank-sorted-5-card-hands
    |=([r=@ud *] =(r best-hand-rank))
  ::  break any ties
  (head (sort best-5-card-hands break-ties))
:: arm for players to evaluate their hand before the river
:: this is the same as evaluate-7-card-hand, just with 6 cards
++  evaluate-6-card-hand
  |=  hand=pokur-deck
  ^-  [@ud pokur-deck]
  =/  removal-indices  [0 1 2 3 4 5 ~]
  =/  rank-sorted-5-card-hands=(list [@ud pokur-deck])
    %-  sort
    :_  |=([a=[@ud *] b=[@ud *]] (gth -.a -.b))
    =|  ranked-hands=(list [@ud pokur-deck])
    |-
    ?~  removal-indices  ranked-hands
    =+  (oust [i.removal-indices 1] hand)
    $(ranked-hands [[(evaluate-5-cards -) -] ranked-hands])
  ::  elimate any hand without a score that matches top hand
  ::  if there are multiple, sort them by break-ties
  =/  best-hand-rank  -.-.rank-sorted-5-card-hands
  =/  best-5-card-hands
    %+  skim  rank-sorted-5-card-hands
    |=([r=@ud *] =(r best-hand-rank))
  ::  break any ties
  (head (sort best-5-card-hands break-ties))
::  core hand evaluation function
::  assigns a rank to 5 card hand
++  evaluate-5-cards
  |=  hand=pokur-deck
  ^-  @ud
  ::  check for pairs with histogram of hand
  =/  raw-hand  (turn hand card-to-raw)
  =/  histogram
    %-  sort  :_  gth
    %-  skip  :_  |=(n=@ud =(n 0))
    =/  histo  (reap 13 0)
    |-
    ?~  hand  histo
    $(histo (snap histo -.i.hand +(snag -.i.hand histo)))
  ?:  =(histogram ~[4 1])      7  ::  four of a kind
  ?:  =(histogram ~[3 2])      6  ::  full house
  ?:  =(histogram ~[3 1 1])    3  ::  trips
  ?:  =(histogram ~[2 2 1])    2  ::  two pair
  ?:  =(histogram ~[2 1 1 1])  1  ::  pair
  ::  at this point, must sort hand
  =.  raw-hand
    (sort raw-hand |=([a=[@ud @ud] b=[@ud @ud]] (gth -.a -.b)))
  ::  check for flush, straight
  ?:  (check-5-card-flush raw-hand)
    ?:  is-straight=(check-5-card-straight raw-hand)
      ?:  &(=(-.-.raw-hand 12) =(-.+>+>-.raw-hand 8))
        9  ::  royal flush!!!!
      8  ::  straight flush!
    5  ::  flush
  ?:  is-straight
    4  ::  straight
  0  ::  high card
::
++  check-5-card-flush
  |=  raw-hand=(list [@ud @ud])
  ^-  ?
  =/  suit  +.-.raw-hand
  %+  levy  raw-hand
  |=(c=[@ud @ud] =(+.c suit))
:: **hand must be sorted before using this
++  check-5-card-straight
  |=  raw-hand=(list [@ud @ud])
  ^-  ?
  ?:  =(4 (sub -.-.raw-hand -.+>+>-.raw-hand))
    %.y
  :: also need to check for wheel straight
  &(=(-.-.raw-hand 12) =(-.+<.raw-hand 3))
:: given two hands, returns %.y if 1 is better than 2 (like gth)
:: ONLY WORKS 100% for 5 card hands -- kickers BREAK THIS
:: use in a sort function to sort hands with more granularity to find true winner
++  break-ties
  |=  [hand1=[r=@ud h=pokur-deck] hand2=[r=@ud h=pokur-deck]]
  ^-  ?
  ::  if ranks are strictly better, just return that
  ::  otherwise break equally-ranked hands
  ?.  =(r.hand1 r.hand2)
    (gth r.hand1 r.hand2)
  ::  sort whole hands to start
  =.  h.hand1  (sort h.hand1 (card-compare a b))
  =.  h.hand2  (sort h.hand2 (card-compare a b))
  ::  match tie-breaking strategy to type of hand
  ?:  ?|  =(r.hand1 8)
          =(r.hand1 5)
          =(r.hand1 4)
          =(r.hand1 0)
        ==
    (find-high-card h.hand1 h.hand2)
  ?:  ?|  =(r.hand1 7)
          =(r.hand1 6)
          =(r.hand1 3)
          =(r.hand1 2)
          =(r.hand1 1)
        ==
    =.  h.hand1
      %-  sort-hand-by-frequency
        h.hand1
    =.  h.hand2
      %-  sort-hand-by-frequency
        h.hand2
    %+  find-high-card
      h.hand1
    h.hand2
  :: if we get here we were given a wrong hand rank or a royal flush (can't tie those)
  %.n
:: Sorts cards in pokur-deck by frequency of value, then rank
++  sort-hand-by-frequency
  |=  hand=pokur-deck
  ^-  pokur-deck
  %-  turn
  :_  head
  %+  sort
    ::  first add frequency to each card
    %+  turn  hand
    |=  c=pokur-card
    :-  c
    %-  lent
    %+  skim  hand
    |=([d=pokur-card] =(-.c -.d))
  ::  then sort by frequency, falling back to card rank
  |=  [a=[c=pokur-card freq=@ud] b=[c=pokur-card freq=@ud]]
  ?:  =(freq.a freq.b)
    (card-compare c.a c.b)
  (gth freq.a freq.b)
:: Utility function to check if two hands are the same.
++  hands-equal
  |=  [h1=pokur-deck h2=pokur-deck]
  ^-  ?
  ?~  h1  %.n
  ?~  h2  %.n
  ?.  (cards-equal i.h1 i.h2)
    %.n
  $(h1 t.h1, h2 t.h2)
::  %.y if hand1 has higher card, %.n if hand2 does
::  hands must be sorted to use
++  find-high-card
  |=  [h1=pokur-deck h2=pokur-deck]
  ^-  ?
  ?~  h1  %.n
  ?~  h2  %.y
  ?.  (cards-equal i.h1 i.h2)
    (card-compare i.h1 i.h2)
  $(h1 t.h1, h2 t.h2)
::
++  card-compare
  |=  [c1=pokur-card c2=pokur-card]
  ^-  ?
  (gth (card-val-to-atom c1) (card-val-to-atom c2))
::
++  cards-equal
  |=  [c1=pokur-card c2=pokur-card]
  ^-  ?
  =((card-val-to-atom c1) (card-val-to-atom c2))
::
++  hierarchy-to-rank
  |=  h=@ud
  ^-  tape
  ?+  h  "-"
    %9  "Royal Flush"
    %8  "Straight Flush"
    %7  "Four of a Kind"
    %6  "Full House"
    %5  "Flush"
    %4  "Straight"
    %3  "Three of a Kind"
    %2  "Two Pair"
    %1  "Pair"
    %0  "High Card"
  ==
::
++  card-to-raw
  |=  c=pokur-card
  ^-  [@ud @ud]
  [(card-val-to-atom -.c) (suit-to-atom +.c)]
::
++  card-val-to-atom
  |=  c=card-val
  ^-  @
  ?-  c
    %2      0
    %3      1
    %4      2
    %5      3
    %6      4
    %7      5
    %8      6
    %9      7
    %10     8
    %jack   9
    %queen  10
    %king   11
    %ace    12
  ==
::
++  suit-to-atom
  |=  s=suit
  ^-  @
  ?-  s
    %hearts    0
    %spades    1
    %clubs     2
    %diamonds  3
  ==
::
++  atom-to-card-val
  |=  n=@
  ^-  card-val
  ?+  n  !!
    %0   %2
    %1   %3
    %2   %4
    %3   %5
    %4   %6
    %5   %7
    %6   %8
    %7   %9
    %8   %10
    %9   %jack
    %10  %queen
    %11  %king
    %12  %ace
  ==
::
++  atom-to-suit
  |=  val=@
  ^-  suit
  ?+  val  !!
    %0  %hearts
    %1  %spades
    %2  %clubs
    %3  %diamonds
  ==
::  create a new 52 card poker deck
++  generate-deck
  ^-  pokur-deck
  =|  new-deck=pokur-deck
  =+  i=0
  |-
  ?:  (gth i 3)  new-deck
  =+  j=0
  |-
  ?.  (lte j 12)  ^$(i +(i))
  %=  $
    j         +(j)
    new-deck  [(atom-to-card-val j) (atom-to-suit i)]^new-deck
  ==
::  given a deck and entropy, return shuffled deck
::  TODO: this could be better... not sure it's robust enough for real play
++  shuffle-deck
  |=  [unshuffled=pokur-deck entropy=@]
  ^-  pokur-deck
  =|  shuffled=pokur-deck
  =/  random  ~(. og entropy)
  =/  remaining  (lent unshuffled)
  |-
  ?:  =(remaining 1)
    [(snag 0 unshuffled) shuffled]
  =^  index  random
    (rads:random remaining)
  %=  $
    shuffled    (snag index unshuffled)^shuffled
    remaining   (dec remaining)
    unshuffled  (oust [index 1] unshuffled)
  ==
::  gives back [hand rest] where hand is n cards from top of deck, rest is rest
++  draw
  |=  [n=@ud d=pokur-deck]
  [(scag n d) (slag n d)]
--
