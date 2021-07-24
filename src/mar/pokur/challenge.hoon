/+  pokur
=,  format
|_  challenge=pokur-challenge:pokur
++  grab
  |%
  ++  noun  pokur-challenge:pokur
  --
++  grow
  |%
  ++  noun  challenge
  ++  json
    =+  challenge
    %-  pairs:enjs
    :~  ['game-id' [%s (scot %ud game-id.challenge)]]
        ['challenger' [%s (scot %p challenger.challenge)]]
        :: ['players' [%s challenger-side.challenge.upd]]
        ['host' [%s (scot %p host.challenge)]]
        ['type' [%s type.challenge]]
    ==
  --
++  grad  %noun
--