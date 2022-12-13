/-  *pokur, wallet=zig-wallet
/+  default-agent, dbug, *pokur-game-logic, *pokur-chain
|%
+$  card  card:agent:gall
+$  versioned-state  $%(state-0)
+$  state-0
  $:  %0
      our-info=host-info
      tables=(map @da table)  ::  host *may* hold some tables, not yet gossiping with other hosts
      games=(map @da host-game-state)  ::  host holds all active games they are running
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
  =+  0x7a9a.97e0.ca10.8e1e.273f.0000.8dca.2b04.fc15.9f70
  :_  this(state [%0 [our.bowl - [0xabcd.abcd 0x0]] ~ ~])
  :_  ~
  :*  %pass  /pokur-wallet-poke
      %agent  [our.bowl %uqbar]
      %poke  %wallet-poke
      !>([%approve-origin [%pokur-host /awards] [1 1.000.000]])
  ==
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
      ::  starting tables, games, etc
      (handle-player-action:hc !<(player-action vase))
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
    :~  :^  %give  %fact  ~
        :-  %pokur-host-update
        !>(`host-update`[%lobby (public-tables tables.state)])
    ::
        :*  %pass  /share-escrow-poke
            %agent  [src.bowl %pokur]
            %poke  %pokur-host-action
            !>(`host-action`[%host-info our-info.state])
        ==
    ==
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
      [%pokur-host-update !>(`host-update`[%game game.u.host-game])]
    ::  give game state to a player
    =.  my-hand.game.u.host-game
      (fall (~(get by hands.u.host-game) player) ~)
    :_  this  :_  ~
    :^  %give  %fact  ~
    [%pokur-host-update !>(`host-update`[%game game.u.host-game])]
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
      ~(increment-current-round modify-game-state u.host-game)
    :_  this(games.state (~(put by games.state) game-id u.host-game))
    %+  snoc
      (send-game-updates u.host-game)
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
    :: reset that game's turn timer
    =.  turn-timer.u.host-game  *@da
    =.  update-message.game
      (crip "{<whose-turn.game>} timed out.")
    :_  this(games.state (~(put by games.state) game-id u.host-game))
    :_  ~
    :*  %pass  /self-poke-wire
        %agent  [our.bowl %pokur-host]
        %poke  %pokur-game-action
        !>([%fold game-id ~])
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
      %host-info
    `state(our-info +.action)
  ::
      %share-table
    ::  get table from other host, add to our lobby
    ?>  =(src.bowl ship.host-info.table.action)
    ?:  =(src.bowl our.bowl)  `state
    =.  tables.state
      (~(put by tables.state) id.table.action table.action)
    [(lobby-update-card tables.state)^~ state]
  ::
      %closed-table
    ::  remove table by other host from our lobby
    ?~  table=(~(get by tables.state) id.action)
      `state
    ?>  =(src.bowl ship.host-info.u.table)
    =.  tables.state
      (~(del by tables.state) id.u.table)
    [(lobby-update-card tables.state)^~ state]
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
    ?:  =(src.bowl our.bowl)
      :: automatic fold from timeout!
      whose-turn.game
    src.bowl
  ?.  =(whose-turn.game from)
    :_  state
    ~[[%give %poke-ack `~[leaf+"error: playing out of turn!"]]]
  :: poke ourself to set a turn timer
  =/  new-timer  (add now.bowl turn-time-limit.game)
  =.  turn-timer.u.host-game  new-timer
  =.  u.host-game
    =+  (~(process-player-action modify-game-state u.host-game) from action)
    ?~  -  ~|("%pokur-host: invalid action received!" !!)  u.-
  =.  games.state  (~(put by games.state) id.game u.host-game)
  =^  cards  state
    ?.  game-is-over.game
      ?.  hand-is-over.u.host-game
        (send-game-updates u.host-game)^state
      =.  u.host-game  (initialize-new-hand u.host-game)
      :-  (send-game-updates u.host-game)
      state(games (~(put by games.state) id.game u.host-game))
    ::  host handles paying winner(s) here
    (end-game-pay-winners u.host-game)
  :_  state
  %+  weld  cards
  ^-  (list card)
  :-  :*  %pass  /timer/(scot %da id.game)
          %arvo  %b  %wait
          ::  if hand is over, add 5s to next turn
          ?.  hand-is-over.u.host-game
            new-timer
          (add ~s5 new-timer)
      ==
  ?~  turn-timer.u.host-game
    :: there's no ongoing timer to cancel, just set new
    ~
  :: there's an ongoing turn timer, cancel it and set fresh one
  :_  ~
  :*  %pass  /timer/(scot %da id.game)
      %arvo  %b  %rest
      turn-timer.u.host-game
  ==
