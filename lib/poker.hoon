/-  poker :: import types from sur/poker.hoon
=,  poker
|%
++  modify-state
  |_  state=server-game-state
  ::  **takes in a shuffled deck**
  ::  assign dealer, assign blinds, assign first action to person left of BB
  ::  (which is dealer in heads-up)
  ::  make sure to shuffle deck from outside with eny!!!
  ++  initialize-hand
    |=  dealer=ship
    ^-  server-game-state
    =.  dealer.game.state  dealer
    =.  state              assign-blinds
    =.  state              deal-hands
    =.  whose-turn.state   (get-next-player big-blind.game.state players.game.state)
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
    :: need to write this better...
    ?:  =(whose-turn.state (head hand))
      =.  my-turn.game.state
        %.y
      [%give %fact ~[/game/(scot %ud game-id.game.state)/(scot %p (head hand))] [%poker-game-state !>(game.state)]]
    =.  my-turn.game.state
      %.n
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
    =.  whose-turn.state
      (get-next-player dealer.game.state players.game.state)
    state
  ::  sets whose-turn to next player in list ("clockwise")
  ++  next-player-turn
    ^-  server-game-state 
    =.  whose-turn.state
      (get-next-player whose-turn.state players.game.state)
    state
  ::  sends chips from player's 'stack' to their 'committed' pile
  ::  used after a bet, call, raise is made
  ::  committed chips don't go to pot until round of betting is complete
  ++  commit-chips
    |=  [who=ship amount=@ud]
    ^-  server-game-state
    =/  f
      |=  [p=ship n=@ud c=@ud]
      ?:  =(p who)
        [p (sub n amount) (add c amount)]
      [p n c] 
    =.  chips.game.state  (turn chips.game.state f)
    state
  ::  takes all chips in 'committed' pile from each player and sends to pot
  ++  committed-chips-to-pot
    ^-  server-game-state
    =/  f
      |=  [[p=ship n=@ud c=@ud] pot=@ud]
        =.  pot  
          (add c pot)
        [[p n 0] pot]
    =/  new  (spin chips.game.state pot.game.state f)
    =.  pot.game.state          q.new
    =.  chips.game.state        p.new
    ~&  >>  "here? 4.2"
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
    ~&  >>  "here? 2"
    =.  state
      committed-chips-to-pot
    :: give pot to winner
    =/  f
      |=  [p=ship n=@ud c=@ud]
      ?:  =(p winner) 
        [p (add n (add c pot.game.state)) 0]
      [p n 0] 
    ~&  >>  "here? 2.1"
    =.  chips.game.state  (turn chips.game.state f)
    =.  pot.game.state  0
    :: take hands away, clear board, clear bet
    =.  board.game.state
      ~
    ~&  >>  "here? 2.2"
    =.  current-bet.game.state
      0
    =.  hands.state
      (turn hands.state |=([s=ship h=poker-deck] [s ~]))
    :: inc hands-played
    ~&  >>  "here? 2.3"
    =.  hands-played.state
      (add 1 hands-played.state)
    :: set fresh deck
    ~&  >>  "here? 3"
    =.  deck.state
      generate-deck
    :: NOTE: BLINDS UP/DOWN etc should be here?
    state
  ::  given a player and a poker-action, handles the action.
  ::  currently checks for being given the wrong player (not their turn),
  ::  bad bet (2x existing bet, >BB, or matches current bet (call)),
  ::  and trying to check when there's a bet to respond to.
  ::  * folds trigger win for other player (assumes heads-up)
  ++  process-player-action
    :: what type should rule violating actions return?
    ::
    |=  [who=ship action=game-action:poker]
    ^-  server-game-state
    ?.  =(who whose-turn.state)
      :: error, wrong player making move
      !!
    ?-  -.action
      %check
    ?:  (gth current-bet.game.state 0)
      :: error, player must match current bet
      !!
    next-player-turn
      %bet
    ~&  >>  "{<current-bet.game.state>},,, {<=(current-bet.game.state 0)>}"
    =/  bet-plus-committed  
      (add amount.action committed:(get-player-chips who chips.game.state))
    ?:  &(=(current-bet.game.state 0) (lth bet-plus-committed min-bet.game.state))
      !!  :: this is a starting bet below min-bet
    ?:  =(bet-plus-committed current-bet.game.state)
      :: this is a call
      =.  state
        (commit-chips who amount.action)
      next-player-turn
    ?:  (lth bet-plus-committed (mul 2 current-bet.game.state))
      :: error, raise must be 2x current bet
      !!
    :: process raise 
    =.  current-bet.game.state
      bet-plus-committed
    =.  state
      (commit-chips who amount.action)
    next-player-turn
      %fold
    ~&  >>  "here? 1"
    :: this changes with n players rather than 2.. but for now just end hand
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
++  atom-to-card-val
  |=  n=@ud
  ^-  card-val
  ?+  n  !! :: ^-(card-val `@tas`n) :: if non-face card just use number?? need to coerce type
    %1   %ace
    %2   %2
    %3   %3
    %4   %4
    %5   %5
    %6   %6
    %7   %7
    %8   %8
    %9   %9
    %10  %10
    %11  %jack
    %12  %queen
    %13  %king
  ==
++  atom-to-suit
  |=  val=@ud
  ^-  suit
  ?+  val  !!
    %1  %hearts
    %2  %spades
    %3  %clubs
    %4  %diamonds
  ==
++  generate-deck
  ^-  poker-deck
  =|  new-deck=poker-deck
  =/  i  1
  |-
  ?:  (gth i 4)
    new-deck
  =/  j  1
  |-
  ?.  (lte j 13)
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
  |=  [who=ship chips=(list [ship in-stack=@ud committed=@ud])]
  ^-  [who=ship in-stack=@ud committed=@ud]
  =/  f
    |=  [p=ship n=@ud c=@ud]
    =(p who)
  (head (skim chips f))
--