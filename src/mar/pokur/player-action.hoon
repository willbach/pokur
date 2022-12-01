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
      :~  [%new-table parse-table]
          [%join-table parse-id]
          [%leave-table parse-id]
          [%start-game parse-id]
          [%leave-game parse-id]
          [%kick-player (ot ~[[%id (se %da)] [%who (se %p)]])]
          [%set-our-address (ot ~[[%address (se %ux)]])]
      ==
    ++  parse-id  (ot ~[[%id (se %da)]])
    ++  parse-table
      %-  ot
      :~  [%id (se %da)]
          [%host (se %p)]
          [%tokenized parse-tokenized]
          [%min-players ni]
          [%max-players ni]
          [%game-type parse-game-type]
          [%public bo]
          [%spectators-allowed bo]
          [%turn-time-limit (se %dr)]
      ==
    ++  parse-game-type
      %-  of
      :~  [%cash parse-cash-type]
          [%sng parse-sng-type]
      ==
    ++  parse-cash-type
      %-  ot
      :~  [%starting-stack ni]
          [%small-blind ni]
          [%big-blind ni]
      ==
    ++  parse-sng-type
      %-  ot
      :~  [%starting-stack ni]
          [%round-duration (se %dr)]
          [%blinds-schedule (ar (ot ~[[%small ni] [%big ni]]))]
          [%current-round ni]
          [%round-is-over bo]
      ==
    ++  parse-tokenized
      |=  jon=^json
      ?~  jon  ~
      %-  some
      %-  ot
      :~  [%metadata (se %ux)]
          [%amount (se %ud)]
          [%bond-id (se %ux)]
      ==
    --
  --
++  grow
  |%
  ++  noun  act
  --
++  grad  %noun
--
