/-  *pokur
=,  enjs:format
|%
++  enjs-messages
  |=  m=(list [@p @t])
  :-  %a
  %+  turn  m
  |=  [shi=@p msg=@t]
  %-  pairs
  :~  ['from' (ship shi)]
      ['msg' s+msg]
  ==
++  enjs-game
  |=  t=game
  ^-  json
  %-  pairs
  :~  ['id' s+(scot %da id.t)]
      ['game_is_over' b+game-is-over.t]
      ['game_type' (enjs-game-type game-type.t)]
      ['turn_time_limit' s+(scot %dr turn-time-limit.t)]
      ['turn_start' s+(scot %da turn-start.t)]
      ['players' (enjs-players players.t)]
      ['pots' (enjs-pots pots.t)]
      ['current_bet' s+(scot %ud current-bet.t)]
      ['last_bet' s+(scot %ud last-bet.t)]
      ['min_bet' s+(scot %ud (make-min-bet t))]
      ['board' (enjs-cards board.t)]
      ['hand' (enjs-cards my-hand.t)]
      ['current_turn' s+(scot %p whose-turn.t)]
      ['dealer' s+(scot %p dealer.t)]
      ['small_blind' s+(scot %p small-blind.t)]
      ['big_blind' s+(scot %p big-blind.t)]
      ['spectators_allowed' b+spectators-allowed.t]
      ['spectators' a+(turn ~(tap in spectators.t) ship)]
      ['hands_played' s+(scot %ud hands-played.t)]
      ['update_message' s+update-message.t]
      ['revealed_hands' (enjs-hands revealed-hands.t)]
  ==
::
++  make-min-bet
  |=  t=game
  ^-  @ud
  ?.  =(0 last-bet.t)
    last-bet.t
  ?:  ?=(%cash -.game-type.t)
    big-blind.game-type.t
  =<  big
  %-  snag
  [current-round blinds-schedule]:game-type.t
::
++  enjs-table
  |=  l=table
  ^-  json
  %-  pairs
  :~  ['id' s+(scot %da id.l)]
      ['host_info' (enjs-host-info host-info.l)]
      ['tokenized' ?~(tokenized.l ~ (enjs-tokenized u.tokenized.l))]
      ['leader' s+(scot %p leader.l)]
      ['players' a+(turn ~(tap in players.l) ship)]
      ['min_players' s+(scot %ud min-players.l)]
      ['max_players' s+(scot %ud max-players.l)]
      ['game_type' (enjs-game-type game-type.l)]
      ['public' b+public.l]
      ['spectators_allowed' b+spectators-allowed.l]
      ['turn_time_limit' s+(scot %dr turn-time-limit.l)]
  ==
::
++  enjs-hands
  |=  hands=(list [@p pokur-deck])
  ^-  json
  %-  pairs
  %+  turn  hands
  |=  [p=@p hand=pokur-deck]
  [(scot %p p) (enjs-cards hand)]
::
++  enjs-cards
  |=  cards=pokur-deck
  ^-  json
  :-  %a
  (turn cards enjs-card)
::
++  enjs-card
  |=  card=pokur-card
  ^-  json
  %-  pairs
  :~  :-  'val'
      ?:  (lte `@`-.card 10)
        s+`@t`~(rent co %$ %ud `@`-.card)
      s+(scot %tas -.card)
      ['suit' s+(scot %tas +.card)]
  ==
::
++  enjs-players
  |=  p=players
  ^-  json
  :-  %a
  %+  turn  p
  |=  [shi=@p i=player-info]
  %-  pairs
  :~  ['ship' (ship shi)]
      ['stack' s+(scot %ud stack.i)]
      ['committed' s+(scot %ud committed.i)]
      ['acted' b+acted.i]
      ['folded' b+folded.i]
      ['left' b+left.i]
  ==
::
++  enjs-pots
  |=  pots=(list [amount=@ud in=(list @p)])
  ^-  json
  :-  %a
  %+  turn  pots
  |=  [amount=@ud in=(list @p)]
  %-  pairs
  :~  ['amount' s+(scot %ud amount)]
      ['players_in' a+(turn in ship)]
  ==
::
++  enjs-game-type
  |=  g=game-type
  ^-  json
  %-  pairs
  ?:  ?=(%cash -.g)
    :~  ['type' s+'cash']
        ['starting_stack' s+(scot %ud starting-stack.g)]
        ['small_blind' s+(scot %ud small-blind.g)]
        ['big_blind' s+(scot %ud big-blind.g)]
    ==
  :~  ['type' s+'sng']
      ['starting_stack' s+(scot %ud starting-stack.g)]
      ['round_duration' s+(scot %dr round-duration.g)]
      ['blinds_schedule' (enjs-blinds-schedule blinds-schedule.g)]
      ['current_round' s+(scot %ud current-round.g)]
      ['round_is_over' b+round-is-over.g]
  ==
::
++  enjs-blinds-schedule
  |=  sch=(list [@ud @ud])
  ^-  json
  :-  %a
  %+  turn  sch
  |=  [s=@ud b=@ud]
  [%a ~[s+(scot %ud s) s+(scot %ud b)]]
::
++  enjs-tokenized
  |=  [metadata=@ux symbol=@t amount=@ud bond-id=@ux]
  ^-  json
  %-  pairs
  :~  ['metadata' s+(scot %ux metadata)]
      ['symbol' s+symbol]
      ['amount' s+(scot %ud amount)]
      ['bond_id' s+(scot %ux bond-id)]
  ==
::
++  enjs-host-info
  |=  h=host-info
  ^-  json
  %-  pairs
  :~  ['ship' (ship ship.h)]
      ['address' s+(scot %ux address.h)]
      ['contract_id' s+(scot %ux id.contract.h)]
      ['contract_town' s+(scot %ux town.contract.h)]
  ==
--
