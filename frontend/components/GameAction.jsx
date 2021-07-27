import React, { Component } from 'react';

class GameAction extends Component {

  constructor(props) {
    super(props);
   
    this.state = {
      currentBet: 0,
    }

    this.handleBetChange = this.handleBetChange.bind(this);
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

  leaveGame() {
    window.urb.poke(
      window.ship,
      'pokur',
      'pokur-client-action',
      {
        'leave-game': {
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
           min={0} 
           max={game.chips['~' + window.ship].stack} 
           value={this.state.currentBet} 
           onChange={this.handleBetChange} />
      <br />
      <label>
        $
        <input name="bet"
               type="number" 
               min={0} 
               max={game.chips['~' + window.ship].stack} 
               value={this.state.currentBet} 
               onChange={this.handleBetChange} />
      </label>
      <button onClick={() => this.handleBet(this.state.currentBet)}>
        {betToMatch > 0 ? <span>Raise to ${this.state.currentBet}</span> : <span>Bet ${this.state.currentBet}</span>}
      </button>
      {betToMatch > 0 
      ? <button onClick={() => this.handleBet(betToMatch)}>
          Call ${game.current_bet}
        </button>
      : <button onClick={() => this.handleCheck()}>
          Check
        </button>}
      
      <button onClick={() => this.handleFold()}>
        Fold
      </button>
      <br />
      <button onClick={() => this.leaveGame()}>
        Leave Game
      </button>
    </div>
  }
}

export default GameAction;
