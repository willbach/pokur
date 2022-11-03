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
+*  this  .
    def   ~(. (default-agent this %|) bowl)
    hc    ~(. +> bowl)
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
  [cards this]
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
    :_  this  :_  ~
    :^  %give  %fact  ~[/lobby-updates]
    [%pokur-update !>(`update`[%lobby u.lobby.state])]
  ::
      [%table-updates ~]
    ?~  table.state  `this
    :_  this  :_  ~
    :^  %give  %fact  ~[/table-updates]
    [%pokur-update !>(`update`[%table u.table.state "-"])]
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
      [%start-lobby-poke @ ~]
    ?.  ?=(%poke-ack -.sign)  (on-agent:def wire sign)
    ?^  p.sign  !!  ::  TODO new lobby poke failed!
    :_  this  :_  ~
    :*  %pass  /lobby-updates/[i.t.wire]
        %agent  [(need host.state) %pokur-host]
        %watch  /lobby-updates/[i.t.wire]
    ==
  ::
      [%table-updates @ @ ~]
    ?.  ?=(%fact -.sign)
      ?+    -.sign  (on-agent:def wire sign)
          %watch-ack
        ?~  p.sign
          ~&  >  "%pokur: watched table hosted by {<src.bowl>}"
          `this
        ~&  >>>  "%pokur: failed to watch table updates path!"
        ~&  >>>  u.p.sign
        `this
      ::
          %kick
        ::  resub on kick
        :_  this  :_  ~
        [%pass wire %agent [src.bowl %pokur-host] %watch wire]
      ==
    =/  upd  !<(host-update q.cage.sign)
    ?>  ?=(%table -.upd)
    =/  my-hand-rank=tape
      %-  hierarchy-to-rank
      =/  full-hand  (weld my-hand.+.upd board.+.upd)
      ?+  (lent full-hand)  100
        %5  (evaluate-5-card-hand full-hand)
        %6  -:(evaluate-6-card-hand full-hand)
        %7  -:(evaluate-7-card-hand full-hand)
      ==
    :_  this(table.state `+.upd)  :_  ~
    :^  %give  %fact  ~[/table-updates]
    [%pokur-update !>(`update`[%table +.upd my-hand-rank])]
  ::
      [%lobby-updates ~]
    ?+    -.sign  (on-agent:def wire sign)
        %watch-ack
      ?~  p.sign
        ~&  >  "%pokur: joined host {<src.bowl>}"
        `this(host.state `src.bowl)
      ~&  >>>  "%pokur: tried to join host {<src.bowl>}, failed"
      ~&  >>>  u.p.sign
      `this
    ::
        %kick
      ::  resub on kick
      :_  this  :_  ~
      [%pass wire %agent [src.bowl %pokur-host] %watch wire]
    ::
        %fact
      =/  upd  !<(host-update q.cage.sign)
      ?+    -.upd  (on-agent:def wire sign)
          %lobbies-available
        :_  this  :_  ~
        :^  %give  %fact  ~[/lobby-updates]
        [%pokur-update !>(`update`upd)]
      ==
    ==
  ::
      [%lobby-updates @ ~]
    ::  information about a specific lobby we're in
    =/  lobby-id  (slav %da i.t.wire)
    ::  ignore updates about lobby we're not in
    ?~  lobby.state  `this
    ?.  =(lobby-id id.u.lobby.state)  `this
    ?+    -.sign  (on-agent:def wire sign)
        %watch-ack
      ::  TODO handle acks and nacks if needed
      `this
    ::
        %kick
      ::  resub on kick
      :_  this  :_  ~
      [%pass wire %agent [src.bowl %pokur-host] %watch wire]
    ::
        %fact
      =/  upd  !<(host-update q.cage.sign)
      ?+    -.upd  (on-agent:def wire sign)
          %lobby
        :_  this(lobby.state `+.upd)
        :_  ~
        :^  %give  %fact  ~[/lobby-updates]
        [%pokur-update !>(`update`[%lobby +.upd])]
      ::
          %game-starting
        =/  path  /table-updates/(scot %da table-id.upd)/(scot %p our.bowl)
        :_  this(lobby.state ~)  :_  ~
        [%pass path %agent [src.bowl %pokur-host] %watch path]
      ==
    ==
  ==
++  on-peek
  ::  TODO scries
  on-peek:def
++  on-arvo  on-arvo:def
++  on-leave  on-leave:def
++  on-fail  on-fail:def
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
        %agent  [u.host.state %pokur-host]
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
    :*  %pass  /start-lobby-poke
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
    :~  :*  %pass  /lobby-poke
            %agent  [u.host.state %pokur-host]
            %poke  %pokur-player-action  !>(action)
        ==
        :*  %pass  /lobby-updates/(scot %da id.action)
            %agent  [u.host.state %pokur-host]
            %watch  /lobby-updates/(scot %da id.action)
    ==  ==
  ::
      %leave-lobby
    ?~  host.state
      ~|("%pokur: error: can't leave lobby, no host" !!)
    ?~  lobby.state
      ~|("%pokur: error: can't leave lobby, not in one" !!)
    :_  state(lobby ~, messages ~)
    :~  :*  %pass  /lobby-poke
            %agent  [u.host.state %pokur-host]
            %poke  %pokur-player-action  !>(action)
        ==
        :*  %pass  /lobby-updates/(scot %da id.u.lobby.state)
            %agent  [u.host.state %pokur-host]
            %leave  ~
    ==  ==
  ::
      %start-game
    ?~  host.state
      ~|("%pokur: error: can't start game, no host" !!)
    ?~  lobby.state
      ~|("%pokur: error: can't start game, not in a lobby" !!)
    ?^  table.state
      ~|("%pokur: error: can't start game, already in one" !!)
    :_  state(lobby ~, messages ~)
    :~  :*  %pass  /lobby-poke
            %agent  [u.host.state %pokur-host]
            %poke  %pokur-player-action  !>(action)
        ==
        :*  %pass  /lobby-updates/(scot %da id.u.lobby.state)
            %agent  [u.host.state %pokur-host]
            %leave  ~
    ==  ==
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
    :_  state(messages [[src.bowl msg.action] messages.state])
    %+  turn
      ?~  table.state
        ?~  lobby.state
          !!
        ~(tap in players.u.lobby.state)
      (turn players.u.table.state head)
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
        ?=(^ (find [src.bowl]~ (turn players.u.table.state head)))
    :_  state(messages [[src.bowl msg.action] messages.state])
    :_  ~
    :^  %give  %fact  ~[/messages]
    [%pokur-update !>(`update`[%new-message src.bowl msg.action])]
  ==
::
++  handle-game-action
  |=  action=game-action
  ^-  (quip card _state)
  ?>  =(src.bowl our.bowl)
  ?~  table.state  !!
  :_  state
  :_  ~
  :^  %pass  /poke-wire  %agent
  :^  [(need host.state) %pokur-host]
    %poke  %pokur-game-action
  ?-  -.action
    %check  !>(`game-action`[%check id.u.table.state ~])
    %fold   !>(`game-action`[%fold id.u.table.state ~])
    %bet    !>(`game-action`[%bet id.u.table.state amount.action])
  ==
--
