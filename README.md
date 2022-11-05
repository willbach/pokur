# pokur
Urbit Texas Hold'em app

**under construction**

On ship ~zod:
```
:pokur-host &pokur-host-action [%escrow-info [0x0 0x0] 0xcafe.babe]
:pokur &pokur-player-action [%join-host ~zod]
```

On ship ~bus:
```
:pokur &pokur-player-action [%join-host ~zod]
:pokur &pokur-player-action [%new-table *@da 2 8 [%cash 1.000 1 2] ~ %.y ~m10]
```

[look at print to find table-id]

On ~zod:
```
:pokur &pokur-player-action [%join-table table-id]
```

On ~bus:
```
:pokur &pokur-player-action [%start-game table-id]
```


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
