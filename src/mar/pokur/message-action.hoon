/-  pokur
=,  dejs:format
|_  act=message-action:pokur
++  grab
  |%
  ++  noun  message-action:pokur
  ++  json
    |=  jon=^json
    %-  message-action:pokur
    =<  (message-action jon)
    |%
    ++  message-action
      %-  of
      :~  [%mute-player (ot ~[[%who (se %p)]])]
          [%send-message (ot ~[[%msg so]])]
          [%receive-message (ot ~[[%msg so]])]
      ==
    --
  --
++  grow
  |%
  ++  noun  act
  --
++  grad  %noun
--
