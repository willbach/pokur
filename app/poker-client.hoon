/-  *poker
/+  default-agent, dbug, *poker
|%
+$  versioned-state
    $%  state-zero
    ==
+$  state-zero
    $:  %0
        current-game=poker-game-state
        challenges-sent=(map @ud poker-challenge)
        challenges-received=(map @ud poker-challenge)
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
  ~&  >  '%poker-client initialized successfully'
  ::  =.  state  [%0 
  `this
++  on-save
  ^-  vase
  !>(state)
++  on-load
  |=  old-state=vase
  ^-  (quip card _this)
  ~&  >  '%poker-client recompiled successfully'
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
      %poker-client-action
      ~&  >>>  !<(client-action:poker vase)
      =^  cards  state
      (handle-client-action:hc !<(client-action:poker vase))
      [cards this]
  ==
::
++  on-watch
  |=  =path
  ^-  (quip card _this)
  ?+     path  (on-watch:def path)
      [%game ~]
        ~&  >>  "got subscription from {<src.bowl>}"  `this
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
++  handle-client-action
  |=  =client-action:poker
  ^-  (quip card _state)
  ?-    -.client-action
          :: :poker-client &poker-client-action [%issue-challenge ~bus [game-id=100 challenger=~zod players=~[~zod ~bus] host=~zod type=%cash]]
          %issue-challenge
        =.  challenges-sent.state  
          (~(put by challenges-sent.state) [game-id.challenge.client-action challenge.client-action])
        :_  state
        ~[[%pass /poke-wire %agent [to.client-action %poker-client] %poke %poker-client-action !>([%receive-challenge challenge=challenge.client-action])]]
          ::
          ::
          :: :poker-client &poker-client-action [%accept-challenge 100]
          %accept-challenge
        =/  challenge  
          (~(get by challenges-received.state) challenge-id.client-action)
        ?~  challenge
          ~&  >>>  "error: no challenge with that id exists"
          :_  state
          ~[[%give %poke-ack `~[leaf+"error: no challenge with that id exists"]]]
        :_  state
        ~[[%pass /poke-wire %agent [challenger.u.challenge %poker-client] %poke %poker-client-action !>([%challenge-accepted by=our.bowl challenge-id=challenge-id.client-action])]]
          ::
          ::
          %receive-challenge
        =.  challenges-received.state  
          (~(put by challenges-received.state) [game-id.challenge.client-action challenge.client-action])
        :_  state
        ~&  >  "got challenged to poker game by {<src.bowl>}, challenge id: {<game-id.challenge.client-action>}"
        ~
          ::
          ::
          %challenge-accepted
        :_  state
        ~&  >  "challenge accepted!"
        ~
    ::    %increase-counter
    ::  =.  counter.state  (add step.action counter.state)
    ::  :_  state
    ::  ~[[%give %fact ~[/counter] [%atom !>(counter.state)]]]
    ::  ::
    ::    %poke-remote
    ::  :_  state
    ::  ~[[%pass /poke-wire %agent [target.action %poketime] %poke %noun !>([%receive-poke 99])]]
    ::  ::
    ::    %poke-self
    ::  :_  state
    ::  ~[[%pass /poke-wire %agent [target.action %poketime] %poke %noun !>(%poke-self)]]
    ::  ::
    ::    %subscribe
    ::  :_  state
    ::  ~[[%pass /counter/(scot %p host.action) %agent [host.action %poketime] %watch /counter]]
    ::  ::
    ::    %leave
    ::  :_  state
    ::  ~[[%pass /counter/(scot %p host.action) %agent [host.action %poketime] %leave ~]]
    ::  ::
    ::    %kick
    ::  :_  state
    ::  ~[[%give %kick paths.action `subscriber.action]]
    ::  ::
    ::    %bad-path
    ::  :_  state
    ::  ~[[%pass /bad-path/(scot %p host.action) %agent [host.action %poketime] %watch /bad-path]]
  ==
--
