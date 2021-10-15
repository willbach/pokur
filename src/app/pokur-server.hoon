/-  *pokur
/+  default-agent, dbug, *pokur
|%
+$  versioned-state
    $%  state-zero
    ==
+$  state-zero
    $:  %0
        active-games=(map @da server-game-state) 
    ==
::
+$  card  card:agent:gall
::
--
%-  agent:dbug
=|  state=versioned-state
^-  agent:gall
=<
|_  =bowl:gall
+*  this      .
    def   ~(. (default-agent this %|) bowl)
    hc    ~(. +> bowl)
::
++  on-init
  ^-  (quip card _this)
  ~&  >  '%pokur-server initialized successfully'
  `this
++  on-save
  ^-  vase
  !>(state)
++  on-load
  |=  old-state=vase
  ^-  (quip card _this)
  ~&  >  '%pokur-server recompiled successfully'
  `this(state !<(versioned-state old-state))
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?+    mark  (on-poke:def mark vase)
      %noun
    ?+    q.vase  (on-poke:def mark vase)
        %print-state
      ~&  >  active-games.state  `this
      ::
        %print-subs
      ~&  >>  &2.bowl  `this
    ==
    ::
    %pokur-server-action
    =^  cards  state
    %-  handle-server-action:hc
    !<(server-action:pokur vase)
    [cards this]
    ::
    %pokur-game-action
    =^  cards  state
    %-  handle-game-action:hc 
    !<(game-action:pokur vase)
    [cards this]
  ==
::
++  on-watch
  |=  =path
  ^-  (quip card _this)
  ?+  path  (on-watch:def path)
    [%game @ta @ta ~]
  :: make sure the subscriber is in game and on their path, reject if not
  =/  game-id  `(unit @da)`(slaw %da i.t.path)
  ?~  game-id
    :_  this
      =/  err  "invalid game id {<game-id>}"
      :~  [%give %watch-ack `~[leaf+err]]
    == 
  =/  game  (~(get by active-games.state) u.game-id)
  ?~  game
    :_  this
      =/  err  "invalid game id {<u.game-id>}"
      :~  [%give %watch-ack `~[leaf+err]]
    ==
  =/  player  `(unit @p)`(slaw %p i.t.t.path)
  ?~  player
    :_  this
      =/  err  "invalid player"
      :~  [%give %watch-ack `~[leaf+err]]
    == 
  ?>  =(src.bowl u.player)
  ?~  (find [u.player]~ players.game.u.game)
    ?.  spectators-allowed.game.u.game
      :_  this
      =/  err  "player not in this game"
      :~  [%give %watch-ack `~[leaf+err]]
      ==
    :: give game state to a spectator
    :: add them to spectator list
    =.  spectators.game.u.game
    %+  weld
      spectators.game.u.game
    ~[src.bowl]
    =.  active-games.state
    (~(put by active-games.state) [u.game-id u.game])
    :_  this
    :~  :*  
          %give 
          %fact 
          ~[/game/(scot %da u.game-id)/(scot %p u.player)]
          [%pokur-game-state !>(game.u.game)]
        ==
    ==
  :: give a good subscriber their game state
  :: find their hand
  =.  my-hand.game.u.game
  +.-:(skim hands.u.game |=([s=ship h=pokur-deck] =(s u.player)))
  :_  this
    :~  :*  
          %give 
          %fact 
          ~[/game/(scot %da u.game-id)/(scot %p u.player)]
          [%pokur-game-state !>(game.u.game)]
        ==
    ==
  ==