::
++  handle-player-action
  |=  action=player-action
  ^-  (quip card _state)
  ?+    -.action  !!
      %new-table
    ?<  (~(has by tables.state) id.action)
    ?>  (lte turn-time-limit.action ~s999)
    ?>  (gte turn-time-limit.action ~s10)
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
    ::  if game is tokenized, find bond on chain and validate
    ?>  ?|  ?=(~ tokenized.action)
            %-  ~(valid-new-table fetch [our now]:bowl our-info.state)
            [src.bowl [bond-id amount]:u.tokenized.action]
        ==
    ::  only handling tokenized %sng tables for now
    ?>  ?|  ?=(~ tokenized.action)
            ?=(%sng -.game-type.action)
        ==
    =+  (~(put by tables.state) id.action table)
    :_  state(tables -)
    :~  (lobby-update-card -)
        (table-share-card table)
    ==
  ::
      %join-table
    ::  add player to existing table
    ?~  table=(~(get by tables.state) id.action)  !!
    ::  table must not be full
    ?<  =(max-players.u.table ~(wyt in players.u.table))
    ::  if game is tokenized, check against
    ::  bond to see if player has paid in
    ?>  ?|  ?=(~ tokenized.u.table)
            %-  ~(valid-new-player fetch [our now]:bowl our-info.state)
            [src.bowl [bond-id amount]:u.tokenized.u.table]
        ==
    =.  players.u.table  (~(put in players.u.table) src.bowl)
    =+  (~(put by tables.state) id.action u.table)
    :_  state(tables -)
    :~  (lobby-update-card -)
        (table-share-card u.table)
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
    ::  if table was tokenized, refund all depositors
    ?:  =(0 ~(wyt in players.u.table))
      =+  (~(del by tables.state) id.action u.table)
      :_  state(tables -)
      :^    (lobby-update-card -)
          (table-closed-card id.action)
        (closed-table-card id.action)
      ?~  tokenized.u.table  ~
      :_  ~
      :*  %pass  /pokur-wallet-poke
          %agent  [our.bowl %uqbar]
          %poke  %wallet-poke
          !>
          :*  %transaction
              origin=~
              from=address.our-info.state
              contract=id.contract.host-info.u.table
              town=town.contract.host-info.u.table
              :-  %noun
              ^-  action:escrow
              :*  %refund
                  bond-id.u.tokenized.u.table
              ==
          ==
      ==
    =+  (~(put by tables.state) id.action u.table)
    :_  state(tables -)
    :~  (lobby-update-card -)
        (table-share-card u.table)
    ==
  ::
      %start-game
    ::  table creator starts game
    ?~  table=(~(get by tables.state) id.action)  !!
    ?>  =(leader.u.table src.bowl)
    ?>  (gte ~(wyt in players.u.table) min-players.u.table)
    ~&  >  "%pokur-host: starting new game {<id.action>}"
    =?    game-type.u.table
        ?=(%sng -.game-type.u.table)
      %=  game-type.u.table
        current-round  0
        round-is-over  %.n
      ==
    =/  =game
      :*  id.u.table
          game-is-over=%.n
          game-type.u.table
          turn-time-limit.u.table
          %+  turn  ~(tap in players.u.table)
          |=  =ship
          [ship starting-stack.game-type.u.table 0 %.n %.n %.n]
          pots=~[[0 ~(tap in players.u.table)]]
          current-bet=0
          last-bet=0
          last-aggressor=~
          board=~
          my-hand=~
          whose-turn=*ship
          dealer=*ship
          small-blind=*ship
          big-blind=*ship
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
          turn-timer=(add now.bowl turn-time-limit.u.table)
          tokenized.u.table
          placements=~
          game
      ==
    =.  tables.state  (~(del by tables.state) id.action)
    :_  state(games (~(put by games.state) id.action host-game-state))
    %+  welp
      :~  :*  %pass  /timer/(scot %da id.game)
              %arvo  %b  %wait
              turn-timer.host-game-state
          ==
          (game-starting-card id.u.table)
          (lobby-update-card tables.state)
      ==
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
      !!
    :: remove sender from their game
    =.  u.host-game
      (~(remove-player modify-game-state u.host-game) src.bowl)
    =*  game  game.u.host-game
    :: remove spectator if they were one
    =.  spectators.game
      (~(del in spectators.game) src.bowl)
    :-  (send-game-updates u.host-game)
    state(games (~(put by games.state) id.action u.host-game))
  ::
      %kick-player
    !!
    ::  ?~  table=(~(get by tables.state) id.action)
    ::    !!
    ::  ::  src must be table leader
    ::  ?>  =(src.bowl leader.u.table)
    ::  ::  table must be private
    ::  ?>  =(%.n public.u.table)
    ::  =-  [(lobby-update-card -)^~ state(tables -)]
    ::  %+  ~(put by tables.state)  id.action
    ::  u.table(players (~(del in players.u.table) who.action))
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
::  +send-game-updates: make update cards for players and spectators
::
++  send-game-updates
  |=  host-game=host-game-state
  ^-  (list card)
  ~&  >>>  "sending game updates"
  %+  weld
    %+  turn  ~(tap by hands.host-game)
    |=  [=ship hand=pokur-deck]
    ^-  card
    =.  my-hand.game.host-game  hand
    :^  %give  %fact
      ~[/game-updates/(scot %da id.game.host-game)/(scot %p ship)]
    [%pokur-host-update !>(`host-update`[%game game.host-game])]
  %+  turn  ~(tap in spectators.game.host-game)
  |=  =ship
  ^-  card
  :^  %give  %fact
    ~[/game-updates/(scot %da id.game.host-game)/(scot %p ship)]
  [%pokur-host-update !>(`host-update`[%game game.host-game])]
