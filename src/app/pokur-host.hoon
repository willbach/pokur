/-  *pokur, wallet=zig-wallet, ui=zig-indexer
/+  default-agent, dbug, *pokur-game-logic, *pokur-chain
|%
+$  card  card:agent:gall
+$  versioned-state
  $%  pokur-host-state-0
      state-1
  ==
+$  state-1
  $:  %1
      our-info=host-info
      ::  host holds its own tables as well as gossipped ones from main host
      tables=(map @da table)
      ::  host holds all active games they are running
      games=(map @da host-game-state)
      pending-player-txns=(jar batch=@ux [src=@p =txn-player-action])
  ==
++  zero-to-one
  |=  old=pokur-host-state-0
  ^-  state-1
  [%1 our-info.old tables.old games.old ~]
--
%-  agent:dbug
=|  state=state-1
^-  agent:gall
=<
|_  =bowl:gall
+*  this  .
    def   ~(. (default-agent this %|) bowl)
    hc    ~(. +> bowl)
::
++  on-init
  ^-  (quip card _this)
  ::  ID of escrow contract
  =+  0xabcd.abcd
  :_  this(state [%1 [our.bowl 0x0 [- 0x0]] ~ ~ ~])
  :~  approve-origin-poke
  ::  always be watching for new batch, to handle any pending tables
      =+  /indexer/pokur-host/batch-order/(scot %ux 0x0)
      [%pass /new-batch %agent [our.bowl %uqbar] %watch -]
  ==
++  on-save
  ^-  vase
  !>(state)
