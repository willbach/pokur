/+  pokur, *pokur-json
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
      ==
    ::
        %table
      (enjs-table table.upd)
    ::
        %lobby
      %-  pairs
      %+  turn  tables.upd
      |=  =table
      [(scot %da id.table) (enjs-table table)]
    ::
        %new-message
      %-  pairs
      :~  ['from' s+(scot %p from.upd)]
          ['msg' s+msg.upd]
      ==
    ::
        %left-game  ~
    ::
        %game-starting  ~
    ==
  --
++  grad  %noun
--