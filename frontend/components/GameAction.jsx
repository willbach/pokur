import React, { Component } from 'react';

class GameAction extends Component {

  constructor(props) {
    super(props);
  }

  handleBet(amount) {
    const lessCommitted = amount - this.props.game.chips['~' + window.ship].committed;
    window.urb.poke(
      window.ship,
      'pokur',
      'pokur-game-action',
      {
        'bet': {
          'game-id': this.props.game.id,
          'amount': lessCommitted,
        }
      },
      () => {},
      (err) => { console.log(err) }
    );
  }

  handleCall(amount) {
    window.urb.poke(
      window.ship,
      'pokur',
      'pokur-game-action',
      {
        'bet': {
          'game-id': this.props.game.id,
          'amount': amount,
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
    const betToMatch = game.current_bet - game.chips['~' + window.ship].committed;
    const myBet = this.props.myBet;
    return <div id="game-info">
      <input name="bet"
           type="range" 
           min={game.last_bet} 
           max={game.chips['~' + window.ship].stack} 
           value={myBet} 
           onChange={this.props.handleBetChange} />
      <br />
      <label>
        $
        <input name="bet"
               type="number" 
               min={game.last_bet} 
               max={game.chips['~' + window.ship].stack} 
               value={myBet} 
               onChange={this.props.handleBetChange} />
      </label>
      <button onClick={() => this.handleBet(myBet)}>
        {game.current_bet > 0 ? <span>Raise to ${myBet}</span> : <span>Bet ${myBet}</span>}
      </button>
      {betToMatch > 0 
      ? <button onClick={() => this.handleCall(betToMatch)}>
          Call ${betToMatch}
        </button>
      : <button onClick={() => this.handleCheck()}>
          Check
        </button>}
      <button onClick={() => this.handleFold()}>
        Fold
      </button>
      <br />
    </div>
  }
}

export default GameAction;
