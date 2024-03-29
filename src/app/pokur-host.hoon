/-  *pokur, wallet=zig-wallet, ui=zig-indexer
/+  default-agent, dbug, io=agentio, verb,
    *pokur-game-logic, *pokur-chain
|%
+$  card  card:agent:gall
+$  state-1
  $:  %1
      our-info=host-info
      ::  keep a last-poked time to drop offline watchers
      ::  if null, they're all caught up -- can send freely
      lobby-watchers=(map @p (unit @da))
      ::  host holds its own tables as well as gossipped ones from main host
      ::  tables can either be tournaments that have *not* started, or cash
      ::  tables that have or have not started (shown by is-active).
      tables=(map @da table)
      ::  host holds all active games they are running
      games=(map @da host-game-state)
  ==
--
^-  agent:gall
%+  verb  &
%-  agent:dbug
=|  state=state-1
=<
|_  =bowl:gall
+*  this  .
    def   ~(. (default-agent this %|) bowl)
    hc    ~(. +> bowl)
::
++  on-init
  ^-  (quip card _this)
  :_  this(state *state-1)
  (approve-origin-poke:hc /awards)^~
::
++  on-save
  ^-  vase
  !>(state)
::
++  on-load
  |=  old=vase
  ^-  (quip card _this)
  =/  old-state
    ::  if the old versioned state does not match what we expect, just
    ::  bunt for a fresh new state.
    ?~  new=((soft state-1) q.old)
      *state-1
    u.new
  :_  this(state old-state)
  (approve-origin-poke:hc /awards)^~
::
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
      ::  handle pokebacks from wallet
      (handle-wallet-update:hc !<(wallet-update:wallet vase))
    ==
  [cards this]
::
++  on-arvo
  |=  [=wire =sign-arvo]
  ^-  (quip card _this)
  ?+    wire  (on-arvo:def wire sign-arvo)
      [%timer @ %round-timer ~]
    ::  ROUND TIMER wire (for tournaments)
    =/  game-id  (slav %da i.t.wire)
    ?~  host-game=(~(get by games.state) game-id)  `this
    =*  game  game.u.host-game
    ::  if no players left in game, end it!
    ?:  %+  levy  players.game
        |=([ship @ud @ud ? ? left=?] left)
      =^  cards  state
        (end-game-pay-winners u.host-game)
      [cards this]
    ::  otherwise, set game to begin next round and end of hand
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
      [%timer @ @ ~]  ::  what game and who timed out
    ::  TURN TIMER wire
    ::  the timer ran out: a player didn't make a move in time
    =/  game-id  (slav %da i.t.wire)
    =/  who      (slav %p i.t.t.wire)
    ::  find whose turn it is
    ?~  host-game=(~(get by games.state) game-id)  `this
    =*  game  game.u.host-game
    ::  if no players left in game, end it
    ?:  %+  levy  players.game
        |=([ship @ud @ud ? ? left=?] left)
      =^  cards  state
        (end-game-pay-winners u.host-game)
      [cards this]
    ?.  =(who whose-turn.game)
      ::  erroneous turn timer, simply ignore
      `this
    ::  player whose turn it was indeed timed out
    ::  reset that game's turn timer
    =.  turn-timer.u.host-game  *@da
    :_  this(games.state (~(put by games.state) game-id u.host-game))
    ?~  inf=(get-player-info:~(gang guts u.host-game) whose-turn.game)
      ~
    :_  ~
    :*  %pass  /self-poke-wire
        %agent  [our.bowl %pokur-host]
        %poke  %pokur-game-action
        !>  ^-  game-action
        ?:  =(current-bet.game committed.u.inf)
          [%check game-id ~]
        [%fold game-id ~]
    ==
  ==
::
++  on-peek
  ::  TODO add scries
  on-peek:def
::
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  ?+    wire  (on-agent:def wire sign)
    ::  TODO add verification of some receipts on-batch?
      [%share-escrow-poke ~]
    ::  record an ack from a lobby-watcher
    `this(lobby-watchers.state (~(put by lobby-watchers.state) src.bowl ~))
  ::
      [%lobby-updates ~]
    ::  record an ack from a lobby-watcher
    `this(lobby-watchers.state (~(put by lobby-watchers.state) src.bowl ~))
  ==
::
++  on-watch  on-watch:def
++  on-leave  on-leave:def
++  on-fail   on-fail:def
--
::  start helper core
|_  bowl=bowl:gall
++  handle-host-action
  |=  action=host-action
  ^-  (quip card _state)
  ?>  =(our src):bowl
  ?+    -.action  !!
      %host-info
    =/  pruned-watchers
      (prune-watchers lobby-watchers.state)
    :_  state(our-info +.action, lobby-watchers pruned-watchers)
    ::  poke our new info out to all lobby-watchers
    ^-  (list card)
    %+  turn  ~(tap in ~(key by pruned-watchers))
    |=(=ship (share-escrow-poke ship +.action))
  ::
      %turn-timers
    ::  super lame & annoying indirection poke because %behn automatically
    ::  inserts src.bowl into the path of a timer, for no good reason.
    :_  state
    ^-  (list card)
    :-  :*  %pass  /timer/(scot %da id.action)/(scot %p who.action)
            %arvo  %b  %wait
            wake.action
        ==
    ?:  =(*@da rest.action)  ~
    :_  ~
    :*  %pass  /timer/(scot %da id.action)/(scot %p pre.action)
        %arvo  %b  %rest
        rest.action
    ==
  ::
      %clear-lobby-watchers
    `state(lobby-watchers ~)
  ::
      %kick-table
    ::  debugging tool for hosts
    ::  **DOES NOT REFUND PLAYERS**
    :_  state(tables (~(del by tables.state) id.action))
    (table-closed-cards id.action)
  ::
      %kick-game
    ::  debugging tool for hosts
    ::  **DOES NOT REFUND PLAYERS**
    `state(games (~(del by games.state) id.action))
  ==
::
++  handle-game-action
  |=  action=game-action
  ^-  (quip card _state)
  ?~  host-game=(~(get by games.state) game-id.action)
    :_  state
    ~[[%give %poke-ack `~[leaf+"error: host could not find game"]]]
  ::  validate that move is from right player
  =/  from=ship
    ?:  =(src our):bowl
      ::  automatic fold from timeout!
      whose-turn.game.u.host-game
    src.bowl
  ?.  =(whose-turn.game.u.host-game from)
    :_  state
    ~[[%give %poke-ack `~[leaf+"error: playing out of turn!"]]]
  =+  (~(process-player-action guts u.host-game) from action)
  ?~  -
    ~&  >>>  "received 'invalid action' from {<src.bowl>}"
    ~&  >>>  action
    ~&  >>  game.u.host-game
    :_  state
    ~[[%give %poke-ack `~[leaf+"error: invalid action received!"]]]
  ::
  (resolve-player-turn u.- from)
