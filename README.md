# pokur
Urbit poker app

How to install
1. Run 'npm install', then 'npm run serve'
2. Copy files from src/ into your pier (moon / throwaway ship reccomended of course)
3. |commit %home, then |start %pokur on two ships, and |start %pokur-server on one of them (or a third ship)
4. Click the new Pokur tile on your ship

To play in dojo:

1. Issue a challenge from one client to another with the following dojo command: 

   :pokur &pokur-client-action [%issue-challenge (ship to challenge) 1 (ship running %poker-server) %cash]]
   
2. Respond on the ship you just sent a challenge to with:

   :pokur &pokur-client-action [%accept-challenge (ship that sent challenge)]

3. The game will be automatically initialized -- clients will receive an updated game and may begin to play
   
4. From here, you can play hands of poker between the two clients. The actions available are:

   :pokur &pokur-game-action [%check (game ID)] /
                                    [%bet (game ID) (amount)] /
                                    [%fold (game ID)]
                                    
If a player bets incorrectly or acts out of turn, their action will be rejected. Once a hand is complete, either through a player folding or a player winning at showdown, the next hand will start immediately with the next dealer.
