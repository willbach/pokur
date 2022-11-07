/-  *pokur
/+  default-agent, dbug, *pokur, pokur-json
|%
+$  card  card:agent:gall
+$  versioned-state  $%(state-0)
+$  state-0
  $:  %0
      host=(unit [=ship info=(unit host-info)])
      game=(unit game)
      table=(unit table)
      messages=(list [=ship msg=@t])
      muted-players=(set ship)
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
  `this(state [%0 ~ ~ ~ ~ ~])  ::  TODO add default host ~bacrys here
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
        %pokur-host-action
      (handle-host-action:hc !<(host-action vase))
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
    `this  ::  forward available tables from host here
  ::
      [%table-updates ~]
    ?~  table.state  `this
    :_  this  :_  ~
    :^  %give  %fact  ~[/table-updates]
    [%pokur-update !>(`update`[%table u.table.state])]
  ::
      [%game-updates ~]
    ?~  game.state  `this
    :_  this  :_  ~
    :^  %give  %fact  ~[/game-updates]
    [%pokur-update !>(`update`[%game u.game.state '-'])]
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
  ::  receive updates about lobbies and active game here
  ::
  ?+    wire  (on-agent:def wire sign)
      [%start-table-poke @ ~]
    ?.  ?=(%poke-ack -.sign)  (on-agent:def wire sign)
    ?^  p.sign  !!  ::  TODO new table poke failed!
    :_  this  :_  ~
    :*  %pass  /table-updates/[i.t.wire]
        %agent  [-:(need host.state) %pokur-host]
        %watch  /table-updates/[i.t.wire]
    ==
  ::
      [%game-updates @ @ ~]
    ?.  ?=(%fact -.sign)
      ?+    -.sign  (on-agent:def wire sign)
          %watch-ack
        ?~  p.sign
          ~&  >  "%pokur: watched game hosted by {<src.bowl>}"
          `this
        ~&  >>>  "%pokur: failed to watch game updates path!"
        `this
      ::
          %kick
        ::  resub on kick
        :_  this  :_  ~
        [%pass wire %agent [src.bowl %pokur-host] %watch wire]
      ==
    ?>  ?=(%pokur-host-update p.cage.sign)
    =/  upd  !<(host-update q.cage.sign)
    ?>  ?=(%game -.upd)
    ~&  >  "new game state:"
    ~&  >  game.upd
    =/  my-hand-rank=@t
      %-  hierarchy-to-rank
      =/  full-hand  (weld my-hand.game.upd board.game.upd)
      ?+  (lent full-hand)  100
        %5  (evaluate-5-card-hand full-hand)
        %6  -:(evaluate-6-card-hand full-hand)
        %7  -:(evaluate-7-card-hand full-hand)
      ==
    :_  this(game.state `game.upd)  :_  ~
    :^  %give  %fact  ~[/game-updates]
    [%pokur-update !>(`update`[%game game.upd my-hand-rank])]
  ::
      [%lobby-updates ~]
    ?+    -.sign  (on-agent:def wire sign)
        %watch-ack
      ?~  p.sign
        ~&  >  "%pokur: joined host {<src.bowl>}"
        `this(host.state `[src.bowl ~])
      ~&  >>>  "%pokur: tried to join host {<src.bowl>}, failed"
      `this
    ::
        %kick
      ::  resub on kick
      :_  this  :_  ~
      [%pass wire %agent [src.bowl %pokur-host] %watch wire]
    ::
        %fact
      ?>  ?=(%pokur-host-update p.cage.sign)
      =/  upd  !<(host-update q.cage.sign)
      ?+    -.upd  (on-agent:def wire sign)
          %lobby
        ~&  >>  "tables available: {<+.upd>}"
        :_  this  :_  ~
        :^  %give  %fact  ~[/lobby-updates]
        [%pokur-update !>(`update`upd)]
      ==
    ==
  ::
      [%table-updates @ ~]
    ::  information about a specific table we're in
    =/  table-id  (slav %da i.t.wire)
    ::  ignore updates about table we're not in, if in one
    ?.  ?~  table.state  %.y
        =(table-id id.u.table.state)
      `this
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
      ?>  ?=(%pokur-host-update p.cage.sign)
      =/  upd  !<(host-update q.cage.sign)
      ?+    -.upd  (on-agent:def wire sign)
          %table
        ~&  >  "new table state:"
        ~&  >  table.upd
        :_  this(table.state `table.upd)
        :_  ~
        :^  %give  %fact  ~[/table-updates]
        [%pokur-update !>(`update`[%table table.upd])]
      ::
          %game-starting
        :_  this(table.state ~)
        :~  =+  /game-updates/(scot %da game-id.upd)/(scot %p our.bowl)
            [%pass - %agent [src.bowl %pokur-host] %watch -]
            =+  /table-updates/(scot %da game-id.upd)
            [%pass - %agent [src.bowl %pokur-host] %leave ~]
            :^  %give  %fact  ~[/table-updates]
            [%pokur-update !>(`update`[%game-starting game-id.upd])]
        ==
      ==
    ==
  ==
++  on-peek
  |=  =path
  ^-  (unit (unit cage))
  ?.  =(%x -.path)  ~
  ?+    +.path  (on-peek:def path)
      [%game-id ~]
    ``noun+!>(?~(game.state ~ `id.u.game.state))
      [%game ~]
    ``json+!>(?~(game.state ~ (enjs-game:pokur-json u.game.state)))
      [%table ~]
    ``json+!>(?~(table.state ~ (enjs-table:pokur-json u.table.state)))
      [%messages ~]
    ``json+!>((enjs-messages:pokur-json messages.state))
      [%muted-players ~]
    ``json+!>(a+(turn ~(tap in muted-players.state) ship:enjs:format))
  ==
++  on-arvo  on-arvo:def
++  on-leave  on-leave:def
++  on-fail  on-fail:def
--
::
::  start helper cores
::
|_  bowl=bowl:gall
++  handle-host-action
  |=  action=host-action
  ^-  (quip card _state)
  ?-    -.action
      %escrow-info
    ::  receive host-info from host
    ?~  host.state  !!
    ?>  =(ship.u.host.state src.bowl)
    `state(host `[src.bowl `+.action])
  ==
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
    :_  state(table ~, game ~, host ~)
    :_  ~
    :*  %pass  /lobby-updates
        %agent  [ship.u.host.state %pokur-host]
        %leave  ~
    ==
  ::
      %new-table
    ::  start a table in our current host, and if game is to be
    ::  tokenized, create a transaction to start a new escrow
    ::  bond with host as custodian of funds
    ?~  host.state
      ~|("%pokur: error: can't start table, no host" !!)
    ?^  table.state
      ~|("%pokur: error: can't start table, already in one" !!)
    ?^  game.state
      ~|("%pokur: error: can't start table, already in game" !!)
    ::  add our.bowl to time in order to disambiguate the unlikely
    ::  scenario of two lobbies started at exact same time
    =.  id.action  (add now.bowl `@ud`our.bowl)
    :_  state
    ::  TODO build transaction poke to %uqbar
    :_  ~
    :*  %pass  /start-table-poke/(scot %da id.action)
        %agent  [ship.u.host.state %pokur-host]
        %poke  %pokur-player-action  !>(action)
    ==
  ::
      %join-table
    ::  join a table in our current host
    ?~  host.state
      ~|("%pokur: error: can't join table, no host" !!)
    ?^  table.state
      ~|("%pokur: error: can't join table, already in one" !!)
    ?^  game.state
      ~|("%pokur: error: can't join table, already in game" !!)
    :_  state
    :~  :*  %pass  /table-poke
            %agent  [ship.u.host.state %pokur-host]
            %poke  %pokur-player-action  !>(action)
        ==
        :*  %pass  /table-updates/(scot %da id.action)
            %agent  [ship.u.host.state %pokur-host]
            %watch  /table-updates/(scot %da id.action)
    ==  ==
  ::
      %leave-table
    ?~  host.state
      ~|("%pokur: error: can't leave table, no host" !!)
    ?~  table.state
      ~|("%pokur: error: can't leave table, not in one" !!)
    :_  state(table ~, messages ~)
    :~  :*  %pass  /table-poke
            %agent  [ship.u.host.state %pokur-host]
            %poke  %pokur-player-action  !>(action)
        ==
        :*  %pass  /table-updates/(scot %da id.u.table.state)
            %agent  [ship.u.host.state %pokur-host]
            %leave  ~
    ==  ==
  ::
      %start-game
    ?~  host.state
      ~|("%pokur: error: can't start game, no host" !!)
    ?~  table.state
      ~|("%pokur: error: can't start game, not in a table" !!)
    ?^  game.state
      ~|("%pokur: error: can't start game, already in one" !!)
    :_  state(table ~, messages ~)
    :_  ~
    :*  %pass  /table-poke
        %agent  [ship.u.host.state %pokur-host]
        %poke  %pokur-player-action  !>(action)
    ==
  ::
      %leave-game
    ?~  host.state
      ~|("%pokur: error: can't leave game, no host" !!)
    ?~  game.state
      ~|("%pokur: error: can't leave game, not in one" !!)
    :_  state(game ~, messages ~)
    :~  :*  %pass
            /game-updates/(scot %da id.action)/(scot %p our.bowl)
            %agent  [ship.u.host.state %pokur-host]
            %leave  ~
        ==
        :*  %pass  /table-poke
            %agent  [ship.u.host.state %pokur-host]
            %poke  %pokur-player-action  !>(action)
    ==  ==
  ::
      %kick-player
    ?~  host.state
      ~|("%pokur: error: can't edit table, no host" !!)
    ?~  table.state
      ~|("%pokur: error: can't edit table, not in one" !!)
    :_  state
    :_  ~
    :*  %pass  /table-poke
        %agent  [ship.u.host.state %pokur-host]
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
      %mute
    ?>  =(src.bowl our.bowl)
    `state(muted-players (~(put in muted-players.state) who.action))
  ::
      %unmute
    ?>  =(src.bowl our.bowl)
    `state(muted-players (~(del in muted-players.state) who.action))
  ::
      %send-message
    ?>  =(src.bowl our.bowl)
    ::  if in table, send to everyone in table
    ::  if in game, send to everyone in game
    :_  state(messages [[src.bowl msg.action] messages.state])
    %+  turn
      ?~  game.state
        ?~  table.state
          !!
        ~(tap in players.u.table.state)
      (turn players.u.game.state head)
    |=  =ship
    ^-  card
    :*  %pass  /message-poke  %agent  [ship %pokur]
        %poke  %pokur-message-action
        !>(`message-action`[%receive-message msg.action])
    ==
  ::
      %receive-message
    ::  add to our message store and forward to frontend
    ::  if in table, only accept messages from players in table
    ::  if in game, only accept from players in game
    ?>  ?~  game.state
          ?~  table.state
            %.n
          (~(has in players.u.table.state) src.bowl)
        ?=(^ (find [src.bowl]~ (turn players.u.game.state head)))
    ::  skip messages from muted players
    ?:  (~(has in muted-players.state) src.bowl)  `state
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
  ?~  game.state  !!
  :_  state
  :_  ~
  :^  %pass  /poke-wire  %agent
  :^  [-:(need host.state) %pokur-host]
    %poke  %pokur-game-action
  ?-  -.action
    %check  !>(`game-action`[%check id.u.game.state ~])
    %fold   !>(`game-action`[%fold id.u.game.state ~])
    %bet    !>(`game-action`[%bet id.u.game.state amount.action])
  ==
--
