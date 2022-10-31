# pokur
Urbit Texas Hold'em app

**under construction**

New program flow:
- user joins a host, by entering a @p (app will default to one)
- user creates or joins a lobby on host
- lobby has information regarding amount of what token required to play
- when in lobby, user is prompted to submit the required asset to an escrow contract
- once a set number of users have entered and paid escrow, lobby creator
  has ability to start game
- all users are awarded chips which host assigns proportional value to,
  based on specifications of game type
- upon game resolution, host awards escrow
