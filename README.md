# pokur
Urbit poker app

How to run (at the moment)
1. copy files into your pier (moon / throwaway ship reccomended of course)
2. |commit %home, then |start %poker-client on two ships, and |start %poker-server on one of them (or a third ship)
3. issue a challenge from one client to another with the following dojo command: 

   :poker-client &poker-client-action [%issue-challenge (ship to challenge) 1 (ship running %poker-server) %cash]]
   
4. respond on the ship you just sent a challenge to with:

   :poker-client &poker-client-action [%accept-challenge (ship that sent challenge)]

5. now, start the game on the server with (note 1 here is the same number in %issue-challenge -- this is the game ID):

   :poker-server &poker-server-action [%initialize-hand 1]
   
6. from here, you can play a hand of poker between the two clients. The actions available are:

   :poker-client &poker-game-action [%check (game ID)]
                                    [%bet (game ID) (amount)]
                                    [%fold (game ID)]
