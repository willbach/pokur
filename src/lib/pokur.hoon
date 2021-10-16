/-  pokur :: import types from sur/pokur.hoon
=,  pokur
|%
++  modify-state
  |_  state=server-game-state
::  modifies game-state with hand from 
::  server-state to send copy to given player
  ++  make-player-cards 
    |=  hand=[ship pokur-deck]
    =.  my-hand.game.state
      (tail hand)
    :^  %give 
        %fact 
        ~[/game/(scot %da game-id.game.state)/(scot %p (head hand))]
        [%pokur-game-state !>(game.state)]

::  checks if all players have acted or folded, and 
::  committed the same amount of chips, OR,
::  if a player is all-in, i.e. has 0 in stack
  ++  is-betting-over
    ^-  ?
    =/  acted-check
      |=  [who=ship n=@ud c=@ud acted=? folded=? left=?]
      ?|  =(acted %.y)
          =(folded %.y)
      ==
    ?.  (levy chips.game.state acted-check)
      %.n
    =/  f
      |=  [who=ship n=@ud c=@ud acted=? folded=? left=?]
      ?|  =(c current-bet.game.state)
          =(n 0)
          =(folded %.y)
      ==
    (levy chips.game.state f)

::  checks cards on table and either initiates flop, 
::  turn, river, or determine-winner
  ++  next-round
    ^-  server-game-state
    =/  n  (lent board.game.state)
    ?:  |(=(3 n) =(4 n))
      turn-river
    ?:  =(5 n)
      =/  unfolded-players
      %+  turn
        %+  skip
          chips.game.state
        |=  [who=ship n=@ud c=@ud acted=? folded=? left=?]
        folded
      |=  [who=ship @ud @ud ? ? ?]
      who
      =/  unfolded-hands
      %+  skip
        hands.state
      |=  [who=ship hand=pokur-deck]
      =(%.y (find [who]~ unfolded-players))
      (process-win (determine-winner unfolded-hands))
    pokur-flop

::  **takes in a shuffled deck**
::  assign dealer, assign blinds, assign first action 
::  to person left of BB (which is dealer in heads-up)
::  make sure to shuffle deck from outside with eny!!!
::  check for players who have left, remove them
  ++  initialize-hand
    |=  dealer=ship
    ^-  server-game-state
    =.  players.game.state
      %+  skip
        players.game.state
      |=  s=ship
        left:(get-player-chips s chips.game.state)
    =.  chips.game.state
      %+  skip
        chips.game.state
      |=  [ship @ud @ud ? ? left=?]
        left
    =.  dealer.game.state   
      %+  get-next-unfolded-player 
        dealer 
      players.game.state
    =.  state
      assign-blinds
    =.  state
      deal-hands
    =.  whose-turn.game.state   
      %+  get-next-unfolded-player 
        big-blind.game.state 
      players.game.state
    =.  hand-is-over.state  
      %.n
    state

::  deals 2 cards from deck to each player in game
  ++  deal-hands
    ^-  server-game-state
    =/  dealt-count  (lent players.game.state)
    ::  clear existing hand, if any
    =.  hands.state  ~
    |-
    ?:  =(dealt-count 0)
      state
    =/  new  
    (draw 2 deck.state)
    =/  player  
    (snag (dec dealt-count) players.game.state)
    %=  $
      hands.state    [player hand:new]^hands.state
      deck.state     rest:new
      dealt-count  (dec dealt-count)
    ==

  ++  pokur-flop
    ^-  server-game-state
    =.  state
      committed-chips-to-pot
    (deal-to-board 3)

  ++  turn-river
    ^-  server-game-state
    =.  state
      committed-chips-to-pot
    (deal-to-board 1)

::  draws n cards (after burning 1) from deck, 
::  appends them to end of board, and sets action 
::  to the next unfolded player left of dealer
  ++  deal-to-board
    |=  n=@ud
    ^-  server-game-state
    =/  burn  (draw 1 deck.state)
    =/  turn  (draw n rest:burn)
    =.  deck.state
      rest:turn
    =.  board.game.state
      %+  weld
        board.game.state
      hand:turn
    :: setting who goes first in betting round here
    =.  whose-turn.game.state
      dealer.game.state 
    next-player-turn

