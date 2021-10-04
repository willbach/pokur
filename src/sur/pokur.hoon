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
+$  poker-game-type  ?(%cash %turbo %fast %slow) :: will need to be fleshed out
::
::  This is the data a poker-server holds for a given game
::  Game state pertaining to a player stored in 'game'
+$  server-game-state
  $:  game=poker-game-state
      hands=(list [ship poker-deck])
      deck=poker-deck
      hand-is-over=?
      turn-timer=?(~ @da)
  ==
::
::  This is the data a poker-client holds for a given game
+$  poker-game-state
  $:  
    game-id=@da
    host=ship
    type=poker-game-type
    turn-time-limit=@dr
    time-limit-seconds=@ud :: for frontend parsing only
    players=(list ship)
    paused=?
    update-message=tape
    hands-played=@ud
    chips=(list [ship in-stack=@ud committed=@ud acted=? folded=? left=?])
    pots=(list [@ud (list ship)]) :: usually just one, but side pots are stored here.
    current-round=@ud :: set to 0 if cash game
    current-bet=@ud
    min-bets=(list @ud)
    round-duration=(unit @dr)
    last-bet=@ud
    board=poker-deck
    my-hand=poker-deck
    whose-turn=ship
    dealer=ship
    small-blind=ship
    big-blind=ship
  == 
+$  pokur-game-update
  $%  [%update game=poker-game-state my-hand-rank=tape]
      [%left-game t=?]
  ==
::
+$  pokur-challenge
  $:
    id=@da
    challenger=ship :: person who issued challenge
    players=(list [player=ship accepted=? declined=?])
    host=ship :: address of poker-server used for game
    min-bet=@ud :: only for cash games
    starting-stack=@ud :: only for cash games
    type=poker-game-type
    turn-time-limit=@dr
    time-limit-seconds=@ud :: for frontend parsing only
  ==
+$  pokur-challenge-update
  $%
    [%open-challenge challenge=pokur-challenge]
    [%close-challenge id=@da]
    [%challenge-update challenge=pokur-challenge]
  ==
::
:: client actions
::
+$  client-action
  $%
    $:  
      %issue-challenge
      to=(list ship) 
      host=ship
      min-bet=@ud
      starting-stack=@ud
      type=poker-game-type
      turn-time-limit=@t :: client converts this to @dr
      time-limit-seconds=@ud :: we store the seconds as @ud for frontend app
    ==
    [%receive-challenge challenge=pokur-challenge]
    [%challenge-update challenge=pokur-challenge]
    [%accept-challenge id=@da]
    [%decline-challenge id=@da]
    [%challenge-accepted id=@da]
    [%challenge-declined id=@da]
    [%cancel-challenge id=@da]
    [%challenge-cancelled id=@da]
    [%game-registered challenge=pokur-challenge]
    [%subscribe id=@da host=ship]
    [%leave-game id=@da]
  ==
+$  game-action
  $%
    [%check game-id=@da]
    [%bet game-id=@da amount=@ud]
    [%fold game-id=@da]
  ==  
::
::  server actions
+$  server-action
  $%
    [%leave-game game-id=@da]
    [%register-game challenge=pokur-challenge]
    [%kick paths=(list path) subscriber=ship]
    [%initialize-hand game-id=@da]
    [%send-game-updates game=server-game-state]
    [%end-game game-id=@da]
    [%set-timer game-id=@da time=@da]
    [%cancel-timer game-id=@da time=@da]
    [%wipe-all-games ~]
  ==
::
--