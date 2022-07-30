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

#### Why not mental poker?

It is possible to create a poker protocol that is entirely trustless -- where each player can self-verify that the shuffle and deal were fair, and eliminate the possibility of other players cheating. In my opinion, however, effective online poker play requires more than this trustless protocol can provide. Features such as turn timers, matchmaking, and some degree of guaranteed message delivery all become feasible with a trusted third party. 

A small case study: imagine the case where two players agree to a trustless game. They each deposit some money in a contract, and to confirm that the winner is eventually paid, set a timer such that either can claim the prize after a certain period of time/blocks if no proof of win has been posted. There's no effective way to stop a losing player from defecting and refusing to take turns in favor of waiting out the lockup and racing to claim the deposit. A trusted dealer node can manage turn timers and simply keep the game running against a real-world clock.

Mental poker, while mathematically fascinating, solves a problem that doesn't exist. Game-players of all varieties routinely trust a third party to enforce the rules whether online or in real life. Furthermore, the trust being asked of dealers is extremely limited in scope! By essentially recording their computation in the dealing and shuffling process, dealer nodes can post a proof to chain that indicates the hand was dealt fairly after-the-fact (with delay to make sure players can't compute their opponents' hands, of course, but also potentially delayed further to make available knowledge of how someone played a certain hand that was never revealed, etc, etc). This, combined with basic reputational tools, creates an environment where dealing is commoditized and players can rapidly feel comfortable playing for high stakes.

The problem that Pokur *does* solve, which is *very* real, is that of easily coordinating games and tying them to identities and money. Anonymous or not, people want to play games with crypto at stake and up to now there hasn't been an environment where such games could be built. 
