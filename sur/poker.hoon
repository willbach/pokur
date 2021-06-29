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
:: +$  poker-game-winner?
::   $~  ~
::   @p
+$  poker-game
  $:
    game-id=@ud
    players=(list ship)
    game-host=ship :: address of poker-server used for game
    winner=ship
    type=poker-game-type
  ==
::
:: client actions
::
+$  client-game-action
  $%
    [%issue-challenge to=ship game=poker-game]
    [%accept-challenge from=ship]
    [%receive-challenge game=poker-game]
    [%challenge-accepted by=ship]
    :: [%register-game host=ship game=poker-game]
    ::  [%concede game-id=@ud]
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
+$  server-game-action
  $%
    [%register-game game=poker-game]
  ==
::
--