::  sets whose-turn to next player in list **who hasn't folded**
::  if all players are folded, this means that everyone left..
  ++  next-player-turn
    ^-  server-game-state
    =.  whose-turn.game.state
      (get-next-unfolded-player whose-turn.game.state players.game.state)
    state

  ++  get-next-unfolded-player
    |=  [player=ship players=(list ship)]
    ^-  ship
    =/  unfolded-players
      %+  turn
        %+  skip
          chips.game.state
        |=  [s=ship @ud @ud ? folded=? ?]
          folded
      |=  [s=ship @ud @ud ? ? ?]
        s
    ?~  unfolded-players
      :: everyone left, just return something so server can delete
      player
    =/  whose-turn  player 
    |-
    =/  next-player
      %+  get-next-player 
        whose-turn 
      players.game.state
    :: if next hasn't folded, set turn to them and return
    ?^  (find [next-player]~ unfolded-players)
      next-player
    :: otherwise recurse to find next unfolded player
    $(whose-turn next-player)

::  returns name of ship that's to the left of given ship
  ++  get-next-player
    |=  [player=ship players=(list ship)]
    ^-  ship
    =/  player-position
      (find [player]~ players)
    (snag (mod +(u.+.player-position) (lent players)) players)

::  given a ship in game, returns their chip count [name stack committed]
  ++  get-player-chips
    |=  [who=ship chips=(list [ship in-stack=@ud committed=@ud ? ? ?])]
    ^-  [who=ship in-stack=@ud committed=@ud acted=? folded=? left=?]
    =/  f
      |=  [p=ship n=@ud c=@ud ? ? ?]
      =(p who)
    (head (skim chips f))

::  sends chips from player's 'stack' to their 
::  'committed' pile. used after a bet, call, raise
::  is made. committed chips don't go to pot until 
::  round of betting is complete
::  if player doesn't have enough chips, put them all-in!
  ++  commit-chips
    |=  [who=ship amount=@ud]
    ^-  server-game-state
    =/  f
      |=  [p=ship n=@ud c=@ud acted=? folded=? left=?]
      ?:  =(p who)
        ?:  (gth n amount)
          [p (sub n amount) (add c amount) acted folded left]
        [p 0 (add c n) acted folded left]
      [p n c acted folded left] 
    =.  chips.game.state  (turn chips.game.state f)
    state

  ++  set-player-as-acted
    |=  who=ship
    ^-  server-game-state
    =/  f
      |=  [p=ship n=@ud c=@ud acted=? folded=? left=?]
      ?:  =(p who)
        [p n c %.y folded left]
      [p n c acted folded left] 
    =.  chips.game.state  (turn chips.game.state f)
    state

  ++  set-player-as-folded
    |=  who=ship
    ^-  server-game-state
    =/  f
      |=  [p=ship n=@ud c=@ud acted=? folded=? left=?]
      ?:  =(p who)
        [p n c acted %.y left]
      [p n c acted folded left] 
    =.  chips.game.state  (turn chips.game.state f)
    state

  ++  set-player-as-left
    |=  who=ship
    ^-  server-game-state
    =/  f
      |=  [p=ship n=@ud c=@ud acted=? folded=? left=?]
      ?:  =(p who)
        [p n c %.y %.y %.y]
      [p n c acted folded left] 
    =.  chips.game.state  (turn chips.game.state f)
    state

  ++  committed-chips-to-pot
    ^-  server-game-state 
    =/  f
      |=  [[p=ship n=@ud c=@ud acted=? folded=? left=?] pot=@ud]
        =.  pot  
          (add c pot)
        [[p n 0 %.n folded left] pot]
    :: committed chips will always go to most recent side-pot,
    :: so we just alter the last pot in the list
    =/  new  (spin chips.game.state -:(rear pots.game.state) f)
    =.  pots.game.state
    %^    snap
        pots.game.state
      (sub (lent pots.game.state) 1)
    [q.new +:(rear pots.game.state)]
    =.  chips.game.state        p.new
    =.  current-bet.game.state  0
    =.  last-bet.game.state     0
    state

