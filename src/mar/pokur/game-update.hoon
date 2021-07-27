/+  pokur
=,  format
|_  upd=pokur-game-update:pokur
++  grab
  |%
  ++  noun  pokur-game-update:pokur
  --
++  grow
  |%
  ++  noun  upd
  ++  json
    ?-  -.upd
      %update
      %-  pairs:enjs
      :~  ['in_game' [%b %.y]]
          ['id' [%s (scot %da game-id.game.upd)]]
          ['host' (ship:enjs host.game.upd)]
          ['type' [%s type.game.upd]]
          ['players' [%a (turn players.game.upd ship:enjs)]]
          ['paused' [%b paused.game.upd]]
          ['hands_played' (numb:enjs hands-played.game.upd)]
          :-  'chips' 
          %-  pairs:enjs 
          %+  turn
            chips.game.upd
          |=  [s=ship stack=@ud committed=@ud acted=? folded=? left=?]
            :-  `@t`(scot %p s)
            %-  pairs:enjs 
            :~  ['stack' (numb:enjs stack)]
                ['committed' (numb:enjs committed)]
                ['acted' [%b acted]]
                ['folded' [%b folded]]
                ['left' [%b left]]
            ==
          ['pot' (numb:enjs pot.game.upd)]
          ['current_bet' (numb:enjs current-bet.game.upd)]
          ['min_bet' (numb:enjs min-bet.game.upd)]
          ['last_bet' (numb:enjs last-bet.game.upd)]
          :-  'board'
          :-  %a
          %+  turn
            board.game.upd
          |=  c=poker-card:pokur
          %-  pairs:enjs 
            :~  ['val' (numb:enjs (card-val-to-atom:pokur -.c))]
                ['suit' [%s +.c]]
            ==
          :-  'hand'
          :-  %a
          %+  turn
            my-hand.game.upd
          |=  c=poker-card:pokur
          %-  pairs:enjs 
            :~  ['val' (numb:enjs (card-val-to-atom:pokur -.c))]
                ['suit' [%s +.c]]
            ==
          ['whose_turn' (ship:enjs whose-turn.game.upd)]
          ['dealer' (ship:enjs dealer.game.upd)]
          ['small_blind' (ship:enjs small-blind.game.upd)]
          ['big_blind' (ship:enjs big-blind.game.upd)]
      ==
      %left-game
      %-  pairs:enjs
      :~  ['in_game' [%b %.n]]
      ==
    ==
  --
++  grad  %noun
--