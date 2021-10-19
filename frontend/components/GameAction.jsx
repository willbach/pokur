import React from 'react';
import { sigil, reactRenderer } from '@tlon/sigil-js';
import { Card, TurnTimer } from '../components';
import styles from './GameAction.module.css';

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
    <div className={styles.player_info}>
      <div className={styles.profile}>
        {window.ship.length <= 13
         ? sigil({
            patp: window.ship,
            renderer: reactRenderer,
            size: 150,
            colors: ['black', 'white'],
          })
         : sigil({
          patp: "zod",
          renderer: reactRenderer,
          size: 150,
          colors: ['black', 'white'],
        })}
        <p>{"~" + window.ship}</p>
      </div>
      <div className={styles.hand}>
        {game.hand.map(card => (
          <Card key={card.val+card.suit} val={card.val} suit={card.suit} size="large" />
          ))}
        <p>Your hand: {game.my_hand_rank}</p>
      </div>
      <div className={styles.bet_input}>
        <p>Your Stack: ${myChips.stack} Bet: ${myChips.committed}</p>
        <input name="bet"
             className={styles.rangeInput}
             type="range"
             step="5"
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
         : <div className={styles.action_buttons}>
             <button className={styles.button} onClick={() => handleAction("bet", myBet)}>
               {myBet > myChips.stack + myChips.committed
                 ? <span>All-in</span>
                 : game.current_bet > 0
                   ? <span>Raise to ${myBet}</span> 
                   : <span>Bet ${myBet}</span>}
             </button>
             {betToMatch > 0 
             ? <button className={styles.button} onClick={() => handleAction("bet", betToMatch + myChips.committed)}>
                 Call ${betToMatch + myChips.committed}
               </button>
             : <button className={styles.button} onClick={() => handleAction("check", 0)}>
                 Check
               </button>}
             <button className={styles.button} onClick={() => handleAction("fold", 0)}>
               Fold
             </button>
           </div>}
           {game.whose_turn == window.ship
            ? <TurnTimer length={game.time_limit_seconds} />
            : <></>}
      </div>
    </div>
  );
};

export default GameAction;
