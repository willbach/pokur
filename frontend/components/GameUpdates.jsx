import React from 'react';
import styles from './GameUpdates.module.css';
import { Card } from '../components';

const GameUpdates = ({ messages }) => {

  const lastFive = messages.length < 5 ? messages : messages.slice(0, 5);
  
  return (
    <div className={styles.update_messages}>
      {
        lastFive.map((message,i) => ( 
          message.hand != []
          ? <h3 key={i}>
              {message.msg}
              {message.hand.map(card => (
                <Card key={card.val+card.suit} val={card.val} suit={card.suit} size="small" />
              ))}
            </h3>
          : <h3 key={i}>{message.msg}</h3>
        ))
      }
    </div>
  );
};

export default GameUpdates;


      