import React from 'react';

const Card = (suit, val) => {

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
      <div className={`card ${color}`}>
        <div className="card-top">
          <div className="card-value">{value}</div>
          <div className="card-suit">{suitIcon}</div>
        </div>
        <div className="card-bot">
          <div className="card-value">{value}</div>
          <div className="card-suit">{suitIcon}</div>
        </div>
      </div>
  );
};

export default Card;