/-  poker
/+  poker
=,  poker
:-  %say
|=  [[* eny=@uv *] *]
=/  new-game-state
  [
    game-id=1
    players=~[~zod ~bus]
    host=~zod
    type=%cash
    chips=(turn ~[~zod ~bus] |=(a=ship [a 1.000 0]))
    my-hand=~
    board=~
    my-turn=%.n
    dealer=~bus
    small-blind=~bus
    big-blind=~zod
    pot=0
    current-bet=0
  ]
=/  state
  [
    game=new-game-state
    hands=~
    deck=(shuffle-deck generate-deck eny)
    paused=%.n
    whose-turn=~bus
    hands-played=0
  ]
::  ~&  state
:: start of hand
=/  state
  (initialize-hand 20 ~bus (shuffle-deck-in-state state eny))
~&  state
:: pre-flop ROUND
=/  state
  (process-player-action ~bus [%bet 20] state)
=/  state
  (deal-to-board 3 (committed-chips-to-pot state))
:: flop ROUND
=/  state
  (process-player-action ~zod [%bet 60] state)
=/  state
  (process-player-action ~bus [%bet 120] state)
=/  state
  (process-player-action ~zod [%bet 60] state)
=/  state
  (deal-to-board 1 (committed-chips-to-pot state))
:: turn ROUND
=/  state
  (process-player-action ~zod [%check] state)
=/  state
  (process-player-action ~bus [%check] state)
=/  state
  (deal-to-board 1 (committed-chips-to-pot state))
:: river ROUND
=/  state
  (process-player-action ~zod [%check] state)
=/  state
  (process-player-action ~bus [%bet 100] state)
=/  state
  (process-player-action ~zod [%bet 100] state)
:: HAND EVALUATION
=/  state   (committed-chips-to-pot state)
=/  winner  (determine-winner state)
=/  state   (process-win winner state)
:-  %noun
state