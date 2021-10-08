/-  pokur
=,  format
|_  act=game-action:pokur
++  grab
  |%
  ++  noun  game-action:pokur
  ++  json
    |=  jon=^json
    %-  game-action:pokur
    =<  (game-action jon)
    |%
    ++  game-action
      %-  of:dejs
      :~  [%check get-id]
          [%bet get-id-and-amount]
          [%fold get-id]
          [%send-msg get-msg]
      ==
    ++  get-id
      %-  ot:dejs
      :~  [%game-id (se:dejs %da)]
      ==
    ++  get-id-and-amount
      %-  ot:dejs
      :~  [%game-id (se:dejs %da)]
          [%amount ni:dejs]
      ==
    ++  get-msg
      %-  ot:dejs
      :~  [%msg (se:dejs %tape)]
      ==
    --
  --
++  grow
  |%
  ++  noun  act
  --
++  grad  %noun
--
