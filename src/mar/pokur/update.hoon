/-  pokur
/+  *pokur-json
=,  enjs:format
|_  upd=update:pokur
++  grab
  |%
  ++  noun  update:pokur
  --
++  grow
  |%
  ++  noun  upd
  ++  json
    ?-    -.upd
        %game
      %-  pairs
      :~  ['game' (enjs-game game.upd)]
          ['hand_rank' s+my-hand-rank.upd]
          ['last_board' (enjs-cards last-board.upd)]
      ==
    ::
        %table-closed
      (pairs ~[['id' s+(scot %da table-id.upd)]])
    ::
        %game-starting
      (pairs ~[['id' s+(scot %da game-id.upd)]])
    ::
        %game-over
      %-  pairs
      :~  ['game' (enjs-game game.upd)]
          ['last_board' (enjs-cards last-board.upd)]
          ['tokenized' ?~(tokenized.upd ~ (enjs-tokenized u.tokenized.upd))]
          :+  'placements'  %a
          %+  turn  placements.upd
          |=  [p=@p win=@ud]
          (pairs ~[['ship' (ship p)] ['winnings' s+(scot %ud win)]])
      ==
    ::
        %lobby
      %-  pairs
      %+  turn  ~(tap by tables.upd)
      |=  [id=@da =table]
      [(scot %da id) (enjs-table table)]
    ::
        %new-message
      %-  pairs
      :~  ['from' s+(scot %p from.upd)]
          ['msg' s+msg.upd]
      ==
    ::
        %left-game  ~
    ::
        %new-invite
      %-  pairs
      :~  ['from' s+(scot %p from.upd)]
          ['table' (enjs-table table.upd)]
      ==
    ==
  --
++  grad  %noun
--