::  takes blinds from the two unfolded players left of dealer
::  (big blind is calculated as min-bet, small blind is 1/2 min. could change..)
::  (in heads up, dealer is small blind)
  ++  assign-blinds
    ^-  server-game-state
    =.  small-blind.game.state  
      ?:  =((lent players.game.state) 2)
        dealer.game.state
      (get-next-unfolded-player dealer.game.state players.game.state)
    =.  big-blind.game.state   
      (get-next-unfolded-player small-blind.game.state players.game.state)
    :: if game type is Cash, just use the first item in min-bets
    :: if Tournament, set blinds based on round we're on
    =/  new-min-bet
      %+  snag
        :: this will always be 0 in a cash game
        current-round.game.state
      min-bets.game.state
    =.  state
      %+  commit-chips 
        small-blind.game.state 
      :: Small blind: 1/2 of big blind
      (div new-min-bet 2)
    =.  state
      %+  commit-chips
        big-blind.game.state
      :: Big blind: equal to minimum bet
      new-min-bet
    =.  current-bet.game.state
      new-min-bet
    =.  last-bet.game.state
      new-min-bet
    state

::  this gets called when a tournament round timer runs out
::  it tells us to increment when current hand is over
::  and sets an update message in the game state
  ++  increment-current-round
    ^-  server-game-state
    =.  round-over.game.state
    %.y
    =/  new-min-bet
    %+  snag
      (add 1 current-round.game.state)
    min-bets.game.state
    =/  new-blinds
    [(div new-min-bet 2) new-min-bet]
    =.  update-message.game.state
    ["Round {<current-round.game.state>} beginning at next hand. New blinds: {<-.new-blinds>}/{<+.new-blinds>}" ~]
    state

