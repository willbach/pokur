import React, { useState, useEffect } from 'react';
import { GameInfo, GameAction } from '../components';
import styles from './Game.module.css';

const Game = ({ urb, game, myBet, setMyBet, gameMessages }) => {

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
    localStorage.removeItem("gameTimer");
  };

  return( 
    <div className={styles.wrapper}>
      <GameInfo game={game} gameMessages={gameMessages} />
      <GameAction urb={urb} game={game} myBet={myBet} setMyBet={setMyBet} />
      <button className={styles.leave_game} onClick={() => leaveGame()}>
        Leave Game
      </button>
    </div>
  );
};

export default Game;
