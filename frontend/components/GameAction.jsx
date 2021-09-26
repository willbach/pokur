import React from 'react';
import { sigil, reactRenderer } from '@tlon/sigil-js';
import { Card } from '../components';

const GameAction = ({ urb, game, myBet, setMyBet }) => {

  const handleAction = (action, amount) => {
    var pokeObject = {
      app: "pokur",
      mark: "pokur-game-action",
      json: {
        [action]: {
          "game-id": game.id,
        }
      },
    };
    if (action == "bet") {
      const lessCommitted = amount - game.chips['~' + window.ship].committed;
      pokeObject["json"]["bet"]["amount"] = lessCommitted;
    } else if (action == "call") {
      pokeObject["json"]["bet"]["amount"] = amount;
    }

    urb.poke(pokeObject);
  }

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
             onChange={(e) => setMyBet(e.target.value)} />
        <br />
        <label>
          $
          <input name="bet"
                 type="number" 
                 min={betToMatch} 
                 max={myChips.stack + myChips.committed} 
                 value={myBet} 
                 onChange={(e) => setMyBet(e.target.value)} />
        </label>
        {game.whose_turn != window.ship
         ? <p>Waiting for {"~"+game.whose_turn} to play</p>
         : <div className="action-buttons">
             <button onClick={() => handleAction("bet", myBet)}>
               {myBet > myChips.stack + myChips.committed
                 ? <span>All-in</span>
                 : game.current_bet > 0
                   ? <span>Raise to ${myBet}</span> 
                   : <span>Bet ${myBet}</span>}
             </button>
             {betToMatch > 0 
             ? <button onClick={() => handleAction("bet", betToMatch + myChips.committed)}>
                 Call ${betToMatch + myChips.committed}
               </button>
             : <button onClick={() => handleAction("check", 0)}>
                 Check
               </button>}
             <button onClick={() => handleAction("fold", 0)}>
               Fold
             </button>
           </div>}
      </div>
    </div>
  );
};

export default GameAction;
