/+  pokur
=,  format
|_  upd=pokur-challenge-update:pokur
++  grab
  |%
  ++  noun  pokur-challenge-update:pokur
  --
++  grow
  |%
  ++  noun  upd
  ++  json
    ?-  -.upd
      %open-challenge
      %-  pairs:enjs
      :~  ['update' [%s 'open']]
          ['id' [%s (scot %da id.challenge.upd)]]
          ['challenger' [%s (scot %p challenger.challenge.upd)]]
          :-  'players' 
          %-  pairs:enjs
          %+  turn
            players.challenge.upd
          |=  [s=ship accepted=? declined=?]
            :-  `@t`(scot %p s)
            %-  pairs:enjs
            :~  ['accepted' [%b accepted]]
                ['declined' [%b declined]]
            ==
          ['host' [%s (scot %p host.challenge.upd)]]
          ['min_bet' (numb:enjs min-bet.challenge.upd)]
          ['starting_stack' (numb:enjs starting-stack.challenge.upd)]
          ['turn_time_limit' (tape:enjs (scow %dr turn-time-limit.challenge.upd))]
          ['type' [%s type.challenge.upd]]
      ==
      %close-challenge
      %-  pairs:enjs
      :~  ['update' [%s 'close']]
          ['id' [%s (scot %da id.upd)]]
      ==
      %challenge-update
      %-  pairs:enjs
      :~  ['update' [%s 'modify']]
          ['id' [%s (scot %da id.challenge.upd)]]
          ['challenger' [%s (scot %p challenger.challenge.upd)]]
          :-  'players' 
          %-  pairs:enjs
          %+  turn
            players.challenge.upd
          |=  [s=ship accepted=? declined=?]
            :-  `@t`(scot %p s)
            %-  pairs:enjs
            :~  ['accepted' [%b accepted]]
                ['declined' [%b declined]]
            ==
          ['host' [%s (scot %p host.challenge.upd)]]
          ['min_bet' (numb:enjs min-bet.challenge.upd)]
          ['starting_stack' (numb:enjs starting-stack.challenge.upd)]
          ['turn_time_limit' (tape:enjs (scow %dr turn-time-limit.challenge.upd))]
          ['type' [%s type.challenge.upd]]
      ==
    ==
  --
++  grad  %noun
--