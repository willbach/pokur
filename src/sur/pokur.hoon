|%
::
::  Basic poker concepts
::
+$  suit  
  $?  %spades    %hearts
      %diamonds  %clubs
  ==
+$  card-val
  $?  %2  %3  %4
      %5  %6  %7
      %8  %9  %10
      %jack  %queen
      %king  %ace
  ==
+$  pokur-card
  [card-val suit]
+$  pokur-deck
  (list pokur-card)
+$  hand-rank
  $?  %royal-flush
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
::  This is the data a pokur-server holds for a given game
::  Game state pertaining to a player stored in 'game'
::
+$  server-game-state
  $:  game=pokur-game-state
      hands=(list [ship pokur-deck])
      deck=pokur-deck
      hand-is-over=?
      turn-timer=?(~ @da)
  ==
::
::  This is the data a pokur-client holds for a given game
::
+$  pokur-game-state
  $:  
    game-id=@da
    game-is-over=?
    host=ship
    type=pokur-game-type
    turn-time-limit=@dr
    :: for frontend parsing only! equivalent to above
    time-limit-seconds=@ud 
    players=(list ship)
    :: not used yet.. will be one day
    paused=?
    update-message=[tape winning-hand=pokur-deck]
    hands-played=@ud
    chips=chips-list
    :: usually just one, but side pots are stored here.
    pots=(list [@ud (list ship)]) 
    :: always 0 if cash game
    current-round=@ud
    :: set to indicate that next hand should increment current-round
    round-over=? 
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
    spectators-allowed=?
    spectators=(list ship)
  == 
+$  chips-list
  %-  list
  $:  ship
      in-stack=@ud 
      committed=@ud 
      acted=? 
      folded=? 
      left=?
  ==
+$  pokur-game-type  
  $?  %cash   %turbo
      %fast   %slow
  ==
+$  pokur-challenge
  $:
    id=@da
    challenger=ship
    players=(list [player=ship accepted=? declined=?])
    host=ship
    :: whether spectators are allowed or not
    spectators=?
    min-bet=@ud
    starting-stack=@ud
    type=pokur-game-type
    turn-time-limit=@dr
    :: only used for frontend parsing, same as above
    time-limit-seconds=@ud
  ==
::
::  Gall actions, pokes
::
+$  game-update
  $%  [%update game=pokur-game-state my-hand-rank=tape]
      [%msgs msg-list=(list [from=ship msg=tape])]
      [%left-game t=?]
  ==
::
+$  challenge-update
  $%
    [%open-challenge challenge=pokur-challenge]
    [%challenge-update challenge=pokur-challenge]
    [%close-challenge id=@da]
  ==
::
+$  client-action
  $%
    $:  
      %issue-challenge
      to=(list ship) 
      host=ship
      spectators=?
      min-bet=@ud
      starting-stack=@ud
      type=pokur-game-type
      :: client converts this to @dr
      turn-time-limit=@t
      :: we store the seconds as @ud for frontend app
      time-limit-seconds=@ud 
    ==
    [%receive-challenge challenge=pokur-challenge]
    [%challenge-update challenge=pokur-challenge]
    [%game-registered challenge=pokur-challenge]
    [%accept-challenge id=@da]
    [%decline-challenge id=@da]
    [%challenge-accepted id=@da]
    [%challenge-declined id=@da]
    [%cancel-challenge id=@da]
    [%challenge-cancelled id=@da]
    [%subscribe id=@da host=ship]
    [%leave-game id=@da]
  ==
::
+$  game-action
  $%
    [%bet game-id=@da amount=@ud]
    [%check game-id=@da]
    [%fold game-id=@da]
    [%send-msg msg=tape]
    [%receive-msg msg=tape]
  ==  
::
::  Pokes used by pokur-server
::
+$  server-action
  $%
    [%register-game challenge=pokur-challenge]
    [%kick paths=(list path) subscriber=ship]
    [%send-game-updates game=server-game-state]
    [%initialize-hand game-id=@da]
    [%leave-game game-id=@da]
    [%end-game game-id=@da]
    [%set-timer game-id=@da type=?(%turn %round) time=@da]
    [%cancel-timer game-id=@da time=@da]
    [%wipe-all-games ~]
  ==
::
:: Historical states for client and server apps
::
+$  pokur-game-state-zero
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
    spectators-allowed=?
    spectators=(list ship)
  == 
+$  server-game-state-zero
  $:  game=pokur-game-state-zero
      hands=(list [ship pokur-deck])
      deck=pokur-deck
      hand-is-over=?
      game-is-over=?
      turn-timer=?(~ @da)
  ==
--