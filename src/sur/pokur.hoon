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
::  the data a pokur-server holds for a given table
::
+$  host-table-state
  $:  hands=(list [ship pokur-deck])
      deck=pokur-deck
      hand-is-over=?
      turn-timer=@da
      table
  ==
::
::  the data a pokur-client holds for a given table
::
+$  table
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
+$  lobby
  $:  id=@da
      leader=ship  ::  created lobby, decides when to start
      players=(set ship)
      type=game-type
      tokenized=(unit [metadata=@ux amount=@ud])
      bond-id=(unit @ux)
      spectators-allowed=?
      ::  represented in cord as number between 1 and 999,
      ::  parsed into @ud or @dr depending on context
      turn-time-limit=@t
  ==
::
::  gall actions, pokes
::
+$  update  ::  from app to frontend
  $%  [%table-update table my-hand-rank=tape]
      [%lobby-update lobby]
      [%lobbies-available lobbies=(list lobby)]
      [%new-message from=ship msg=tape]
      [%left-game ~]
  ==
+$  host-update  ::  from host to player
  $%  [%table-update table]
      [%lobby-update lobby]
      [%lobbies-available lobbies=(list lobby)]
  ==
::
+$  player-action  ::  to host
  $%  [%join-host host=ship]
      [%leave-host ~]
      $:  %new-lobby
          type=game-type
          tokenized=(unit [metadata=@ux amount=@ud])
          min-players=@ud
          spectators-allowed=?
          turn-time-limit=@t
      ==
      [%join-lobby id=@da]
      [%leave-lobby ~]
      [%start-game ~]  ::  creator of lobby must perform
      [%leave-game ~]
      [%add-escrow ~]  ::  generate %uqbar transaction, if game is tokenized
  ==
::
+$  message-action
  $%  [%send-message msg=tape]  ::  from frontend to app
      [%receive-message msg=tape]  ::  from our app to their app
  ==
::
+$  game-action
  $%  [%bet amount=@ud]
      [%check ~]
      [%fold ~]
  ==
::
+$  host-action  ::  internal pokes for host
  $%  [%send-game-updates game=server-game-state]
      [%initialize-hand game-id=@da]
      [%set-timer game-id=@da type=?(%turn %round) time=@da]
      [%kick paths=(list path) subscriber=ship]
      [%cancel-timer game-id=@da time=@da]
      [%end-game game-id=@da]
      [%wipe-all-games ~]
  ==
--