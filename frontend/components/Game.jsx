import React, { useState, useEffect } from 'react';
import { GameInfo, GameAction, Chat } from '../components';
import styles from './Game.module.css';
import TurnTimer from './TurnTimer';

const Game = ({ urb, game, spectating, myBet, setMyBet, gameMessages, chatMessages }) => {

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
