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
          [%accept-challenge parse-id]
          [%decline-challenge parse-id]
          [%leave-game parse-id]
          [%cancel-challenge parse-id]
      ==
    ++  parse-challenge
      %-  ot:dejs
      :~  [%to (ar:dejs (se:dejs %p))]
          [%host (se:dejs %p)]
          [%spectators bo:dejs]
          [%min-bet ni:dejs]
          [%starting-stack ni:dejs]
          [%type (se:dejs %tas)]
          [%turn-time-limit so:dejs]
          [%time-limit-seconds ni:dejs]
      ==
    ++  parse-id
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
