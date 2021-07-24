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
          [%leave-game leave]
      ==
    ++  get-id
      %-  ot:dejs
      :~  [%game-id ni:dejs]
      ==
    ++  get-id-and-amount
      %-  ot:dejs
      :~  [%game-id ni:dejs]
          [%amount ni:dejs]
      ==
    --
  --
++  grow
  |%
  ++  noun  act
  --
++  grad  %noun
--