++  on-load
  |=  =old=vase
  ^-  (quip card _this)
  ::  one-update-only manual reset of state type
  ::  =+  0xabcd.abcd
  ::  :-  approve-origin-poke^~
  ::  this(state [%1 [our.bowl 0x0 [- 0x0]] ~ ~ ~])
  =/  old-state  !<(versioned-state old-vase)
  ?-    -.old-state
      %1
    `this(state old-state)
      %0
    :_  this(state (zero-to-one old-state))
    =-  [%pass /new-batch %agent [our.bowl %uqbar] %watch -]~
    /indexer/pokur-host/batch-order/(scot %ux town.contract.our-info.state)
  ==
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  =^  cards  state
    ?+    mark  (on-poke:def mark vase)
        %pokur-player-action
      ::  starting tables, games, etc
      (handle-player-action:hc !<(player-action vase) tokenized=%.n)
        %pokur-txn-player-action
      ::  starting and joining tokenized tables
      (handle-player-txn:hc !<(txn-player-action vase) on-batch=%.n)
        %pokur-game-action
      ::  checks, bets, folds inside game
      (handle-game-action:hc !<(game-action vase))
        %pokur-host-action
      ::  internal pokes and host management
      (handle-host-action:hc !<(host-action vase))
        %wallet-update
      (handle-wallet-update:hc !<(wallet-update:wallet vase))
    ==
  [cards this]
++  on-watch
  |=  =path
  ^-  (quip card _this)
  ?+    path  (on-watch:def path)
      [%lobby-updates ~]
    ::  new player using us as lobby; poke them with our escrow info
    ~&  >  "new player {<src.bowl>} joined lobby, sending tables available"
    :_  this
    :-  :^  %give  %fact  ~
        :-  %pokur-host-update
        !>(`host-update`[%lobby (public-tables tables.state)])
    ::
    ?:  =(0x0 address.our-info.state)  ~
    :_  ~
    :*  %pass  /share-escrow-poke
        %agent  [src.bowl %pokur]
        %poke  %pokur-host-action
        !>(`host-action`[%host-info our-info.state])
    ==
  ::
      [%lobby-updates @ ~]
    ::  watcher seeks updates about a private table
    =/  table-id=@da  (slav %da i.t.path)
    ~&  >  "player {<src.bowl>} watching private table {<table-id>}"
    :_  this
    ?~  table=(~(get by tables.state) table-id)  ~
    :_  ~
    :^  %give  %fact  ~
    :-  %pokur-host-update
    !>(`host-update`[%new-table u.table])
  ::
      [%game-updates @ @ ~]
    ::  assert the player is in game and on their path
    =/  game-id    (slav %da i.t.path)
    =/  player=@p  (slav %p i.t.t.path)
    ?>  =(player src.bowl)
    ?~  host-game=(~(get by games.state) game-id)
      :_  this
      =/  err  "invalid game id {<game-id>}"
      :~  [%give %watch-ack `~[leaf+err]]
      ==
    ?~  (find [player]~ (turn players.game.u.host-game head))
      ?.  spectators-allowed.game.u.host-game
        :_  this
        =/  err  "player not in this game"
        :~  [%give %watch-ack `~[leaf+err]]
        ==
      ::  give game state to a spectator
      =.  spectators.game.u.host-game
        (~(put in spectators.game.u.host-game) player)
      :_  this(games.state (~(put by games.state) game-id u.host-game))
      :_  ~
      :^  %give  %fact  ~
      [%pokur-host-update !>(`host-update`[%game game.u.host-game ~])]
    ::  give game state to a player
    =.  my-hand.game.u.host-game
      (fall (~(get by hands.u.host-game) player) ~)
    :_  this  :_  ~
    :^  %give  %fact  ~
    [%pokur-host-update !>(`host-update`[%game game.u.host-game ~])]
  ==
++  on-arvo
  |=  [=wire =sign-arvo]
  ^-  (quip card _this)
  ?+    wire  (on-arvo:def wire sign-arvo)
      [%timer @ %round-timer ~]
    :: ROUND TIMER wire (for tournaments)
    =/  game-id  (slav %da i.t.wire)
    ?~  host-game=(~(get by games.state) game-id)
      `this
    =*  game  game.u.host-game
    :: if no players left in game, end it
    ?:  %+  levy  players.game
        |=([ship @ud @ud ? ? left=?] left)
      =^  cards  state
        (end-game-pay-winners u.host-game)
      [cards this]
    =.  u.host-game
      ~(increment-current-round guts u.host-game)
    :_  this(games.state (~(put by games.state) game-id u.host-game))
    %+  snoc
      (send-game-updates u.host-game ~)
    ::  set new round timer
    ?>  ?=(%sng -.game-type.game)
    :*  %pass  /timer/(scot %da game-id)/round-timer
        %arvo  %b  %wait
        (add now.bowl round-duration.game-type.game)
    ==
  ::
      [%timer @ ~]
    :: TURN TIMER wire
    :: the timer ran out.. a player didn't make a move in time
    =/  game-id  (slav %da i.t.wire)
    ::  find whose turn it is
    ?~  host-game=(~(get by games.state) game-id)
      `this
    =*  game  game.u.host-game
    ::  if no players left in game, end it
    ?:  %+  levy  players.game
        |=([ship @ud @ud ? ? left=?] left)
      =^  cards  state
        (end-game-pay-winners u.host-game)
      [cards this]
    ::  reset that game's turn timer
    =.  turn-timer.u.host-game  *@da
    :_  this(games.state (~(put by games.state) game-id u.host-game))
    :_  ~
    :*  %pass  /self-poke-wire
        %agent  [our.bowl %pokur-host]
        %poke  %pokur-game-action
        !>  ^-  game-action
        ::  if there is a required bet, auto-fold
        ::  otherwise, auto-check
        ?:  =-  =(current-bet.game committed:(need -))
            (get-player-info:~(gang guts u.host-game) whose-turn.game)
          [%check game-id ~]
        [%fold game-id ~]
    ==
  ==
++  on-peek
  ::  TODO add scries
  on-peek:def
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  ?+    wire  (on-agent:def wire sign)
      [%new-batch ~]
    ::  new batch notif from indexer: check our pending-tables
    ::  and see if any valid new tables or table joins have occurred
    ?:  ?=(%kick -.sign)
      :_  this  ::  attempt to re-sub
      =-  [%pass /new-batch %agent [our.bowl %uqbar] %watch -]~
      /indexer/pokur-host/batch-order/(scot %ux town.contract.our-info.state)
    ?.  ?=(%fact -.sign)  (on-agent:def wire sign)
    =/  upd  !<(update:ui q.cage.sign)
    ?.  ?=(%batch-order -.upd)  `this
    ?~  batch-order.upd         `this
    =/  batch-hash=@ux  (rear batch-order.upd)
    ::  there's a new batch, check all pending table actions
    =|  cards=(list card)
    ::  need to make new list so as not to handle any pending actions
    ::  created during this loop
    =^  pending=(list [src=@p =txn-player-action])  pending-player-txns.state
      :-  (~(get ja pending-player-txns.state) batch-hash)
      (~(del by pending-player-txns.state) batch-hash)
    |-
    ?~  pending  [cards this]
    =*  action  txn-player-action.i.pending
    =.  src.bowl  src.i.pending
    =^  new-cards  state
      (handle-player-txn:hc action on-batch=%.y)
    $(pending t.pending, cards (weld new-cards cards))
  ==
++  on-leave  on-leave:def
++  on-fail   on-fail:def
--
::  start helper core
|_  bowl=bowl:gall
++  handle-host-action
  |=  action=host-action
  ^-  (quip card _state)
  ?-    -.action
      %host-info
    :_  state(our-info +.action)
    ::  poke our new info out to all subscribers
    ^-  (list card)
    %+  murn  ~(val by sup.bowl)
    |=  [who=ship pat=path]
    ?.  ?=([%lobby-updates ~] pat)  ~
    :-  ~
    ^-  card
    :*  %pass  /share-escrow-poke
        %agent  [who %pokur]
        %poke  %pokur-host-action
        !>(`host-action`[%host-info +.action])
    ==
  ::
      %share-table
    ::  get table from other host, add to our lobby
    ?>  =(src.bowl ship.host-info.table.action)
    ?:  =(src.bowl our.bowl)  `state
    =.  tables.state
      (~(put by tables.state) id.table.action table.action)
    [(new-table-card table.action)^~ state]
  ::
      %closed-table
    ::  remove table by other host from our lobby
    ?:  =(src.bowl our.bowl)  `state
    ?~  table=(~(get by tables.state) id.action)
      `state
    ?>  =(src.bowl ship.host-info.u.table)
    :-  (table-closed-card id.u.table)^~
    state(tables (~(del by tables.state) id.u.table))
  ::
      %game-starting
    ::  remove table by other host from our lobby
    ?:  =(src.bowl our.bowl)  `state
    ?~  table=(~(get by tables.state) id.action)
      `state
    ?>  =(src.bowl ship.host-info.u.table)
    `state(tables (~(del by tables.state) id.u.table))
  ::
      %turn-timers
    :_  state
    ^-  (list card)
    :-  :*  %pass  /timer/(scot %da id.action)
            %arvo  %b  %wait
            wake.action
        ==
    ?:  =(*@da rest.action)  ~
    :_  ~
    :*  %pass  /timer/(scot %da id.action)
        %arvo  %b  %rest
        rest.action
    ==
  ::
      %kick-table
    ::  debugging tool for hosts
    ::  **DOES NOT REFUND PLAYERS**
    =+  (~(del by tables.state) id.action)
    :_  state(tables -)
    :~  (table-closed-card id.action)
        (table-gossip-card [%closed id.action])
    ==
  ==
::
++  handle-game-action
  |=  action=game-action
  ^-  (quip card _state)
  ?~  host-game=(~(get by games.state) game-id.action)
    :_  state
    ~[[%give %poke-ack `~[leaf+"error: host could not find game"]]]
  =*  game  game.u.host-game
  :: validate that move is from right player
  =/  from=ship
    ?:  ?&  =(src.bowl our.bowl)
            (gth now.bowl turn-timer.u.host-game)
        ==
      :: automatic fold from timeout!
      whose-turn.game
    src.bowl
  ?.  =(whose-turn.game from)
    :_  state
    ~[[%give %poke-ack `~[leaf+"error: playing out of turn!"]]]
  =+  (~(process-player-action guts u.host-game) from action)
  ?~  -
    :_  state
    ~[[%give %poke-ack `~[leaf+"error: invalid action received!"]]]
  ::
  (resolve-player-turn u.-)
