import React, { Component } from 'react';

class Card extends Component {

  constructor(props) {
    super(props);

    this.state = {
      suits: {
        spades: ["♠︎", "black"], 
        hearts: ["♥︎", "red"], 
        clubs: ["♣︎", "black"], 
        diamonds: ["♦︎", "red"]
      },
    }
  }
  
  rawCardToVal(n) {
    const valArray = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A'];
    return valArray[n]
  }

  render() {
    const color = this.state.suits[this.props.suit][1];
    const val = this.rawCardToVal(this.props.val);
    const suit = this.state.suits[this.props.suit][0];
    return (
      <div className={`card ${color}`}>
        <div className="card-top">
          <div className="card-value">{val}</div>
          <div className="card-suit">{suit}</div>
        </div>
        <div className="card-bot">
          <div className="card-value">{val}</div>
          <div className="card-suit">{suit}</div>
        </div>
      </div>
    )
  }
}

export default Card;