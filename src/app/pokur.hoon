/-  *pokur, indexer=zig-indexer, wallet=zig-wallet
/+  default-agent, dbug, *pokur, pokur-json, smart=zig-sys-smart
|%
+$  card  card:agent:gall
+$  versioned-state  $%(state-0)
::  HARDCODED to ~bacrys IRL, ~zod in FAKESHIP TESTING
++  fixed-lobby-source  ~zod
+$  state-0
  $:  %0
      known-hosts=(map ship host-info)
      our-address=(unit @ux)
      lobby-source=ship
      lobby=(map @da table)
      our-table=(unit @da)
      game=(unit game)
      game-host=(unit ship)
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
  :_  this(state [%0 ~ ~ fixed-lobby-source ~ ~ ~ ~ ~ ~])
  :_  ~
  :*  %pass  /lobby-updates
      %agent  [fixed-lobby-source %pokur-host]
      %watch  /lobby-updates
  ==
++  on-save
  ^-  vase
  !>(state)
++  on-load
  |=  old=vase
  ^-  (quip card _this)
  :_  this(state !<(versioned-state old))
  ::  resub to get initial listing
  :~  :*  %pass  /lobby-updates
          %agent  [fixed-lobby-source %pokur-host]
          %leave  ~
      ==
      :*  %pass  /lobby-updates
          %agent  [fixed-lobby-source %pokur-host]
          %watch  /lobby-updates
  ==  ==
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
    ::  forward available tables from host here
    :_  this  :_  ~
    :^  %give  %fact  ~[/lobby-updates]
    [%pokur-update !>(`update`[%lobby lobby.state])]
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
    `this(our-table.state `(slav %da i.t.wire))
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
    ?+    -.upd  (on-agent:def wire sign)
        %game
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
    ::  %game-over
    ::
    ==
  ::
      [%lobby-updates ~]
    ?+    -.sign  (on-agent:def wire sign)
        %watch-ack
      ?~  p.sign
        ~&  >  "%pokur: joined lobby source {<src.bowl>}"
        `this
      ~&  >>>  "%pokur: tried to join lobby source {<src.bowl>}, failed"
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
        ~&  >>  "tables available: {<tables.upd>}"
        ?.  ?&  ?=(^ our-table.state)
                !(~(has by tables.upd) u.our-table.state)
            ==
          :_  this(lobby.state tables.upd)  :_  ~
          :^  %give  %fact  ~[/lobby-updates]
          [%pokur-update !>(`update`upd)]
        ::  if we're in a table and it's no longer in lobby,
        ::  it closed
        :_  this(our-table.state ~, lobby.state tables.upd)
        :~  :^  %give  %fact  ~[/lobby-updates]
            [%pokur-update !>(`update`upd)]
            :^  %give  %fact  ~[/lobby-updates]
            [%pokur-update !>(`update`[%table-closed u.our-table.state])]
        ==
      ::
          %game-starting
        ::  check if it's our game, if so, sub to path and notify FE
        ?~  our-table.state  `this
        ?.  =(game-id.upd u.our-table.state)  `this
        =/  =table  (~(got by lobby.state) u.our-table.state)
        :_  this
        :~  :^  %give  %fact  ~[/game-updates]
            [%pokur-update !>(`update`upd)]
            :*  %pass  /game-updates/(scot %da id.table)/(scot %p our.bowl)
                %agent  [ship.host-info.table %pokur-host]
                %watch  /game-updates/(scot %da id.table)/(scot %p our.bowl)
        ==  ==
      ==
    ==
  ::
      [%thread @ @ ~]
    ::  receive eth block from thread, generate escrow transaction
    ?+    -.sign  (on-agent:def wire sign)
        %fact
      ?+    p.cage.sign  (on-agent:def wire sign)
          %thread-fail
        =/  err  !<  (pair term tang)  q.cage.sign
        %.  `this
        %+  slog
          leaf+"%pokur: get-eth-block thread failed: {(trip p.err)}"
        q.err
          %thread-done
        =/  height=@ud  !<(@ud q.cage.sign)
        ~&  >  "eth-block-height: {<height>}"
        =/  host=ship  (slav %p i.t.t.wire)
        ::  [%new-bond custodian=address timelock=@ud asset-metadata=id]
        ?~  host-info=(~(get by known-hosts.state) host)  !!
        ?~  our-address.state  !!
        =/  default-timelock=@ud  ::  roughly 48 hours
          (add height 14.400)
        =/  asset-metadata=@ux
          (slav %ux i.t.wire)
        :_  this  :_  ~
        :*  %pass  /pokur-wallet-poke
            %agent  [our.bowl %uqbar]
            %poke  %wallet-poke
            !>
            :*  %transaction
                from=u.our-address.state
                contract=id.contract.u.host-info
                town=town.contract.u.host-info
                :-  %noun
                :^    %new-bond
                    address.u.host-info
                  default-timelock
                asset-metadata
            ==
        ==
      ==
    ==
  ==
