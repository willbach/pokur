/-  poker :: import types from sur/poker.hoon
=,  poker
|%
++  modify-state
  |_  state=server-game-state
  ::  checks if all players have acted, and committed the same amount of chips
  ::  returns a bool
  ++  is-betting-over
    =/  acted-check
      |=  [who=ship n=@ud c=@ud acted=?]
      =(acted %.y)
    ?.  (levy chips.game.state acted-check)
      %.n
    =/  x  committed:(head chips.game.state)
    =/  f
      |=  [who=ship n=@ud c=@ud acted=?]
      =(c x)
    (levy chips.game.state f)
  ::  checks cards on table and either initiates flop, turn, river, or determine-winner
  ++  next-round
    ^-  server-game-state
    :: better way to write this?
    =/  n  (lent board.game.state)
    ?:  |(=(3 n) =(4 n))
      turn-river
    ?:  =(5 n)
      (process-win determine-winner)
    poker-flop
  ::  **takes in a shuffled deck**
  ::  assign dealer, assign blinds, assign first action to person left of BB
  ::  (which is dealer in heads-up)
  ::  make sure to shuffle deck from outside with eny!!!
  ++  initialize-hand
    |=  dealer=ship
    ^-  server-game-state
    =.  dealer.game.state       dealer
    =.  state                   assign-blinds
    =.  state                   deal-hands
    =.  whose-turn.game.state   (get-next-player big-blind.game.state players.game.state)
    =.  hand-is-over.state      %.n
    state
  ::  deals 2 cards from deck to each player in game
  ++  deal-hands
    ^-  server-game-state
    =/  player-count  (lent players.game.state)
    |-
    ?:  =(player-count 0)
      state
    =/  new  (draw 2 deck.state)
    =/  player  (snag (dec player-count) players.game.state)
    %=  $
      hands.state    [player hand:new]^hands.state
      deck.state     rest:new
      player-count  (dec player-count)
    ==
  ::  modifies game-state with their hand from server-state to send copy to them
  ++  make-player-cards
    |=  hand=[ship poker-deck]
    =.  my-hand.game.state
      (tail hand)
    [%give %fact ~[/game/(scot %ud game-id.game.state)/(scot %p (head hand))] [%poker-game-state !>(game.state)]]
  ++  poker-flop
    ^-  server-game-state
    =.  state
      committed-chips-to-pot
    (deal-to-board 3)
  ++  turn-river
    ^-  server-game-state
    =.  state
      committed-chips-to-pot
    (deal-to-board 1)
  ::  draws n cards (after burning 1) from deck and appends them to board state,
  ::  and sets action to the player left of dealer
  ++  deal-to-board
    |=  n=@ud
    ^-  server-game-state
    =/  burn  (draw 1 deck.state)
    =/  turn  (draw n rest:burn)
    =.  deck.state
      rest:turn
    =.  board.game.state
      (weld hand:turn board.game.state)
    :: setting who goes first in betting round here
    =.  whose-turn.game.state
      (get-next-player dealer.game.state players.game.state)
    state
  ::  sets whose-turn to next player in list ("clockwise")
  ++  next-player-turn
    ^-  server-game-state 
    =.  whose-turn.game.state
      (get-next-player whose-turn.game.state players.game.state)
    state
  ::  sends chips from player's 'stack' to their 'committed' pile
  ::  used after a bet, call, raise is made
  ::  committed chips don't go to pot until round of betting is complete
  ++  commit-chips
    |=  [who=ship amount=@ud]
    ^-  server-game-state
    =/  f
      |=  [p=ship n=@ud c=@ud acted=?]
      ?:  =(p who)
        [p (sub n amount) (add c amount) acted]
      [p n c acted] 
    =.  chips.game.state  (turn chips.game.state f)
    state
  ++  set-player-as-acted
    |=  who=ship
    ^-  server-game-state
    =/  f
      |=  [p=ship n=@ud c=@ud acted=?]
      ?:  =(p who)
        [p n c %.y]
      [p n c acted] 
    =.  chips.game.state  (turn chips.game.state f)
    state
  ++  committed-chips-to-pot
    ^-  server-game-state 
    =/  f
      |=  [[p=ship n=@ud c=@ud acted=?] pot=@ud]
        =.  pot  
          (add c pot)
        [[p n 0 %.n] pot]
    =/  new  (spin chips.game.state pot.game.state f)
    =.  pot.game.state          q.new
    =.  chips.game.state        p.new
    =.  current-bet.game.state  0
    state
  ::  takes blinds from the two players left of dealer
  ::  (big blind is calculated as min-bet, small blind is 1/2 min. could change..)
  ::  (in heads up, dealer is small blind and this is done for now. future will
  ::  require a check to see if game is in heads up)
  ++  assign-blinds
    ^-  server-game-state
    ::  THIS CHANGES WHEN NOT HEADS-UP (future)
    =.  small-blind.game.state  
      dealer.game.state
    =/  sb-position  
      (find [small-blind.game.state]~ players.game.state)
    =.  big-blind.game.state    
      (snag (mod (add 1 u.+.sb-position) (lent players.game.state)) players.game.state)
    =.  state
      (commit-chips small-blind.game.state (div min-bet.game.state 2))
    =.  state
      (commit-chips big-blind.game.state min-bet.game.state)
    =.  current-bet.game.state
      min-bet.game.state
    state
  ::  given a winner, send them the pot. prepare for next hand by
  ::  clearing board, clearing hands and bets, and incrementing hands-played.
  ::  in future, should manage raising of blinds and other things...
  ++  process-win
    |=  winner=ship
    ^-  server-game-state
    :: sends any extra committed chips to pot
    =.  state
      committed-chips-to-pot
    :: give pot to winner
    =/  f
      |=  [p=ship n=@ud c=@ud acted=?]
      ?:  =(p winner) 
        [p (add n (add c pot.game.state)) 0 %.n]
      [p n 0 %.n] 
    =.  chips.game.state  (turn chips.game.state f)
    =.  pot.game.state  0
    :: take hands away, clear board, clear bet
    =.  board.game.state
      ~
    =.  current-bet.game.state
      0
    =.  hands.state
      ~
    :: inc hands-played
    =.  hands-played.game.state
      (add 1 hands-played.game.state)
    :: set fresh deck
    =.  deck.state
      generate-deck
    :: rotate dealer
    =.  dealer.game.state
      (get-next-player dealer.game.state players.game.state)
    :: set hand to OVEr
    =.  hand-is-over.state
      %.y
    :: NOTE: BLINDS UP/DOWN etc should be here?
    state
  ::  given a player and a poker-action, handles the action.
  ::  currently checks for being given the wrong player (not their turn),
  ::  bad bet (2x existing bet, >BB, or matches current bet (call)),
  ::  and trying to check when there's a bet to respond to.
  ::  * if betting is complete, go right into flop/turn/river/determine-winner
  ::  * folds trigger win for other player (assumes heads-up)
  ++  process-player-action
    :: what type should rule violating actions return?
    ::
    |=  [who=ship action=game-action:poker]
    ^-  server-game-state
    ?.  =(who whose-turn.game.state)
      :: error, wrong player making move
      !!
    ?-  -.action
      %check
    ?:  (gth current-bet.game.state 0)
      :: error, player must match current bet
      !!
    ::  set checking player to 'acted'
    =.  state
      (set-player-as-acted who)
    ?.  is-betting-over
      next-player-turn
    next-round
      %bet
    =/  bet-plus-committed  
      (add amount.action committed:(get-player-chips who chips.game.state))
    ?:  &(=(current-bet.game.state 0) (lth bet-plus-committed min-bet.game.state))
      !!  :: this is a starting bet below min-bet
    ?:  =(bet-plus-committed current-bet.game.state)
      :: this is a call
      =.  state
        (commit-chips who amount.action)
      =.  state
      (set-player-as-acted who)
      ?.  is-betting-over
        next-player-turn
      next-round
    ?:  (lth bet-plus-committed (mul 2 current-bet.game.state))
      :: error, raise must be 2x current bet
      !!
    :: process raise 
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
    :: this changes with n players rather than 2.. but for now just end hand
    =.  state
      (set-player-as-acted who)
    (process-win (get-next-player who players.game.state))
    ==
  :: TODO: hand evaluation. given state, look at hands+board to see
  :: who has the best hand, and return their name
  ++  determine-winner
    :: This is the hand evaluation arm
    :: currently a placeholder
    ^-  ship
    (head players.game.state)
  --
