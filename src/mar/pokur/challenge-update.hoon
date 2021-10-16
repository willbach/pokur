/+  pokur
=,  format
|_  upd=challenge-update:pokur
++  grab
  |%
  ++  noun  challenge-update:pokur
  --
++  grow
  |%
  ++  noun  upd
  ++  json
    ?-  -.upd
    %open-challenge
      (parse-challenge challenge.upd)
    %challenge-update
      (parse-challenge challenge.upd)
    %close-challenge
      %-  pairs:enjs
      :~  ['update' [%s 'close']]
          ['id' [%s (scot %da id.upd)]]
      ==
    ==
  ++  parse-challenge
    |=  c=pokur-challenge:pokur
    %-  pairs:enjs
    :~  ['update' [%s 'modify']]
        ['id' [%s (scot %da id.c)]]
        ['challenger' [%s (scot %p challenger.c)]]
        :-  'players' 
        %-  pairs:enjs
        %+  turn
          players.c
        |=  [s=ship accepted=? declined=?]
          :-  `@t`(scot %p s)
          %-  pairs:enjs
          :~  ['accepted' [%b accepted]]
              ['declined' [%b declined]]
          ==
        ['host' [%s (scot %p host.c)]]
        ['min_bet' (numb:enjs min-bet.c)]
        ['starting_stack' (numb:enjs starting-stack.c)]
        ['turn_time_limit' (tape:enjs (scow %dr turn-time-limit.c))]
        ['type' [%s type.c]]
    ==
  --
++  grad  %noun
--