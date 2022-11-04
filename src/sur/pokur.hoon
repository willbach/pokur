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
+$  pokur-card  [card-val suit]
+$  pokur-deck  (list pokur-card)
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
  $:  starting-stack=@ud
      round-duration=@dr
      blinds-schedule=(list [small=@ud big=@ud])
      current-round=@ud
      round-is-over=?
  ==
::
+$  players
  ::  list maintains table arrangement
  (list [=ship player-info])
+$  player-info
  [stack=@ud committed=@ud acted=? folded=? left=?]
::
::
::  the data a pokur-host holds for a given table
::
+$  host-table-state
  $:  hands=(map ship pokur-deck)
      deck=pokur-deck
      hand-is-over=?
      turn-timer=@da
      =table
  ==
::
::  the data a pokur player holds for a given table
::
+$  table
  $:  id=@da
      game-is-over=?
      =game-type
      turn-time-limit=@dr
      =players
      pots=(list [amount=@ud in=(list ship)])  ::  list is for side-pots
      current-bet=@ud
      last-bet=@ud
      board=pokur-deck
      my-hand=pokur-deck
      whose-turn=ship
      dealer=ship
      small-blind=ship
      big-blind=ship
      ::  game metadata
      spectators-allowed=?
      spectators=(set ship)
      hands-played=@ud
      update-message=[tape winning-hand=pokur-deck]  ::  XX
  ==
::
+$  lobby
  $:  id=@da
      leader=ship  ::  created lobby, decides when to start
      players=(set ship)
      min-players=@ud
      max-players=@ud
      =game-type
      tokenized=(unit [metadata=@ux amount=@ud])
      bond-id=(unit @ux)
      spectators-allowed=?
      ::  represented in cord as number between 1 and 999,
      ::  parsed into @ud or @dr depending on context
      turn-time-limit=@dr
  ==
::
+$  host-info
  $:  escrow-contract=[id=@ux town=@ux]
      uqbar-address=@ux
  ==
::
::  gall actions, pokes
::
+$  update  ::  from app to frontend
  $%  [%table table my-hand-rank=tape]
      [%lobby lobby]
      [%lobbies-available lobbies=(list lobby)]
      [%new-message from=ship msg=@t]
      [%left-game ~]
  ==
+$  host-update  ::  from host to player
  $%  [%table table]
      [%lobby lobby]
      [%game-starting table-id=@da]
      [%lobbies-available lobbies=(list lobby)]
  ==
::
+$  player-action  ::  to host
  $%  [%join-host host=ship]
      [%leave-host ~]
      $:  %new-lobby
          min-players=@ud
          max-players=@ud
          =game-type
          tokenized=(unit [metadata=@ux amount=@ud])
          spectators-allowed=?
          turn-time-limit=@dr
      ==
      [%join-lobby id=@da]
      [%leave-lobby id=@da]
      [%start-game id=@da]  ::  creator of lobby must perform
      [%leave-game id=@da]
      [%kick-player id=@da who=ship]  ::  creator of lobby must perform
      [%add-escrow ~]  ::  TODO generate %uqbar transaction, if game is tokenized
  ==
::
+$  message-action
  $%  [%mute-player who=ship]    ::  from frontend to app
      [%send-message msg=@t]     ::  from frontend to app
      [%receive-message msg=@t]  ::  from our app to their app
  ==
::
+$  game-action
  $%  [%check table-id=@da ~]
      [%fold table-id=@da ~]
      [%bet table-id=@da amount=@ud]
  ==
::
+$  host-action  ::  internal pokes for host
  $%  [%set-escrow-info host-info]
  ==
--