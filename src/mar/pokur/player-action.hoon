/-  pokur
=,  dejs:format
|_  act=player-action:pokur
++  grab
  |%
  ++  noun  player-action:pokur
  ++  json
    |=  jon=^json
    |^
    %-  player-action:pokur
    =/  res  (player-action jon)
    ?.  ?=(%new-table -.res)  res
    =/  tok  -.+.+.+.res
    ?:  =(0 -.+.tok)
      res(-.+.+.+ ~)
    res(-.+.+.+ `tok)
    ++  player-action
      %-  of
      :~  [%new-table parse-table]
          [%join-table (ot ~[[%id (se %da)] [%buy-in (se %ud)] [%public bo]])]
          [%leave-table parse-id]
          [%start-game parse-id]
          [%leave-game parse-id]
          [%kick-player (ot ~[[%id (se %da)] [%who (se %p)]])]
          [%set-our-address (ot ~[[%address (se %ux)]])]
          [%find-host (ot ~[[%who (se %p)]])]
          [%remove-host (ot ~[[%who (se %p)]])]
          [%send-invite (ot ~[[%to (se %p)]])]
          ::  %invite not used by FE
          [%spectate-game (ot ~[[%host (se %p)] [%id (se %da)]])]
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
      :~  [%min-buy ni]
          [%max-buy ni]
          [%buy-ins ul]
          [%chips-per-token ni]
          [%small-blind ni]
          [%big-blind ni]
          [%tokens-in-bond ni]  ::  put 0 here
      ==
    ++  parse-sng-type
      %-  ot
      :~  [%starting-stack ni]
          [%round-duration (se %dr)]
          [%blinds-schedule (ar (ot ~[[%small ni] [%big ni]]))]
          [%current-round ni]
          [%round-is-over bo]
          [%payouts (ar ni)]
      ==
    ++  parse-tokenized
      %-  ot
      :~  [%metadata (se %ux)]
          [%symbol so]
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