::  given a list of [winner [rank hand]], send them the pot. prepare for next hand 
::  by clearing board, hands and bets, reset fold status, increment hands-played.
  ++  process-win
    |=  winners=(list [ship [@ud pokur-deck]])
    ^-  server-game-state
    :: get ship names
    =/  winning-ships
    %+  turn
      winners
    |=  a=[ship [@ud pokur-deck]]
    -.a
    =/  winning-rank  -.+:(head winners)
    :: sends any extra committed chips to pot
    =.  state  committed-chips-to-pot
    :: give pot to winner
    :: in case of multiple winners, split pot evenly between them.
    :: TODO: address that div rounds up lol
    :: step backwards through side pots, assigning them to their winner(s)
    :: the winners we're sent here may NOT be the winners of every pot
    :: you can only win a pot you participated in.
    =/  new-chips
      %^    spin
          (flop pots.game.state)
        chips.game.state
      |=  [pot=[val=@ud players-in=(list ship)] chips=(list [p=ship n=@ud c=@ud acted=? folded=? left=?])]
      :: if winner is not in pot, call determine-winner on set of ships that are.
      =/  winners-in-pot
        %+  skim
          winning-ships
        |=  [p=ship]
        ?^  (find [p]~ players-in.pot)
          %.y
        %.n
      =/  winners-in-pot
        ?.  =(~ winners-in-pot)
          winners-in-pot
        :: no winners in this pot, find the relative winner present (may be multiple!)
        =/  hands-in-pot
          %+  skim
            hands.state
          |=  [p=ship hand=pokur-deck]
          ?^  (find [p]~ players-in.pot)
            %.y
          %.n
        (determine-winner hands-in-pot)
      :: now we award chips to winners found for this pot
      =.  chips
        ?:  =((lent winners-in-pot) 1)
          :: one winner, give pot
          %+  turn
            chips
          |=  [p=ship n=@ud c=@ud acted=? folded=? left=?]
          ?:  =(p -.-.winners)
            [p (add n (add c val.pot)) 0 %.n %.n left]
          [p n 0 %.n %.n left] 
        :: many winners, split
        =/  split-pot  (div val.pot (lent winners-in-pot))
        %+  turn 
          chips
        |=  [p=ship n=@ud c=@ud acted=? folded=? left=?]
        ?^  (find [p]~ winning-ships)
          [p (add n (add c split-pot)) 0 %.n %.n left]
        [p n 0 %.n %.n left]
      [pot chips]
    ::  clear board, clear bet, clear pot
    =.  chips.game.state         q.new-chips
    =.  pots.game.state          ~[[0 players.game.state]]
    =.  board.game.state         ~
    =.  current-bet.game.state   0
    =.  last-bet.game.state      0
    :: if round is over, increment it
    =.  current-round.game.state
    ?.  round-over.game.state
      current-round.game.state
    (add 1 current-round.game.state)
    =.  round-over.game.state    %.n
    =.  hands-played.game.state  +(hands-played.game.state)
    =.  deck.state               generate-deck
    :: set any players with stack of 0 to folded
    =.  chips.game.state
    %+  turn
      chips.game.state
    |=  [s=ship stack=@ud c=@ud acted=? folded=? left=?]
      ?:  =(stack 0)
        [s stack c %.y %.y %.n]
      [s stack c acted folded left]
    :: set hand to over to trigger next hand on server
    =.  hand-is-over.state       %.y
    :: set game to over if only one player has any chips
    =/  players-with-chips
    %+  skip
      chips.game.state
    |=  [s=ship stack=@ud c=@ud ? ? left=?]
    |(left &(=(0 stack) =(0 c)))
    =.  game-is-over.game.state
    ?:  ?|  =(1 (lent players-with-chips))
            =(0 (lent players-with-chips))
        ==
      %.y
    %.n
    :: update game message to inform clients
    :: TODO pretty-print this, branching if multiple people tie
    =.  update-message.game.state
      ?:  =(winning-rank 10)
        ["{<(head winning-ships)>} wins hand #{<hands-played.game.state>}." ~]
      ?:  =((lent winners) 1)
        :-  %+  weld
              "{<(head winning-ships)>} wins hand #{<hands-played.game.state>} with "
            (hierarchy-to-rank winning-rank) 
        +.+:(head winners)
      :: multiple winners.. more complex update message
      =/  winning-hands
      %+  turn
        winners
      |=  [s=ship info=[@ud hand=pokur-deck]]
      hand.info
      ["{<winning-ships>} win hand, split pot. Their hands: " -.winning-hands]
    state

