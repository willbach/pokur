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
          [%leave-game leave]
      ==
    ++  parse-challenge
      %-  ot:dejs
      :~  [%to (se:dejs %p)]
          [%host (se:dejs %p)]
          [%type so:dejs]
      ==
    ++  accept
      %-  ot:dejs
      :~  [%from (se:dejs %p)]
      ==
    ++  leave
      %-  ot:dejs
      :~  [%game-id (se:dejs %da)]
      == 
    --
  --
++  grow
  |%
  ++  noun  act
  --
++  grad  %noun
--
