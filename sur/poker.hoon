|%
::
:: basic poker types
::
+$  suit  ?(%spades %hearts %diamonds %clubs)
+$  card-val
  ?(%2 %3 %4 %5 %6 %7 %8 %9 %10 %jack %queen %king %ace)
+$  poker-card  [card-val suit]
:: a deck is any amount of cards, thus also represents a hand
+$  poker-deck  (list poker-card)
+$  poker-hand-rank
  $?
    %royal-flush
    %straight-flush
    %four-of-a-kind
    %full-house
    %flush
    %straight
    %three-of-a-kind
    %two-pair
    %pair
    %high-card
  ==
::
:: poker game types
::
+$  poker-game-type  ?(%cash %tournament) :: will need to be fleshed out
::
::  This is the data a poker-server holds for a given game
::  Game state pertaining to a player stored in 'game'
+$  server-game-state
  $:  game=poker-game-state
      hands=(list [ship poker-deck])
      deck=poker-deck
      hand-is-over=?
  ==
::
::  This is the data a poker-client holds for a given game
+$  poker-game-state
  $:  
    game-id=@ud
    host=ship
    type=poker-game-type
    players=(list ship)
    paused=?
    hands-played=@ud
    chips=(list [ship in-stack=@ud committed=@ud acted=?])
    pot=@ud
    current-bet=@ud
    min-bet=@ud
    board=poker-deck
    my-hand=poker-deck
    whose-turn=ship
    dealer=ship
    small-blind=ship
    big-blind=ship
  ==  
::
+$  poker-challenge
  $:
    game-id=@ud
    challenger=ship :: person who issued challenge
    players=(list ship)
    host=ship :: address of poker-server used for game
    type=poker-game-type
  ==
::
:: client actions
::
+$  client-action
  $%
    [%issue-challenge to=ship game-id=@ud host=ship type=poker-game-type]
    [%accept-challenge from=ship]
    [%receive-challenge challenge=poker-challenge]
    [%challenge-accepted by=ship]
    [%subscribe game-id=@ud host=ship]
    [%leave-game game-id=@ud]
  ==
+$  game-action
  $%
    [%check game-id=@ud]
    [%bet game-id=@ud amount=@ud]
    [%fold game-id=@ud]
  ==  
::
::  server actions
+$  server-action
  $%
    [%register-game challenge=poker-challenge]
    [%kick paths=(list path) subscriber=ship]
    [%initialize-hand game-id=@ud]
    [%send-game-updates game=server-game-state]
    [%wipe-all-games game-id=@ud]
  ==
::
--