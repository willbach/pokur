import React, { useCallback, useEffect, useState } from "react";
import { ChallengeForm, ChallengeList, Game } from './components';
import _ from "lodash";
import Urbit from "@urbit/http-api";

const createApi = (host, code) =>
  _.memoize(
    () => {
      const urb = new Urbit(host, code);
      urb.ship = window.ship;
      try {
        urb.connect();
      } catch (err) {
        console.log(err);
      }
      urb.onError = (message) => console.log(message);
      return urb;
    }
  );

const App = () => {
  const gameStateTemplate = {
    "hands_played": 0,
    "players": [
        "bus",
        "zod"
    ],
    "big_blind": "zod",
    "update_message": "Pokur game started, served by ~zod",
    "current_bet": 0,
    "board": [],
    "chips": {
        "~zod": {
            "acted": false,
            "folded": false,
            "stack": 0,
            "committed": 0,
            "left": false
        },
        "~bus": {
            "acted": false,
            "folded": false,
            "stack": 0,
            "committed": 0,
            "left": false
        }
    },
    "my_hand_rank": "-",
    "id": "~2021.9.23..22.59.04..12ea",
    "last_bet": 0,
    "small_blind": "bus",
    "host": "zod",
    "paused": false,
    "min_bet": 0,
    "type": "cash",
    "hand": [
        {
            "val": 4,
            "suit": "clubs"
        },
        {
            "val": 11,
            "suit": "hearts"
        }
    ],
    "pot": 0,
    "in_game": false,
    "whose_turn": "bus",
    "dealer": "bus"
  };
  const [loggedIn, setLoggedIn] = useState();
  const [urb, setUrb] = useState();
  const [sub, setSub] = useState();
  const [inGame, setInGame] = useState(false);
  const [gameState, setGameState] = useState(gameStateTemplate);
  const [myBet, setMyBet] = useState();

  useEffect(() => {
    if (localStorage.getItem("host") && localStorage.getItem("code")) {
      console.log("got host/code from cookie");
      setLoggedIn(true);
      const _urb = createApi(
        localStorage.getItem("host"),
        localStorage.getItem("code")
      );
      setUrb(_urb);
      return () => {};
    }
  }, []);

  // subscribe to /game path to recieve game updates
  useEffect(() => {
    if (!urb || sub) return;
    urb
      .subscribe({
        app: "pokur",
        path: "/game",
        event: updateGameState,
        err: console.log,
        quit: console.log,
      })
      .then((subscriptionId) => {
        setSub(subscriptionId);
      });
  }, [urb, sub]);

  const login = (host, code) => {
    localStorage.setItem("host", host);
    localStorage.setItem("code", code);
    const _urb = createApi(host, code);
    setUrb(_urb);
    setLoggedIn(true);
    return () => {};
  };

  function updateGameState(newGameState) {
    if (newGameState.in_game) {
      setGameState(newGameState);
      setMyBet(
        newGameState.current_bet > 0 
              ? newGameState.current_bet + newGameState.last_bet
              : newGameState.min_bet
      )
      setInGame(true);
    } else {
      setInGame(false);
    }
  };

  return (
    <>
      <header>
        <p>Pokur -- play Texas hold 'em on Urbit</p>
        <a href="/">Return to Landscape</a> 
      </header>
      {loggedIn 
      ? <span></span>
      : <div id="login"><pre>Login:</pre>
      <form
        onSubmit={(e) => {
          e.preventDefault();
          const host = e.target.host.value;
          const code = e.target.code.value;
          login(host, code);
        }}
      >
        <input
          type="host"
          name="host"
          placeholder={
            loggedIn ? localStorage.getItem("host") : "Host"
          }
        />
        <br />
        <input
          type="code"
          name="code"
          placeholder={
            loggedIn ? localStorage.getItem("code") : "Code"
          }
        />
        <br />
        <input type="submit" value="Login" />
      </form></div> }
      {inGame ? <Game 
                  urb={urb}
                  game={gameState} 
                  myBet={myBet} 
                  handleBetChange={setMyBet}
                />
              : <div>
                  <ChallengeForm 
                    urb={urb} 
                  />
                  <ChallengeList 
                    urb={urb}  
                  />
                </div>}
    </>
  );
};

export default App;
