/=  escrow  /con/lib/escrow
|%
::  HARDCODED to ~bacrys IRL, ~zod in FAKESHIP TESTING
++  fixed-lobby-source  ~zod
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
      [%sng sng-spec]
  ==
+$  cash-spec
  $:  starting-stack=@ud
      small-blind=@ud
      big-blind=@ud
  ==
+$  sng-spec
  $:  starting-stack=@ud
      round-duration=@dr
      blinds-schedule=(list [small=@ud big=@ud])
      current-round=@ud
      round-is-over=?
      ::  1 to n size list, number is 1-100 % of prize
      ::  first item is payout for first place, etc
      payouts=(list @ud)
  ==
::
+$  players
  ::  list maintains table arrangement
  (list [=ship player-info])
+$  player-info
  [stack=@ud committed=@ud acted=? folded=? left=?]
::
::  the data a pokur-host holds for a given table
::
+$  host-game-state
  $:  hands=(map ship pokur-deck)
      deck=pokur-deck
      hand-is-over=?
      turn-timer=@da
      tokenized=(unit [metadata=@ux symbol=@t amount=@ud bond-id=@ux])
      ::  keep an ordered list of player stacks
      ::  1st is winner, 2nd is second, etc
      placements=(list ship)
      =game
  ==
::
::  the data a pokur player holds for a given table
::
+$  game
  $:  id=@da
      game-is-over=?
      =game-type
      turn-time-limit=@dr
      =players
      pots=(list [amount=@ud in=(list ship)])  ::  list is for side-pots
      current-bet=@ud
      last-bet=@ud
      last-aggressor=(unit ship)  ::  used in showdowns for hand reveal
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
      update-message=@t
  ==
::
+$  table
  $:  id=@da
      =host-info
      tokenized=(unit [metadata=@ux symbol=@t amount=@ud bond-id=@ux])
      leader=ship  ::  created lobby, decides when to start
      players=(set ship)
      min-players=@ud
      max-players=@ud
      =game-type
      public=?
      spectators-allowed=?
      ::  between 10 and 999 seconds, enforced by frontend parsing
      ::  and by host
      turn-time-limit=@dr
  ==
::
+$  host-info
  [=ship address=@ux contract=[id=@ux town=@ux]]
::
::  gall actions, pokes
::
+$  update  ::  from app to frontend
  $%  [%game =game my-hand-rank=@t]
      [%table-closed table-id=@da]
      [%game-starting game-id=@da]
      [%game-over game-id=@da placements=(list ship)]
      [%lobby tables=(map @da table)]
      [%new-message from=ship msg=@t]
      [%left-game ~]
  ==
+$  host-update  ::  from host to player app
  $%  [%game =game]
      [%table-closed table-id=@da]
      [%game-starting game-id=@da]
      [%game-over game-id=@da placements=(list ship)]
      [%lobby tables=(map @da table)]
  ==
::
+$  player-action
  $%  $:  %new-table
          id=@da  ::  FE can bunt -- populated with now.bowl
          host=ship
          tokenized=(unit [metadata=@ux symbol=@t amount=@ud bond-id=@ux])
          min-players=@ud
          max-players=@ud
          =game-type
          public=?  ::  private means need the link to join
          spectators-allowed=?
          turn-time-limit=@dr
      ==
      [%join-table id=@da]  ::  pokes to the HOST, must first pay escrow!
      [%leave-table id=@da]
      [%start-game id=@da]  ::  from FE to player app
      [%leave-game id=@da]
      [%kick-player id=@da who=ship]  ::  creator of *private* table must perform
      ::  choose which wallet address we wish to use to pay escrow
      [%set-our-address address=@ux]
  ==
::
+$  message-action
  $%  [%mute who=ship]    ::  from frontend to app
      [%unmute who=ship]
      [%send-message msg=@t]     ::  from frontend to app
      [%receive-message msg=@t]  ::  from our app to their app
  ==
::
+$  game-action
  $%  [%check game-id=@da ~]
      [%fold game-id=@da ~]
      [%bet game-id=@da amount=@ud]
  ==
::
+$  host-action
  $%  [%host-info =host-info]
      [%share-table =table]  ::  for lobby gossip
      [%closed-table id=@da]
  ==
--