/-  *pokur
/+  default-agent, dbug, *pokur
|%
+$  versioned-state
    $%  state-zero
    ==
+$  state-zero
    $:  game=(unit pokur-game-state)
        challenge-sent=(unit pokur-challenge) :: can only send 1 active challenge
        challenges-received=(map @da pokur-challenge)
        game-msgs-received=(list [from=ship msg=tape])
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
  =.  game.state  ~
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
      ::
        %print-challenge
      ~&  >>  challenge-sent.state  `this
      ::
        %print-challenges-received
      ~&  >>  challenges-received.state  `this
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
          ~(val by challenges-received.state)
        (drop challenge-sent.state)
      |=  item=pokur-challenge
      :^    %give
          %fact
        ~[/challenge-updates]
      [%pokur-challenge-update !>([%open-challenge item])]
    [cards this]
    ::
    [%game ~]
    ?~  game.state
      `this
    ~&  >  "CLIENT: sending current game state to subscriber"
    :_  this
      ~[[%give %fact ~[/game] [%pokur-game-update !>([%update u.game.state "-"])]]]
    [%game-msgs ~]
    ?~  game.state
      `this
    ~&  >  "CLIENT: sending game msgs"
    :_  this
      ~[[%give %fact ~[/game-msgs] [%pokur-game-update !>([%msgs game-msgs-received.state])]]]
  ==
