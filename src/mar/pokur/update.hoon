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
        %table
      %-  pairs
      :~  ['table' (enjs-table table.upd)]
          ['hand_rank' s+my-hand-rank.upd]
      ==
    ::
        %lobby
      (enjs-lobby lobby.upd)
    ::
        %lobbies-available
      %-  pairs
      %+  turn  lobbies.upd
      |=  =lobby
      [(scot %da id.lobby) (enjs-lobby lobby)]
    ::
        %new-message
      %-  pairs
      :~  ['from' s+(scot %p from.upd)]
          ['msg' s+msg.upd]
      ==
    ::
        %left-game  ~
    ==
  --
++  grad  %noun
--