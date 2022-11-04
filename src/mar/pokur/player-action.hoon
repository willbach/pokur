/-  pokur
=,  dejs:format
|_  act=player-action:pokur
++  grab
  |%
  ++  noun  player-action:pokur
  ++  json
    |=  jon=^json
    %-  player-action:pokur
    =<  (player-action jon)
    |%
    ++  player-action
      %-  of
      :~  [%join-host (ot ~[[%host (se %p)]])]
          [%leave-host ul]
          [%new-lobby parse-lobby]
          [%join-lobby parse-id]
          [%leave-lobby parse-id]
          [%start-game parse-id]
          [%leave-game parse-id]
          [%kick-player (ot ~[[%id (se %da)] [%who (se %p)]])]
          [%add-escrow ul]  ::  TODO
      ==
    ++  parse-id  (ot ~[[%id (se %da)]])
    ++  parse-lobby
      %-  ot
      :~  [%min-players ni]
          [%max-players ni]
          [%game-type parse-game-type]
          [%tokenized ~]  ::  TODO softly
          [%spectators-allowed bo]
          [%turn-time-limit (se %dr)]
      ==
    ++  parse-game-type
      %-  of
      :~  [%cash parse-cash-type]
          [%tournament parse-tournament-type]
      ==
    ++  parse-cash-type
      %-  ot
      :~  [%starting-stack ni]
          [%small-blind ni]
          [%big-blind ni]
      ==
    ++  parse-tournament-type
      %-  ot
      :~  [%starting-stack ni]
          [%round-duration (se %dr)]
          [%blinds-schedule (ar (ot ~[[%small ni] [%big ni]]))]
          [%current-round ni]
          [%round-is-over bo]
      ==
    --
  --
++  grow
  |%
  ++  noun  act
  --
++  grad  %noun
--
