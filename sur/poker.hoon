|%
::
:: basic poker types
::
+$  suit  ?(%spades %hearts %diamonds %clubs)
+$  card-val
  $~  %ace
  ?(%ace %2 %3 %4 %5 %6 %7 %8 %9 %10 %jack %queen %king)
+$  poker-card  [card-val suit]
:: a deck is any amount of cards, thus also represents a hand
+$  poker-deck  (list poker-card)
::
:: poker game types
::
+$  poker-game-type  ?(%cash %tournament) :: will need to be fleshed out
::
+$  poker-game-state
  $:  
    game-id=@ud
    players=(list ship)
    host=ship
    type=poker-game-type
    chips=(list [ship @ud])
    current-hand=poker-deck
    current-board=poker-deck
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
    [%issue-challenge to=ship challenge=poker-challenge]
    [%accept-challenge challenge-id=@ud]
    [%receive-challenge challenge=poker-challenge]
    [%challenge-accepted by=ship challenge-id=@ud]
    [%subscribe game-id=@ud host=ship]
  ==
+$  poker-action
  $%
    %deal-hand
    %check
    [%bet amount=@ud]
    %fold
  ==  
::
::  server actions
+$  server-action
  $%
    [%register-game challenge=poker-challenge]
  ==
::
--