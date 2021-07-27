import React, { Component } from 'react';

class GameInfo extends Component {

  constructor(props) {
    super(props);
  }

  rawCardToVal(n) {
    const valArray = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'Jack', 'Queen', 'King', 'Ace'];
    return valArray[n]
  }

  calcFullPot(pot) {
    const playerChips = this.props.game.chips;
    for (const [_, data] of Object.entries(playerChips)) {
        pot = pot + data.committed;
    }
    return pot
  }

  render() {
    const game = this.props.game;
    return <div id="game-info">
      <p>Game ID: {game.id}</p>
      <p>Host: {game.host}</p>
      <p>Hands played: {game.hands_played}</p>
      <p>SB/BB: ${game.min_bet / 2}/${game.min_bet}</p>
      <br />
      <br />
      <p>Current board:</p>
      {game.board.map(card => (
        <li key={card.val+card.suit}>{this.rawCardToVal(card.val)} of {card.suit}</li>
        ))}
      <p>Hand:</p>
      {game.hand.map(card => (
        <li key={card.val+card.suit}>{this.rawCardToVal(card.val)} of {card.suit}</li>
        ))}
      <p>Pot: ${this.calcFullPot(game.pot)}</p>
      <br />
      <p>Chip counts:</p>
      {Object.entries(game.chips).map(([player, data]) => (
          <li key={player}><span>{player}: ${data.stack} &nbsp;</span> 
                           {data.committed > 0 
                           ? <span>bet: ${data.committed} &nbsp;</span> 
                           : <span></span>}     
                           {data.left 
                           ? <span>(left game)</span> 
                           : data.folded ? <span>(folded) &nbsp;</span> 
                                         : <span></span>}</li>
      ))}
    </div>
  }
}

export default GameInfo;
