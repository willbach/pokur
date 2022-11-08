import React from 'react';
import styles from './Card.module.css';

const Card = ({ suit, val, size }) => {

  const suits = {
          spades: ["♠︎", "black"], 
          hearts: ["♥︎", "red"], 
          clubs: ["♣︎", "green"], 
          diamonds: ["♦︎", "blue"]
        };
  
  const rawCardToVal = (n) => {
    const valArray = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A'];
    return valArray[n]
  };

  const color = suits[suit][1];
  const value = rawCardToVal(val);
  const suitIcon = suits[suit][0];

  return (
      <div className={`${styles.card} ${styles[color]} ${styles[size]}`}>
        <div className={styles.card_top}>
          <div className={`${styles.card_value} ${styles[size]}`}>{value}</div>
          <div className={`${styles.card_suit} ${styles[size]}`}>{suitIcon}</div>
        </div>
        <div className={styles.card_bot}>
          <div className={`${styles.card_value} ${styles[size]}`}>{value}</div>
          <div className={`${styles.card_suit} ${styles[size]}`}>{suitIcon}</div>
        </div>
      </div>
  );
};

export default Card;