++  on-peek
  |=  =path
  ^-  (unit (unit cage))
  ?.  =(%x -.path)  ~
  ?+    +.path  (on-peek:def path)
  ::    [%host ~]
  ::  ``json+!>(?~(host.state ~ (enjs-host-ship:pokur-json ship.u.host.state)))
      [%game-id ~]
    ``noun+!>(?~(game.state ~ `id.u.game.state))
      [%game ~]
    ``json+!>(?~(game.state ~ (enjs-game:pokur-json u.game.state)))
      [%messages ~]
    ``json+!>((enjs-messages:pokur-json messages.state))
      [%muted-players ~]
    ``json+!>(a+(turn ~(tap in muted-players.state) ship:enjs:format))
  ::
      [%table @ ~]
    :^  ~  ~  %json
    !>  ?~  our-table.state  ~
        %-  enjs-table:pokur-json
        (~(got by lobby.state) (slav %da i.t.t.path))
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
  ?+    -.action  !!
      %host-info
    ::  receive host-info from host
    ?>  =(src.bowl ship.+.action)
    `state(known-hosts (~(put by known-hosts.state) src.bowl +.action))
  ==
++  handle-player-action
  |=  action=player-action
  ^-  (quip card _state)
  ?>  =(src.bowl our.bowl)
  ?-    -.action
      %new-table
    ::  start a table in our current host, and if game is to be
    ::  tokenized, create a transaction to start a new escrow
    ::  bond with host as custodian of funds
    ?^  our-table.state
      ~|("%pokur: error: can't join table, already in one" !!)
    ?^  game.state
      ~|("%pokur: error: can't join table, already in game" !!)
    =.  id.action  now.bowl
    ?~  tokenized.action
      :_  state  :_  ~
      :*  %pass  /start-table-poke/(scot %da id.action)
          %agent  [fixed-lobby-source %pokur-host]
          %poke  %pokur-player-action  !>(action)
      ==
    ::  generate new escrow bond with host
    ::  [%new-bond custodian=address timelock=@ud asset-metadata=id]
    ::  fetch latest ETH block height to produce timelock
    =/  tid          `@ta`(cat 3 'thread_' (scot %uv (sham eny.bowl)))
    =/  ta-now       (scot %da now.bowl)
    =/  ta-metadata  (scot %ux metadata.u.tokenized.action)
    =/  ta-host      (scot %p host.action)
    =/  start-args  [~ `tid byk.bowl(r da+now.bowl) %get-eth-block !>(~)]
    :_  state
    :~  :*  %pass  /thread/[ta-metadata]/[ta-host]
            %agent  [our.bowl %spider]
            %watch  /thread-result/[tid]
        ==
        :*  %pass  /thread/[ta-now]
            %agent  [our.bowl %spider]
            %poke  %spider-start  !>(start-args)
    ==  ==
  ::
      %join-table
    ?^  our-table.state
      ~|("%pokur: error: can't join table, already in one" !!)
    ?^  game.state
      ~|("%pokur: error: can't join table, already in game" !!)
    :_  state(our-table `id.action)
    :_  ~
    :*  %pass  /table-poke
        %agent  [fixed-lobby-source %pokur-host]
        %poke  %pokur-player-action  !>(action)
    ==
  ::
      %leave-table
    ?~  our-table.state
      ~|("%pokur: error: can't leave table, not in one" !!)
    =/  =table  (~(got by lobby.state) u.our-table.state)
    :_  state(our-table ~, messages ~)
    :_  ~
    :*  %pass  /table-poke
        %agent  [fixed-lobby-source %pokur-host]
        %poke  %pokur-player-action  !>(action)
    ==
  ::
      %start-game
    ?~  our-table.state
      ~|("%pokur: error: can't start game, not in a table" !!)
    ?^  game.state
      ~|("%pokur: error: can't start game, already in one" !!)
    =/  =table  (~(got by lobby.state) u.our-table.state)
    :_  state(our-table ~, messages ~)
    ?:  =(ship.host-info.table fixed-lobby-source)
      :_  ~
      :*  %pass  /table-poke
          %agent  [ship.host-info.table %pokur-host]
          %poke  %pokur-player-action  !>(action)
      ==
    :~  :*  %pass  /table-poke
            %agent  [fixed-lobby-source %pokur-host]
            %poke  %pokur-player-action  !>(action)
        ==
        :*  %pass  /table-poke
            %agent  [ship.host-info.table %pokur-host]
            %poke  %pokur-host-action
            !>  ^-  host-action
            [%start-game-with-host table]
    ==  ==
  ::
      %leave-game
    ?~  game.state
      ~|("%pokur: error: can't leave game, not in one" !!)
    :_  state(game ~, game-host ~, messages ~)
    :~  :*  %pass  /game-updates/(scot %da id.action)/(scot %p our.bowl)
            %agent  [(need game-host.state) %pokur-host]
            %leave  ~
        ==
        :*  %pass  /table-poke
            %agent  [(need game-host.state) %pokur-host]
            %poke  %pokur-player-action  !>(action)
    ==  ==
  ::
      %kick-player
    ?~  our-table.state
      ~|("%pokur: error: can't edit table, not in one" !!)
    =/  =table  (~(got by lobby.state) u.our-table.state)
    :_  state  :_  ~
    :*  %pass  /table-poke
        %agent  [ship.host-info.table %pokur-host]
        %poke  %pokur-player-action  !>(action)
    ==
  ::
      %set-our-address
    `state(our-address `address.action)
  ::
      %add-escrow
    ?~  our-table.state
      ~|("%pokur: error: can't add escrow, not at a table" !!)
    =/  =table  (~(got by lobby.state) u.our-table.state)
    ?~  tokenized.table
      ~|("%pokur: error: can't add escrow, table isn't tokenized" !!)
    ?~  our-address.state
      ~|("%pokur: error: can't add escrow, missing a wallet address" !!)
    ::  scry indexer for token metadata so we can find our token account
    =/  found=(unit asset-metadata:wallet)
      .^  (unit asset-metadata:wallet)  %gx
          (scot %p our.bowl)  %wallet  (scot %da now.bowl)
          %metadata  (scot %ux metadata.u.tokenized.table)  %noun
      ==
    ~|  "%pokur: error: can't find metadata for escrow token"
    ?~  found  !!
    ?>  ?=(%token -.u.found)
    ::  generate ID of our token account
    =/  our-account-id=@ux
      %:  hash-data:smart
          contract.u.found
          u.our-address.state
          town.contract.host-info.table
          salt.u.found
      ==
    :_  state  :_  ~
    :*  %pass  /pokur-wallet-poke
        %agent  [our.bowl %uqbar]
        %poke  %wallet-poke
        !>
        :*  %transaction
            from=u.our-address.state
            contract=id.contract.host-info.table
            town=town.contract.host-info.table
            :-  %noun
            :^    %deposit
                bond-id.u.tokenized.table
              amount.u.tokenized.table
            our-account-id
        ==
    ==
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
    :_  state
    %+  turn
      ?~  game.state
        ?~  our-table.state
          !!
        =/  =table  (~(got by lobby.state) u.our-table.state)
        ~(tap in players.table)
      %+  weld
        (turn players.u.game.state head)
      ~(tap in spectators.u.game.state)
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
          ?~  our-table.state
            %.n
          =/  =table  (~(got by lobby.state) u.our-table.state)
          (~(has in players.table) src.bowl)
        ?|  ?=(^ (find [src.bowl]~ (turn players.u.game.state head)))
            (~(has in spectators.u.game.state) src.bowl)
        ==
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
  :_  state  :_  ~
  :^  %pass  /poke-wire  %agent
  :^  [(need game-host.state) %pokur-host]
    %poke  %pokur-game-action
  ?-  -.action
    %check  !>(`game-action`[%check id.u.game.state ~])
    %fold   !>(`game-action`[%fold id.u.game.state ~])
    %bet    !>(`game-action`[%bet id.u.game.state amount.action])
  ==
--
