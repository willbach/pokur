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
      (handle-player-action:hc !<(player-action vase))
        %pokur-game-action
      ::  checks, bets, folds inside table
      (handle-game-action:hc !<(game-action vase))
        %pokur-host-action
      ::  internal pokes and host management
      (handle-host-action:hc !<(host-action vase))
    ==
  [cards this]
++  on-watch
  |=  =path
  ^-  (quip card _this)
  ?+    path  (on-watch:def path)
      [%lobby-updates ~]
    :_  this  :_  ~
    :^  %give  %fact  ~
    !>(`host-update`[%lobbies-available ~(val by lobbies.state)])
  ::
      [%lobby-updates @ ~]
    ::  updates about a specific lobby
    =/  lobby-id  (slav %da i.t.wire)
    ?~  lobby=(~(get by lobbies.state) lobby-id)
      !!
    :_  this  :_  ~
    :^  %give  %fact  ~[wire]
    !>(`host-update`[%lobby u.lobby])
  ::
      [%table-updates @ @ ~]
    ::  assert the player is in game and on their path
    =/  table-id  (slav %da i.t.path)
    =/  player  (slav %p i.t.t.path)
    ?>  =(player src.bowl)
    ?~  host-table=(~(get by tables.state) u.table-id)
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
        %+  snoc
          spectators.table.u.host-table
        src.bowl
      :_  this(tables (~(put by tables) u.table-id host-table))
      :_  ~
      :^  %give  %fact  path
      [%table !>(table.u.host-table)]
    ::  give table state to a player
    =.  my-hand.table.u.host-table
      (fall (~(get by hands.u.host-table) src.bowl) ~)
    :_  this
    :_  ~
    :^  %give  %face  path
    [%table !>(table.u.host.table)]
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
      (end-game u.host-table)
    =.  table  ~(increment-current-round modify-table-state table)
    :_  this(tables (~(put by tables) table-id u.host-table))
    %+  snoc
      (send-game-updates u.host-table)
    ::  set new round timer
    :*  %pass  /timer/(scot %da table-id)/round-timer
        %arvo  %b  %wait
        (add now.bowl (need round-duration.table))
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
      (end-game u.host-table)
    :: reset that game's turn timer
    =:  turn-timer.table  ~
        update-message.table
      ["{<whose-turn.game.game>} timed out." ~]
    ==
    :_  this(tables (~(put by tables) table-id u.host-table))
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
  ^-  (quip card state)
  ?-    -.action
      %set-escrow-info
    `state(my-info `+.action)
  ==
::
++  handle-game-action
  |=  action=game-action
  ^-  (quip card state)
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
  =.  turn-timer.table  new-timer
  =.  tables.state
    %+  ~(put by tables.state)  id.table
    %=    u.host-table
        table
      (~(process-player-action modify-table-state table) from action)
    ==
  =^  cards  state
    ?.  game-is-over.table
      ?.  hand-is-over.table
        (send-game-updates u.host-table)^state
      (initialize-new-hand u.host-table)
    (end-game u.host-table)
  :_  state
  %+  weld  cards
  :-  :*  %pass  /timer/(scot %da table-id)
          %arvo  %b  %wait
          new-timer
      ==
  ?~  turn-timer.u.host-table
    :: there's no ongoing timer to cancel, just set new
    ~
  :: there's an ongoing turn timer, cancel it and set fresh one
  :_  ~
  :*  %pass  /timer/(scot %da game-id.action)
      %arvo  %b  %rest
      u.turn-timer.u.host-table
  ==