++  on-leave
  |=  =path
  ~&  "pokur-server: got leave request from {<src.bowl>}"
  `this
++  on-peek   on-peek:def
++  on-agent  on-agent:def
++  on-arvo
  |=  [=wire =sign-arvo]
  ^-  (quip card _this)
  ?+  wire  (on-arvo:def wire sign-arvo)
  :: ROUND TIMER wire (for tournaments)
    [%timer @ta %round-timer ~]
  =/  game-id  (need `(unit @da)`(slaw %da i.t.wire))
  =/  game
    (~(get by active-games.state) game-id)
  ?~  game
    ~&  >>>  "pokur-server: round timer popped on non-existent game."
    :-  ~  this
  =/  game  u.game
  :: if no players left in game, poke ourselves to end it
  ?:  %+  levy
        chips.game.game
      |=  [ship @ud @ud ? ? left=?]
      left
    :_  this
    :~
      :*  %pass
          /poke-wire
          %agent
          [our.bowl %pokur-server]
          %poke
          %pokur-server-action
          !>([%end-game game-id.game.game])
      ==
    ==
  =.  game
  ~(increment-current-round modify-state game)
  =.  active-games.state
  (~(put by active-games.state) [game-id game])
  =/  cards
  :~  :*  %pass
          /poke-wire
          %agent
          [our.bowl %pokur-server]
          %poke
          %pokur-server-action
          !>([%send-game-updates game])
      ==
      :: set new round timer 
      :*  %pass
          /poke-wire
          %agent
          [our.bowl %pokur-server]
          %poke
          %pokur-server-action
          !>([%set-timer game-id %round `@da`(add now.bowl (need round-duration.game.game))])
      ==
  ==
  [cards this]
  :: TURN TIMER wire
    [%timer @ta ~]
  :: the timer ran out.. a player didn't make a move in time
  =/  game-id  (need `(unit @da)`(slaw %da i.t.wire))
  ~&  >>>  "pokur-server: Player timed out on game {<game-id>} at {<now.bowl>}"
  :: find active player in that game
  =/  game
    (~(get by active-games.state) game-id)
  ?~  game
    ~&  >>>  "server error: turn timeout on non-existent game."
    :-  ~  this
  =/  game  u.game
  :: if no players left in game, poke ourselves to end it
  ?:  %+  levy
        chips.game.game
      |=  [ship @ud @ud ? ? left=?]
      left
    :_  this
    :~
      :*  %pass
          /poke-wire
          %agent
          [our.bowl %pokur-server]
          %poke
          %pokur-server-action
          !>([%end-game game-id.game.game])
      ==
    ==
  :: reset that game's turn timer
  =.  turn-timer.game  ~
  :: push alert that player timed out
  ~&  >>  "pokur-server: {<whose-turn.game.game>} timed out."
  =.  update-message.game.game
    ["{<whose-turn.game.game>} timed out." ~]
  =.  active-games.state
  (~(put by active-games.state) [game-id game])
  =/  player-to-fold
    whose-turn.game.game
  =/  card
  :~
    :*  %pass
        /poke-wire
        %agent
        [our.bowl %pokur-server]
        %poke
        %pokur-game-action
        !>([%fold game-id.game.game])
    ==
  ==  
  :: (perform-move current-time player-to-fold game-id %fold 0)
  [card this]
  ==
++  on-fail   on-fail:def
--
::  start helper core
|_  bowl=bowl:gall
++  generate-update-cards
  |=  game=server-game-state
  ^-  (list card)
  ?.  game-is-over.game.game
    ?.  hand-is-over.game
      :~  :*  %pass
              /poke-wire
              %agent
              [our.bowl %pokur-server]
              %poke
              %pokur-server-action
              !>([%send-game-updates game])
          ==
      ==
    :: initialize new hand, update message to clients
    :~  :*  %pass
            /poke-wire
            %agent
            [our.bowl %pokur-server]
            %poke
            %pokur-server-action
            !>([%initialize-hand game-id.game.game])
        ==
    ==
  :: the game is over, end it
  :~  :*  %pass
          /poke-wire
          %agent
          [our.bowl %pokur-server]
          %poke
          %pokur-server-action
          !>([%end-game game-id.game.game])
      ==
  ==
++  perform-move
  |=  [time=@da who=ship game-id=@da move-type=@tas amount=@ud]
  ^-  (quip card _state)
  =/  game  (~(get by active-games.state) game-id)
  ?~  game
    :_  state
    ~[[%give %poke-ack `~[leaf+"error: server could not find game"]]]
  =/  game  u.game
  :: validate that move is from right player
  =/  from
    ?:  =(who our.bowl)
    :: automatic fold from timeout!
    whose-turn.game.game
  who
  ?.  =(whose-turn.game.game from)
    :_  state
    ~[[%give %poke-ack `~[leaf+"error: playing out of turn!"]]]
  :: poke ourself to set a turn timer
  =/  new-timer  `@da`(add time turn-time-limit.game.game)
  =/  timer-cards
  ?.  =(turn-timer.game ~)
    :: there's an ongoing turn timer, cancel it and set fresh one
    :~
      :*  %pass
          /poke-wire
          %agent
          [our.bowl %pokur-server]
          %poke
          %pokur-server-action
          !>([%cancel-timer game-id `@da`turn-timer.game])
      ==
      :*  %pass
          /poke-wire
          %agent
          [our.bowl %pokur-server]
          %poke
          %pokur-server-action
          !>([%set-timer game-id %turn new-timer])
      ==
    ==
  :: there's no ongoing timer to cancel, just set new
  :~
    :*  %pass
        /poke-wire
        %agent
        [our.bowl %pokur-server]
        %poke
        %pokur-server-action
        !>([%set-timer game-id %turn new-timer])
    ==
  ==
  =.  turn-timer.game  new-timer
  =.  game 
  ?:  =(move-type %bet)
    (~(process-player-action modify-state game) from [%bet game-id amount])
  ?:  =(move-type %check)
    (~(process-player-action modify-state game) from [%check game-id])
  (~(process-player-action modify-state game) from [%fold game-id])
  =.  active-games.state
  (~(put by active-games.state) [game-id game])
  :_  state
  %+  welp
    (generate-update-cards game)
  timer-cards
  
++  handle-game-action
  |=  action=game-action:pokur
  ^-  (quip card _state)
  ?-  -.action
      %check
    (perform-move now.bowl src.bowl game-id.action %check 0)
      %bet
    (perform-move now.bowl src.bowl game-id.action %bet amount.action)
      %fold
    (perform-move now.bowl src.bowl game-id.action %fold 0)
    :: server doesn't do these... yet.
      %receive-msg
    !!
      %send-msg
    !!
  ==
++  handle-server-action
  |=  =server-action:pokur
  ^-  (quip card _state)
  ?-  -.server-action
    %set-timer
  ?>  (team:title [our src]:bowl)
  =/  timer-path
  ?-  type.server-action
    %turn
  /timer/(scot %da game-id.server-action)
    %round
  /timer/(scot %da game-id.server-action)/round-timer
  ==
  :_  state
    :~
      :*  %pass
          timer-path
          %arvo
          %b
          %wait
          time.server-action
      ==
    ==
    ::
    %cancel-timer
  ?>  (team:title [our src]:bowl)
  :_  state
    :~
      :*  %pass
          /timer/(scot %da game-id.server-action)
          %arvo
          %b
          %rest
          time.server-action
      ==
    ==
    ::
    %register-game
  ~&  >>  "pokur-server: Game initiated with server {<our.bowl>}."
  =/  players
    %+  turn
      players.challenge.server-action
    |=  [player=ship ? ?]
    player
  =/  c-data  challenge.server-action
  :: TOURNAMENT STRUCTURE STORED HERE
  :: set values for tournament
  =/  round-duration
    ?-  type.c-data
      %cash
      ~
      %turbo
      (some ~m5)
      %fast
      (some ~m10)
      %slow
      (some ~m20)
    ==
  =/  min-bets-list
    ?:  =(type.c-data %cash)
      ~[min-bet.c-data]
    ~[20 40 60 100 150 200 300 400 600 800 1.000 1.500 2.000 3.000]
  =/  starting-stack
    ?-  type.c-data
      %cash
      starting-stack.c-data
      %turbo
      1.000
      %fast
      1.000
      %slow
      1.000
    ==
  =/  chips
    %+  turn
      players
    |=  player=ship
    [player starting-stack 0 %.n %.n %.n]
  =/  new-game-state
    [
      game-id=id.c-data
      game-is-over=%.n
      host=host.c-data
      type=type.c-data
      :: pad the turn timer 5s to account for latency
      :: TODO: workshop this once beta starts
      turn-time-limit=`@dr`(add ~s5 turn-time-limit.c-data)
      time-limit-seconds=time-limit-seconds.c-data
      players=players
      paused=%.n
      update-message=["Pokur game started, served by {<our.bowl>}" ~]
      hands-played=0
      chips=chips
      pots=~[[0 players]]
      current-round=0 :: stays at 0 for cash games
      round-over=%.n
      current-bet=0
      min-bets=min-bets-list
      round-duration=round-duration
      last-bet=0
      board=~
      my-hand=~
      whose-turn=(snag 1 players)
      dealer=(snag 1 players)  :: TODO this should be random perhaps?
      small-blind=~zod :: these get re-assigned in hand initialization,
      big-blind=~zod   :: ~zod is placeholder.
      spectators-allowed=spectators.c-data
      spectators=~
    ]
  =/  new-server-state
    :: this is where very first game timer is set
    [
      game=new-game-state
      hands=~
      deck=(shuffle-deck generate-deck eny.bowl)
      hand-is-over=%.y
      turn-timer=`@da`(add now.bowl turn-time-limit.new-game-state)
    ]
  =.  active-games.state
    (~(put by active-games.state) [id.c-data new-server-state])
  =/  init-cards
    :~  
      :*  %pass
          /poke-wire
          %agent 
          [our.bowl %pokur-server] 
          %poke
          %pokur-server-action 
          !>([%initialize-hand id.c-data])
      ==
      :: init first timer
      :*  %pass
          /poke-wire
          %agent
          [our.bowl %pokur-server]
          %poke
          %pokur-server-action
          !>([%set-timer id.c-data %turn turn-timer.new-server-state])
      ==
    ==
  :_  state
    :: init first *round timer*, if in tournament
    ?:  =(type.c-data %cash)  
      init-cards
    %+  weld
      init-cards
    :~
      :*  %pass
          /poke-wire
          %agent
          [our.bowl %pokur-server]
          %poke
          %pokur-server-action
          !>([%set-timer id.c-data %round `@da`(add now.bowl (need round-duration))])
      ==
    ==
    ::
    %leave-game
  =/  game  (~(get by active-games.state) game-id.server-action)
  ?~  game
    :_  state
    ~[[%give %poke-ack `~[leaf+"error: server could not find game"]]]
  =/  game  u.game
  :: remove sender from their game
  =/  game
    (~(remove-player modify-state game) src.bowl)
  :: remove spectator if they were one
  =.  spectators.game.game
  %+  skip
    spectators.game.game
  |=  s=ship
  =(s src.bowl)
  =.  active-games.state
    (~(put by active-games.state) [game-id.server-action game])
  :_  state
    (generate-update-cards game)
    ::
    %initialize-hand
  ?>  (team:title [our src]:bowl)
  =/  game  (~(get by active-games.state) game-id.server-action)
  ?~  game
    :_  state
    ~[[%give %poke-ack `~[leaf+"error: server could not find game"]]]
  =/  game  u.game
  :: first, shuffle
  =.  deck.game
  (shuffle-deck deck.game eny.bowl)
  =/  game
  (~(initialize-hand modify-state game) dealer.game.game)
  :: make cards to show players game state
  =/  cards
  %+  turn 
    hands.game 
  |=  hand=[ship pokur-deck]
  (~(make-player-cards modify-state game) hand)
  =.  active-games.state
    (~(put by active-games.state) [game-id.server-action game])
  :_  state
  ?:  =((lent spectators.game.game) 0)
    cards
  :: send spectator updates if any
  %+  weld
    cards
  %+  turn
    spectators.game.game
  |=  s=ship
  :^  %give 
      %fact 
      ~[/game/(scot %da game-id.server-action)/(scot %p s)]
      [%pokur-game-state !>(game.game)]
    ::
    ::
    %send-game-updates
  ?>  (team:title [our src]:bowl)
  =/  cards
    %+  turn 
        hands.game.server-action 
      |=  hand=[ship pokur-deck]
      (~(make-player-cards modify-state game.server-action) hand)
  :_  state
  ?:  =((lent spectators.game.game.server-action) 0)
    cards
  :: send spectator updates if any
  %+  weld
    cards
  %+  turn
    spectators.game.game.server-action
  |=  s=ship
  :^  %give 
      %fact 
      ~[/game/(scot %da game-id.game.game.server-action)/(scot %p s)]
      [%pokur-game-state !>(game.game.server-action)]
    ::
    ::
    %kick
  ?>  (team:title [our src]:bowl)
  :_  state
    :~  :*  %give
            %kick
            paths.server-action
            `subscriber.server-action
        ==
    ==  
    ::
    ::
    %end-game
  ?>  (team:title [our src]:bowl)
  =/  game  (~(get by active-games.state) game-id.server-action)
  ?~  game
    :_  state
    ~[[%give %poke-ack `~[leaf+"error: server could not find game"]]]
  =/  last-game-state  u.game
  =/  cancel-timer-card
  :~  :*  %pass
          /poke-wire
          %agent
          [our.bowl %pokur-server]
          %poke
          %pokur-server-action
          !>([%cancel-timer game-id.server-action `@da`turn-timer.u.game])
      ==
  ==
  ~&  "pokur-server: a game has ended: {<game-id.server-action>}"
  =.  -.update-message.game.last-game-state
    %+  weld
      "The game is now over!   "
    -.update-message.game.last-game-state 
  =.  active-games.state
  (~(del by active-games.state) game-id.server-action)
  :_  state
    %+  welp
      cancel-timer-card
    :~  :*  %pass
            /poke-wire
            %agent
            [our.bowl %pokur-server]
            %poke
            %pokur-server-action
            !>([%send-game-updates last-game-state])
        ==
    ==
    ::
    ::
    %wipe-all-games :: for debugging, mostly
  ?>  (team:title [our src]:bowl)
  =.  active-games.state
    ~  
  ~&  >>>  "server wiped"
  :_  state
    ~
  ==
--
