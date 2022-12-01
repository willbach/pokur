/-  *pokur, indexer=zig-indexer, wallet=zig-wallet
/+  default-agent, dbug, smart=zig-sys-smart,
    *pokur-game-logic, pokur-json
|%
+$  card  card:agent:gall
+$  versioned-state  $%(state-0)
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
      ::  used for delaying tokenized actions until we get txn confirmation
      pending-poke=(unit player-action)
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
  :_  this(state [%0 ~ ~ fixed-lobby-source ~ ~ ~ ~ ~ ~ ~])
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
        %wallet-update
      (handle-wallet-update:hc !<(wallet-update:wallet vase))
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
      [%join-table-poke @ ~]
    ?.  ?=(%poke-ack -.sign)  (on-agent:def wire sign)
    ?^  p.sign  !!  ::  TODO join table poke failed!
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
        :_  this(lobby.state tables.upd)  :_  ~
        :^  %give  %fact  ~[/lobby-updates]
        [%pokur-update !>(`update`upd)]
      ::
          %table-closed
        ::  if our table closed, clear
        ?~  our-table.state  `this
        ?.  =(u.our-table.state table-id.upd)  `this
        :_  this(our-table.state ~)
        :_  ~
        :^  %give  %fact  ~[/lobby-updates]
        [%pokur-update !>(`update`[%table-closed table-id.upd])]
      ::
          %game-starting
        ::  check if it's our game, if so, sub to path and notify FE
        ?~  our-table.state  `this
        ?.  =(game-id.upd u.our-table.state)  `this
        =/  =table  (~(got by lobby.state) u.our-table.state)
        :_  this(our-table.state ~, game-host.state `ship.host-info.table)
        :~  :^  %give  %fact  ~[/game-updates]
            [%pokur-update !>(`update`upd)]
        ::
            :*  %pass  /game-updates/(scot %da id.table)/(scot %p our.bowl)
                %agent  [ship.host-info.table %pokur-host]
                %watch  /game-updates/(scot %da id.table)/(scot %p our.bowl)
        ==  ==
      ==
    ==
  ::
      [%new-table-thread ~]
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
      ::
          %thread-done
        ?~  pending-poke.state  !!
        ?>  ?=(%new-table -.u.pending-poke.state)
        ?~  tokenized.u.pending-poke.state  !!
        =/  height=@ud  !<(@ud q.cage.sign)
        ~&  >  "eth-block-height: {<height>}"
        ?~  host-info=(~(get by known-hosts.state) host.u.pending-poke.state)
          !!
        ?~  our-address.state  !!
        =/  default-timelock=@ud  ::  roughly 48 hours
          (add height 14.400)
        ::  generate ID of our token account
        =/  our-account-id=@ux
          %:  get-token-account-id
              metadata.u.tokenized.u.pending-poke.state
              u.our-address.state
              town.contract.u.host-info
              now.bowl
          ==
        ::  we'll get a pokeback from %wallet when this transaction goes through
        :_  this  :_  ~
        :*  %pass  /pokur-wallet-poke
            %agent  [our.bowl %uqbar]
            %poke  %wallet-poke
            !>
            :*  %transaction
                origin=`[%pokur /new-bond-confirmation]
                from=u.our-address.state
                contract=id.contract.u.host-info
                town=town.contract.u.host-info
                :-  %noun
                :*  %new-bond-with-deposit
                    address.u.host-info
                    default-timelock
                    metadata.u.tokenized.u.pending-poke.state
                    our.bowl
                    amount.u.tokenized.u.pending-poke.state
                    our-account-id
                ==
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
      [%our-table ~]
    ``json+!>(?~(our-table.state ~ s+(scot %da u.our-table.state)))
      [%game ~]
    ``json+!>(?~(game.state ~ (enjs-game:pokur-json u.game.state)))
      [%messages ~]
    ``json+!>((enjs-messages:pokur-json messages.state))
      [%muted-players ~]
    ``json+!>(a+(turn ~(tap in muted-players.state) ship:enjs:format))
  ::
      [%table @ ~]
    :^  ~  ~  %json
    !>  %-  enjs-table:pokur-json
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
    ?>  =(src.bowl ship.host-info.action)
    `state(known-hosts (~(put by known-hosts.state) src.bowl +.action))
  ==
::
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
          %agent  [host.action %pokur-host]
          %poke  %pokur-player-action  !>(action)
      ==
    ::  generate new escrow bond with host
    ::  [%new-bond custodian=address timelock=@ud asset-metadata=id]
    ::  fetch latest ETH block height to produce timelock
    =/  tid          `@ta`(cat 3 'thread_' (scot %uv (sham eny.bowl)))
    =/  ta-now       (scot %da now.bowl)
    =/  start-args  [~ `tid byk.bowl(r da+now.bowl) %get-eth-block !>(~)]
    ::  set pending poke
    :_  state(pending-poke `action)
    :~  :*  %pass  /new-table-thread
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
    =/  =table  (~(got by lobby.state) id.action)
    ::  if table is tokenized, generate escrow transaction, otherwise just join
    ::  host will add us to queue but not enter us to table if tokenized, until
    ::  transaction is received
    ?~  tokenized.table
      :_  state(our-table `id.action)
      (poke-pass-through ship.host-info.table action)^~
    ::  escrow work -- set pending join poke
    :_  state(pending-poke `action)
    ?~  our-address.state
      ~|("%pokur: error: can't add escrow, missing a wallet address" !!)
    ::  scry indexer for token metadata so we can find our token account
    =/  our-account-id=@ux
      %:  get-token-account-id
          metadata.u.tokenized.table
          (need our-address.state)
          town.contract.host-info.table
          now.bowl
      ==
    =/  host-ta  (scot %p ship.host-info.table)
    :_  ~
    :*  %pass  /pokur-wallet-poke
        %agent  [our.bowl %uqbar]
        %poke  %wallet-poke
        !>
        :*  %transaction
            origin=`[%pokur /deposit-confirmation/[host-ta]]
            from=u.our-address.state
            contract=id.contract.host-info.table
            town=town.contract.host-info.table
            :-  %noun
            :*  %deposit
                bond-id.u.tokenized.table
                our.bowl
                amount.u.tokenized.table
                our-account-id
            ==
        ==
    ==
  ::
      %leave-table
    ?~  our-table.state
      ~|("%pokur: error: can't leave table, not in one" !!)
    =/  =table  (~(got by lobby.state) u.our-table.state)
    :_  state(our-table ~, messages ~)
    (poke-pass-through ship.host-info.table action)^~
  ::
      %start-game
    ?~  our-table.state
      ~|("%pokur: error: can't start game, not in a table" !!)
    ?^  game.state
      ~|("%pokur: error: can't start game, already in one" !!)
    =/  =table  (~(got by lobby.state) u.our-table.state)
    :_  state(messages ~)
    (poke-pass-through ship.host-info.table action)^~
  ::
      %leave-game
    ?~  game.state
      ~|("%pokur: error: can't leave game, not in one" !!)
    :_  state(game ~, game-host ~, messages ~)
    :~  (poke-pass-through (need game-host.state) action)
        :*  %pass  /game-updates/(scot %da id.action)/(scot %p our.bowl)
            %agent  [(need game-host.state) %pokur-host]
            %leave  ~
    ==  ==
  ::
      %kick-player
    !!
    ::  ?~  our-table.state
    ::    ~|("%pokur: error: can't edit table, not in one" !!)
    ::  =/  =table  (~(got by lobby.state) u.our-table.state)
    ::  :_  state
    ::  (poke-pass-through ship.host-info.table action)^~
  ::
      %set-our-address
    `state(our-address `address.action)
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
::
++  handle-wallet-update
  |=  update=wallet-update:wallet
  ^-  (quip card _state)
  ?+    -.update  !!
  ::  only ever expecting a %finished-transaction notification
      %finished-transaction
    ::  wallet announcing that either our %new-bond has been started,
    ::  meaning we've successfully created a tokenized table, or that
    ::  our %deposit has gone through, meaning we've joined a tokenized table
    ?>  ?=(^ origin.update)
    ?~  pending-poke.state  !!
    ?+    q.u.origin.update  !!
        [%new-bond-confirmation ~]
      ::  send bond info to host with a %new-table poke, finally
      ?>  ?=(%new-table -.u.pending-poke.state)
      ?~  tokenized.u.pending-poke.state  !!
      ::  make sure txn succeeded
      ~|  "%pokur: transaction failed!!"
      ?>  =(%200 status.transaction.update)
      ::  modify bond-id with txn output
      ::  should be in events.output.update
      =/  event=contract-event:eng:wallet
        (head events.output.update)
      ?>  =(%new-bond label.event)
      =.  bond-id.u.tokenized.u.pending-poke.state
        ((se:dejs:format %ux) json.event)
      :_  state(pending-poke ~)
      :_  ~
      :*  %pass   /start-table-poke/(scot %da id.u.pending-poke.state)
          %agent  [host.u.pending-poke.state %pokur-host]
          %poke   %pokur-player-action  !>(u.pending-poke.state)
      ==
    ::
        [%deposit-confirmation @ ~]
      ?>  ?=(%join-table -.u.pending-poke.state)
      ::  request to %join-table on host
      ::  don't need any data other than the fact that the txn succeeded
      ~|  "%pokur: transaction failed!!"
      ?>  =(%200 status.transaction.update)
      =/  host=ship  (slav %p i.t.q.u.origin.update)
      :_  state(pending-poke ~)
      :_  ~
      :*  %pass   /join-table-poke/(scot %da id.u.pending-poke.state)
          %agent  [host %pokur-host]
          %poke   %pokur-player-action  !>(u.pending-poke.state)
      ==
    ==
  ==
::
++  poke-pass-through
  |=  [host=ship action=player-action]
  ^-  card
  ::  give a poke from frontend to host
  :*  %pass   /table-poke
      %agent  [host %pokur-host]
      %poke   %pokur-player-action  !>(action)
  ==
::
++  get-token-account-id
  |=  [metadata=@ux our-addr=@ux town=@ux now=@da]
  ~|  "%pokur: error: can't find metadata for escrow token"
  =/  found=wallet-update:wallet
    .^  wallet-update:wallet  %gx
        /(scot %p our.bowl)/wallet/(scot %da now)/metadata/(scot %ux metadata)/noun
    ==
  ?:  ?=(~ found)  !!
  ?>  ?=(%metadata -.found)
  ?>  ?=(%token -.+.found)
  ::  generate ID of our token account
  %:  hash-data:smart
      contract.found
      our-addr
      town
      salt.found
  ==
--
