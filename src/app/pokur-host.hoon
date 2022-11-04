/-  *pokur
/+  default-agent, dbug, *pokur
|%
+$  card  card:agent:gall
+$  versioned-state  $%(state-0)
+$  state-0
  $:  %0
      my-info=(unit host-info)
      lobbies=(map @da lobby)
      tables=(map @da host-table-state)
  ==
--
%-  agent:dbug
=|  state=state-0
^-  agent:gall
=<
|_  =bowl:gall
+*  this  .
    def   ~(. (default-agent this %|) bowl)
    hc    ~(. +> bowl)
::
++  on-init
  ^-  (quip card _this)
  `this(state [%0 ~ ~ ~])
++  on-save
  ^-  vase
  !>(state)
++  on-load
  |=  old=vase
  ^-  (quip card _this)
  `this(state !<(versioned-state old))
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  =^  cards  state
    ?+    mark  (on-poke:def mark vase)
        %pokur-player-action
      ::  starting lobbies, games, etc
      (handle-player-action !<(player-action vase))
        %pokur-game-action
      ::  checks, bets, folds inside table
      (handle-game-action !<(game-action vase))
        %pokur-host-action
      ::  internal pokes and host management
      (handle-host-action !<(host-action vase))
    ==
  [cards this]
++  on-watch
  |=  =path
  ^-  (quip card _this)
  ?+    path  (on-watch:def path)
      [%lobby-updates ~]
    :_  this  :_  ~
    :^  %give  %fact  ~
    :-  %pokur-host-update
    !>(`host-update`[%lobbies-available ~(val by lobbies.state)])
  ::
      [%lobby-updates @ ~]
    ::  updates about a specific lobby
    =/  lobby-id  (slav %da i.t.path)
    ?~  lobby=(~(get by lobbies.state) lobby-id)
      !!
    :_  this  :_  ~
    :^  %give  %fact  [path]~
    [%pokur-host-update !>(`host-update`[%lobby u.lobby])]
  ::
      [%table-updates @ @ ~]
    ::  assert the player is in game and on their path
    =/  table-id  (slav %da i.t.path)
    =/  player  (slav %p i.t.t.path)
    ?>  =(player src.bowl)
    ?~  host-table=(~(get by tables.state) table-id)
      :_  this
      =/  err  "invalid table id {<table-id>}"
      :~  [%give %watch-ack `~[leaf+err]]
      ==
    ?~  (find [src.bowl]~ players.table.u.host-table)
      ?.  spectators-allowed.table.u.host-table
        :_  this
        =/  err  "player not in this game"
        :~  [%give %watch-ack `~[leaf+err]]
        ==
      ::  give table state to a spectator
      =.  spectators.table.u.host-table
        (~(put in spectators.table.u.host-table) src.bowl)
      :_  this(tables.state (~(put by tables.state) table-id u.host-table))
      :_  ~
      :^  %give  %fact  [path]~
      [%pokur-host-update !>([%table table.u.host-table])]
    ::  give table state to a player
    =.  my-hand.table.u.host-table
      (fall (~(get by hands.u.host-table) src.bowl) ~)
    :_  this  :_  ~
    :^  %give  %fact  [path]~
    [%pokur-host-update !>([%table table.u.host-table])]
  ==
++  on-arvo
  |=  [=wire =sign-arvo]
  ^-  (quip card _this)
  ?+    wire  (on-arvo:def wire sign-arvo)
      [%timer @ %round-timer ~]
    :: ROUND TIMER wire (for tournaments)
    =/  table-id  (slav %da i.t.wire)
    ?~  host-table=(~(get by tables.state) table-id)
      `this
    =*  table  table.u.host-table
    :: if no players left in game, end it
    ?:  %+  levy  players.table
        |=([ship @ud @ud ? ? left=?] left)
      =^  cards  state
        (end-game u.host-table)
      [cards this]
    =.  u.host-table
      ~(increment-current-round modify-table-state u.host-table)
    :_  this(tables.state (~(put by tables.state) table-id u.host-table))
    %+  snoc
      (send-game-updates u.host-table)
    ::  set new round timer
    ?>  ?=(%tournament -.game-type.table)
    :*  %pass  /timer/(scot %da table-id)/round-timer
        %arvo  %b  %wait
        (add now.bowl round-duration.game-type.table)
    ==
  ::
      [%timer @ ~]
    :: TURN TIMER wire
    :: the timer ran out.. a player didn't make a move in time
    =/  table-id  (slav %da i.t.wire)
    ~&  >>>
    "%pokur-host: player timed out on game {<table-id>} at {<now.bowl>}"
    ::  find whose turn it is
    ?~  host-table=(~(get by tables.state) table-id)
      `this
    =*  table  table.u.host-table
    ::  if no players left in game, end it
    ?:  %+  levy  players.table
        |=([ship @ud @ud ? ? left=?] left)
      =^  cards  state
        (end-game u.host-table)
      [cards this]
    :: reset that game's turn timer
    =.  turn-timer.u.host-table  *@da
    =.  update-message.table
      ["{<whose-turn.table>} timed out." ~]
    :_  this(tables.state (~(put by tables.state) table-id u.host-table))
    :_  ~
    :*  %pass  /self-poke-wire
        %agent  [our.bowl %pokur-host]
        %poke  %pokur-game-action
        !>([%fold table-id])
    ==
  ==
