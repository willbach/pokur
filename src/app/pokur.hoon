/-  *pokur
/+  default-agent, dbug, *pokur
|%
+$  versioned-state
    $%  state-zero
    ==
+$  state-zero
    $:  in-game=?
        game=poker-game-state
        challenges-sent=(map @da pokur-challenge)
        challenges-received=(map @da pokur-challenge)
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
  =.  in-game.state  %.n
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
    =/  cards
      %+  turn
        %+  weld  
          ~(tap by challenges-received.state)
        ~(tap by challenges-sent.state)
      |=  item=[id=@da c=pokur-challenge]
      :^    %give
          %fact
        ~[/challenge-updates]
      [%pokur-challenge-update !>([%open-challenge c.item])]
    [cards this]
    ::
    [%game ~]
    ?:  in-game.state
      :_  this
        ~[[%give %fact ~[/game] [%pokur-game-update !>([%update game.state])]]]
    `this
  ==
++  on-leave  on-leave:def
++  on-peek   on-peek:def
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  ?+    wire  (on-agent:def wire sign)
      [%game-updates @ta ~]
    ?+  -.sign  (on-agent:def wire sign)
        %fact
      =/  new-state=poker-game-state  !<(poker-game-state q.cage.sign)
      ~&  >  "New game state: {<new-state>}"
      =.  game.state
        new-state
      :_  this
        ~[[%give %fact ~[/game] [%pokur-game-update !>([%update new-state])]]]
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
  ?>  (team:title [our src]:bowl)
  ?-  -.action
    %check
  :_  state
    :~  :*  %pass  /poke-wire  %agent 
            [host.game.state %pokur-server] 
            %poke  %pokur-game-action 
            !>([%check game-id=game-id.game.state])
        ==
    ==
    %bet
  :_  state
    :~  :*  %pass  /poke-wire  %agent 
            [host.game.state %pokur-server]
            %poke  %pokur-game-action
            !>([%bet game-id=game-id.game.state amount=amount.action])
        ==
    ==
    %fold
  :_  state
    :~  :*  %pass  /poke-wire  %agent
            [host.game.state %pokur-server]
            %poke  %pokur-game-action
            !>([%fold game-id=game-id.game.state])
        ==
    ==
  ==
++  handle-client-action
  |=  =client-action:pokur
  ^-  (quip card _state)
  ?-  -.client-action
    :: :pokur &pokur-client-action [%issue-challenge ~bus 1 ~zod %cash]
    ::
    %issue-challenge
  ?>  (team:title [our src]:bowl)
  =/  player-list  
    (weld to.client-action ~[our.bowl])
  =/  accepted-list
    %+  turn 
      to.client-action
    |=  s=ship
    [s %.n]
  =/  challenge
    [
      game-id=now.bowl
      challenger=our.bowl
      players=player-list
      accepted=accepted-list
      host=host.client-action
      min-bet=min-bet.client-action
      starting-stack=starting-stack.client-action
      type=type.client-action
    ]
  =.  challenges-sent.state  
    (~(put by challenges-sent.state) [game-id.challenge challenge])
  :_  state
    %+  welp 
      :~  :*  %give  %fact  
              ~[/challenge-updates]
              [%pokur-challenge-update !>([%open-challenge challenge])]
          ==
      ==
    %+  turn
      to.client-action
    |=  player=ship
    :*  %pass  /poke-wire  %agent  [player %pokur] 
        %poke  %pokur-client-action  !>([%receive-challenge challenge=challenge])
    ==
    ::
    %receive-challenge
  =.  challenges-received.state  
    (~(put by challenges-received.state) [game-id.challenge.client-action challenge.client-action])
  :_  state
    :~  :*  %give  %fact  
            ~[/challenge-updates]
            [%pokur-challenge-update !>([%open-challenge challenge.client-action])]
        ==
    ==
    :: :pokur &pokur-client-action [%accept-challenge ~zod]
    ::
    %accept-challenge
  ?>  (team:title [our src]:bowl)
  =/  challenge  
    (~(get by challenges-received.state) id.client-action)
  ?~  challenge
    :_  state
      ~[[%give %poke-ack `~[leaf+"error: no challenge from {<from.client-action>} exists"]]]
  =.  challenges-received.state
    (~(del by challenges-received.state) id.client-action)
  :_  state
    :~  :*  :: notify challenger that we've accepted
          %pass  /poke-wire  %agent  [from.client-action %pokur]
          %poke  %pokur-client-action  !>([%challenge-accepted by=our.bowl id=id.client-action])
        ==
    ==
    ::
    %challenge-accepted
  =/  challenge  
    (~(get by challenges-sent.state) id.client-action)
  ?~  challenge
    :_  state
      ~[[%give %poke-ack `~[leaf+"error: no challenge from {<by.client-action>} exists"]]]
  =.  accepted.u.challenge
    %+  turn
      accepted.u.challenge
    |=  [s=ship has=?]
    ?:  =(by.client-action s)
      [s %.y]
    [s has]
  ?.  %+  levy
        accepted.u.challenge
      |=  [s=ship has=?]
      has
    :: if not all have accepted, just wait and update stored challenge-sent
    =.  challenges-sent.state  
      (~(put by challenges-sent.state) [id.client-action u.challenge])
    :_  state
      ~
  :: otherwise, init game
  =.  challenges-sent.state
    (~(del by challenges-sent.state) id.client-action)
  :_  state
    %+  welp
      :~
        :*  :: register game with server
          %pass  /poke-wire  %agent  [host.u.challenge %pokur-server]
          %poke  %pokur-server-action  !>([%register-game challenge=u.challenge])
        ==
        :*  :: subscribe to path which game will be served from
          %pass  /poke-wire  %agent  [our.bowl %pokur]
          %poke  %pokur-client-action  !>([%subscribe game-id=game-id.u.challenge host=host.u.challenge])
        ==
      ==
    %+  turn
      players.u.challenge
    |=  player=ship
      :*  :: notify all players that the game is registered
        %pass  /poke-wire  %agent  [player %pokur]
        %poke  %pokur-client-action  !>([%game-registered challenge=u.challenge])
      ==
    ::
    %game-registered
  :_  state
    :~  :*  :: subscribe to path which game will be served from
          %pass  /poke-wire  %agent  [our.bowl %pokur]
          %poke  %pokur-client-action  
          !>([%subscribe game-id=game-id.challenge.client-action host=host.challenge.client-action])
        ==
    ==
    %subscribe
  ?>  (team:title [our src]:bowl)
  :: if we're already in a game, we need to leave it
  ?:  =(in-game.state %.y)
    :_  state
      ~[[%give %poke-ack `~[leaf+"error: leave current game before joining new one"]]]
  =.  in-game.state  %.y
  :_  state
    :~  :*  %pass  /game-updates/(scot %da game-id.client-action)
            %agent  [host.client-action %pokur-server]
            %watch  /game/(scot %da game-id.client-action)/(scot %p our.bowl)
          ==
        :*  %give  %fact  
            ~[/challenge-updates]
            [%pokur-challenge-update !>([%close-challenge game-id.client-action])]
        ==
    ==
    ::
    %leave-game
  ?>  (team:title [our src]:bowl)
  =.  in-game.state  %.n
  :_  state    
    :~  :: unsub from game's path
        :*  %pass  /game-updates/(scot %da game-id.client-action)
            %agent  [host.game.state %pokur-server]
            %leave  ~
        ==
        :: tell server we're leaving game
        :*  %pass  /poke-wire  %agent 
            [host.game.state %pokur-server] 
            %poke  %pokur-server-action
            !>([%leave-game game-id=game-id.game.state])
        ==
        :: tell frontend we left a game
        :*  %give  %fact
            ~[/game]  
            %pokur-game-update  !>([%left-game in-game.state])
        ==
    ==
  ==
--
