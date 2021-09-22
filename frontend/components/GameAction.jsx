import React from 'react';
import { sigil, reactRenderer } from '@tlon/sigil-js';
import { Card } from '../components';

const GameAction = (urb, game, myBet, handleBetChange) => {

  const handleBet = (amount) => {
    const lessCommitted = amount - game.chips['~' + window.ship].committed;
    urb.urb.poke({
      app: 'pokur',
      mark: 'pokur-game-action',
      json: {
        'bet': {
          'game-id': game.id,
          'amount': lessCommitted,
        }
      },
    });
  };

  const handleCall = (amount) => {
    urb.urb.poke({
      app: 'pokur',
      mark: 'pokur-game-action',
      json: {
        'bet': {
          'game-id': game.id,
          'amount': amount,
        }
      },
    });
  };

  const handleCheck = () => {
    urb.urb.poke({
      app: 'pokur',
      mark: 'pokur-game-action',
      json: {
        'check': {
          'game-id': game.id,
        }
      },
    });
  };

  const handleFold = () => {
    urb.urb.poke({
      app: 'pokur',
      mark: 'pokur-game-action',
      json: {
        'fold': {
          'game-id': game.id,
        }
      },
    });
  };

  const myChips = game.chips['~' + window.ship];
  const betToMatch = game.current_bet - myChips.committed;

  return (
    <div className="player-info">
      <div className="profile">
        {window.ship.length <= 13
         ? sigil({
            patp: window.ship,
            renderer: reactRenderer,
            size: 100,
            colors: ['black', 'white'],
          })
         : sigil({
          patp: "zod",
          renderer: reactRenderer,
          size: 100,
          colors: ['black', 'white'],
        })}
        <p>{"~" + window.ship}</p>
      </div>
      <div className="hand">
        {game.hand.map(card => (
          <Card key={card.val+card.suit} val={card.val} suit={card.suit} />
          ))}
      </div>
      <div className="bet-input">
        <p>Your stack: ${myChips.stack} Bet: ${myChips.committed}</p>
        <p>Your hand: {game.my_hand_rank}</p>
        <input name="bet"
             type="range" 
             min={game.current_bet > 0 
                   ? game.current_bet + game.last_bet
                   : game.min_bet}
             max={myChips.stack + myChips.committed} 
             value={myBet} 
             onChange={handleBetChange} />
        <br />
        <label>
          $
          <input name="bet"
                 type="number" 
                 min={betToMatch} 
                 max={myChips.stack + myChips.committed} 
                 value={myBet} 
                 onChange={handleBetChange} />
        </label>
        {game.whose_turn != window.ship
         ? <p>Waiting for {"~"+game.whose_turn} to play</p>
         : <div className="action-buttons">
             <button onClick={() => handleBet(myBet)}>
               {myBet > myChips.stack + myChips.committed
                 ? <span>All-in</span>
                 : game.current_bet > 0
                   ? <span>Raise to ${myBet}</span> 
                   : <span>Bet ${myBet}</span>}
             </button>
             {betToMatch > 0 
             ? <button onClick={() => handleCall(betToMatch)}>
                 Call ${betToMatch + myChips.committed}
               </button>
             : <button onClick={() => handleCheck()}>
                 Check
               </button>}
             <button onClick={() => handleFold()}>
               Fold
             </button>
           </div>}
      </div>
    </div>
  );
};

export default GameAction;
