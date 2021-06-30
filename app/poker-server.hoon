/-  *poker
/+  default-agent, dbug, *poker
|%
+$  versioned-state
    $%  state-zero
    ==
::
+$  server-game-state
    $:  game=poker-game-state
        current-deck=poker-deck
        paused=?
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
      %server-action
      ~&  >>>  !<(server-action:poker vase)
      =^  cards  state
      (handle-server-action:hc !<(server-action:poker vase))
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
++  handle-server-action
  |=  =server-action:poker
  ^-  (quip card _state)
  ?-    -.server-action
          %register-game
        :_  state
        ~&  >>  "yeah... loch..."
        ~
  ==
--