::  given a player and a pokur-action, handles the action.
::  currently checks for being given the wrong player (not their turn),
::  bad bet (2x existing bet, >BB, or matches current bet (call)),
::  and trying to check when there's a bet to respond to.
::  * if betting is complete, go right into flop/turn/river/determine-winner
::  * folds trigger win for last standing player
  ++  process-player-action
    |=  [who=ship action=game-action]
    ^-  server-game-state
    ?.  =(who whose-turn.game.state)
      :: error, wrong player making move
      !!
    ?-  -.action
      %check
    =/  committed
    committed:(get-player-chips who chips.game.state)
    ?:  (gth current-bet.game.state committed)
      :: error, player must match current bet
      !!
    ::  set checking player to 'acted'
    =.  state
      (set-player-as-acted who)
    ?.  is-betting-over
      next-player-turn
    next-round
      %bet
    =/  stack  
      in-stack:(get-player-chips who chips.game.state)
    =/  bet-plus-committed  
      %+  add 
        amount.action 
      committed:(get-player-chips who chips.game.state)
    =/  current-min-bet
      %+  snag
        :: this will always be 0 in a cash game
        current-round.game.state
      min-bets.game.state
    :: ALL-IN logic here
    ?:  ?|  =(amount.action stack)
            (gth amount.action stack)
        ==
      :: if someone tries to bet more than their stack, count it as an all-in
      =.  last-bet.game.state
        :: same with last-bet, only update if raise
        ?:  (gth bet-plus-committed current-bet.game.state)
          (sub bet-plus-committed current-bet.game.state)
        last-bet.game.state
      =.  current-bet.game.state
        :: only update current bet if the all-in is a raise
        ?:  (gth bet-plus-committed current-bet.game.state)
          bet-plus-committed
        current-bet.game.state
      =.  state
        (commit-chips who stack)
      =.  state
        (set-player-as-acted who)
      =.  update-message.game.state
        ["{<who>} is all-in." ~]
      ?.  is-betting-over
        next-player-turn
      next-round  
    :: resume logic for not-all-in
    ?:  ?&  
          =(current-bet.game.state 0)
          (lth bet-plus-committed current-min-bet)
        ==
      !!  :: this is a starting bet below min-bet
    ?:  =(bet-plus-committed current-bet.game.state)
      :: this is a call
      =.  state
      %+  commit-chips
        who
      amount.action
      =.  state
      (set-player-as-acted who)
      ?.  is-betting-over
        next-player-turn
      next-round
    :: this is a raise attempt
    ?.  ?&
          (gte amount.action last-bet.game.state)
          (gte bet-plus-committed (add last-bet.game.state current-bet.game.state))
        ==
      :: error, raise must be >= amount of previous bet/raise
      !!
    :: process raise 
    :: do this before updating current-bet
    =.  last-bet.game.state
      (sub bet-plus-committed current-bet.game.state)
    =.  current-bet.game.state
      bet-plus-committed
    =.  state
      (commit-chips who amount.action)
    =.  state
      (set-player-as-acted who)
    ?.  is-betting-over
      next-player-turn
    next-round
      %fold
    =.  state
      (set-player-as-acted who)
    =.  state
      (set-player-as-folded who)
    :: if only one player hasn't folded, process win for them
    =/  players-left
      %+  turn
        %+  skip
          chips.game.state
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
    next-round
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
        (weld hand board.game.state)  
      [who (evaluate-hand hand)]
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

  ++  remove-player
    |=  who=ship
    ^-  server-game-state
    :: set player to folded/acted/left
    :: if it was their turn, go to next player's turn
    =.  state
      (set-player-as-left who)
    ?:  =(whose-turn.game.state who)
      ?.  is-betting-over
        next-player-turn
      next-round
    state
  --

::
::  Hand evaluation and sorted helper arms
::
:: **returns a cell of [hierarchy-number hand]
:: where hand is the strongest 5 cards evaluated.
++  evaluate-hand
  |=  hand=pokur-deck
  ^-  [@ud pokur-deck]
  =/  removal-pairs
  :~  [0 1]  [0 2]  [0 3]  [0 4]  [0 5]  [0 6]
      [1 2]  [1 3]  [1 4]  [1 5]  [1 6]
      [2 3]  [2 4]  [2 5]  [2 6]
      [3 4]  [3 5]  [3 6]
      [4 5]  [4 6]
      [5 6]
  ==

  =/  possible-5-card-hands
  %^    spin
      `(list [@ud @ud])`removal-pairs
    hand
  |=  [r=[@ud @ud] h=pokur-deck]
  ^-  [[@ud pokur-deck] pokur-deck]
  =/  new-hand
  (oust [-.r 1] (oust [+.r 1] h))
  [[(eval-5-cards new-hand) new-hand] h]

  =/  sorted-5-card-hands
    %+  sort
      p.possible-5-card-hands
    |=  [a=[r=@ud h=pokur-deck] b=[r=@ud h=pokur-deck]]
    (gth r.a r.b)
    
  ::  elimate any hand without a score that matches top hand
  ::  if there are multiple, sort them by break-ties
  =/  best-hand-rank
    -.-.sorted-5-card-hands
  =.  sorted-5-card-hands
    %+  skim
      sorted-5-card-hands
    |=  [r=@ud h=pokur-deck]
    ^-  ?
    =(r best-hand-rank)
  :: break any ties
  ?:  (gth (lent sorted-5-card-hands) 1)
    =.  sorted-5-card-hands
      %+  sort
        sorted-5-card-hands
      break-ties
    (head sorted-5-card-hands)
  (head sorted-5-card-hands)

