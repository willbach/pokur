|%
::
::  basic poker concepts
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
+$  game-type
  $%  [%cash cash-spec]
      [%tournament tournament-spec]
  ==
+$  cash-spec
  $:  starting-stack=@ud
      small-blind=@ud
      big-blind=@ud
  ==
+$  tournament-spec
  $:  round-duration=@dr
      starting-stack=@ud
      blinds-schedule=(list [sb=@ud bb=@ud])
  ==
::
::  the data a pokur-server holds for a given game
::  game state pertaining to a player stored in 'game'
::
+$  server-game-state
  $:  game=game-state
      hands=(list [ship pokur-deck])
      deck=pokur-deck
      hand-is-over=?
      turn-timer=@da
  ==
::
::  the data a pokur-client holds for a given game
::
+$  game-state
  $:
    game-id=@da
    game-is-over=?
    host=ship
    type=game-type
    ::  represented in cord as number between 1 and 999,
    ::  parsed into @ud or @dr depending on context
    turn-time-limit=@t
    players=(map ship [in-stack=@ud committed=@ud acted=? folded=? left=?])
    pots=(list [@ud (list ship)])  ::  list is for side-pots
    current-bet=@ud
    last-bet=@ud
    board=pokur-deck
    my-hand=pokur-deck
    whose-turn=ship
    dealer=ship
    small-blind=ship
    big-blind=ship
    ::  for tournaments
    current-round=@ud
    round-over=?  ::  indicates that next hand should increment current-round
    ::  game metadata
    spectators-allowed=?
    spectators=(list ship)
    hands-played=@ud
    update-message=[tape winning-hand=pokur-deck]  ::  XX
  ==
::
+$  pokur-challenge
  $:
    id=@da
    challenger=ship
    players=(list [player=ship accepted=? declined=?])
    host=ship
    spectators-allowed=?
    min-bet=@ud
    starting-stack=@ud
    type=game-type
    ::  represented in cord as number between 1 and 999,
    ::  parsed into @ud or @dr depending on context
    turn-time-limit=@t
  ==
::
::  gall actions, pokes
::
+$  game-update
  $%  [%update game=game-state my-hand-rank=tape]
      [%msgs msg-list=(list [from=ship msg=tape])]
      [%left-game ~]
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
    $:  %new-lobby
        host=ship
        type=game-type
        min-players=@ud
        spectators-allowed=?
        turn-time-limit=@t
    ==
    [%join-lobby host=ship id=@da]
    [%add-escrow]
    [%leave-lobby ~]
    [%leave-game ~]
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
--