::
::  Assorted helper arms
::
++  eval-5-cards
  |=  hand=poker-deck
  ^-  poker-hand-rank 
  :: check for pairs 
  =/  make-histogram
    |=  [c=[@ud @ud] h=(list @ud)]
      =/  new-hist  (snap h -.c (add 1 (snag -.c h)))
      [c new-hist]
  =/  r  (spin (turn hand card-to-raw) (reap 13 0) make-histogram) 
  =/  raw-hand  p.r
  =/  histogram  (sort (skip q.r |=(x=@ud =(x 0))) gth)
  ?:  =(histogram ~[4 1])
    %four-of-a-kind
  ?:  =(histogram ~[3 2])
    %full-house
  ?:  =(histogram ~[3 1 1])
    %three-of-a-kind
  ?:  =(histogram ~[2 2 1])
    %two-pair
  ?:  =(histogram ~[2 1 1 1])
    %pair
  :: check for flush
  =/  is-flush  %.n
  =/  first-card-suit  +:(head raw-hand)
  =/  suit-check
    |=  c=[@ud @ud]
      =(+.c first-card-suit)
  =/  is-flush  (levy raw-hand suit-check)
  :: check for straight
  =.  raw-hand  (sort raw-hand |=([a=[@ud @ud] b=[@ud @ud]] (gth -.a -.b)))
  :: check for royal flush here too
  ?:  =(4 (sub -.-.raw-hand -.+>+>-.raw-hand))
    ?:  is-flush
      ?:  &(=(-.-.raw-hand 12) =(-.+>+>-.raw-hand 8))
        :: if this code ever executes i will smile
        ~&  >  "someone just got a royal flush!"
        %royal-flush
      %straight-flush
    %straight
  :: also need to check for wheel straight
  ?:  &(=(-.-.raw-hand 12) =(-.+<.raw-hand 3))
    ?:  is-flush
      %straight-flush
    %straight
  ?:  is-flush
    %flush
  %high-card
++  card-to-raw
  |=  c=poker-card
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
  ^-  poker-deck
  =|  new-deck=poker-deck
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
  |=  [unshuffled=poker-deck entropy=@]
  ^-  poker-deck
  =|  shuffled=poker-deck
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
  |=  [n=@ud d=poker-deck]
  ^-  [hand=poker-deck rest=poker-deck]
  :-  (scag n d)
  (slag n d)
::  returns name of ship that's to the left of given ship
++  get-next-player
  |=  [player=ship players=(list ship)]
  ^-  ship
  =/  player-position
    (find [player]~ players)
  (snag (mod (add 1 u.+.player-position) (lent players)) players)
::  given a ship in game, returns their chip count [name stack committed]
++  get-player-chips
  |=  [who=ship chips=(list [ship in-stack=@ud committed=@ud acted=?])]
  ^-  [who=ship in-stack=@ud committed=@ud acted=?]
  =/  f
    |=  [p=ship n=@ud c=@ud acted=?]
    =(p who)
  (head (skim chips f))
--
