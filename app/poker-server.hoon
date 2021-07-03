/-  *poker
/+  default-agent, dbug, *poker
|%
+$  versioned-state
    $%  state-zero
    ==
::
+$  server-game-data
    $:  game=poker-game-state
        current-deck=poker-deck
        paused=?
    ==
+$  state-zero
    $:  %0
        active-games=(map @ud server-game-data) 
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
      ~&  >>>  !<(server-action:poker vase)
      =^  cards  state
      (handle-server-action:hc !<(server-action:poker vase))
      [cards this]
  ==
::
++  on-watch
  |=  =path
  ^-  (quip card _this)
  ~&  >  "sub::: {<path>}"
  ?+  path  (on-watch:def path)
    [%game @ta @ta ~]
  :: make sure the subscriber is in game and on their path, reject if not
  =/  game-id  `(unit @ud)`(slaw %ud i.t.path)
  ?~  game-id
    :_  this
      =/  err
        "invalid game id {<game-id>}"
      :~  [%give %watch-ack `~[leaf+err]]
    == 
  =/  game  (~(get by active-games.state) u.game-id)
  ?~  game
    ~&  >>  "current state: {<active-games.state>}"
    :_  this
      =/  err
        "invalid game id {<u.game-id>}"
      :~  [%give %watch-ack `~[leaf+err]]
    ==
  =/  player  `(unit @p)`(slaw %p i.t.t.path)
  ?~  player
    :_  this
      =/  err
        "invalid player"
      :~  [%give %watch-ack `~[leaf+err]]
    == 
  ?~  (find [u.player]~ players.game.u.game)
    ~&  >>  "players list: {<u.player>}"
    :_  this
      =/  err
        "player not in this game"
      :~  [%give %watch-ack `~[leaf+err]]
    ==
  ?>  =(src.bowl u.player)
  ~&  >>  "got subscription on {<game-id>}/{<u.player>} from {<src.bowl>}"  `this
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
++  handle-server-action
  |=  =server-action:poker
  ^-  (quip card _state)
  ?-    -.server-action
          %register-game
        ~&  >>  "Game initiated with server {<our.bowl>}."
        =/  new-game-state
          [
            game-id=game-id.challenge.server-action
            players=players.challenge.server-action
            host=host.challenge.server-action
            type=type.challenge.server-action
            chips=(turn players.challenge.server-action |=(a=ship [a 1.000]))
            current-hand=~
            current-board=~
          ]
        =/  new-game
          [
            game=new-game-state
            current-deck=(shuffle-deck generate-deck eny.bowl)
            paused=%.n
          ]
        =.  active-games.state
          (~(put by active-games.state) [game-id.challenge.server-action new-game])
        ~&  >  "umm game is {<active-games.state>}"
        :_  state
          ~[[%give %poke-ack `~[leaf+"uhhjej"]]]       
  ==
--
