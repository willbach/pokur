import React, { Component } from 'react';

class GameAction extends Component {

  constructor(props) {
    super(props);

    if (this.props.game.current_bet > 0) {
      this.state = {
        // raise logic
        myBet: this.props.game.current_bet + this.props.game.last_bet,
      }
    } else {
      this.state = {
        myBet: this.props.game.min_bet,
      }
    }

    this.handleBetChange = this.handleBetChange.bind(this);
  }

  handleBetChange(event) {
    this.setState({
      myBet: event.target.value,
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
    const betToMatch = game.current_bet - game.chips['~' + window.ship].committed;
    return <div id="game-info">
      <input name="bet"
           type="range" 
           min={game.last_bet} 
           max={game.chips['~' + window.ship].stack} 
           value={this.state.myBet} 
           onChange={this.handleBetChange} />
      <br />
      <label>
        $
        <input name="bet"
               type="number" 
               min={game.last_bet} 
               max={game.chips['~' + window.ship].stack} 
               value={this.state.myBet} 
               onChange={this.handleBetChange} />
      </label>
      <button onClick={() => this.handleBet(this.state.myBet)}>
        {game.current_bet > 0 ? <span>Raise to ${this.state.myBet}</span> : <span>Bet ${this.state.myBet}</span>}
      </button>
      {betToMatch > 0 
      ? <button onClick={() => this.handleBet(betToMatch)}>
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
