/-  *pokur
|%
++  parse-time-limit
  |=  tex=@t
  ^-  @dr
  ?>  (lth (slav %ud tex) 1.000)
  (slav %dr `@t`(cat 3 '~s' tex))
::
++  modify-game-state
  |_  state=host-game-state
  ::  checks if all players have acted or folded, and
  ::  committed the same amount of chips, OR,
  ::  if a player is all-in, i.e. has 0 in stack
  ++  is-betting-over
    ^-  ?
    %+  levy  players.game.state
    |=  [ship player-info]
    ?|  acted
        folded
        ?&  =(0 stack)
            =(committed current-bet.game.state)
    ==  ==
  ::  checks cards on game and either initiates flop,
  ::  turn, river, or determine-winner
  ++  next-betting-round
    ^-  host-game-state
    =/  n  (lent board.game.state)
    ?:  |(=(3 n) =(4 n))  turn-or-river
    ?.  =(5 n)            pokur-flop
    ::  handle end of hand
    %-  process-win
    %-  turn  :_  head
    %-  determine-winner
    %+  murn  players.game.state
    |=  [who=ship player-info]
    ?:  folded  ~
    `[who (~(got by hands.state) who)]
  ::  **takes in a shuffled deck**
  ::  assign dealer, assign blinds, assign first action
  ::  to person left of BB (which is dealer in heads-up)
  ::  make sure to shuffle deck from outside with eny!!!
  ::  check for players who have left, remove them
  ++  initialize-hand
    |=  dealer=ship
    ^-  host-game-state
    =.  players.game.state
      %+  skip  players.game.state
      |=([ship player-info] left)
    =.  dealer.game.state
      %+  get-next-unfolded-player
        dealer
      players.game.state
    =.  state  assign-blinds
    =.  state  deal-hands
    =.  whose-turn.game.state
      %+  get-next-unfolded-player
        big-blind.game.state
      players.game.state
    =.  hand-is-over.state  %.n
    state
  ::  deals 2 cards from deck to each player in game
  ++  deal-hands
    ^-  host-game-state
    =/  players  players.game.state
    |-
    ?~  players  state
    =/  drawn    (draw 2 deck.state)
    %=  $
      players      t.players
      deck.state   rest.drawn
      hands.state  (~(put by hands.state) ship.i.players hand.drawn)
    ==
  ::
  ++  pokur-flop
    ^-  host-game-state
    =.  state  committed-chips-to-pot
    (deal-to-board 3)
  ::
  ++  turn-or-river
    ^-  host-game-state
    =.  state  committed-chips-to-pot
    (deal-to-board 1)
  ::  draws n cards (after burning 1) from deck,
  ::  appends them to end of board, and sets action
  ::  to the next unfolded player left of dealer
  ++  deal-to-board  ::  TODO
    |=  n=@ud
    ^-  host-game-state
    =/  turn  (draw n rest:(draw 1 deck.state))
    =.  deck.state
      rest:turn
    =.  board.game.state
      %+  weld
        board.game.state
      hand:turn
    ::  setting who goes first in betting round here
    =.  whose-turn.game.state
      dealer.game.state
    next-player-turn
  ::  sets whose-turn to next player in list **who hasn't folded**
  ::  if all players are folded, this means that everyone left..
  ++  next-player-turn
    ^-  host-game-state
    %=    state
        whose-turn.game
      %+  get-next-unfolded-player
        whose-turn.game.state
      players.game.state
    ==
  ::
  ++  get-next-unfolded-player
    |=  [current=ship =players]
    ^-  ship
    =/  unfolded-players
      %+  skip  players
      |=([ship player-info] folded)
    ?:  =(~ unfolded-players)
      ::  everyone left, just return something so server can delete
      current
    %-  head
    %+  snag
      %+  mod
        +((need (find [current]~ (turn players head))))
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
    %+  turn  players.game.state
    |=  [p=ship i=player-info]
    ?.  =(p who)  [p i]
    ?:  (gth amount stack.i)
      ::  all-in
      [p i(committed (add committed.i stack.i), stack 0)]
    [p i(committed (add committed.i amount), stack (sub stack.i amount))]
  ::
  ++  set-player-as-acted
    |=  who=ship
    ^-  players
    %+  turn  players.game.state
    |=  [p=ship i=player-info]
    ?.  =(p who)  [p i]
    [p i(acted %.y)]
  ::
  ++  set-player-as-folded
    |=  who=ship
    ^-  players
    %+  turn  players.game.state
    |=  [p=ship i=player-info]
    ?.  =(p who)  [p i]
    [p i(folded %.y)]
  ::
  ++  committed-chips-to-pot
    ^-  host-game-state
    =/  pot-to-update  (rear pots.game.state)
    =/  [=players new-pot=@ud]
      %^  spin  players.game.state  -.pot-to-update
      |=  [[p=ship i=player-info] pot=@ud]
      [p i(committed 0, acted %.n)]^(add pot committed.i)
    %=  state
      current-bet.game  0
      last-bet.game     0
      players.game      players
      pots.game  (snoc (snip pots.game.state) [new-pot +.pot-to-update])
    ==
  ::  takes blinds from the two unfolded players left of dealer
  ::  (in heads up, dealer is small blind)
  ++  assign-blinds
    ^-  host-game-state
    =.  small-blind.game.state
      ?:  =((lent players.game.state) 2)
        dealer.game.state
      %+  get-next-unfolded-player
        dealer.game.state
      players.game.state
    ::
    =.  big-blind.game.state
      %+  get-next-unfolded-player
        small-blind.game.state
      players.game.state
    ::  if game type is %cash, use set blinds
    ::  if %tournament, set blinds based on round we're on
    =/  blinds=[small=@ud big=@ud]
      ?:  ?=(%cash -.game-type.game.state)
        [small-blind big-blind]:game-type.game.state
      %+  snag  current-round.game-type.game.state
      blinds-schedule.game-type.game.state
    =.  players.game.state
      (commit-chips small-blind.game.state small.blinds)
    %=  state
      current-bet.game  big.blinds
      last-bet.game     big.blinds
      players.game  (commit-chips big-blind.game.state big.blinds)
    ==
  ::  this gets called when a tournament round timer runs out
  ::  it tells us to increment when current hand is over
  ::  and sets an update message in the game state
  ++  increment-current-round
    ^-  host-game-state
    ?>  ?=(%sng -.game-type.game.state)
    =/  blinds=[small=@ud big=@ud]
      %+  snag  current-round.game-type.game.state
      blinds-schedule.game-type.game.state
    %=  state
      round-is-over.game-type.game  %.y
        update-message.game
      %-  crip
      """
      Round {<current-round.game-type.game.state>} beginning at next hand.
      New blinds: {<small.blinds>}/{<big.blinds>}
      """
    ==
  ::
  ++  award-pots
    |=  winners=(list ship)
    ^-  host-game-state
    ::  TODO create update message with side pot handling
    ?~  pots.game.state  state
    =*  pot  i.pots.game.state
    =/  winners-in-pot=(list ship)
      %+  skip  winners
      |=  =ship
      =(~ (find [ship]~ in.pot))
    =?    winners-in-pot
        =(~ winners-in-pot)
      ::  no winners in this pot, find the relative winner(s) present
      ::  this must only occur at showdown, if the best hand went all-in
      ::  prior to this side-pot and therefore doesn't deserve it
      ::  if a pot is to be awarded before showdown, the player that
      ::  was folded to will be in all pots.
      %-  turn  :_  head
      %-  determine-winner
      %+  skim  ~(tap by hands.state)
      |=  [=ship hand=pokur-deck]
      ?=(^ (find [ship]~ in.pot))
    %=  $
      pots.game.state  t.pots.game.state
    ::
        update-message.game.state
      ?:  =(1 (lent winners-in-pot))
        ;:  (cury cat 3)
            (scot %p -.winners-in-pot)
            ' wins pot of '
            (scot %ud amount.pot)
        ==
      =+  (roll (turn winners-in-pot |=(a=@ (scot %p a))) (cury cat 3))
      ;:  (cury cat 3)
          -  ' split pot of '
          (scot %ud amount.pot)
      ==
        players.game.state
      ?:  =(1 (lent winners-in-pot))
        ::  award entire pot to single winner
        %+  turn  players.game.state
        |=  [p=ship player-info]
        ?.  =(p -.winners-in-pot)
          [p stack 0 %.n %.n left]
        [p (add stack amount.pot) 0 %.n %.n left]
      ::  split pot evenly between multiple winners
      =/  split  (div amount.pot (lent winners-in-pot))
      %+  turn  players.game.state
      |=  [p=ship player-info]
      ?~  (find [p]~ winners-in-pot)
        [p stack 0 %.n %.n left]
      [p (add stack split) 0 %.n %.n left]
    ==
  ::  given a list of winners, send them the pot. prepare for next
  ::  hand by clearing board, hands and bets, reset fold status,
  ::  and incrementing hands-played.
  ++  process-win
    |=  winners=(list ship)
    ^-  host-game-state
    ::  sends any extra committed chips to pot
    =.  state  committed-chips-to-pot
    =.  state  (award-pots winners)
    =?    state
        ?&  ?=(%sng -.game-type.game.state)
            round-is-over.game-type.game.state
        ==
      %=    state
          current-round.game-type.game
        +(current-round.game-type.game.state)
          round-is-over.game-type.game
        %.n
      ==
    %=  state
      hands              ~
      board.game         ~
      current-bet.game   0
      last-bet.game      0
      hand-is-over       %.y
      deck               generate-deck
      hands-played.game  +(hands-played.game.state)
      pots.game  [0 (turn players.game.state head)]~
    ::
        game-is-over.game
      =/  active-with-chips
        %-  lent
        %+  skip  players.game.state
        |=  [p=ship player-info]
        |(=(0 stack) left)
      ?|  =(1 active-with-chips)
          =(0 active-with-chips)
      ==
    ::
        players.game
      %+  turn  players.game.state
      |=  [p=ship i=player-info]
      ?.  =(0 stack.i)  [p i]
      [p i(acted %.y, folded %.y)]
    ==
  ::  given a player and a pokur-action, handles the action.
  ::  returns a unit for pokur-host to either ingest or reject
  ::  currently checks for being given the wrong player (not their turn),
  ::  bad bet (<2x existing bet, >BB, or matches current bet (call)),
  ::  and trying to check when there's a bet to respond to.
  ::  if betting is complete, go right into flop/turn/river/determine-winner
  ::  * folds trigger win for last standing player
  ++  process-player-action
    |=  [who=ship action=game-action]
    ^-  (unit host-game-state)
    ?>  =(who whose-turn.game.state)
    =/  =player-info
      =<  +  %-  head
      %+  skim  players.game.state
      |=([p=ship player-info] =(p who))
    ?-    -.action
        %check
      ?.  =(current-bet.game.state committed.player-info)
        ~
      ::  set checking player to 'acted'
      =.  players.game.state  (set-player-as-acted who)
      ?:  is-betting-over
        `next-betting-round
      `next-player-turn
    ::
        %fold
      =.  players.game.state  (set-player-as-acted who)
      =.  players.game.state  (set-player-as-folded who)
      :: if only one player hasn't folded, process win for them
      =/  players-left
        %+  skip  players.game.state
        |=([ship ^player-info] folded)
      ?:  =(1 (lent players-left))
        `(process-win [-.-.players-left]~)
      :: otherwise continue game
      ?.  is-betting-over
        `next-player-turn
      `next-betting-round
    ::
        %bet
      =/  bet-plus-committed
        (add amount.action committed.player-info)
      =/  current-min-bet
        ?:  ?=(%cash -.game-type.game.state)
          big-blind.game-type.game.state
        =<  big
        %-  snag
        [current-round blinds-schedule]:game-type.game.state
      ?:  (gte amount.action stack.player-info)
        ::  ALL-IN logic here
        =.  last-bet.game.state
          ::  same with last-bet, only update if raise
          ?:  (gth bet-plus-committed current-bet.game.state)
            (sub bet-plus-committed current-bet.game.state)
          last-bet.game.state
        =.  current-bet.game.state
          ::  only update current bet if the all-in is a raise
          ?:  (gth bet-plus-committed current-bet.game.state)
            bet-plus-committed
          current-bet.game.state
        =.  players.game.state  (commit-chips who stack.player-info)
        =.  players.game.state  (set-player-as-acted who)
        =.  update-message.game.state  (crip "{<who>} is all-in.")
        ?.  is-betting-over
          `next-player-turn
        `next-betting-round
      ::  resume logic for not-all-in
      ?:  ?&  =(current-bet.game.state 0)
              (lth bet-plus-committed current-min-bet)
          ==
        ~  ::  this is a starting bet below min-bet
      ?:  =(bet-plus-committed current-bet.game.state)
        ::  this is a call
        =.  players.game.state  (commit-chips who amount.action)
        =.  players.game.state  (set-player-as-acted who)
        ?.  is-betting-over
          `next-player-turn
        `next-betting-round
      ::  this is a raise attempt
      ?.  ?&  (gte amount.action last-bet.game.state)
              %+  gte  bet-plus-committed
              (add last-bet.game.state current-bet.game.state)
          ==
        ::  error, raise must be >= amount of previous bet/raise
        !!
      ::  process raise
      ::  do this before updating current-bet
      =.  last-bet.game.state
        (sub bet-plus-committed current-bet.game.state)
      =.  current-bet.game.state  bet-plus-committed
      =.  players.game.state  (commit-chips who amount.action)
      =.  players.game.state  (set-player-as-acted who)
      ?.  is-betting-over
        `next-player-turn
      `next-betting-round
    ==
  ::  takes a list of hands and finds winning hand. This is only called
  ::  when the board is full, so it deals with all 7-card hands.
  ::  It returns a list of winning ships, which usually contains just
  ::  the one, but can have up to n ships all tied.
  ++  determine-winner
    |=  hands=(list [ship pokur-deck])
    ^-  (list [ship [@ud pokur-deck]])
    =/  hand-ranks
      %+  turn  hands
      |=  [who=ship hand=pokur-deck]
      [who (evaluate-7-card-hand (weld hand board.game.state))]
    ::  return player with highest hand rank
    =/  player-ranks=(list [ship @ud hand=pokur-deck])
      %+  sort  hand-ranks
      |=  [a=[@ [r=@ud *]] b=[@ [r=@ud *]]]
      (gth r.a r.b)
    ::  check for ties and return winner(s)
    =/  top-rank  -.+.-.player-ranks
    ?.  =(top-rank -.+.+<.player-ranks)
      ::  no ties, proceed
      -.player-ranks^~
    ::  some players have equally-ranked hands
    =.  player-ranks
      %+  sort  player-ranks
      |=  [a=[@ [r=@ud h=pokur-deck]] b=[@ [r=@ud h=pokur-deck]]]
      ?:  =(r.a r.b)
        (break-ties +.a +.b)
      (gth r.a r.b)
    ::  then check for identical hands, in which case pot must be split.
    ?~  player-ranks  ~
    =/  winning-hand  hand.i.player-ranks
    %+  skim  t.player-ranks
    |=  [ship @ud hand=pokur-deck]
    (hands-equal hand winning-hand)
  ::
  ++  remove-player
    |=  who=ship
    ^-  host-game-state
    ::  set player to folded+acted+left
    ::  if it was their turn, go to next player's turn
    =.  players.game.state
      %+  turn  players.game.state
      |=  [p=ship i=player-info]
      ?.  =(p who)  [p i]
      [p i(acted %.y, folded %.y, left %.y)]
    ?.  =(who whose-turn.game.state)  state
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
    ^-  (list [@ud pokur-deck])
    =|  ranked-hands=(list [@ud pokur-deck])
    |-
    ?~  removal-pairs  ranked-hands
    =+  %+  oust  [-.i.removal-pairs 1]
        (oust [+.i.removal-pairs 1] hand)
    %=  $
      removal-pairs  t.removal-pairs
      ranked-hands  [[(evaluate-5-card-hand -) -] ranked-hands]
    ==
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
  =/  removal-indices=(list @ud)  [0 1 2 3 4 5 ~]
  =/  rank-sorted-5-card-hands=(list [@ud pokur-deck])
    %-  sort
    :_  |=([a=[@ud *] b=[@ud *]] (gth -.a -.b))
    ^-  (list [@ud pokur-deck])
    =|  ranked-hands=(list [@ud pokur-deck])
    |-
    ?~  removal-indices  ranked-hands
    =+  (oust [i.removal-indices 1] hand)
    %=  $
      removal-indices  t.removal-indices
      ranked-hands  [[(evaluate-5-card-hand -) -] ranked-hands]
    ==
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
++  evaluate-5-card-hand
  |=  hand=pokur-deck
  ^-  @ud
  ::  check for pairs with histogram of hand
  =/  raw-hand  (turn hand card-to-raw)
  =/  histogram=(list @ud)
    %-  sort  :_  gth
    %-  skip  :_  |=(n=@ud =(n 0))
    ^-  (list @ud)
    =/  histo  (reap 13 0)
    |-
    ?~  raw-hand  histo
    %=  $
      raw-hand  t.raw-hand
      histo  (snap histo -.i.raw-hand +((snag -.i.raw-hand histo)))
    ==
  ?:  =(histogram ~[4 1])      7  ::  four of a kind
  ?:  =(histogram ~[3 2])      6  ::  full house
  ?:  =(histogram ~[3 1 1])    3  ::  trips
  ?:  =(histogram ~[2 2 1])    2  ::  two pair
  ?:  =(histogram ~[2 1 1 1])  1  ::  pair
  ::  at this point, must sort hand
  =.  raw-hand
    (sort raw-hand |=([a=[@ud @ud] b=[@ud @ud]] (gth -.a -.b)))
  ::  check for flush, straight
  =/  is-straight  (check-5-card-straight raw-hand)
  ?:  (check-5-card-flush raw-hand)
    ?:  is-straight
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
:: given two hands, returns %.y if 1 is better than 2
:: *ONLY WORKS* for 5 card hands
++  break-ties
  |=  [hand1=[r=@ud h=pokur-deck] hand2=[r=@ud h=pokur-deck]]
  ^-  ?
  ::  if ranks are strictly better, just return that
  ::  otherwise break equally-ranked hands
  ?.  =(r.hand1 r.hand2)  (gth r.hand1 r.hand2)
  ::  sort whole hands to start
  =.  h.hand1  (sort h.hand1 card-compare)
  =.  h.hand2  (sort h.hand2 card-compare)
  ::  match tie-breaking strategy to type of hand
  ?:  ?|  =(r.hand1 8)
          =(r.hand1 5)
          =(r.hand1 4)
          =(r.hand1 0)
        ==
    ::  these ties can be broken by just finding high card
    (find-high-card h.hand1 h.hand2)
  ::  other hands must be sorted by card frequency, then
  ::  high card within that frequency sorting
  %+  find-high-card
    (sort-hand-by-frequency h.hand1)
  (sort-hand-by-frequency h.hand2)
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
::  hands must be sorted by card rank to use
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
  (gth (card-val-to-atom -.c1) (card-val-to-atom -.c2))
::
++  cards-equal
  |=  [c1=pokur-card c2=pokur-card]
  ^-  ?
  =((card-val-to-atom -.c1) (card-val-to-atom -.c2))
::
++  hierarchy-to-rank
  |=  h=@ud
  ^-  @t
  ?+  h  '-'
    %9  'Royal Flush'
    %8  'Straight Flush'
    %7  'Four of a Kind'
    %6  'Full House'
    %5  'Flush'
    %4  'Straight'
    %3  'Three of a Kind'
    %2  'Two Pair'
    %1  'Pair'
    %0  'High Card'
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
  [hand=(scag n d) rest=(slag n d)]
--
