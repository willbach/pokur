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
          [%cancel-challenge cancel]
      ==
    ++  parse-challenge
      %-  ot:dejs
      :~  [%to (ar:dejs (se:dejs %p))]
          [%host (se:dejs %p)]
          [%min-bet ni:dejs]
          [%starting-stack ni:dejs]
          [%type so:dejs]
      ==
    ++  accept
      %-  ot:dejs
      :~  [%from (se:dejs %p)]
          [%id (se:dejs %da)]
      ==
    ++  leave
      %-  ot:dejs
      :~  [%id (se:dejs %da)]
      == 
    ++  cancel
      %-  ot:dejs
      :~  [%id (se:dejs %da)]
      ==
    --
  --
++  grow
  |%
  ++  noun  act
  --
++  grad  %noun
--
