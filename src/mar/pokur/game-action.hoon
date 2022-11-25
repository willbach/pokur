/-  pokur
=,  dejs:format
|_  act=game-action:pokur
++  grab
  |%
  ++  noun  game-action:pokur
  ++  json
    |=  jon=^json
    |^
    %-  game-action:pokur
    =/  ac  `*`(game-action jon)
    ?+  -.ac  !!
      %bet    ac
      %check  [-.ac +.ac ~]
      %fold   [-.ac +.ac ~]
    ==
    ++  game-action
      %-  of
      :~  [%check (ot ~[[%game-id (se %da)]])]
          [%fold (ot ~[[%game-id (se %da)]])]
          [%bet (ot ~[[%game-id (se %da)] [%amount ni]])]
      ==
    --
  --
++  grow
  |%
  ++  noun  act
  --
++  grad  %noun
--
