# pokur
Urbit poker app

How to run (at the moment)
1. Copy files into your pier (moon / throwaway ship reccomended of course)
2. |commit %home, then |start %poker-client on two ships, and |start %poker-server on one of them (or a third ship)
3. Issue a challenge from one client to another with the following dojo command: 

   :poker-client &poker-client-action [%issue-challenge (ship to challenge) 1 (ship running %poker-server) %cash]]
   
4. Respond on the ship you just sent a challenge to with:

   :poker-client &poker-client-action [%accept-challenge (ship that sent challenge)]

5. The game will be automatically initialized -- clients will receive an updated game and may begin to play
   
6. From here, you can play hands of poker between the two clients. The actions available are:

   :poker-client &poker-game-action [%check (game ID)] /
                                    [%bet (game ID) (amount)] /
                                    [%fold (game ID)]
                                    
If a player bets incorrectly or acts out of turn, their action will be rejected. Once a hand is complete, either through a player folding or a player winning at showdown, the next hand will start immediately with the next dealer.