::
++  handle-player-txn
  |=  [action=txn-player-action on-batch=?]
  ^-  (quip card _state)
  ?-    -.action
      %new-table-txn
    ?>  ?=(%new-table -.player-action.action)
    ?~  tokenized.player-action.action  !!
    ::  game is tokenized, check the chain and get escrow stuff
    =/  valid
      %-  ~(valid-new-table fetch [our now]:bowl our-info.state)
      [src.bowl on-batch [bond-id amount]:u.tokenized.player-action.action]
    ?~  valid
      ::  can't find bond yet... kick over to pending
      =-  `state(pending-player-txns -)
      (~(add ja pending-player-txns.state) batch-id.action [src.bowl action])
    ?.  u.valid
      :_  state
      ~[[%give %poke-ack `~[leaf+"error: bond sent to host was rejected"]]]
    ::  only handling tokenized %sng tables for now
    ?>  ?=(%sng -.game-type.player-action.action)
    (handle-player-action player-action.action tokenized=%.y)
  ::
      %join-table-txn
    ?>  ?=(%join-table -.player-action.action)
    ?~  table=(~(get by tables.state) id.player-action.action)  !!
    ?~  tokenized.u.table  !!
    ::  game is tokenized, check against bond to see if player has paid in
    =/  valid
      %-  ~(valid-new-player fetch [our now]:bowl our-info.state)
      [src.bowl on-batch [bond-id amount]:u.tokenized.u.table]
    ?~  valid
      ::  can't find player info yet... kick over to pending
      =-  `state(pending-player-txns -)
      (~(add ja pending-player-txns.state) batch-id.action [src.bowl action])
    ?.  u.valid
      :_  state
      ~[[%give %poke-ack `~[leaf+"error: request sent to host was rejected"]]]
    (handle-player-action player-action.action tokenized=%.y)
  ==
