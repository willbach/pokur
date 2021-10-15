import React, { useReducer, useEffect, useState } from "react";
import { ChallengeForm, ChallengeList, Game } from './components';
import _ from "lodash";
import Urbit from "@urbit/http-api";
const ob = require('urbit-ob');

const createApi = () =>
  _.memoize(
    () => {
      const urb = new Urbit('', '');
      urb.ship = window.ship;
      return urb;
    }
  );

function messageReducer(state, newMessage) {
  if (newMessage == "clear") {
    return [{msg: "", hand: []}, {msg: "", hand: []}, {msg: "", hand: []}, {msg: "", hand: []}, {msg: "", hand: []}];
  }
  if (state[0].msg != newMessage.msg) {
    return [newMessage, ...state];
  } else {
    return state;
  }
}

const App = () => {
  const [urb, setUrb] = useState();
  const [gameSub, setGameSub] = useState();
  const [challengeSub, setChallengeSub] = useState();
  const [chatSub, setChatSub] = useState();
  const [inGame, setInGame] = useState(false);
  const [spectating, setSpectating] = useState(false);
  const [gameState, setGameState] = useState();
  const [myBet, setMyBet] = useState();
  const [gameMessages, setGameMessages] = useReducer(messageReducer, [{msg: "", hand: []}, {msg: "", hand: []}, {msg: "", hand: []}, {msg: "", hand: []}, {msg: "", hand: []}]);
  const [chatMessages, setChatMessages] = useState([]);
  const [challenges, setChallenges] = useState({});
  const [sentChallenge, setSentChallenge] = useState(false);

  useEffect(() => {
      const _urb = createApi();
      setUrb(_urb);
  }, []);

  // subscribe to /game path to recieve game updates
  useEffect(() => {
    if (!urb || gameSub) return;
    urb
      .subscribe({
        app: "pokur",
        path: "/game",
        event: updateGameState,
        err: console.log,
        quit: console.log,
      })
      .then((subscriptionId) => {
        setGameSub(subscriptionId);
      });
  }, [urb]);

  function updateGameState(newGameState) {
    if (newGameState.in_game) {
      setGameState(newGameState);
      setGameMessages(newGameState.update_message);
      setMyBet(
        newGameState.current_bet > 0 
              ? newGameState.current_bet + newGameState.last_bet
              : newGameState.min_bet
      )
      if (newGameState.players.includes(window.ship)) {
        setSpectating(false);
      } else {
        setSpectating(true);
      }
      setInGame(true);
    } else {
      setInGame(false);
    }
  };

  // subscribe to /challenge-updates
  useEffect(() => {
    if (!urb || challengeSub) return;
    urb
      .subscribe({
        app: "pokur",
        path: "/challenge-updates",
        event: processChallengeUpdate,
        err: console.log,
        quit: console.log,
      })
      .then((subscriptionId) => {
        setChallengeSub(subscriptionId);
      });
  }, [urb]);

  const processChallengeUpdate = (data) => {
    if (data["update"] == "open" || data["update"] == "modify") {
      const newChallenge = {
        challenger: data["challenger"],
        players: data["players"],
        host: data["host"],
        type: data["type"],
      }
      setChallenges({ ...challenges, [data["id"]]: newChallenge});
    } else if (data["update"] == "close") {
      var newList = {...challenges};
      delete newList[data["id"]];
      setChallenges(newList);
    }
  };

  // subscribe to /game-msgs path to recieve player messages
  useEffect(() => {
    if (!urb || chatSub) return;
    urb
      .subscribe({
        app: "pokur",
        path: "/game-msgs",
        event: updateMessages,
        err: console.log,
        quit: console.log,
      })
      .then((subscriptionId) => {
        setChatSub(subscriptionId);
      });
  }, [urb]);

  // should messages be sent on the subscription one at a time, or in a bundle??
  // sending all of them in a bundle for now
  function updateMessages(messageUpdate) {
    setChatMessages(messageUpdate["messages"]);
  };

  return (
    <>
      <header>
        <p>Pokur Beta</p>
      </header>
      {inGame 
        ? <Game 
            urb={urb}
            game={gameState} 
            spectating={spectating}
            myBet={myBet} 
            setMyBet={setMyBet}
            setSentChallenge={setSentChallenge} 
            gameMessages={gameMessages}
            chatMessages={chatMessages}
          />
        : <>
            {!sentChallenge 
              ? <ChallengeForm 
                  ob={ob}
                  urb={urb}
                  sentChallenge={sentChallenge}
                  setSentChallenge={setSentChallenge} 
                />
              : <></>
            }
            <ChallengeList 
              ob={ob}
              urb={urb}
              challenges={challenges}
              setChallenges={setChallenges}
              setSentChallenge={setSentChallenge}
              setGameMessages={setGameMessages}
            /> 
          </>
        }
    </>
  );
};

export default App;
