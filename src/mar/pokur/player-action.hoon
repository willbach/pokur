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
          [%new-table parse-table]
          [%join-table parse-id]
          [%leave-table parse-id]
          [%start-game parse-id]
          [%leave-game parse-id]
          [%kick-player (ot ~[[%id (se %da)] [%who (se %p)]])]
          [%add-escrow ul]  ::  TODO
      ==
    ++  parse-id  (ot ~[[%id (se %da)]])
    ++  parse-table
      %-  ot
      :~  [%id (se %da)]
          [%min-players ni]
          [%max-players ni]
          [%game-type parse-game-type]
          [%tokenized ul]  ::  TODO softly
          [%public bo]
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