::
++  handle-player-action
  |=  action=player-action
  ^-  (quip card state)
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
    !>(`host-update`[%lobbies-available ~(val by -)])
  ::
      %join-lobby
    ::  add player to existing lobby
    ?~  lobby=(~(get by lobbies.state) id.action)
      !!
    =.  players.u.lobby
      (~(put in players.u.lobby) src.bowl)
    :_  state(lobbies (~(put by lobbies.state) u.lobby))
    :~  :^  %give  %fact  ~[/lobby-updates/(scot %da id.u.lobby)]
        !>(`host-update`[%lobby u.lobby])
    ==
  ::
      %leave-lobby
    ::  remove player from existing lobby
    ?~  lobby=(~(get by lobbies.state) id.action)
      !!
    ?.  (~(has in players.u.lobby) src.bowl)
      `this
    =.  players.u.lobby
      (~(del in players.u.lobby) src.bowl)
    :_  state(lobbies (~(put by lobbies.state) u.lobby))
    :~  :^  %give  %fact  ~[/lobby-updates/(scot %da id.u.lobby)]
        !>(`host-update`[%lobby u.lobby])
    ==
  ::
      %start-game
    ::  lobby creator starts game
    ?~  lobby=(~(get by lobbies.state) id.action)
      !!
    ?.  =(leader.u.lobby src.bowl)
      !!
    ?.  (gte ~(wyt in players.u.lobby) min-players.u.lobby)
      !!
    (start-game u.lobby)
  ::
      %leave-game
    ::  player leaves game
    ?~  host-table=(~(get by tables.state) id.action)
      !!
    =*  table  table.u.host-table
    :: remove sender from their game
    =.  table  (~(remove-player modify-table-state table) src.bowl)
    :: remove spectator if they were one
    =.  spectators.table
      (~(del in spectators.table) src.bowl)
    :-  (send-game-updates u.host-table)
    state(tables (~(put by tables.state) id.action u.host-table))
  ==
::
::  +send-game-updates: make update cards for players and spectators
::
++  send-game-updates
  |=  host-table=host-table-state
  ^-  (list card)
  =*  table  table.u.host-table
  :_  state
  %+  weld
    %+  turn  ~(tap by hands.u.host-table)
    |=  [=ship hand=pokur-deck]
    ^-  card
    =+  /table-update/(scot %da id.table)/(scot %p ship)
    :^  %give  %fact  -
    :-  %pokur-host-update
    !>(`host-update`[%table table(my-hand hand)])
  %+  turn  ~(tap in spectators.table)
  |=  =ship
  ^-  card
  =+  /table-update/(scot %da id.table)/(scot %p ship)
  :^  %give  %fact  -
  [%pokur-host-update !>(`host-update`[%table table])]
::
++  initialize-new-hand
  |=  host-table=host-table-state
  ^-  (quip card state)
  =.  deck.host-table
    (shuffle-deck deck.host-table eny.bowl)
  =.  table.host-table
    %-  ~(initialize-hand modify-table-state table.host-table)
    dealer.table.host-table
  :-  (send-game-updates host-table)
  state(tables (~(put by tables.state) id.table.host-table host-table))
::
++  start-game
  |=  =lobby
  ^-  (quip card state)
  ~&  >  "%pokur-host: starting new game {<id.lobby>}"
  =/  =table
    :*  id.lobby
        game-is-over=%.n
        game-type.lobby(current-round 0, round-is-over %.n)
        turn-time-limit.lobby
        %-  malt
        %+  turn  ~(tap in players.lobby)
        |=  =ship
        [ship starting-stack.game-type.lobby 0 %.n %.n %.n]
        pots=~[[0 ~(tap in players.lobby)]]
        current-bet=0
        last-bet=0
        board=~
        my-hand=~
        whose-turn=*ship
        dealer=*ship
        small-blind=*ship
        big-blind=*ship
        spectators-allowed.lobby
        spectators=~
        hands-played=0
        update-message=["Pokur game started, hosted by {<our.bowl>}" ~]
    ==
  =/  =host-table-state
    :*  hands=~
        deck=(shuffle-deck generate-deck eny.bowl)
        hand-is-over=%.y
        turn-timer=(add now.bowl turn-time-limit.lobby)
        table
    ==
  =^  cards  state
    (initialize-new-hand host-table-state)
  :_  state
  %+  weld
    :~  :*  %pass  /timer/(scot %da table-id)
            %arvo  %b  %wait
            turn-timer.host-table
    ==  ==
  ?.  ?=(%tournament game-type.table)  ~
  :~  :*  %pass  /timer/(scot %da table-id)/round-timer
          %arvo  %b  %wait
          (add now.bowl round-duration.game-type.table)
  ==  ==
::
++  end-game
  |=  host-table=host-table-state
  ^-  (quip card state)
  :_  state(tables (~(del by tables.state) id.table.host-table))
  :~  :*  %pass  /timer/(scot %da id.table.host-table)
          %arvo  %b  %rest
          turn-timer.host-table
  ==  ==
--
