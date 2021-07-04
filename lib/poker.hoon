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
++  draw
  |=  [n=@ud d=poker-deck]
  ^-  [hand=poker-deck rest=poker-deck]
  :-  (scag n d)
  (slag n d)
::
::  state changes made by server
::
++  deal-hands
  |=  [state=server-game-state]
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
++  assign-dealer
  |=  [who=ship state=server-game-state]
  ^-  server-game-state
  =.  dealer.game.state
    who
  state
++  chips-to-pot
  |=  [who=ship amt=@ud state=server-game-state]
  ^-  server-game-state
  =/  f
    |=  [p=ship n=@ud]
    ?:  =(p who)
      =.  pot.game.state  
        (add pot.game.state amt)
      [p (sub n amt)]
    [p n] 
  =.  chips.game.state  (turn chips.game.state f)
  state
++  take-blinds
  |=  [sb-size=@ud state=server-game-state]
  ^-  server-game-state
  =/  sb  
    dealer.game.state
  =/  sb-position  
    (find [sb]~ players.game.state)
  =/  bb  
    (snag (mod (add 1 u.+.sb-position) (lent players.game.state)) players.game.state)
  =.  state
    (chips-to-pot sb sb-size state)
  =.  state
    (chips-to-pot bb (mul 2 sb-size) state)
  =.  current-bet.game.state
    (mul 2 sb-size)
  state
++  next-player-turn
  |=  [state]
++  process-player-action
  |=  [action=poker-action state=server-game-state]
  ^-  server-game-state
  ?-  -.action
    %check
  ::  ?.  =(current-bet.game.state 0)
    :: error, player must match current bet
    :: do i need to handle this in gall though? probably
  
    %bet

    %fold
--