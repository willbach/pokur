import React, { Component } from 'react';

class Game extends Component {

  constructor(props) {
    super(props);

    this.state = {
    }

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
    return <div className="game-wrapper">
      <h2>Pokur Game</h2>
      <p>Game ID: {game.id}</p>
      <p>Host: {game.host}</p>
      <p>Hands played: {game.hands_played}</p>
      <p>SB/BB: ${game.min_bet / 2}/${game.min_bet}</p>
      <br />
      <br />
      <p>Current board:</p>
      {game.board.map(card => (
        <p>* {this.rawCardToVal(card.val)} of {card.suit}</p>
        ))}
      <p>Hand:</p>
      {game.hand.map(card => (
        <p>* {this.rawCardToVal(card.val)} of {card.suit}</p>
        ))}
      <p>Pot: ${this.calcFullPot(game.pot)}</p>
      <br />
      <p>Chip counts:</p>
      {Object.entries(game.chips).map(([player, data]) => (
          <p>{player}: ${data.stack}</p>
      ))}
      <br />
      {game.whose_turn == window.ship
       ? <p>It's your turn!</p>
       : <p>Waiting for {game.whose_turn} to play</p>}
      <p></p>
    </div>
  };
}

export default Game;