::
++  handle-player-action
  |=  [action=player-action tokenized=?]
  ^-  (quip card _state)
  ?+    -.action  !!
      %new-table
    ?>  ?|  tokenized
            ?=(~ tokenized.action)
        ==
    ?<  (~(has by tables.state) id.action)
    ?>  (lte turn-time-limit.action ~s999)
    ?>  (gte turn-time-limit.action ~s20)
    ?>  (gte min-players.action 2)
    ?>  (lte max-players.action 10)
    =/  =table
      :*  id.action
          ::  insert our host info
          our-info.state
          tokenized.action
          src.bowl
          (silt ~[src.bowl])
          min-players.action
          max-players.action
          game-type.action
          public.action
          spectators-allowed.action
          turn-time-limit.action
      ==
    ::  validate spec
    ?>  ?-  -.game-type.action
          %cash  %.y  ::  TODO
          %sng  (valid-sng-spec action)
        ==
    =+  (~(put by tables.state) id.action table)
    :_  state(tables -)
    ?.  public.action  (private-table-card table)^~
    :~  (new-table-card table)
        (table-gossip-card [%open table])
    ==
  ::
      %join-table
    ::  add player to existing table
    ?~  table=(~(get by tables.state) id.action)  !!
    ?>  ?|  tokenized
            ?=(~ tokenized.u.table)
        ==
    ::  table must not be full
    ?<  =(max-players.u.table ~(wyt in players.u.table))
    =.  players.u.table  (~(put in players.u.table) src.bowl)
    =+  (~(put by tables.state) id.action u.table)
    :_  state(tables -)
    ?.  public.u.table  (private-table-card u.table)^~
    :~  (new-table-card u.table)
        (table-gossip-card [%open u.table])
    ==
  ::
      %leave-table
    ::  remove player from existing table
    ?~  table=(~(get by tables.state) id.action)  !!
    ?.  (~(has in players.u.table) src.bowl)
      `state
    =.  players.u.table
      (~(del in players.u.table) src.bowl)
    ::  if all players left, close table
    ::  if table was tokenized, refund leaving player
    =/  award-card
      ?~  tokenized.u.table  ~
      :_  ~
      :*  %pass  /pokur-wallet-poke
          %agent  [our.bowl %uqbar]
          %poke  %wallet-poke
          !>
          :*  %transaction
              origin=`[%pokur-host /awards]
              from=address.our-info.state
              contract=id.contract.host-info.u.table
              town=town.contract.host-info.u.table
              :-  %noun
              ^-  action:escrow
              :*  %award
                  bond-id.u.tokenized.u.table
                  src.bowl
                  amount.u.tokenized.u.table
              ==
          ==
      ==
    ?:  =(0 ~(wyt in players.u.table))
      =+  (~(del by tables.state) id.action)
      :_  state(tables -)
      :+  (table-closed-card id.action)
        (table-gossip-card [%closed id.action])
      award-card
    =+  (~(put by tables.state) id.action u.table)
    :_  state(tables -)
    ?.  public.u.table
      (private-table-card u.table)^award-card
    :+  (new-table-card u.table)
      (table-gossip-card [%open u.table])
    award-card
  ::
      %start-game
    ::  table creator starts game
    ?~  table=(~(get by tables.state) id.action)  !!
    ?>  =(leader.u.table src.bowl)
    ?>  (gte ~(wyt in players.u.table) min-players.u.table)
    =?    game-type.u.table
        ?=(%sng -.game-type.u.table)
      %=  game-type.u.table
        current-round  0
        round-is-over  %.n
      ==
    ::  shuffle player list to get random starting order
    =/  player-order=(list @p)
      (shuffle ~(tap in players.u.table) eny.bowl)
    =/  =game
      :*  id.u.table
          game-is-over=%.n
          game-type.u.table
          turn-time-limit.u.table
          turn-start=(add now.bowl ~s5)
          %+  turn  player-order
          |=  =ship
          [ship starting-stack.game-type.u.table 0 %.n %.n %.n]
          pots=~[[0 player-order]]
          current-bet=0
          last-bet=0
          last-action=~
          last-aggressor=~
          board=~
          my-hand=~
          ::  these values all get replaced by game engine, they don't matter
          whose-turn=(head player-order)
          dealer=(head player-order)
          small-blind=(head player-order)
          big-blind=(head player-order)
          spectators-allowed.u.table
          spectators=~
          hands-played=0
          (crip "Pokur game started, hosted by {<our.bowl>}")
          revealed-hands=~
      ==
    =/  =host-game-state
      %-  initialize-new-hand
      :*  hands=~
          deck=generate-deck
          hand-is-over=%.y
          ::  pad start of game with 5s
          turn-timer=(add now.bowl (add turn-time-limit.u.table ~s5))
          tokenized.u.table
          placements=~
          game
      ==
    =.  tables.state  (~(del by tables.state) id.action)
    :_  state(games (~(put by games.state) id.action host-game-state))
    %+  welp
      :~  (game-starting-card id.u.table)
          (table-gossip-card [%starting id.u.table])
          :*  %pass  /self-poke
              %agent  [our.bowl %pokur-host]
              %poke  %pokur-host-action
              !>  ^-  host-action
              [%turn-timers id.game turn-timer.host-game-state *@da]
      ==  ==
    ::  initialize first round timer, if tournament style game
    ?.  ?=(%sng -.game-type.u.table)  ~
    :~  :*  %pass  /timer/(scot %da id.game)/round-timer
            %arvo  %b  %wait
            (add now.bowl round-duration.game-type.u.table)
    ==  ==
  ::
      %leave-game
    ::  player leaves game
    ?~  host-game=(~(get by games.state) id.action)
      `state
    ?.  ?|  (~(has by hands.u.host-game) src.bowl)
            (~(has in spectators.game.u.host-game) src.bowl)
        ==
      `state
    :: remove sender from their game
    =?    u.host-game
        (~(has by hands.u.host-game) src.bowl)
      (~(remove-player guts u.host-game) src.bowl)
    :: remove spectator if they were one
    =.  spectators.game.u.host-game
      (~(del in spectators.game.u.host-game) src.bowl)
    ::  check if player left on their turn
    ?.  =(src.bowl whose-turn.game.u.host-game)
      ::  player left out of turn, check for game over
      ?:  game-is-over.game.u.host-game
        ::  leaving resulted in game ending, handle
        (end-game-pay-winners u.host-game)
      ::  game not over, just send update showing they left
      :-  (send-game-updates u.host-game ~)
      state(games (~(put by games.state) id.action u.host-game))
    (resolve-player-turn u.host-game)
  ::
      %kick-player
    ?~  table=(~(get by tables.state) id.action)  !!
    ::  src must be table leader
    ?>  =(src.bowl leader.u.table)
    ::  table must be private
    ?>  =(%.n public.u.table)
    ::  player must be in table
    ?>  (~(has in players.u.table) who.action)
    =/  refund-card
      ?~  tokenized.u.table  ~
      ::  if tokenized, we award kicked player their funds back
      ::  only paid-in players are allowed to join tokenized tables
      ::  so we know they paid if they're here
      :_  ~
      :*  %pass  /pokur-wallet-poke
          %agent  [our.bowl %uqbar]
          %poke  %wallet-poke
          !>
          :*  %transaction
              origin=`[%pokur-host /awards]
              from=address.our-info.state
              contract=id.contract.host-info.u.table
              town=town.contract.host-info.u.table
              :-  %noun
              ^-  action:escrow
              :*  %award
                  bond-id.u.tokenized.u.table
                  who.action
                  amount.u.tokenized.u.table
              ==
          ==
      ==
    =+  %+  ~(put by tables.state)  id.action
        u.table(players (~(del in players.u.table) who.action))
    :_  state(tables -)
    ?.  public.u.table  (private-table-card u.table)^refund-card
    :+  (new-table-card u.table)
      (table-gossip-card [%open u.table])
    refund-card
  ==
::
++  handle-wallet-update
  |=  update=wallet-update:wallet
  ^-  (quip card _state)
  ?+    -.update  !!
  ::  only ever expecting a %finished-transaction notification
      %finished-transaction
    ::  can ignore for now, maybe do something in future
    ~&  >  "%pokur-host: %award transaction was successful"
    `state
  ==