++  on-leave  on-leave:def
++  on-peek   on-peek:def
:: Receives responses from pokes or subscriptions to other Gall agents
:: This is where updates are handled from the pokur-server to which we've subscribed.
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  ?+    wire  (on-agent:def wire sign)
      [%game-updates @ta ~]
    ?+  -.sign  (on-agent:def wire sign)
      %fact
      =/  new-state=pokur-game-state  
        !<(pokur-game-state q.cage.sign)
      =/  my-hand-eval
        =/  full-hand  (weld my-hand.new-state board.new-state)
        ?+  (lent full-hand)  100 :: fake rank number to induce "-"
          %5  (eval-5-cards full-hand)  
          %6  (eval-6-cards full-hand)  
          %7  -:(evaluate-hand full-hand)
        ==
      =.  game.state
        %-  some  new-state
      ~&  >  "CLIENT: receiving updated game state"
      :_  this
        ~[[%give %fact ~[/game] [%pokur-game-update !>([%update new-state (hierarchy-to-rank my-hand-eval)])]]]
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
::  start helper cores
::
|_  bowl=bowl:gall
++  handle-game-action
  |=  action=game-action:pokur
  ^-  (quip card _state)
  ?~  game.state
    :_  state
      ~[[%give %poke-ack `~[leaf+"Error: can't process action, not in game yet."]]]
  ?-  -.action
    %check
  ?>  (team:title [our src]:bowl)
  :_  state
    :~  :*  %pass  /poke-wire  %agent 
            [host.u.game.state %pokur-server] 
            %poke  %pokur-game-action 
            !>([%check game-id=game-id.u.game.state])
        ==
    ==
    %bet
  ?>  (team:title [our src]:bowl)
  :_  state
    :~  :*  %pass  /poke-wire  %agent 
            [host.u.game.state %pokur-server]
            %poke  %pokur-game-action
            !>([%bet game-id=game-id.u.game.state amount=amount.action])
        ==
    ==
    %fold
  ?>  (team:title [our src]:bowl)
  :_  state
    :~  :*  %pass  /poke-wire  %agent
            [host.u.game.state %pokur-server]
            %poke  %pokur-game-action
            !>([%fold game-id=game-id.u.game.state])
        ==
    ==
    %send-msg
  ?>  (team:title [our src]:bowl)
  :: poke should fail if we're not in a game
  =/  game  (need game.state)
  =/  cards
    %+  turn
      players.game
    |=  player=ship
    :*  %pass
        /poke-wire 
        %agent 
        [player %pokur]
        %poke
        %pokur-game-action
        !>([%receive-msg msg=msg.action])
    ==
  :_  state
    cards
    %receive-msg
  :: poke should fail if we're not in a game
  =/  game  (need game.state)
  :: this, but title matches a player in players.game.state???
  :: ?>  (team:title [our src]:bowl)
  =.  game-msgs-received.state
  %+  weld
    ~[[src.bowl msg.action]]
  game-msgs-received.state
  
  :: add it to our state (from: src.bowl)
  :: and update our subscribers
  :_  state
    :~  :*  %give
            %fact
            ~[/game-msgs]
            :-  %pokur-game-update
            !>([%msgs game-msgs-received.state])
        ==
    ==
  ==
++  handle-client-action
  |=  =client-action:pokur
  ^-  (quip card _state)
  ?-  -.client-action
  ::
  ::  Send challenges from our ship to others
    %issue-challenge
  ?>  (team:title [our src]:bowl)
  =/  player-list
  %+  turn 
    %+  weld 
      to.client-action 
    ~[our.bowl]
  |=  s=ship
  ?:  =(s our.bowl)
    :: [@p / accepted? / declined?]
    [s %.y %.n]
  [s %.n %.n]
  =/  turn-time-limit
  `@dr`+:(scan (trip turn-time-limit.client-action) crub:so)
  =/  challenge
    [
      id=now.bowl
      challenger=our.bowl
      players=player-list
      host=host.client-action
      min-bet=min-bet.client-action
      starting-stack=starting-stack.client-action
      type=type.client-action
      turn-time-limit=turn-time-limit
      time-limit-seconds=time-limit-seconds.client-action
    ]
  =.  challenge-sent.state  
    %-  some  challenge
  :_  state
    ::  tell our frontend that we've opened a challenge
    %+  welp 
      :~  :*  %give  %fact  
              ~[/challenge-updates]
              [%pokur-challenge-update !>([%open-challenge challenge])]
          ==
      ==
    :: poke every ship invited with the challenge
    %+  turn
      to.client-action
    |=  player=ship
    :*  %pass  /poke-wire  %agent  [player %pokur] 
        %poke  %pokur-client-action  !>([%receive-challenge challenge=challenge])
    ==
  ::
  ::  Cancel a challenge that we initiated
    %cancel-challenge
  ?>  (team:title [our src]:bowl)
  ?:  =(~ challenge-sent.state)
    :_  state
      ~[[%give %poke-ack `~[leaf+"error: you haven't issued a challenge yet."]]]
  =/  challenge  
    (need challenge-sent.state)
  ?.  =(id.challenge id.client-action)
    :_  state
      ~[[%give %poke-ack `~[leaf+"error: no challenge found with ID {<id.client-action>} to cancel."]]]
  =.  challenge-sent.state  ~
  :_  state
    :: tell our frontend we're closing a challenge
    %+  welp
      :~  :*  %give  %fact  
              ~[/challenge-updates]
              [%pokur-challenge-update !>([%close-challenge id.challenge])]
          ==
      ==
    :: poke every invited ship with an alert that the challenge has been closed
    :: unless they've already declined.
    %+  turn
      %+  skip
        players.challenge
      |=  [player=ship accepted=? declined=?]
      ?|  =(player our.bowl)
          declined
        ==
    |=  [player=ship accepted=? declined=?]
    :*  %pass  /poke-wire  %agent  [player %pokur] 
        %poke  %pokur-client-action  !>([%challenge-cancelled id=id.challenge])
    ==
  ::
  ::  Challenge cancelled: a ship that previously challenged us is cancelling it
    %challenge-cancelled
  ?.  (~(has by challenges-received.state) id.client-action)
    :_  state
      ~[[%give %poke-ack `~[leaf+"error: got a cancellation for a challenge from {<src.bowl>} that does not exist"]]]
  =.  challenges-received.state
    (~(del by challenges-received.state) id.client-action)
  :_  state
    :: alert the frontend of the update
    :~  :*  %give  %fact  
            ~[/challenge-updates]
            [%pokur-challenge-update !>([%close-challenge id.client-action])]
        ==
    ==
  ::
  ::  We've received a challenge from another ship
    %receive-challenge
  =.  challenges-received.state  
    (~(put by challenges-received.state) [id.challenge.client-action challenge.client-action])
  :_  state
    :: alert the frontend of the new challenge
    :~  :*  %give  %fact  
            ~[/challenge-updates]
            [%pokur-challenge-update !>([%open-challenge challenge.client-action])]
        ==
    ==
  ::  We've received a challenge UPDATE regarding a challenge
  ::  that we had previously received but not yet declined.
    %challenge-update
  ?.  (~(has by challenges-received.state) id.challenge.client-action)
    ?~  challenge-sent.state
      :_  state
        ~[[%give %poke-ack `~[leaf+"error: got an update for a challenge from {<src.bowl>} that you don't have."]]]
    ?.  =(id.challenge.client-action id.u.challenge-sent.state)
      :_  state
        ~[[%give %poke-ack `~[leaf+"error: got an update for a non-existent challenge that you didn't make."]]]
    =.  challenge-sent.state
      (some challenge.client-action)
    :_  state
    :: alert the frontend of the update
    :~  :*  %give  %fact  
            ~[/challenge-updates]
            [%pokur-challenge-update !>([%challenge-update challenge.client-action])]
        ==
    ==  
  :: just need to replace our stored version of the challenge with this update
  =.  challenges-received.state
    (~(put by challenges-received.state) [id.challenge.client-action challenge.client-action])
  :_  state
    :: alert the frontend of the update
    :~  :*  %give  %fact  
            ~[/challenge-updates]
            [%pokur-challenge-update !>([%challenge-update challenge.client-action])]
        ==
    ==
  ::
  ::  Accept a specific challenge that we've received
    %accept-challenge
  ?>  (team:title [our src]:bowl)
  =/  challenge  
    (~(get by challenges-received.state) id.client-action)
  ?~  challenge
    :_  state
      ~[[%give %poke-ack `~[leaf+"error: no challenge with that ID exists"]]]
  =.  challenges-received.state
    (~(del by challenges-received.state) id.client-action)
  :_  state
    :: notify challenger that we've accepted
    :: they'll notify the other ships in the lobby of this
    :~  :*  
          %pass  /poke-wire  %agent  [challenger.u.challenge %pokur]
          %poke  %pokur-client-action  !>([%challenge-accepted id=id.client-action])
        ==
    ==
  ::
  ::  Decline a specific challenge that we've received
    %decline-challenge
  ?>  (team:title [our src]:bowl)
  =/  challenge  
    (~(get by challenges-received.state) id.client-action)
  ?~  challenge
    :_  state
      ~[[%give %poke-ack `~[leaf+"error: no challenge with that ID exists"]]]
  =.  challenges-received.state
    (~(del by challenges-received.state) id.client-action)
  :_  state
    :: notify challenger that we've declined
    :: they'll notify the other ships in the lobby of this
    :~  :*  
          %pass  /poke-wire  %agent  [challenger.u.challenge %pokur]
          %poke  %pokur-client-action  !>([%challenge-declined id=id.client-action])
        ==
    ==
  ::
  ::  Poke from a ship we've challenged, notifying us that they've DECLINED
    %challenge-declined
  ?~  challenge-sent.state
    :_  state
      ~[[%give %poke-ack `~[leaf+"error: someone declined an invite to a challenge you didn't send."]]]
  =/  challenge  u.challenge-sent.state
  =.  players.challenge
    %+  turn
      players.challenge
    |=  [s=ship accepted=? declined=?]
    ?:  =(src.bowl s)
      [s %.n %.y]
    [s accepted declined]
  :_  state
      :: poke every non-declined ship with update
      %+  turn
        %+  skip
          players.challenge
        |=  [ship ? declined=?]
          declined
      |=  [player=ship ? ?]
      :*  %pass  /poke-wire  %agent  [player %pokur]
          %poke  %pokur-client-action  !>([%challenge-update challenge])
      ==
  ::
  ::  Poke from a ship we've challenged, notifying us that they've ACCEPTED
    %challenge-accepted
  ?~  challenge-sent.state
    :_  state
      ~[[%give %poke-ack `~[leaf+"error: someone accepted an invite to a challenge you didn't send."]]]
  =/  challenge  u.challenge-sent.state
  =.  players.challenge
    %+  turn
      players.challenge
    |=  [s=ship accepted=? declined=?]
    ?:  =(src.bowl s)
      [s %.y declined]
    [s accepted declined]
  :: if not all have either accepted or declined, don't start game
  :: also, notify others in the challenge that peer has accepted
  ?.  %+  levy
        players.challenge
      |=  [s=ship accepted=? declined=?]
      |(accepted declined)
    :_  state
      :: poke every non-declined ship with update
      %+  turn
        %+  skip
          players.challenge
        |=  [player=ship accepted=? declined=?]
        ?|  =(player our.bowl)
            declined
          ==
      |=  [player=ship accepted=? declined=?]
      :*  %pass  /poke-wire  %agent  [player %pokur]
          %poke  %pokur-client-action  !>([%challenge-update challenge])
      ==
  :: if all players have responded, automatically initialize game
  :: give server the list of players which accepted and will be playing
  =.  players.challenge
    %+  skim
        players.challenge
      |=  [ship accepted=? ?]
      accepted
  :_  state
    %+  welp
      :: register game with server
      :~
        :*  
          %pass  /poke-wire  %agent  [host.challenge %pokur-server]
          %poke  %pokur-server-action  !>([%register-game challenge=challenge])
        ==
      :: already doing this
      :: :*  
      ::   %pass  /poke-wire  %agent  [our.bowl %pokur]
      ::   %poke  %pokur-client-action  !>([%subscribe game-id=id.challenge host=host.challenge])
      :: ==
      ==
    :: notify all players that the game is registered
    %+  turn
      %+  skip
        players.challenge
      |=  [ship ? declined=?]
      declined
    |=  [player=ship ? ?]
      :*
        %pass  /poke-wire  %agent  [player %pokur]
        %poke  %pokur-client-action  !>([%game-registered challenge=challenge])
      ==
  ::
  ::
    %game-registered
  :_  state
    :: subscribe to path which game will be served from
    :~  :*
          %pass  /poke-wire  %agent  [our.bowl %pokur]
          %poke  %pokur-client-action  
          !>([%subscribe id=id.challenge.client-action host=host.challenge.client-action])
        ==
    ==
    %subscribe
  ?>  (team:title [our src]:bowl)
  :: TODO if we're already in a game, we need to leave it?
  ?~  game.state
    ~&  >  "CLIENT: subcribing to new game"
    :_  state
      :~  :*  %pass  /game-updates/(scot %da id.client-action)
              %agent  [host.client-action %pokur-server]
              %watch  /game/(scot %da id.client-action)/(scot %p our.bowl)
            ==
          :*  %give  %fact  
              ~[/challenge-updates]
              [%pokur-challenge-update !>([%close-challenge id.client-action])]
          ==
      ==
  :_  state
    ~[[%give %poke-ack `~[leaf+"error: leave current game before joining new one"]]]
    ::
    %leave-game
  ?>  (team:title [our src]:bowl)
  :: TODO fix this.
  :: can't set game.state to ~ after using ?~
  :: how to do?
  :: ?~  game.state
  ::   :_  state
  ::     ~[[%give %poke-ack `~[leaf+"Error: can't leave game, not in game yet."]]]
  =/  old-game     (need game.state)
  =/  old-host     host.old-game
  =/  old-game-id  game-id.old-game
  =:  
      game.state            ~
      challenge-sent.state  ~
    ==
  :_  state    
    :~  :: unsub from game's path
        :*  %pass  /game-updates/(scot %da id.client-action)
            %agent  [old-host %pokur-server]
            %leave  ~
        ==
        :: tell server we're leaving game
        :*  %pass  /poke-wire  %agent 
            [old-host %pokur-server] 
            %poke  %pokur-server-action
            !>([%leave-game old-game-id])
        ==
        :: tell frontend we left a game
        :*  %give  %fact
            ~[/game]  
            %pokur-game-update  !>([%left-game %.n])
        ==
    ==
  ==
--
