import React, { useState, useEffect } from 'react';
import { GameInfo, GameAction } from '../components';

const Game = ({ urb, game, myBet, handleBetChange }) => {

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

  return( 
    <div className="game-wrapper">
      <GameInfo game={game} />
      <br />
      {game.whose_turn != window.ship
       ? <span></span>
       : <p>It's your turn!</p>}
      <GameAction urb={urb} game={game} myBet={myBet} handleBetChange={handleBetChange} />
      <br />
      <button onClick={() => leaveGame()}>
        Leave Game
      </button>
    </div>
  );
};

export default Game;