++  on-peek
  ::  TODO add scries
  on-peek:def
++  on-agent  on-agent:def
++  on-leave  on-leave:def
++  on-fail   on-fail:def
--
::  start helper core
|_  bowl=bowl:gall
++  handle-host-action
  |=  action=host-action
  ^-  (quip card _state)
  ?-    -.action
      %set-escrow-info
    `state(my-info `+.action)
  ==
::
++  handle-game-action
  |=  action=game-action
  ^-  (quip card _state)
  ?~  host-table=(~(get by tables.state) table-id.action)
    :_  state
    ~[[%give %poke-ack `~[leaf+"error: host could not find table"]]]
  =*  table  table.u.host-table
  :: validate that move is from right player
  =/  from=ship
    ?:  =(src.bowl our.bowl)
      :: automatic fold from timeout!
      whose-turn.table
    src.bowl
  ?.  =(whose-turn.table from)
    :_  state
    ~[[%give %poke-ack `~[leaf+"error: playing out of turn!"]]]
  :: poke ourself to set a turn timer
  =/  new-timer  (add now.bowl turn-time-limit.table)
  =.  turn-timer.u.host-table  new-timer
  =.  u.host-table
    =+  (~(process-player-action modify-table-state u.host-table) from action)
    ?~  -  !!  u.-
  =.  tables.state  (~(put by tables.state) id.table u.host-table)
  =^  cards  state
    ?.  game-is-over.table
      ?.  hand-is-over.u.host-table
        (send-game-updates u.host-table)^state
      (initialize-new-hand u.host-table)
    (end-game u.host-table)
  :_  state
  %+  weld  cards
  ^-  (list card)
  :-  :*  %pass  /timer/(scot %da id.table)
          %arvo  %b  %wait
          new-timer
      ==
  ?~  turn-timer.u.host-table
    :: there's no ongoing timer to cancel, just set new
    ~
  :: there's an ongoing turn timer, cancel it and set fresh one
  :_  ~
  :*  %pass  /timer/(scot %da id.table)
      %arvo  %b  %rest
      turn-timer.u.host-table
  ==
