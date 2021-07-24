/-  *pokur
/+  default-agent, dbug, *pokur
|%
+$  versioned-state
    $%  state-zero
    ==
+$  state-zero
    $:  %0
        game=poker-game-state
        challenges-sent=(map ship pokur-challenge)
        challenges-received=(map ship pokur-challenge)
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
  ~&  >  '%pokur initialized successfully'
  =/  launchapp  [%launch-action !>([%add %pokur [[%basic 'pokur' '/~pokur/img/tile.png' '/~pokur'] %.y]])]
  =/  filea  [%file-server-action !>([%serve-dir /'~pokur' /app/pokur %.n %.n])]
  :_  this
  :~  [%pass /srv %agent [our.bowl %file-server] %poke filea]
      [%pass /pokur %agent [our.bowl %launch] %poke launchapp]
      ==
++  on-save
  ^-  vase
  !>(state)
++  on-load
  |=  old-state=vase
  ^-  (quip card _this)
  ~&  >  '%pokur recompiled successfully'
  `this(state !<(versioned-state old-state))
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?+    mark  (on-poke:def mark vase)
    %json
    ~&  >>  !<(json vase)
    `this
    ::
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
    %pokur-client-action
    ~&  >  !<(client-action:pokur vase)
    =^  cards  state
    (handle-client-action:hc !<(client-action:pokur vase))
    [cards this]
    ::
    %pokur-game-action
    ~&  >  !<(game-action:pokur vase)
    =^  cards  state
    (handle-game-action:hc !<(game-action:pokur vase))
    [cards this]
  ==
::
++  on-watch
  |=  =path
  ^-  (quip card _this)
  ?+    path  (on-watch:def path)
    [%challenge-updates ~]
    :: TODO we should send a new subscriber the list of active challenges sent & recieved
    `this
  ==
++  on-leave  on-leave:def
++  on-peek   on-peek:def
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  ::  ~&  >>  "smth on {<wire>}: {<-.sign>}" :: {<q.cage.sign>}"
  ?+    wire  (on-agent:def wire sign)
      [%game-updates @ta ~]
    ?+  -.sign  (on-agent:def wire sign)
        %fact
      =/  val=poker-game-state  !<(poker-game-state q.cage.sign)
      ~&  >  "New game state: {<val>}"
      =.  game.state
        val
      `this
    ==
  ==
++  on-arvo
  |=  [=wire =sign-arvo]
  ^-  (quip card _this)
  ?.  ?=(%bound +<.sign-arvo)
    (on-arvo:def wire sign-arvo)
  [~ this]
++  on-fail   on-fail:def
--
::  start helper core
::
|_  bowl=bowl:gall
++  handle-game-action
  |=  action=game-action:pokur
  ^-  (quip card _state)
  ?-  -.action
    %check
  :_  state
    ~[[%pass /poke-wire %agent [host.game.state %pokur-server] %poke %pokur-game-action !>([%check game-id=game-id.game.state])]]
    %bet
  :_  state
    ~[[%pass /poke-wire %agent [host.game.state %pokur-server] %poke %pokur-game-action !>([%bet game-id=game-id.game.state amount=amount.action])]]
    %fold
  :_  state
    ~[[%pass /poke-wire %agent [host.game.state %pokur-server] %poke %pokur-game-action !>([%fold game-id=game-id.game.state])]]
  ==
++  handle-client-action
  |=  =client-action:pokur
  ^-  (quip card _state)
  ?-  -.client-action
    :: :pokur &pokur-client-action [%issue-challenge ~bus 1 ~zod %cash]
    ::
    %issue-challenge
  ?>  (team:title [our src]:bowl)
  =/  challenge
    [
      game-id=game-id.client-action
      challenger=our.bowl
      players=~[our.bowl to.client-action] :: change this for multiplayer
      host=host.client-action
      type=type.client-action
    ]
  =.  challenges-sent.state  
    (~(put by challenges-sent.state) [to.client-action challenge])
  :_  state
    :~  :*  %pass  /poke-wire  %agent  [to.client-action %pokur] 
            %poke  %pokur-client-action  !>([%receive-challenge challenge=challenge])
          ==
        :*  %give  %fact  
            ~[/challenge-updates]
            [%pokur-challenge !>(challenge)]
        ==
    ==  
    ::
    %receive-challenge
  =.  challenges-received.state  
    (~(put by challenges-received.state) [challenger.challenge.client-action challenge.client-action])
  :_  state
    :~  :*  %give  %fact  
            ~[/challenge-updates]
            [%pokur-challenge !>(challenge.client-action)]
        ==
    ==
    :: :pokur &pokur-client-action [%accept-challenge ~zod]
    ::
    %accept-challenge
  ?>  (team:title [our src]:bowl)
  =/  challenge  
    (~(get by challenges-received.state) from.client-action)
  ?~  challenge
    :_  state
      ~[[%give %poke-ack `~[leaf+"error: no challenge from {<from.client-action>} exists"]]]
  =.  challenges-received.state
    (~(del by challenges-received.state) from.client-action)
  :_  state
    :~  :*  :: notify challenger that we've accepted
          %pass  /poke-wire  %agent  [from.client-action %pokur]
          %poke  %pokur-client-action  !>([%challenge-accepted by=our.bowl])
        ==
        :*  :: subscribe to path which game will be served from
          %pass  /poke-wire  %agent  [our.bowl %pokur]
          %poke  %pokur-client-action  !>([%subscribe game-id=game-id.u.challenge host=host.u.challenge])
        ==
      ==
    ::
    %challenge-accepted
  =/  challenge  
    (~(get by challenges-sent.state) by.client-action)
  ?~  challenge
    :_  state
      ~[[%give %poke-ack `~[leaf+"error: no challenge from {<by.client-action>} exists"]]]
  =.  challenges-sent.state
    (~(del by challenges-sent.state) by.client-action)
  :_  state
    :~
      :*  :: register game with server
        %pass  /poke-wire  %agent  [host.u.challenge %pokur-server]
        %poke  %pokur-server-action  !>([%register-game challenge=u.challenge])
      ==
      :*  :: subscribe to path which game will be served from
        %pass  /poke-wire  %agent  [our.bowl %pokur]
        %poke  %pokur-client-action  !>([%subscribe game-id=game-id.u.challenge host=host.u.challenge])
      ==
      :*  :: notify other player the game is registered
        %pass  /poke-wire  %agent  [by.client-action %pokur]
        %poke  %pokur-client-action  !>([%game-registered challenge=u.challenge])
      ==
    ==
    ::
    %game-registered
  :_  state
    :~  
      :*  :: request first hand initialization
        %pass  /poke-wire  %agent  [host.challenge.client-action %pokur-server]
        %poke  %pokur-server-action  !>([%request-hand-initialization game-id=game-id.challenge.client-action])
      ==
    ==
    ::
    %subscribe
  ?>  (team:title [our src]:bowl)
  :_  state
    :~  :*  %pass  /game-updates/(scot %ud game-id.client-action)
            %agent  [host.client-action %pokur-server]
            %watch  /game/(scot %ud game-id.client-action)/(scot %p our.bowl)
          ==
      ==
    ::
    %leave-game
  ?>  (team:title [our src]:bowl)  
  :_  state
  ~[[%pass /game-updates/(scot %ud game-id.client-action) %agent [host.game.state %pokur-server] %leave ~]]
  ==
--
