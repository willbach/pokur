# pokur
Urbit Texas Hold'em app

**under construction**

Fake monies game:

On ship ~zod:
```
:pokur &pokur-player-action [%new-table *@da ~zod ~ 2 2 [%sng 1.000 ~m60 ~[[1 2] [2 4] [4 8]] 0 %.n] %.y %.y ~m10]
```

(look at "lobbies available" print to find table id -- this prints twice, is ok)

On ship ~bus:
```
:pokur &pokur-player-action [%join-table <id>]
```

On ~zod:
```
:pokur &pokur-player-action [%start-game <id>]
```

On ~bus:
```
:pokur|bet 1  ::  call big blind
```

can play game from here using format `:pokur|[bet/check/fold]` where only bet takes any further input


New program flow:
- user joins a host, by entering a @p (app will default to one)
- user creates or joins a table on host
- lobby has information regarding amount of what token required to play
- when in table, user is prompted to submit the required asset to an escrow contract
- once a set number of users have entered and paid escrow, table creator
  has ability to start game
- all users are awarded chips which host assigns proportional value to,
  based on specifications of game type
- upon game resolution, host awards escrow
