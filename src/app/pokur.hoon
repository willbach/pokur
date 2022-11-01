/-  *pokur
/+  default-agent, dbug, *pokur
|%
+$  card  card:agent:gall
+$  versioned-state  $%(state-0)
+$  state-0
  $:  %0
      host=(unit ship)
      table=(unit table)
      lobby=(unit lobby)
      messages=(list [=ship =tape])
  ==
--
%-  agent:dbug
=|  state=state-0
^-  agent:gall
=<
|_  =bowl:gall
+*  this      .
    def      ~(. (default-agent this %|) bowl)
    hc       ~(. +> bowl)
::
++  on-init
  ^-  (quip card _this)
  `this(state [%0 ~ ~ ~ ~])  ::  TODO add default host ~bacrys here
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
      (handle-player-action:hc !<(player-action vase))
        %pokur-message-action
      (handle-message-action:hc !<(message-action vase))
        %pokur-game-action
      (handle-game-action:hc !<(game-action vase))
    ==
  ==
++  on-watch
  |=  =path
  ^-  (quip card _this)
  ::
  ::  all subscriptions are from our frontend
  ::
  ?>  =(src.bowl our.bowl)
  ?+    path  (on-watch:def path)
      [%lobby-updates ~]
    ?~  lobby.state  `this
    :^  %give  %fact  ~[/lobby-updates]
    [%pokur-update !>(`update`[%lobby-update u.lobby.state])]
  ::
      [%table-updates ~]
    ?~  table.state  `this
    :_  this
    :_  ~
    :^  %give  %fact  ~[/table-updates]
    [%pokur-update !>(`update`[%table-update u.table.state "-"])]
  ::
      [%messages ~]
    ::  don't send all messages, rather scry for those and
    ::  send subsequent messages along this path
    `this
  ==
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  ::
  ::  all updates are from our subscription(s) to host ship
  ::  receive updates about lobbies and active table here
  ::
  ?+    wire  (on-agent:def wire sign)
      [%table-updates ~]
    ?.  ?=(%fact -.sign)
      ?+    -.sign  (on-agent:def wire sign)
          %watch-ack
        ?~  p.sign
          ~&  >  "%pokur: watched table hosted by {<src.bowl>}"
          `this
        ~&  >>>  "%pokur: failed to watch table updates path!"
        `this
      ::
          %kick
        ::  resub on kick
        :_  this
        :_  ~
        :*  %pass  /table-updates
            %agent  [src.bowl %pokur-host]
            %watch  /table-updates
        ==
      ==
    =/  new  !<(table q.cage.sign)
    =/  my-hand=tape
      %-  hierarchy-to-rank
      =/  full-hand  (weld my-hand.new board.new)
      ?+  (lent full-hand)  "-"
        %5  (eval-5-cards full-hand)
        %6  (eval-6-cards full-hand)
        %7  -:(evaluate-hand full-hand)
      ==
    :_  this(table new)
    :_  ~
    :^  %give  %fact  ~[/table-updates]
    [%pokur-update !>(`update`[%update new my-hand])]
  ::
      [%lobby-updates ~]
    ?+    -.sign  (on-agent:def wire sign)
        %watch-ack
      ?~  p.sign
        ~&  >  "%pokur: joined host {<src.bowl>}"
        `this(host `src.bowl)
      ~&  >>>  "%pokur: tried to join host {<src.bowl>}, failed"
      `this
    ::
        %kick
      ::  resub on kick
      :_  this
      :_  ~
      :*  %pass  /lobby-updates
          %agent  [src.bowl %pokur-host]
          %watch  /lobby-updates
      ==
    ::
        %fact
      =/  upd  !<(host-update cage.sign)
      ?+    -.upd  (on-agent:def wire sign)
          %lobby-update
        :_  this(lobby `+.upd)
        :_  ~
        :^  %give  %fact  ~[/lobby-updates]
        [%pokur-update !>(`update`[%lobby-update new])]
      ::
          %lobbies-available
        :_  this
        :_  ~
        :^  %give  %fact  ~[/lobby-updates]
        [%pokur-update !>(`update`upd)]
      ==
    ==
  ==
++  on-arvo  on-arvo:def
++  on-fail  on-fail:def
++  on-leave  on-leave:def
++  on-peek
  ::  TODO scries
  on-peek:def
