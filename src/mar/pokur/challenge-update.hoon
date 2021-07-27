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
          ['id' [%s (scot %da game-id.challenge.upd)]]
          ['challenger' [%s (scot %p challenger.challenge.upd)]]
          ['players' [%a (turn players.challenge.upd ship:enjs)]]
          ['host' [%s (scot %p host.challenge.upd)]]
          ['min_bet' (numb:enjs min-bet.challenge.upd)]
          ['starting_stack' (numb:enjs starting-stack.challenge.upd)]
          ['type' [%s type.challenge.upd]]
      ==
      %close-challenge
      %-  pairs:enjs
      :~  ['update' [%s 'close']]
          ['id' [%s (scot %da id.upd)]]
      ==
    ==
  --
++  grad  %noun
--