::
::  +resolve-player-turn: reset turn timer, generate game updates,
::  handle ending hands and games
::
++  resolve-player-turn
  |=  host-game=host-game-state
  ^-  (quip card _state)
  =/  old-timer=@da  turn-timer.host-game
  ::  poke ourself to set a turn timer
  =.  turn-timer.host-game
    ::  if hand is over, add 5s to next turn
    ?.  hand-is-over.host-game
      `@da`(add now.bowl turn-time-limit.game.host-game)
    `@da`(add now.bowl (add turn-time-limit.game.host-game ~s5))
  =.  turn-start.game.host-game
    ?.  hand-is-over.host-game
      now.bowl
    `@da`(add now.bowl ~s5)
  ::
  =.  games.state  (~(put by games.state) id.game.host-game host-game)
  =^  cards  state
    ?.  game-is-over.game.host-game
      ?.  hand-is-over.host-game
        (send-game-updates host-game ~)^state
      ::  a hand has ended, send last board in next updates
      ::  and initialized new hand
      =/  last-board=pokur-deck  board.game.host-game
      =.  host-game  (initialize-new-hand host-game)
      :-  (send-game-updates host-game last-board)
      =-  state(games (~(put by games.state) id.game.host-game -))
      host-game(revealed-hands.game ~)
    ::  host handles paying winner(s) here
    (end-game-pay-winners host-game)
  :_  state
  ::  set new turn timer and cancel old one, if any
  %+  snoc  cards
  :*  %pass  /self-poke
      %agent  [our.bowl %pokur-host]
      %poke  %pokur-host-action
      !>  ^-  host-action
      [%turn-timers id.game.host-game turn-timer.host-game old-timer]
  ==
