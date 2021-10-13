import React, { useState, useEffect } from 'react';
import { GameInfo, GameAction, Chat } from '../components';
import styles from './Game.module.css';
import TurnTimer from './TurnTimer';

const Game = ({ urb, game, spectating, myBet, setMyBet, gameMessages }) => {
  const [sub, setSub] = useState();
  const [chatMessages, setChatMessages] = useState([]);

  // subscribe to /game-msgs path to recieve game updates
  useEffect(() => {
    if (!urb || sub) return;
    urb
      .subscribe({
        app: "pokur",
        path: "/game-msgs",
        event: updateMessages,
        err: console.log,
        quit: console.log,
      })
      .then((subscriptionId) => {
        setSub(subscriptionId);
      });
  }, [urb]);

  // should messages be sent on the subscription one at a time, or in a bundle??
  // sending all of them in a bundle for now
  function updateMessages(messageUpdate) {
    setChatMessages(messageUpdate["messages"]);
  };

  const leaveGame = () => {
    urb.poke({
      app: 'pokur',
      mark: 'pokur-client-action',
      json: {
        'leave-game': {
          'id': game.id,
        }
      },
    });
  };

  const sendChat = (value) => {
    urb.poke({
      app: 'pokur',
      mark: 'pokur-game-action',
      json: {
        'send-msg': {
          'msg': value,
        }
      },
    });
  };

  return( 
    <div className={styles.wrapper}>
      <GameInfo game={game} gameMessages={gameMessages} />
      <div className={styles.lower}>
        {
         spectating
         ? <></>
         : <GameAction urb={urb}
                       game={game}
                       myBet={myBet}
                       setMyBet={setMyBet} />
        }
        <Chat messages={chatMessages} send={sendChat} />
      </div>
      <button className={styles.leave_game} onClick={() => leaveGame()}>
        Leave Game
      </button>
    </div>
  );
};

export default Game;
