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
      :~  ['id' [%s (scot %da game-id.game.upd)]]
          ['host' [%s (scot %p host.game.upd)]]
          ['type' [%s type.game.upd]]
          ['players' [%a (turn players.game.upd ship:enjs)]]
          ['paused' [%b paused.game.upd]]
          ['hands_played' [%n (scot %ud hands-played.game.upd)]]
          :-  'chips' 
          %-  pairs:enjs 
          %+  turn
            chips.game.upd
          |=  [s=ship stack=@ud committed=@ud acted=?]
            :-  `@t`(scot %p s)
            %-  pairs:enjs 
            :~  ['stack' [%n (scot %ud stack)]]
                ['committed' [%n (scot %ud committed)]]
                ['acted' [%b acted]]
            ==
          ['pot' [%n (scot %ud pot.game.upd)]]
          ['current_bet' [%n (scot %ud current-bet.game.upd)]]
          ['min_bet' [%n (scot %ud min-bet.game.upd)]]
          :-  'board'
          :-  %a
          %+  turn
            board.game.upd
          |=  c=poker-card:pokur
          %-  pairs:enjs 
            :~  ['val' [%n (scot %ud (card-val-to-atom:pokur -.c))]]
                ['suit' [%s +.c]]
            ==
          :-  'hand'
          :-  %a
          %+  turn
            my-hand.game.upd
          |=  c=poker-card:pokur
          %-  pairs:enjs 
            :~  ['val' [%n (scot %ud (card-val-to-atom:pokur -.c))]]
                ['suit' [%s +.c]]
            ==
          ['whose_turn' (ship:enjs whose-turn.game.upd)]
          ['dealer' (ship:enjs dealer.game.upd)]
          ['small_blind' (ship:enjs small-blind.game.upd)]
          ['big_blind' (ship:enjs big-blind.game.upd)]
      ==
    ==
  --
++  grad  %noun
--