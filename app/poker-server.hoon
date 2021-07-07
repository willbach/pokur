/-  *poker
/+  default-agent, dbug, *poker
|%
+$  versioned-state
    $%  state-zero
    ==
+$  state-zero
    $:  %0
        active-games=(map @ud server-game-state) 
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
  ~&  >  '%poker-server initialized successfully'
  ::  =.  state  [%0 
  `this
++  on-save
  ^-  vase
  !>(state)
++  on-load
  |=  old-state=vase
  ^-  (quip card _this)
  ~&  >  '%poker-server recompiled successfully'
  `this(state !<(versioned-state old-state))
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?+    mark  (on-poke:def mark vase)
      %noun
    ?+    q.vase  (on-poke:def mark vase)
        %print-state
      ~&  >  state
      ~&  >>  bowl  `this
      ::
        %print-subs
      ~&  >>  &2.bowl  `this
    ==
    ::
    %poker-server-action
    :: ~&  >>>  !<(server-action:poker vase)
    =^  cards  state
    (handle-server-action:hc !<(server-action:poker vase))
    [cards this]
    ::
    %poker-game-action
    ~&  >  !<(game-action:poker vase)
    =^  cards  state
    (handle-game-action:hc !<(game-action:poker vase))
    [cards this]
  ==
::
++  on-watch
  |=  =path
  ^-  (quip card _this)
  ::  ~&  >  "sub::: {<path>}"
  ?+  path  (on-watch:def path)
    [%game @ta @ta ~]
  :: make sure the subscriber is in game and on their path, reject if not
  =/  game-id  `(unit @ud)`(slaw %ud i.t.path)
  ?~  game-id
    :_  this
      =/  err  "invalid game id {<game-id>}"
      :~  [%give %watch-ack `~[leaf+err]]
    == 
  =/  game  (~(get by active-games.state) u.game-id)
  ?~  game
    ~&  >>  "current state: {<active-games.state>}"
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
  ?~  (find [u.player]~ players.game.u.game)
    :_  this
      =/  err  "player not in this game"
      :~  [%give %watch-ack `~[leaf+err]]
    ==
  ?>  =(src.bowl u.player)
    `this
  ==
++  on-leave
  |=  =path
  ~&  "got leave request from {<src.bowl>}"  `this
++  on-peek   on-peek:def
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  ?+  wire  (on-agent:def wire sign)
    [%game ~]
      ?+  -.sign  (on-agent:def wire sign)
          %fact
        =/  deck=%poker-deck  !<(%poker-deck q.cage.sign)
        ~&  >>  "deck from {<src.bowl>} is {<deck>}"
        `this
        ==
  ==
++  on-arvo   on-arvo:def
++  on-fail   on-fail:def
--
::  start helper core
|_  bowl=bowl:gall
++  get-game-by-id
  |=  game-id=@ud
  ^-  server-game-state
  ::  obviously add error handling to this
  (~(got by active-games.state) game-id)
++  generate-update-cards
  |=  game=server-game-state
  ^-  (list card)
  ?.  hand-is-over.game
    ~[[%pass /poke-wire %agent [our.bowl %poker-server] %poke %poker-server-action !>([%send-game-updates game])]]
  :: initialize new hand
  ~[[%pass /poke-wire %agent [our.bowl %poker-server] %poke %poker-server-action !>([%initialize-hand game-id.game.game])]]
++  handle-game-action
  |=  action=game-action:poker
  ^-  (quip card _state)
  :: state changes will throw an error if a player who's not in a game
  :: or playing out-of-turn tries to register a move, but let's check here
  :: anyways that the person poking us is a member of the game they are poking...
  ?-  -.action
  :: TODO: how do i avoid repeating all this code?
      %check
    =/  game  (get-game-by-id game-id.action)
    =.  game  (~(process-player-action modify-state game) src.bowl [%check game-id=game-id.action])
    =.  active-games.state
      (~(put by active-games.state) [game-id.action game])
    :_  state
      (generate-update-cards game)  
      %bet
    =/  game  (get-game-by-id game-id.action)
    =.  game  (~(process-player-action modify-state game) src.bowl [%bet game-id=game-id.action amount=amount.action])
    =.  active-games.state
      (~(put by active-games.state) [game-id.action game])
    :_  state
      (generate-update-cards game)  
      %fold
    =/  game  (get-game-by-id game-id.action)
    =.  game  (~(process-player-action modify-state game) src.bowl [%fold game-id=game-id.action])
    =.  active-games.state
      (~(put by active-games.state) [game-id.action game])
    :_  state
      (generate-update-cards game)
  ==
++  handle-server-action
  |=  =server-action:poker
  ^-  (quip card _state)
  ?-  -.server-action
    %register-game
  ~&  >>  "Game initiated with server {<our.bowl>}."
  =/  new-game-state
    [
      game-id=game-id.challenge.server-action  
      host=host.challenge.server-action
      type=type.challenge.server-action
      players=players.challenge.server-action
      paused=%.n
      hands-played=0
      chips=(turn players.challenge.server-action |=(a=ship [a 1.000 0 %.n]))
      pot=0
      current-bet=0
      min-bet=40
      board=~
      my-hand=~
      whose-turn=(snag 1 players.challenge.server-action)
      dealer=(snag 1 players.challenge.server-action)  :: heads-up specific
      small-blind=(snag 1 players.challenge.server-action)
      big-blind=(snag 0 players.challenge.server-action)
    ]
  =/  new-server-state
    [
      game=new-game-state
      hands=~
      deck=(shuffle-deck generate-deck eny.bowl)
      hand-is-over=%.y
    ]
  =.  active-games.state
    (~(put by active-games.state) [game-id.challenge.server-action new-server-state])
  :_  state
    ~
    ::
    :: :poker-server &poker-server-action [%initialize-hand 1]
    %initialize-hand
  =/  game  (get-game-by-id game-id.server-action)
    :: first, shuffle
  =.  deck.game
    (shuffle-deck deck.game eny.bowl)
  =/  game
    (~(initialize-hand modify-state game) dealer.game.game)
  =/  cards
    (turn hands.game |=(hand=[ship poker-deck] (~(make-player-cards modify-state game) hand)))
  =.  active-games.state
    (~(put by active-games.state) [game-id.server-action game])
  :_  state
    cards
    ::
    ::
    %send-game-updates
  =/  cards
    (turn hands.game.server-action |=(hand=[ship poker-deck] (~(make-player-cards modify-state game.server-action) hand)))
  :_  state
    cards
    ::
    ::
    %kick
  :_  state
    ~[[%give %kick paths.server-action `subscriber.server-action]]  
    ::
    ::
    %wipe-all-games :: for debugging, mostly
  =.  active-games.state
    ~  
  ~&  >>>  "server wiped"
  :_  state
    ~
  ==
--