::
::  +send-game-updates: make update cards for players and spectators
::
++  send-game-updates
  |=  [host-game=host-game-state last-board=pokur-deck]
  ^-  (list card)
  %+  weld
    %+  turn  players.game.host-game
    |=  [=ship player-info]
    ^-  card
    =.  my-hand.game.host-game
      ?~(h=(~(get by hands.host-game) ship) ~ u.h)
    :^  %give  %fact
      ~[/game-updates/(scot %da id.game.host-game)/(scot %p ship)]
    [%pokur-host-update !>(`host-update`[%game game.host-game last-board])]
  %+  turn  ~(tap in spectators.game.host-game)
  |=  =ship
  ^-  card
  :^  %give  %fact
    ~[/game-updates/(scot %da id.game.host-game)/(scot %p ship)]
  [%pokur-host-update !>(`host-update`[%game game.host-game last-board])]
::
++  game-over-updates
  |=  [host-game=host-game-state winnings=(list [ship @ud])]
  ^-  (list card)
  %+  turn
    %+  weld
      (turn players.game.host-game head)
    ~(tap in spectators.game.host-game)
  |=  =ship
  ^-  card
  :^  %give  %fact
    ~[/game-updates/(scot %da id.game.host-game)/(scot %p ship)]
  :-  %pokur-host-update
  !>  ^-  host-update
  [%game-over game.host-game board.game.host-game winnings tokenized.host-game]
