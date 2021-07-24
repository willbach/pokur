/-  pokur
=,  format
|_  act=client-action:pokur
++  grab
  |%
  ++  noun  client-action:pokur
  ++  json
    |=  jon=^json
    %-  client-action:pokur
    =<  (client-action jon)
    |%
    ++  client-action
      %-  of:dejs
      :~  [%issue-challenge parse-challenge]
          [%accept-challenge accept]
          [%subscribe subscribe]
          [%leave-game leave]
      ==
    ++  parse-challenge
      %-  ot:dejs
      :~  [%to (se:dejs %p)]
          [%game-id ni:dejs]
          [%host (se:dejs %p)]
          [%type so:dejs]
      ==
    ++  accept
      %-  ot:dejs
      :~  [%from (se:dejs %p)]
      ==
    ++  subscribe
      %-  ot:dejs
      :~  [%game-id ni:dejs]
          [%host (se:dejs %p)]
      == 
    ++  leave
      %-  ot:dejs
      :~  [%game-id ni:dejs]
      == 
    --
  --
++  grow
  |%
  ++  noun  act
  --
++  grad  %noun
--
