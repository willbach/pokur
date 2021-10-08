|%
::
:: basic pokur types
::
+$  suit  ?(%spades %hearts %diamonds %clubs)
+$  card-val
  ?(%2 %3 %4 %5 %6 %7 %8 %9 %10 %jack %queen %king %ace)
+$  pokur-card  [card-val suit]
:: a deck is any amount of cards, thus also represents a hand
+$  pokur-deck  (list pokur-card)
+$  pokur-hand-rank
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
:: pokur game types
::
+$  pokur-game-type  ?(%cash %turbo %fast %slow) :: will need to be fleshed out
::
::  This is the data a pokur-server holds for a given game
::  Game state pertaining to a player stored in 'game'
+$  server-game-state
  $:  game=pokur-game-state
      hands=(list [ship pokur-deck])
      deck=pokur-deck
      hand-is-over=?
      game-is-over=?
      turn-timer=?(~ @da)
  ==
::
::  This is the data a pokur-client holds for a given game
+$  pokur-game-state
  $:  
    game-id=@da
    host=ship
    type=pokur-game-type
    turn-time-limit=@dr
    time-limit-seconds=@ud :: for frontend parsing only
    players=(list ship)
    paused=?
    update-message=tape
    hands-played=@ud
    chips=(list [ship in-stack=@ud committed=@ud acted=? folded=? left=?])
    pots=(list [@ud (list ship)]) :: usually just one, but side pots are stored here.
    current-round=@ud :: set to 0 if cash game
    round-over=? :: set to indicate that next hand should increment current-round
    current-bet=@ud
    min-bets=(list @ud)
    round-duration=(unit @dr)
    last-bet=@ud
    board=pokur-deck
    my-hand=pokur-deck
    whose-turn=ship
    dealer=ship
    small-blind=ship
    big-blind=ship
  == 
+$  pokur-game-update
  $%  [%update game=pokur-game-state my-hand-rank=tape]
      [%left-game t=?]
      [%msgs msg-list=(list [from=ship msg=tape])]
  ==
::
+$  pokur-challenge
  $:
    id=@da
    challenger=ship :: person who issued challenge
    players=(list [player=ship accepted=? declined=?])
    host=ship :: address of pokur-server used for game
    min-bet=@ud :: only for cash games
    starting-stack=@ud :: only for cash games
    type=pokur-game-type
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
      type=pokur-game-type
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
    [%send-msg msg=tape]
    [%receive-msg msg=tape]
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
    [%set-timer game-id=@da type=?(%turn %round) time=@da]
    [%cancel-timer game-id=@da time=@da]
    [%wipe-all-games ~]
  ==
::
--