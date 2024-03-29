/-  uqbar=zig-uqbar
/=  escrow  /con/lib/escrow
|%
::  HARDCODED to ~datwet IRL, ~nec in FAKESHIP TESTING
++  fixed-lobby-source  ~nec
::
+$  host-info
  [=ship address=@ux contract=[id=@ux town=@ux]]
::
+$  tokenized
  (unit [metadata=@ux symbol=@t amount=@ud bond-id=@ux])
::
+$  game-type
  $%  [%cash cash-spec]
      [%sng sng-spec]
  ==
+$  cash-spec
  $:  min-buy=@ud  ::  all values in chips
      max-buy=@ud
      buy-ins=(map ship @ud)
      chips-per-token=@ud  ::  how many chips you get for each token. assumes 18 decimal-precision.
      small-blind=@ud
      big-blind=@ud
      tokens-in-bond=@ud
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
+$  player-info
  [stack=@ud committed=@ud acted=? folded=? left=?]
+$  players
  ::  list maintains table arrangement
  (list [=ship player-info])
::
::  the data a pokur-host holds for a given table
::
+$  host-game-state
  $:  hands=(map ship pokur-deck)
      deck=pokur-deck
      hand-is-over=?
      turn-timer=@da
      =tokenized
      ::  keep an ordered list of player stacks
      ::  1st is winner, 2nd is second, etc
      placements=(list ship)
      =game
  ==
::
::  the data a pokur player holds for a given table
::  "That's one Big Beautiful Buc-col" – ~rovnys
::
+$  game
  $:  id=@da
      game-is-over=?
      =game-type
      turn-time-limit=@dr
      turn-start=@da
      =players
      pots=(list [amount=@ud in=(list ship)])  ::  list is for side-pots
      current-bet=@ud
      last-bet=@ud
      last-action=(unit ?(%call %raise %check %fold))
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
      revealed-hands=(list [ship pokur-deck])
  ==
::
+$  table
  $:  id=@da
      is-active=?
      =host-info
      =tokenized
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
::  updates
::
::  from app to frontend, sent via subscription on paths:
::  /lobby-updates, /game-updates, /messages
::
+$  update
  $%  [%game =game my-hand-rank=@t last-board=pokur-deck]
      [%table-closed table-id=@da]
      [%game-starting game-id=@da]
      [%lobby tables=(map @da table)]
      [%new-message from=ship msg=@t]
      [%left-game ~]
      [%new-invite from=ship =table]
      $:  %game-over
          =game
          last-board=pokur-deck
          placements=(list [ship @ud])
          =tokenized
      ==
  ==
::
::  from %pokur-host to %pokur. sent via solid-state pokes.
::
+$  host-update
  $%  [%lobby tables=(map @da table)]      ::  received upon ask
      [%new-table =table]                  ::  for lobby watchers
      [%table-closed table-id=@da]         ::  for lobby watchers
      [%game-starting game-id=@da]         ::  for lobby watchers
      [%game =game last-board=pokur-deck]  ::  for game watchers
      $:  %game-over                       ::  for game watchers
          =game
          last-board=pokur-deck
          placements=(list [ship @ud])
          =tokenized
      ==
  ==
::
::  pokes
::
+$  player-action
  $%  [%watch-lobby ~]  ::  ask host to poke us with lobby-updates
      [%stop-watching-lobby ~]
      $:  %new-table
          id=@da  ::  FE can bunt -- populated with now.bowl
          host=ship
          =tokenized
          min-players=@ud
          max-players=@ud
          =game-type
          public=?  ::  private means need the link to join
          spectators-allowed=?
          turn-time-limit=@dr
      ==
      [%join-table id=@da buy-in=@ud public=?]  ::  buy-in is in tokens, for %cash games
      [%leave-table id=@da]
      [%start-game id=@da]  ::  from FE to player app
      [%leave-game id=@da]
      [%kick-player id=@da who=ship]  ::  only for leader of private tables
      ::  choose which wallet address we wish to use to pay escrow
      [%set-our-address address=@ux]
      ::  add a ship to our known-hosts
      [%find-host who=ship]
      [%remove-host who=ship]
      [%send-invite to=ship]  ::  from FE to player app
      [%invite =table]  ::  from player app to player app
      [%spectate-game host=ship id=@da]
  ==
::
+$  txn-player-action
  ::  these player actions trigger on-chain escrow transactions
  $%  [%new-table-txn =sequencer-receipt:uqbar =player-action]
      [%join-table-txn =sequencer-receipt:uqbar =player-action]
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
      [%game-starting id=@da]
      [%turn-timers id=@da who=@p pre=@p wake=@da rest=@da]
      ::  debugging/cli tools for hosts
      [%clear-lobby-watchers ~]
      [%kick-table id=@da]
      [%kick-game id=@da]
  ==
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
      %wheel-straight  ::  A2345
      %three-of-a-kind
      %two-pair
      %pair
      %high-card
  ==
--
