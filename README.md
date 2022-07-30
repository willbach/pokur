# pokur
Urbit Texas Hold'em app

Now available for distribution from ~bacrys!

On an Urbit ship, search for ~bacrys and you'll see the option to install %pokur and/or %pokur-server. For more information, join the group at ~bacrys/pokur.

This program was designed by ~hodzod-walrus as a grant project for the Urbit Foundation.

## Phase 2: Uqbar-enabled provably-fair poker

I intend to write a Pokur smart contract which in coordination with this app will allow Urbit ships to provide provably-fair poker games. These ships will also be able to show lobbies, making it much easier to find a game.

- clean up codebase with improved hoon abilities
- refactor player-dealer comms to offload all but the necessary provable computation to dealer
- make dealer run hands such that deck shuffle + deal are hinted out in zink
- post proof blob at end of each hand/round/tournament??
- players share actions directly?
