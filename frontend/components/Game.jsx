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
      <br />
      {game.whose_turn == window.ship
       ? <p>It's your turn!</p>
       : <p>Waiting for {game.whose_turn} to play</p>}
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
  };
}

export default Game;
