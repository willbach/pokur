import React, { Component } from 'react';
import { sigil, reactRenderer } from '@tlon/sigil-js';
import { Card } from '../components';

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
    const myChips = game.chips['~' + window.ship]
    const betToMatch = game.current_bet - myChips.committed;
    return <div className="player-info">
      <div className="profile">
        {window.ship.length <= 13
         ? sigil({
            patp: window.ship,
            renderer: reactRenderer,
            size: 100,
            colors: ['black', 'white'],
          })
         : sigil({
          patp: "zod",
          renderer: reactRenderer,
          size: 100,
          colors: ['black', 'white'],
        })}
        <p>{"~" + window.ship}</p>
      </div>
      <div className="hand">
        {game.hand.map(card => (
          <Card key={card.val+card.suit} val={card.val} suit={card.suit} />
          ))}
      </div>
      <div className="bet-input">
        <p>Your stack: ${myChips.stack} Bet: ${myChips.committed}</p>
        <p>Your hand: {game.my_hand_rank}</p>
        <input name="bet"
             type="range" 
             min={game.current_bet > 0 
                   ? game.current_bet + game.last_bet
                   : game.min_bet}
             max={myChips.stack + myChips.committed} 
             value={this.props.myBet} 
             onChange={this.props.handleBetChange} />
        <br />
        <label>
          $
          <input name="bet"
                 type="number" 
                 min={betToMatch} 
                 max={myChips.stack + myChips.committed} 
                 value={this.props.myBet} 
                 onChange={this.props.handleBetChange} />
        </label>
        {game.whose_turn != window.ship
         ? <p>Waiting for {"~"+game.whose_turn} to play</p>
         : <div className="action-buttons">
             <button onClick={() => this.handleBet(this.props.myBet)}>
               {this.props.myBet > myChips.stack + myChips.committed
                 ? <span>All-in</span>
                 : game.current_bet > 0
                   ? <span>Raise to ${this.props.myBet}</span> 
                   : <span>Bet ${this.props.myBet}</span>}
             </button>
             {betToMatch > 0 
             ? <button onClick={() => this.handleCall(betToMatch)}>
                 Call ${betToMatch + myChips.committed}
               </button>
             : <button onClick={() => this.handleCheck()}>
                 Check
               </button>}
             <button onClick={() => this.handleFold()}>
               Fold
             </button>
           </div>}
      </div>
    </div>
  }
}

export default GameAction;
