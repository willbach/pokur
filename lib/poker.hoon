/-  poker :: import types from sur/poker.hoon
=,  poker
|%
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
++  shuffle-deck-in-state
  |=  [state=server-game-state eny=@]
  =.  deck.state  (shuffle-deck deck.state eny)
  state
++  draw
  |=  [n=@ud d=poker-deck]
  ^-  [hand=poker-deck rest=poker-deck]
  :-  (scag n d)
  (slag n d)
::
::  state changes made by server
::
++  initialize-hand
  |=  [sb-size=@ud dealer=ship state=server-game-state]
  ^-  server-game-state
  ::  **takes in a shuffled deck**
  ::  assign dealer, assign blinds, assign first action to dealer
  ::  make sure to shuffle deck from outside with eny!!!
  =.  dealer.game.state  dealer
  =.  state              (deal-hands (assign-blinds sb-size state))
  =.  whose-turn.state   dealer
  state
++  deal-hands
  |=  state=server-game-state
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
++  send-hands
  |=  [hand=[ship poker-deck] state=server-game-state]
  :: wtf is the type this spits out
  =.  my-hand.game.state
    (tail hand)
  [%give %fact ~[/game/(scot %ud game-id.game.state)/(scot %p (head hand))] [%poker-game-state !>(game.state)]]
++  deal-to-board
  |=  [n=@ud state=server-game-state]
  ^-  server-game-state
  =/  burn  (draw 1 deck.state)
  =/  turn  (draw n rest:burn)
  =.  deck.state
    rest:turn
  =.  board.game.state
    (weld hand:turn board.game.state)
  :: setting who goes first in betting round here
  =.  whose-turn.state
    big-blind.game.state
  state
++  get-next-player
  |=  [current-player=ship players=(list ship)]
  ^-  ship
  =/  current-player-position
    (find [current-player]~ players)
  (snag (mod (add 1 u.+.current-player-position) (lent players)) players)
++  get-player-chips
  |=  [who=ship chips=(list [ship in-stack=@ud committed=@ud])]
  ^-  [who=ship in-stack=@ud committed=@ud]
  =/  f
    |=  [p=ship n=@ud c=@ud]
    =(p who)
  (head (skim chips f))
++  next-player-turn
  |=  state=server-game-state
  ^-  server-game-state 
  =.  whose-turn.state
    (get-next-player whose-turn.state players.game.state)
  state
++  commit-chips
  |=  [who=ship amount=@ud state=server-game-state]
  ^-  server-game-state
  =/  f
    |=  [p=ship n=@ud c=@ud]
    ?:  =(p who)
      [p (sub n amount) (add c amount)]
    [p n c] 
  =.  chips.game.state  (turn chips.game.state f)
  state
++  committed-chips-to-pot
  |=  state=server-game-state
  ^-  server-game-state
  =/  f
    |=  [[p=ship n=@ud c=@ud] pot=@ud]
      =.  pot  
        (add c pot)
      [[p n 0] pot]
  =/  new  (spin chips.game.state pot.game.state f)
  =.  pot.game.state          q.new
  =.  chips.game.state        p.new
  =.  current-bet.game.state  0
  state
++  assign-blinds
  |=  [sb-size=@ud state=server-game-state]
  ^-  server-game-state
  ::  THIS CHANGES WHEN NOT HEADS-UP (future)
  =.  small-blind.game.state  
    dealer.game.state
  =/  sb-position  
    (find [small-blind.game.state]~ players.game.state)
  =.  big-blind.game.state    
    (snag (mod (add 1 u.+.sb-position) (lent players.game.state)) players.game.state)
  =.  state
    (commit-chips small-blind.game.state sb-size state)
  =.  state
    (commit-chips big-blind.game.state (mul 2 sb-size) state)
  =.  current-bet.game.state
    (mul 2 sb-size)
  state
++  process-win
  |=  [winner=ship state=server-game-state]
  ^-  server-game-state
  :: give pot to winner
  =/  f
    |=  [p=ship n=@ud c=@ud]
    ?:  =(p winner) 
      [p (add n (add c pot.game.state)) 0]
    [p n 0] 
  =.  chips.game.state  (turn chips.game.state f)
  =.  pot.game.state  0
  :: take hands away, clear board, clear bet
  =.  board.game.state
    ~
  =.  current-bet.game.state
    0
  =.  hands.state
    (turn hands.state |=([s=ship h=poker-deck] [s ~]))
  :: inc hands-played
  =.  hands-played.state
    (add 1 hands-played.state)
  :: NOTE: BLINDS UP/DOWN etc should be here?
  (initialize-hand 20 (get-next-player dealer.game.state players.game.state) state)
++  process-player-action
  :: what type should rule violating actions return?
  ::
  |=  [who=ship action=poker-action:poker state=server-game-state]
  ^-  server-game-state
  ?.  =(who whose-turn.state)
    :: error, wrong player making move
    !!
  ?-  action
    %check
  ?:  (gth current-bet.game.state 0)
    :: error, player must match current bet
    !!
  (next-player-turn state)
    [%bet amount=@ud]
  =/  bet-plus-committed  
    (add amount.action committed:(get-player-chips who chips.game.state))
  ?:  =(bet-plus-committed current-bet.game.state)
    :: this is a call
    (next-player-turn (commit-chips who amount.action state))
  ?:  (lth bet-plus-committed (mul 2 current-bet.game.state))
    :: error, raise must be 2x current bet
    !!
  :: process raise 
  =.  current-bet.game.state
    bet-plus-committed
  (next-player-turn (commit-chips who amount.action state))
    %fold
  :: this changes with n players rather than 2.. but for now just end hand
  =.  state
    (committed-chips-to-pot state)
  (process-win (get-next-player who players.game.state) state)
  ==
++  determine-winner
  :: This is the hand evaluation arm
  :: currently a placeholder
  |=  state=server-game-state
  ^-  ship
  (head players.game.state)
--