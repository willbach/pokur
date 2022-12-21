/-  pokur
=,  dejs:format
|_  act=host-action:pokur
++  grab
  |%
  ++  noun  host-action:pokur
  ++  json
    |=  jon=^json
    |^
    %-  host-action:pokur
    (host-action jon)
    ++  host-action
      %-  of
      :~  [%host-info parse-host-info]
          ::  we never accept these from FE
          ::  [%share-table ~]
          ::  [%closed-table ~]
          ::  [%turn-timers ~]
      ==
    ++  parse-host-info
      %-  ot
      :~  [%ship (se %p)]
          [%address (se %ux)]
          [%contract (ot ~[[%id (se %ux)] [%town (se %ux)]])]
      ==
    --
  --
++  grow
  |%
  ++  noun  act
  --
++  grad  %noun
--