::
++  game-over-updates
  |=  host-game=host-game-state
  ^-  (list card)
  %+  weld
    %+  turn  players.game.host-game
    |=  [=ship *]
    ^-  card
    :^  %give  %fact
      ~[/game-updates/(scot %da id.game.host-game)/(scot %p ship)]
    [%pokur-host-update !>(`host-update`[%game-over [id.game placements]:host-game])]
  %+  turn  ~(tap in spectators.game.host-game)
  |=  =ship
  ^-  card
  :^  %give  %fact
    ~[/game-updates/(scot %da id.game.host-game)/(scot %p ship)]
  [%pokur-host-update !>(`host-update`[%game-over [id.game placements]:host-game])]
::
++  initialize-new-hand
  |=  host-game=host-game-state
  ^-  host-game-state
  =.  deck.host-game  (shuffle-deck deck.host-game eny.bowl)
  %-  ~(initialize-hand modify-game-state host-game)
  dealer.game.host-game
::
++  end-game-pay-winners
  |=  host-game=host-game-state
  ^-  (quip card _state)
  :_  state(games (~(del by games.state) id.game.host-game))
  %+  welp
    (game-over-updates host-game)
  :-  :*  %pass  /timer/(scot %da id.game.host-game)
          %arvo  %b  %rest
          turn-timer.host-game
      ==
  ::  if game isn't tokenized, just delete
  ?~  tokenized.host-game
    ~
  ::  pay based on game type (only handling %sng now)
  ::  TODO handle cash
  ?>  ?=(%sng -.game-type.game.host-game)
  =/  total-payout=@ud
    %-  ~(total-payout fetch [our now]:bowl our-info.state)
    bond-id.u.tokenized.host-game
  ~&  >  "pokur-host: awarding players in game {<id.game.host-game>}"
  ~&  >  "payouts: {<payouts.game-type.game.host-game>}"
  ~&  >  "placements: {<placements.host-game>}"
  =<  p
  %^  spin  payouts.game-type.game.host-game  0
  |=  [award-pct=@ud place=@ud]
  ::  build an award transaction for each paid placement
  ::  automatically sign+submit these by poking %wallet
  ::  in advance to automate txns from this origin
  ^-  [card @ud]
  :_  +(place)
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
          :*  %award
              bond-id.u.tokenized.host-game
              (snag place placements.host-game)
              ::  calculate payout
              ::  TODO verify this is accurate
              %+  mul  award-pct
              (div total-payout 100)
          ==
      ==
  ==
::
++  valid-sng-spec
  |=  act=player-action
  ^-  ?
  ?.  ?=(%new-table -.act)  %.n
  ?.  ?=(%sng -.game-type.act)  %.n
  ?.  (gte min-players.act (lent payouts.game-type.act))  %.n
  =(100 (roll payouts.game-type.act add))
::
++  table-share-card
  |=  =table
  ^-  card
  ::  TODO put gossip here, for now just share with central ship
  :*  %pass   /table-share
      %agent  [fixed-lobby-source %pokur-host]
      %poke   %pokur-host-action
      !>(`host-action`[%share-table table])
  ==
::
++  closed-table-card
  |=  id=@da
  ^-  card
  ::  TODO put gossip here, for now just share with central ship
  :*  %pass   /table-share
      %agent  [fixed-lobby-source %pokur-host]
      %poke   %pokur-host-action
      !>(`host-action`[%closed-table id])
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
++  lobby-update-card
  |=  m=(map @da table)
  ^-  card
  :^  %give  %fact  ~[/lobby-updates]
  :-  %pokur-host-update
  !>(`host-update`[%lobby (public-tables m)])
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