:: arm for players to evaluate their hand before the river
:: this is the same as evaluate-hand, just with 6 cards
++  eval-6-cards
  |=  hand=pokur-deck
  ^-  @ud
  =/  possible-5-card-hands
  %^    spin
      (gulf 0 5)
    hand
  |=  [r=@ud h=pokur-deck]
  ^-  [[@ud pokur-deck] pokur-deck]
  =/  new-hand
  (oust [r 1] h)
  [[(eval-5-cards new-hand) new-hand] h] 
  =/  sorted-5-card-hands
    %+  sort
      p.possible-5-card-hands
    |=  [a=[r=@ud h=pokur-deck] b=[r=@ud h=pokur-deck]]
    (gth r.a r.b)
  =/  best-hand-rank
    -.-.sorted-5-card-hands
  =.  sorted-5-card-hands
    %+  skim
      sorted-5-card-hands
    |=  [r=@ud h=pokur-deck]
    ^-  ?
    =(r best-hand-rank)
  ?:  (gth (lent sorted-5-card-hands) 1)
    =.  sorted-5-card-hands
      %+  sort
        sorted-5-card-hands
      break-ties
    -:(head sorted-5-card-hands)
  -:(head sorted-5-card-hands)

::
++  eval-5-cards
  |=  hand=pokur-deck
  ^-  @ud 
  :: check for pairs 
  =/  make-histogram
    |=  [c=[@ud @ud] h=(list @ud)]
      =/  new-hist  (snap h -.c (add 1 (snag -.c h)))
      [c new-hist]
  =/  r  (spin (turn hand card-to-raw) (reap 13 0) make-histogram) 
  =/  raw-hand  p.r
  =/  histogram  (sort (skip q.r |=(x=@ud =(x 0))) gth)
  ?:  =(histogram ~[4 1])
    7
  ?:  =(histogram ~[3 2])
    6
  ?:  =(histogram ~[3 1 1])
    3
  ?:  =(histogram ~[2 2 1])
    2
  ?:  =(histogram ~[2 1 1 1])
    1
  :: at this point, must sort hand
  =.  raw-hand  (sort raw-hand |=([a=[@ud @ud] b=[@ud @ud]] (gth -.a -.b)))
  :: check for flush
  =/  is-flush  (check-5-hand-flush raw-hand)
  :: check for straight
  =/  is-straight  (check-5-hand-straight raw-hand)
  :: check for royal flush
  ?:  &(is-straight is-flush)
    ?:  &(=(-.-.raw-hand 12) =(-.+>+>-.raw-hand 8))
      :: if this code ever executes i will smile
      :: ~&  >  "someone just got a royal flush!"
      9
    8
  ?:  is-flush
    5
  ?:  is-straight
    4
  0

::
++  check-5-hand-flush
  |=  raw-hand=(list [@ud @ud])
  ^-  ?
  =/  first-card-suit  +:(head raw-hand)
  =/  suit-check
    |=  c=[@ud @ud]
      =(+.c first-card-suit)
  (levy raw-hand suit-check)

:: **hand must be sorted before using this
++  check-5-hand-straight
  |=  raw-hand=(list [@ud @ud])
  ^-  ?
  ?:  =(4 (sub -.-.raw-hand -.+>+>-.raw-hand))
    %.y
  :: also need to check for wheel straight
  ?:  &(=(-.-.raw-hand 12) =(-.+<.raw-hand 3))
    %.y
  %.n

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
  =/  sorter
   |=  [a=pokur-card b=pokur-card]
     (gth (card-val-to-atom -.a) (card-val-to-atom -.b))
  =.  h.hand1  (sort h.hand1 sorter)
  =.  h.hand2  (sort h.hand2 sorter)
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