::
++  handle-player-txn
  |=  [act=txn-player-action on-batch=?]
  ^-  (quip card _state)
  ::  for all txn-actions:
  ::  - check that sequencer matches our known sequencer for the town
  ::  - validate their uqbar-sig
  ?>  (~(valid receipt sequencer-receipt.act) [our now]:bowl)
  ?-    -.act
      %new-table-txn
    ?>  ?=(%new-table -.player-action.act)
    ?~  tokenized.player-action.act  !!
    =/  =bond:escrow
      %-  need
      %-  ~(get-bond receipt sequencer-receipt.act)
      bond-id.u.tokenized.player-action.act
    ::  - assert output includes a bond item from our escrow contract,
    ::    and that the bond contains the amount specified by table,
    ::    from the poke sender
    ?>  =(custodian.bond address.our-info.state)
    ?>  .=  amount.u.tokenized.player-action.act
        amount:(~(got py:smart depositors.bond) src.bowl)
    (handle-player-action player-action.act tokenized=%.y)
  ::
      %join-table-txn
    ?>  ?=(%join-table -.player-action.act)
    ?~  table=(~(get by tables.state) id.player-action.act)  !!
    ?~  tokenized.u.table  !!
    =/  =bond:escrow
      %-  need
      %-  ~(get-bond receipt sequencer-receipt.act)
      bond-id.u.tokenized.u.table
    ::  - assert output includes a bond item from our escrow contract,
    ::    and that the bond contains the amount specified by table,
    ::    from the poke sender
    ?>  =(custodian.bond address.our-info.state)
    ?>  %+  lte  ::  lte in case they double-deposit
          ?-  -.game-type.u.table
            %sng   amount.u.tokenized.u.table
            %cash  buy-in.player-action.act
          ==
        amount:(~(got py:smart depositors.bond) src.bowl)
    (handle-player-action player-action.act tokenized=%.y)
  ==