--
::
::  start helper cores
::
|_  bowl=bowl:gall
++  handle-player-action
  |=  action=player-action
  ^-  (quip card _state)
  ?>  =(src.bowl our.bowl)
  ?-    -.action
      %join-host
    ?^  host.state
      ~|("%pokur: error: already in a host" !!)
    :_  state  ::  host set in %watch-ack
    :_  ~
    :*  %pass  /lobby-updates
        %agent  [host.action %pokur-host]
        %watch  /lobby-updates
    ==
  ::
      %leave-host
    ?~  host.state
      ~|("%pokur: error: can't leave host, don't have one" !!)
    :_  state(lobby ~, table ~, host ~)
    :_  ~
    :*  %pass  /lobby-updates
        %agent  [host.action %pokur-host]
        %leave  ~
    ==
  ::
      %new-lobby
    ::  start a lobby in our current host, and if game is to be
    ::  tokenized, create a transaction to start a new escrow
    ::  bond with host as custodian of funds
    ?~  host.state
      ~|("%pokur: error: can't start lobby, no host" !!)
    ?^  lobby.state
      ~|("%pokur: error: can't start lobby, already in one" !!)
    ?^  table.state
      ~|("%pokur: error: can't start lobby, already in game" !!)
    :_  state
    ::  TODO build transaction poke to %uqbar
    :_  ~
    :*  %pass  /lobby-poke
        %agent  [u.host.state %pokur-host]
        %poke  %pokur-player-action  !>(action)
    ==
  ::
      %join-lobby
    ::  join a lobby in our current host
    ?~  host.state
      ~|("%pokur: error: can't join lobby, no host" !!)
    ?^  lobby.state
      ~|("%pokur: error: can't join lobby, already in one" !!)
    ?^  table.state
      ~|("%pokur: error: can't join lobby, already in game" !!)
    :_  state
    :_  ~
    :*  %pass  /lobby-poke
        %agent  [u.host.state %pokur-host]
        %poke  %pokur-player-action  !>(action)
    ==
  ::
      %leave-lobby
    ?~  host.state
      ~|("%pokur: error: can't leave lobby, no host" !!)
    ?~  lobby.state
      ~|("%pokur: error: can't leave lobby, not in one" !!)
    :_  state(lobby ~, messages ~)
    :_  ~
    :*  %pass  /lobby-poke
        %agent  [u.host.state %pokur-host]
        %poke  %pokur-player-action  !>(action)
    ==
  ::
      %start-game
    ?~  host.state
      ~|("%pokur: error: can't start game, no host" !!)
    ?~  lobby.state
      ~|("%pokur: error: can't start game, not in a lobby" !!)
    ?^  table.state
      ~|("%pokur: error: can't start game, already in one" !!)
    :_  state(lobby ~, messages ~)
    :_  ~
    :*  %pass  /lobby-poke
        %agent  [u.host.state %pokur-host]
        %poke  %pokur-player-action  !>(action)
    ==
  ::
      %leave-game
    ?~  host.state
      ~|("%pokur: error: can't leave game, no host" !!)
    ?~  table.state
      ~|("%pokur: error: can't leave game, not in one" !!)
    :_  state(table ~, messages ~)
    :_  ~
    :*  %pass  /lobby-poke
        %agent  [u.host.state %pokur-host]
        %poke  %pokur-player-action  !>(action)
    ==
  ::
      %add-escrow
    ::  TODO poke wallet with transaction to escrow contract
    !!
  ::
  ==
::
++  handle-message-action
  |=  action=message-action
  ^-  (quip card _state)
  ?-    -.action
      %send-message
    ?>  =(src.bowl our.bowl)
    ::  if in lobby, send to everyone in lobby
    ::  if in game, send to everyone in game
    :_  state(messages [[src.bowl msg.action] messages])
    %+  turn
      ?~  table.state
        ?~  lobby.state
          !!
        ~(tap in players.u.lobby.state)
      ~(key by players.u.game.state)
    |=  =ship
    ^-  card
    :*  %pass  /message-poke  %agent  [ship %pokur]
        %poke  %pokur-message-action
        !>(`message-action`[%receive-message msg.action])
    ==
  ::
      %receive-message
    ::  add to our message store and forward to frontend
    ::  if in lobby, only accept messages from players in lobby
    ::  if in game, only accept from players in game
    ?>  ?~  table.state
          ?~  lobby.state
            %.n
          (~(has in players.u.lobby.state) src.bowl)
        (~(has by players.u.table.state) src.bowl)
    :_  state(messages [[src.bowl msg.action] messages])
    :_  ~
    :^  %give  %fact  ~[/messages]
    [%pokur-update !>(`update`[%new-message src.bowl msg.action])]
  ==
::
++  handle-game-action
  |=  action=game-action
  ^-  (quip card _state)
  ?>  =(src.bowl our.bowl)
  ?~  game.state
    :_  state
    =+  [%give %poke-ack `~[-]]~
    leaf+"Error: can't process action, not in game yet."
  :_  state
  :_  ~
  :^  %pass  /poke-wire  %agent
  :^  [(need host.state) %pokur-host]
    %poke  %pokur-game-action
  ?-  -.action
    %check  !>(`game-action`[%check game-id.u.game.state])
    %bet    !>(`game-action`[%bet game-id.u.game.state amount.action])
    %fold   !>(`game-action`[%fold game-id.u.game.state])
  ==
--