::
++  handle-player-action
  |=  action=player-action
  ^-  (quip card _state)
  ?+    -.action  !!
      %new-lobby
    ::  if lobby is started at *exact* same time as another,
    ::  add a tiny nonce to disambiguate. never gonna happen!
    =/  lobby-id
      ?:  (~(has by lobbies.state) now.bowl)
      (add now.bowl 1)  now.bowl
    =/  =lobby
      :*  lobby-id
          src.bowl
          (silt ~[src.bowl])
          min-players.action
          max-players.action
          game-type.action
          tokenized.action
          ~  ::  TODO bond id
          spectators-allowed.action
          turn-time-limit.action
      ==
    =+  (~(put by lobbies.state) lobby-id lobby)
    :_  state(lobbies -)
    :_  ~
    :^  %give  %fact  ~[/lobby-updates]
    [%pokur-host-update !>(`host-update`[%lobbies-available ~(val by -)])]
  ::
      %join-lobby
    ::  add player to existing lobby
    ?~  lobby=(~(get by lobbies.state) id.action)
      !!
    ::  lobby must not be full
    ?<  =(max-players.u.lobby ~(wyt in players.u.lobby))
    =.  players.u.lobby
      (~(put in players.u.lobby) src.bowl)
    :_  state(lobbies (~(put by lobbies.state) id.action u.lobby))
    :_  ~
    :^  %give  %fact  ~[/lobby-updates/(scot %da id.u.lobby)]
    [%pokur-host-update !>(`host-update`[%lobby u.lobby])]
  ::
      %leave-lobby
    ::  remove player from existing lobby
    ?~  lobby=(~(get by lobbies.state) id.action)
      !!
    ?.  (~(has in players.u.lobby) src.bowl)
      `state
    =.  players.u.lobby
      (~(del in players.u.lobby) src.bowl)
    :_  state(lobbies (~(put by lobbies.state) id.action u.lobby))
    :_  ~
    :^  %give  %fact  ~[/lobby-updates/(scot %da id.u.lobby)]
    [%pokur-host-update !>(`host-update`[%lobby u.lobby])]
  ::
      %start-game
    ::  lobby creator starts game
    ?~  lobby=(~(get by lobbies.state) id.action)
      !!
    ?>  =(leader.u.lobby src.bowl)
    ?>  (gte ~(wyt in players.u.lobby) min-players.u.lobby)
    ~&  >  "%pokur-host: starting new game {<id.action>}"
    =?    game-type.u.lobby
        ?=(%tournament -.game-type.u.lobby)
      %=  game-type.u.lobby
        current-round  0
        round-is-over  %.n
      ==
    =/  =table
      :*  id.u.lobby
          game-is-over=%.n
          game-type.u.lobby
          turn-time-limit.u.lobby
          %+  turn  ~(tap in players.u.lobby)
          |=  =ship
          [ship starting-stack.game-type.u.lobby 0 %.n %.n %.n]
          pots=~[[0 ~(tap in players.u.lobby)]]
          current-bet=0
          last-bet=0
          board=~
          my-hand=~
          whose-turn=*ship
          dealer=*ship
          small-blind=*ship
          big-blind=*ship
          spectators-allowed.u.lobby
          spectators=~
          hands-played=0
          update-message=["Pokur game started, hosted by {<our.bowl>}" ~]
      ==
    =/  =host-table-state
      :*  hands=~
          deck=(shuffle-deck generate-deck eny.bowl)
          hand-is-over=%.y
          turn-timer=(add now.bowl turn-time-limit.u.lobby)
          table
      ==
    =^  cards  state
      (initialize-new-hand host-table-state)
    ^-  (quip card _state)
    :_  state
    %+  welp  cards
    %+  welp
      :~  :*  %pass  /timer/(scot %da id.table)
              %arvo  %b  %wait
              turn-timer.host-table-state
      ==  ==
    ?.  ?=(%tournament -.game-type.u.lobby)  ~
    :~  :*  %pass  /timer/(scot %da id.table)/round-timer
            %arvo  %b  %wait
            (add now.bowl round-duration.game-type.u.lobby)
    ==  ==
  ::
      %leave-game
    ::  player leaves game
    ?~  host-table=(~(get by tables.state) id.action)
      !!
    :: remove sender from their game
    =.  u.host-table
      (~(remove-player modify-table-state u.host-table) src.bowl)
    =*  table  table.u.host-table
    :: remove spectator if they were one
    =.  spectators.table
      (~(del in spectators.table) src.bowl)
    :-  (send-game-updates u.host-table)
    state(tables (~(put by tables.state) id.action u.host-table))
  ::
      %kick-player
    ::  src must be lobby leader
    ?~  lobby=(~(get by lobbies.state) id.action)
      !!
    ?>  =(leader.u.lobby src.bowl)
    =.  players.u.lobby
      (~(del in players.u.lobby) who.action)
    :_  state(lobbies (~(put by lobbies.state) id.action u.lobby))
    :_  ~
    :^  %give  %fact  ~[/lobby-updates/(scot %da id.u.lobby)]
    [%pokur-host-update !>(`host-update`[%lobby u.lobby])]
  ==
::
::  +send-game-updates: make update cards for players and spectators
::
++  send-game-updates
  |=  host-table=host-table-state
  ^-  (list card)
  =*  table  table.host-table
  %+  weld
    %+  turn  ~(tap by hands.host-table)
    |=  [=ship hand=pokur-deck]
    ^-  card
    :^  %give  %fact  ~[/table-update/(scot %da id.table)/(scot %p ship)]
    [%pokur-host-update !>(`host-update`[%table table(my-hand hand)])]
  %+  turn  ~(tap in spectators.table)
  |=  =ship
  ^-  card
  :^  %give  %fact  ~[/table-update/(scot %da id.table)/(scot %p ship)]
  [%pokur-host-update !>(`host-update`[%table table])]
::
++  initialize-new-hand
  |=  host-table=host-table-state
  ^-  (quip card _state)
  =.  deck.host-table
    (shuffle-deck deck.host-table eny.bowl)
  =.  host-table
    %-  ~(initialize-hand modify-table-state host-table)
    dealer.table.host-table
  :-  (send-game-updates host-table)
  state(tables (~(put by tables.state) id.table.host-table host-table))
::
++  end-game
  |=  host-table=host-table-state
  ^-  (quip card _state)
  :_  state(tables (~(del by tables.state) id.table.host-table))
  :_  ~
  :*  %pass  /timer/(scot %da id.table.host-table)
      %arvo  %b  %rest
      turn-timer.host-table
  ==
--
