import React, { Component } from 'react';

class Game extends Component {

  constructor(props) {
    super(props);

    this.state = {
      currentBet: 0,
    }

    this.handleBetChange = this.handleBetChange.bind(this);
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

  handleBetChange(event) {
    this.setState({
      currentBet: event.target.value,
    });
  }

  handleBet(amount) {
    window.urb.poke(
      window.ship,
      'pokur',
      'pokur-game-action',
      {
        'bet': {
          'game-id': this.props.game.id,
          'amount': parseInt(amount),
        }
      },
      () => {},
      (err) => { console.log(err) }
    );
  }

  handleCheck() {
    window.urb.poke(
      window.ship,
      'pokur',
      'pokur-game-action',
      {
        'check': {
          'game-id': this.props.game.id,
        }
      },
      () => {},
      (err) => { console.log(err) }
    );
  }

  handleFold() {
    window.urb.poke(
      window.ship,
      'pokur',
      'pokur-game-action',
      {
        'fold': {
          'game-id': this.props.game.id,
        }
      },
      () => {},
      (err) => { console.log(err) }
    );
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
        <label>
          Bet: $
          <input name="bet" type="number" value={this.state.currentBet} onChange={this.handleBetChange} />
        </label>
        <button onClick={() => this.handleBet(this.state.currentBet)}>
          Bet
        </button>
        <button onClick={() => this.handleCheck()}>
          Check
        </button>
        <button onClick={() => this.handleFold()}>
          Fold
        </button>
    </div>
  };
}

export default Game;