:: Sorts cards in pokur-deck by frequency of value
:: **assumes it is getting a rank-sorted hand**
++  sort-hand-by-frequency
  |=  hand=pokur-deck
  ^-  pokur-deck
  ::  need to preserve sorting, other than moving pairs/sets to top
  ::  this is n^2 complexity and can/should be better... 
  =/  get-frequency
    |=  c=pokur-card
    ^-  @ud
    %-  lent
      %+  skim
        hand
      |=  [d=pokur-card]
        =(-.d -.c)  
  =/  sorted-cards-with-frequencies
    %+  sort
      %+  turn
        hand
      |=  [c=pokur-card]
        [c (get-frequency c)]
    |=  [a=[c=pokur-card f=@ud] b=[c=pokur-card f=@ud]]
      ?:  =(f.a f.b)
        (gth (card-val-to-atom -.c.a) (card-val-to-atom -.c.b))
      (gth f.a f.b)
  :: get rid of freq counts for final return
  %+  turn
    sorted-cards-with-frequencies
  |=  [c=pokur-card f=@ud]
    c

:: Utility function to check if two 5-card hands are the same.
++  hands-equal
  |=  [hand1=pokur-deck hand2=pokur-deck]
  ^-  ?
  ?:  .=  (card-val-to-atom -:(head hand1))
      (card-val-to-atom -:(head hand2))
    ?:  &(=((lent hand1) 1) =((lent hand2) 1))
      %.y  
    $(hand1 (tail hand1), hand2 (tail hand2))
  %.n

:: %.y if hand1 has higher card, %.n if hand2 does  
++  find-high-card
  |=  [hand1=pokur-deck hand2=pokur-deck]
  ^-  ?
  ?:  .=  (card-val-to-atom -:(head hand1))
      (card-val-to-atom -:(head hand2))
    ?:  &(=((lent hand1) 1) =((lent hand2) 1))
      %.n  
    $(hand1 (tail hand1), hand2 (tail hand2))
  ?:  %+  gth   
        (card-val-to-atom -:(head hand1))
      (card-val-to-atom -:(head hand2))
    %.y
  %.n

::  not actually using this anywhere
++  rank-to-hierarchy
  |=  rank=hand-rank
  ^-  @ud
  ?-  rank
    %royal-flush      9
    %straight-flush   8
    %four-of-a-kind   7
    %full-house       6
    %flush            5
    %straight         4
    %three-of-a-kind  3
    %two-pair         2
    %pair             1
    %high-card        0
  ==

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

++  card-to-raw
  |=  c=pokur-card
  ^-  [@ud @ud]
  [(card-val-to-atom -.c) (suit-to-atom +.c)]

++  card-val-to-atom
  |=  c=card-val
  ^-  @ud
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

++  suit-to-atom
  |=  s=suit
  ^-  @ud
  ?-  s
    %hearts    0
    %spades    1
    %clubs     2
    %diamonds  3
  ==

++  atom-to-card-val
  |=  n=@ud
  ^-  card-val
  ?+  n  !! :: ^-(card-val `@tas`n) :: if non-face card just use number?? need to coerce type
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

++  atom-to-suit
  |=  val=@ud
  ^-  suit
  ?+  val  !!
    %0  %hearts
    %1  %spades
    %2  %clubs
    %3  %diamonds
  ==

++  generate-deck
  ^-  pokur-deck
  =|  new-deck=pokur-deck
  =/  i  0
  |-
  ?:  (gth i 3)
    new-deck
  =/  j  0
  |-
  ?.  (lte j 12)
    ^$(i +(i))
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
    :_  shuffled
    (snag 0 unshuffled)
  =^  index  random  (rads:random remaining)
  %=  $
    shuffled      (snag index unshuffled)^shuffled
    remaining     (dec remaining)
    unshuffled    (oust [index 1] unshuffled)
  ==

::  gives back [hand rest] where hand is n cards from top of deck, rest is rest
++  draw
  |=  [n=@ud d=pokur-deck]
  ^-  [hand=pokur-deck rest=pokur-deck]
  :-  (scag n d)
  (slag n d)
--