::
++  initialize-new-hand
  |=  host-game=host-game-state
  ^-  host-game-state
  =.  deck.host-game  (shuffle deck.host-game eny.bowl)
  ~(initialize-hand guts host-game)
::
++  end-game-pay-winners
  |=  host-game=host-game-state
  ^-  (quip card _state)
  ::  if non-token game, just delete and update
  ?~  tokenized.host-game
    :-  (game-over-updates host-game (turn placements.host-game |=(p=@p [p 0])))
    state(games (~(del by games.state) id.game.host-game))
  ::  pay tokens based on game type (only handling %sng now)
  ::  TODO handle cash
  ?>  ?=(%sng -.game-type.game.host-game)
  =/  total-payout=@ud
    %-  ~(total-payout fetch [our now]:bowl our-info.state)
    bond-id.u.tokenized.host-game
  ~&  >  "pokur-host: awarding players in game {<id.game.host-game>}"
  =/  winnings=(list [ship @ud])
    =<  p
    %^  spin  payouts.game-type.game.host-game  0
    |=  [award-pct=@ud place=@ud]
    :_  +(place)
    :-  (snag place placements.host-game)
    (mul award-pct (div total-payout 100))
  ~&  >  "winnings: {<winnings>}"
  ::
  :_  state(games (~(del by games.state) id.game.host-game))
  %+  welp
    (game-over-updates host-game winnings)
  %+  turn  winnings
  |=  [=ship amount=@ud]
  ::  build an award transaction for each paid placement
  ::  automatically sign+submit these by poking %wallet
  ::  in advance to automate txns from this origin
  :*  %pass  /pokur-wallet-poke
      %agent  [our.bowl %uqbar]
      %poke  %wallet-poke
      !>
      :*  %transaction
          origin=`[%pokur-host /awards]
          from=address.our-info.state
          contract=id.contract.our-info.state
          town=town.contract.our-info.state
          :-  %noun
          ^-  action:escrow
          :^    %award
              bond-id.u.tokenized.host-game
            ship
          amount
  ==  ==
::
++  valid-sng-spec
  |=  act=player-action
  ^-  ?
  ?.  ?=(%new-table -.act)  %.n
  ?.  ?=(%sng -.game-type.act)  %.n
  ?.  (gte min-players.act (lent payouts.game-type.act))  %.n
  =(100 (roll payouts.game-type.act add))
::
++  table-gossip-card
  |=  info=$%([%open table] [%closed @da] [%starting @da])
  ^-  card
  ::  TODO put gossip here, for now just share with central ship
  :*  %pass   /table-share
      %agent  [fixed-lobby-source %pokur-host]
      %poke   %pokur-host-action
      ?-  -.info
        %open      !>(`host-action`[%share-table +.info])
        %closed    !>(`host-action`[%closed-table +.info])
        %starting  !>(`host-action`[%game-starting +.info])
      ==
  ==
::
++  game-starting-card
  |=  id=@da
  ^-  card
  :^  %give  %fact  ~[/lobby-updates]
  :-  %pokur-host-update
  !>(`host-update`[%game-starting id])
::
++  table-closed-card
  |=  id=@da
  ^-  card
  :^  %give  %fact  ~[/lobby-updates]
  :-  %pokur-host-update
  !>(`host-update`[%table-closed id])
::
++  new-table-card
  |=  =table
  ^-  card
  :^  %give  %fact  ~[/lobby-updates]
  :-  %pokur-host-update
  !>(`host-update`[%new-table table])
::
++  private-table-card
  |=  =table
  ^-  card
  :^  %give  %fact  ~[/lobby-updates/(scot %da id.table)]
  :-  %pokur-host-update
  !>(`host-update`[%new-table table])
::
++  approve-origin-poke
  ^-  card
  :*  %pass  /pokur-wallet-poke
      %agent  [our.bowl %uqbar]
      %poke  %wallet-poke
      !>([%approve-origin [%pokur-host /awards] [1 1.000.000]])
  ==
::
++  public-tables
  |=  m=(map @da table)
  ^-  (map @da table)
  %-  ~(gas by *(map @da table))
  %+  murn  ~(tap by m)
  |=  [key=@da =table]
  ?.  public.table  ~
  `[key table]
--
