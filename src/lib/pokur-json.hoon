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
++  enjs-table
  |=  t=table
  ^-  json
  %-  pairs
  :~  ['id' s+(scot %da id.t)]
      ['game_is_over' b+game-is-over.t]
      ['game_type' (enjs-game-type game-type.t)]
      ['turn_time_limit' s+(scot %dr turn-time-limit.t)]
      ['players' (enjs-players players.t)]
      ['pots' (enjs-pots pots.t)]
      ['current-bet' s+(scot %ud current-bet.t)]
      ['last-bet' s+(scot %ud last-bet.t)]
      ['board' (enjs-cards board.t)]
      ['my-hand' (enjs-cards my-hand.t)]
      ['whose-turn' s+(scot %p whose-turn.t)]
      ['dealer' s+(scot %p dealer.t)]
      ['small_blind' s+(scot %p small-blind.t)]
      ['big_blind' s+(scot %p big-blind.t)]
      ['spectators_allowed' b+spectators-allowed.t]
      ['spectators' a+(turn ~(tap in spectators.t) ship)]
      ['hands_played' s+(scot %ud hands-played.t)]
      ['update_message' (enjs-update-message update-message.t)]
  ==
::
++  enjs-lobby
  |=  l=lobby
  ^-  json
  %-  pairs
  :~  ['id' s+(scot %da id.l)]
      ['leader' s+(scot %p leader.l)]
      ['players' a+(turn ~(tap in players.l) ship)]
      ['min_players' s+(scot %ud min-players.l)]
      ['max_players' s+(scot %ud max-players.l)]
      ['game-type' (enjs-game-type game-type.l)]
      ['tokenized' ?~(tokenized.l ~ (enjs-tokenized u.tokenized.l))]
      ['bond_id' ?~(bond-id.l ~ s+(scot %ux u.bond-id.l))]
      ['spectators_allowed' b+spectators-allowed.l]
      ['turn_time_limit' s+(scot %dr turn-time-limit.l)]
  ==
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
  :~  ['val' s+(scot %tas -.card)]
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
  :~  ['type' s+'tournament']
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
  |=  [metadata=@ux amount=@ud]
  ^-  json
  %-  pairs
  :~  ['metadata' s+(scot %ux metadata)]
      ['amount' s+(scot %ud amount)]
  ==
::
++  enjs-update-message
  |=  [tex=@t winning-hand=pokur-deck]
  ^-  json
  %-  pairs
  :~  ['text' s+tex]
      ['winning_hand' (enjs-cards winning-hand)]
  ==
--