import React, { useState, useEffect } from 'react';
import GameAction from "./GameAction";
import GameInfo from "./GameInfo";
import Chat from "./Chat";
import styles from './Game.module.css';

const Game = ({ urb, game, spectating, myBet, setMyBet, setSentChallenge, gameMessages, chatMessages }) => {

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
    setSentChallenge(false);
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
      <GameInfo game={game} 
                gameMessages={gameMessages} 
                />
      <div className={styles.lower}>
        {
         spectating ||  game.game_is_over
         ? <></>
         : <GameAction urb={urb}
                       game={game}
                       myBet={myBet}
                       setMyBet={setMyBet}
                       />
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