::
++  handle-player-action
  |=  [action=player-action tokenized=?]
  ^-  (quip card _state)
  ?+    -.action  !!
      %watch-lobby
    ~&  >  "new player {<src.bowl>} joined lobby, sending tables available"
    :_  state(lobby-watchers (~(put by lobby-watchers.state) [src `now]:bowl))
    =/  cards=(list card)
      :_  ~
      %+  ~(poke pass:io /lobby-updates)
        [src.bowl %pokur]
      :-  %pokur-host-update
      !>(`host-update`[%lobby (public-tables tables.state)])
    ?:  =(0x0 address.our-info.state)  cards
    [(share-escrow-poke src.bowl our-info.state) cards]
  ::
      %stop-watching-lobby
    `state(lobby-watchers (~(del by lobby-watchers.state) src.bowl))
  ::
      %new-table
    ?>  |(tokenized ?=(~ tokenized.action))
    ?<  (~(has by tables.state) id.action)
    ?>  (lte turn-time-limit.action ~s999)
    ?>  (gte turn-time-limit.action ~s20)
    ?>  (gte min-players.action 2)
    ?>  (lte max-players.action 10)
    =/  =table
      :*  id.action
          is-active=%.n
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
    ?>  (valid-game-spec action)
    ::  if cash game, set player chip stack based on their token
    ::  buy-in and assert stack is between min and max
    =?  game-type.table  &(?=(^ tokenized.action) ?=(%cash -.game-type.table))
      =/  chips-bought=@ud
        ::  TODO handle tokens with nonstandard decimal amounts
        %+  div
          (mul amount.u.tokenized.action chips-per-token.game-type.table)
        1.000.000.000.000.000.000
      ?>  ?&  (gte chips-bought min-buy.game-type.table)
              (lte chips-bought max-buy.game-type.table)
          ==
      %=    game-type.table
          buy-ins
        (~(put by buy-ins.game-type.table) src.bowl chips-bought)
          tokens-in-bond
        (add tokens-in-bond.game-type.table amount.u.tokenized.action)
      ==
    ::  prune lobby watchers for offline ships
    =.  lobby-watchers.state
      (prune-watchers lobby-watchers.state)
    :_  state(tables (~(put by tables.state) id.action table))
    ?.  public.action  (private-table-cards table)
    (new-table-cards table)
  ::
      %join-table
    ::  add player to existing table
    ?~  table=(~(get by tables.state) id.action)  !!
    ?>  |(tokenized ?=(~ tokenized.u.table))
    ::  table must not be full
    ~|  "table is full!"
    ?<  =(max-players.u.table ~(wyt in players.u.table))
    =.  players.u.table  (~(put in players.u.table) src.bowl)
    ::  if cash game, set player chip stack based on their token
    ::  buy-in and assert stack is between min and max
    =?  game-type.u.table  ?=(%cash -.game-type.u.table)
      =/  chips-bought=@ud
        ::  TODO handle tokens with nonstandard decimal amounts
        %+  div
          (mul buy-in.action chips-per-token.game-type.u.table)
        1.000.000.000.000.000.000
      ?>  ?&  (gte chips-bought min-buy.game-type.u.table)
              (lte chips-bought max-buy.game-type.u.table)
          ==
      %=    game-type.u.table
          buy-ins
        (~(put by buy-ins.game-type.u.table) src.bowl chips-bought)
          tokens-in-bond
        (add tokens-in-bond.game-type.u.table buy-in.action)
      ==
    ::  if table is active, add the player directly to the ongoing game
    ::  otherwise just update table and share with subscribers
    =^  game-update-cards  games.state
      ?.  is-active.u.table
        `games.state
      =/  =host-game-state  (~(got by games.state) id.action)
      ::  for now, we just say that sit-n-go tables are closed,
      ::  and cash tables are open to new players
      ?>  ?=(%cash -.game-type.game.host-game-state)
      ?>  ?=(%cash -.game-type.u.table)
      =+  %+  ~(add-player guts host-game-state)
            src.bowl
          (~(got by buy-ins.game-type.u.table) src.bowl)
      :-  (send-game-updates - ~)
      (~(put by games.state) id.action -)
    ::  prune lobby watchers for offline ships
    =.  lobby-watchers.state
      (prune-watchers lobby-watchers.state)
    =+  (~(put by tables.state) id.action u.table)
    :_  state(tables -)
    %+  weld  game-update-cards
    ?.  public.u.table  (private-table-cards u.table)
    (new-table-cards u.table)
  ::
      %leave-table
    ::  remove player from existing table
    ?~  table=(~(get by tables.state) id.action)  !!
    ?.  (~(has in players.u.table) src.bowl)  `state
    =.  players.u.table  (~(del in players.u.table) src.bowl)
    ::  if all players left, close table
    ::  if table was tokenized, refund leaving player
    =/  award-card=(list card)
      ?~  tokenized.u.table  ~
      :_  ~
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
                  bond-id.u.tokenized.u.table
                  src.bowl
                  ?-  -.game-type.u.table
                    %sng   amount.u.tokenized.u.table
                    %cash  (~(got by buy-ins.game-type.u.table) src.bowl)
                  ==
              ==
          ==
      ==
    ?:  =(0 ~(wyt in players.u.table))
      =+  (~(del by tables.state) id.action)
      :_  state(tables -)
      %+  weld  (table-closed-cards id.action)
      award-card
    =+  (~(put by tables.state) id.action u.table)
    :_  state(tables -)
    ?.  public.u.table
      %+  weld  (private-table-cards u.table)
      award-card
    %+  weld  (new-table-cards u.table)
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
    ::  if tokenized, calculate total number of tokens paid into game
    ::  so that at end of game we can pay winners
    =?    tokenized.u.table
        ?=(^ tokenized.u.table)
      =/  total
        ?-  -.game-type.u.table
          %sng   (mul ~(wyt in players.u.table) amount.u.tokenized.u.table)
          %cash  tokens-in-bond.game-type.u.table
        ==
      tokenized.u.table(amount.u total)
    =/  =game
      :*  id.u.table
          game-is-over=%.n
          game-type.u.table
          turn-time-limit.u.table
          turn-start=(add now.bowl ~s5)
          ?-    -.game-type.u.table
              %sng
            %+  turn  player-order
            |=  =ship
            [ship starting-stack.game-type.u.table 0 %.n %.n %.n]
          ::
              %cash
            %+  turn  ~(tap by buy-ins.game-type.u.table)
            |=  [=ship buy-in=@ud]
            [ship buy-in 0 %.n %.n %.n]
          ==
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
    ::  remove table from lobby if tournament, set to active if not
    =.  tables.state
      ?-  -.game-type.u.table
        %sng   (~(del by tables.state) id.action)
        %cash  (~(put by tables.state) id.action u.table(is-active %.y))
      ==
    ::
    :_  state(games (~(put by games.state) id.action host-game-state))
    %+  weld  (game-starting-cards players.u.table id.u.table)
    %+  welp  (send-game-updates host-game-state ~)
    :-  %+  ~(poke pass:io /self-poke)
          [our.bowl %pokur-host]
        :-  %pokur-host-action
        !>  ^-  host-action
        :*  %turn-timers  id.game
            whose-turn.game.host-game-state  *@p
            turn-timer.host-game-state  *@da
        ==
    ::  initialize first round timer, if tournament style game
    ?.  ?=(%sng -.game-type.u.table)  ~
    :_  ~
    :*  %pass  /timer/(scot %da id.game)/round-timer
        %arvo  %b  %wait
        (add now.bowl round-duration.game-type.u.table)
    ==
  ::
      %leave-game
    ::  player leaves game
    ?~  host-game=(~(get by games.state) id.action)
      `state
    =/  player-info
      (get-player-info:~(gang guts u.host-game) src.bowl)
    ?.  |(?=(^ player-info) (~(has in spectators.game.u.host-game) src.bowl))
      `state
    =/  whose-turn-pre=@p  whose-turn.game.u.host-game
    :: remove sender from their game
    =?    u.host-game
        ?=(^ player-info)
      ~&  >>>  "removing player {<src.bowl>} from game."
      (~(remove-player guts u.host-game) src.bowl)
    :: remove spectator if they were one
    =.  spectators.game.u.host-game
      (~(del in spectators.game.u.host-game) src.bowl)
    ::  if player is leaving a cash game, award them tokens
    ::  in proportion to their stack when leaving the table.
    ::  TODO factor into arm
    =/  cash-cards=(list card)
      ?~  tokenized.u.host-game                   ~
      ?.  ?=(%cash -.game-type.game.u.host-game)  ~
      ?~  player-info                             ~
      %+  snoc
        ?~  table=(~(get by tables.state) id.action)  ~
        ?.  public.u.table  (private-table-cards u.table)
        (new-table-cards u.table)
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
                  bond-id.u.tokenized.u.host-game
                  src.bowl
                  ::  find token amount by multiplying stack by 10^18
                  ::  then dividing stack by chips-per-token.
                  ::  TODO handle nonstandard
                  %+  div
                    (mul stack.u.player-info 1.000.000.000.000.000.000)
                  chips-per-token.game-type.game.u.host-game
      ==  ==  ==
    =^  cards  state
      ::  check if player left on their turn
      ?.  =(src.bowl whose-turn-pre)
        ::  player left out of turn, check for game over
        ?:  game-is-over.game.u.host-game
          ::  leaving resulted in game ending, handle
          (end-game-pay-winners u.host-game)
        ::  game not over, just send update showing they left
        :-  (send-game-updates u.host-game ~)
        state(games (~(put by games.state) id.action u.host-game))
      ::  player left on their turn.
      (resolve-player-turn u.host-game whose-turn-pre)
    =?    lobby-watchers.state
        ?=(%cash -.game-type.game.u.host-game)
      (prune-watchers lobby-watchers.state)
    =?    tables.state
        ?=(%cash -.game-type.game.u.host-game)
      ::  if this is last player at table leaving,
      ::  remove the table from the lobby
      ?:  game-is-over.game.u.host-game
        (~(del by tables.state) id.action)
      ::  otherwise just modify
      %+  ~(jab by tables.state)
        id.action
      |=  =table
      table(players (~(del in players.table) src.bowl))
    [;:(weld cards cash-cards (table-closed-cards id.action)) state]
  ::
      %kick-player
    ?~  table=(~(get by tables.state) id.action)  !!
    ::  src must be table leader
    ?>  =(src.bowl leader.u.table)
    ::  table must be private
    ?>  =(%.n public.u.table)
    ::  player must be in table
    ?>  (~(has in players.u.table) who.action)
    =/  refund-card=(list card)
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
              contract=id.contract.our-info.state
              town=town.contract.our-info.state
              :-  %noun
              ^-  action:escrow
              :*  %award
                  bond-id.u.tokenized.u.table
                  who.action
                  ?-  -.game-type.u.table
                    %sng   amount.u.tokenized.u.table
                    %cash  (~(got by buy-ins.game-type.u.table) src.bowl)
                  ==
              ==
          ==
      ==
    :_  =-  state(tables -)
        %+  ~(put by tables.state)  id.action
        u.table(players (~(del in players.u.table) who.action))
    %+  weld  refund-card
    ?.  public.u.table
      (private-table-cards u.table)
    (new-table-cards u.table)
  ::
      %spectate-game
    ::  add a spectator to an ongoing *game* (not a table!)
    ?>  =(our.bowl host.action)
    =/  host-game  (~(got by games.state) id.action)
    ?>  spectators-allowed.game.host-game
    =.  spectators.game.host-game
      (~(put in spectators.game.host-game) src.bowl)
    :_  state(games (~(put by games.state) id.action host-game))
    :_  ~
    %+  ~(poke pass:io /game-updates)
      [src.bowl %pokur]
    pokur-host-update+!>(`host-update`[%game game.host-game ~])
  ==
::
++  handle-wallet-update
  |=  update=wallet-update:wallet
  ^-  (quip card _state)
  ?+    -.update  `state
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
  |=  [host-game=host-game-state whose-turn-pre=@p]
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
  ?:  game-is-over.game.host-game  cards
  %+  snoc  cards
  :*  %pass  /self-poke
      %agent  [our.bowl %pokur-host]
      %poke  %pokur-host-action
      !>  ^-  host-action
      :*  %turn-timers
          id.game.host-game
          whose-turn.game:(~(got by games.state) id.game.host-game)
          whose-turn-pre
          turn-timer.host-game
          old-timer
      ==
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
    =.  my-hand.game.host-game  ?~(h=(~(get by hands.host-game) ship) ~ u.h)
    %+  ~(poke pass:io /game-updates)
      [ship %pokur]
    pokur-host-update+!>(`host-update`[%game game.host-game last-board])
  %+  turn  ~(tap in spectators.game.host-game)
  |=  =ship
  %+  ~(poke pass:io /game-updates)
    [ship %pokur]
  pokur-host-update+!>(`host-update`[%game game.host-game last-board])
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
  %+  ~(poke pass:io /game-updates)
    [ship %pokur]
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
  ::  if cash game, remove from lobby
  =?    tables.state
      ?=(%cash -.game-type.game.host-game)
    (~(del by tables.state) id.game.host-game)
  ::  if non-token game, just delete and update
  ?~  tokenized.host-game
    :-  (game-over-updates host-game (turn placements.host-game |=(p=@p [p 0])))
    state(games (~(del by games.state) id.game.host-game))
  ::  pay tokens based on game type
  ?:  ?=(%cash -.game-type.game.host-game)
    ::  handle cash payout
    ::  game over means one player left at table. pay them their stack.
    =*  total-payout  tokens-in-bond.game-type.game.host-game
    =/  winner  (head placements.host-game)
    ~&  >  "winnings: {<total-payout>} to {<winner>}"
    ::
    :_  state(games (~(del by games.state) id.game.host-game))
    %+  snoc  (game-over-updates host-game ~[winner^total-payout])
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
              winner
            total-payout
    ==  ==
  ::  handle tournament payout
  =*  total-payout  amount.u.tokenized.host-game
  ~&  >  "pokur-host: awarding players in game {<id.game.host-game>}"
  ~&  >>  "placements: {<placements.host-game>}"
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
++  valid-game-spec
  |=  act=player-action
  ^-  ?
  ?.  ?=(%new-table -.act)  %.n
  ?:  ?=(%cash -.game-type.act)
    ::  cash games
    (gte max-buy.game-type.act min-buy.game-type.act)
  ::  sng games
  ?&  =(100 (roll payouts.game-type.act add))
      (gte min-players.act (lent payouts.game-type.act))
  ==
::
++  game-starting-cards
  |=  [players=(set @p) id=@da]
  ^-  (list card)
  %+  turn  ~(tap in (~(uni in players) ~(key by lobby-watchers.state)))
  |=  =ship
  %+  ~(poke pass:io /lobby-updates)
    [ship %pokur]
  pokur-host-update+!>(`host-update`[%game-starting id])
::
++  table-closed-cards
  |=  id=@da
  ^-  (list card)
  %+  turn  ~(tap in ~(key by lobby-watchers.state))
  |=  =ship
  %+  ~(poke pass:io /lobby-updates)
    [ship %pokur]
  pokur-host-update+!>(`host-update`[%table-closed id])
::
++  new-table-cards
  |=  =table
  ^-  (list card)
  %+  turn  ~(tap in ~(key by lobby-watchers.state))
  |=  =ship
  %+  ~(poke pass:io /lobby-updates)
    [ship %pokur]
  pokur-host-update+!>(`host-update`[%new-table table])
::
++  private-table-cards
  |=  =table
  ^-  (list card)
  %+  turn  ~(tap in players.table)
  |=  =ship
  %+  ~(poke pass:io /lobby-updates)
    [ship %pokur]
  pokur-host-update+!>(`host-update`[%new-table table])
::
++  share-escrow-poke
  |=  [who=@p =host-info]
  ^-  card
  %+  ~(poke pass:io /share-escrow-poke)  [who %pokur]
  pokur-host-action+!>(`host-action`[%host-info host-info])
::
++  approve-origin-poke
  |=  =wire
  ^-  card
  %+  ~(poke pass:io /pokur-wallet-poke)
    [our.bowl %wallet]
  :-  %wallet-poke
  !>  ^-  wallet-poke:wallet
  [%approve-origin [%pokur-host wire] [1 1.000.000]]
::
++  public-tables
  |=  m=(map @da table)
  ^-  (map @da table)
  %-  ~(gas by *(map @da table))
  %+  murn  ~(tap by m)
  |=  [key=@da =table]
  ?.  public.table  ~
  `[key table]
::
++  prune-watchers
  |=  watchers=(map @p (unit @da))
  ^+  watchers
  ::  configurable: remove watchers who have not ack'd a lobby-update
  ::  in the past 10 minutes. (watchers coming back online will always
  ::  know to request an update)
  ::  set their last-poked time to now, as well
  %-  ~(gas by *(map @p (unit @da)))
  %+  murn  ~(tap by watchers)
  |=  [p=@p da=(unit @da)]
  ?~  da  `[p `now.bowl]
  ?:  (gth (sub now.bowl u.da) ~m10)
    ~
  `[p `now.bowl]
--
