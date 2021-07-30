import React, { Component } from 'react';
import { GameInfo, GameAction } from '../components';

class Game extends Component {

  constructor(props) {
    super(props);
  }
  
  leaveGame() {
    window.urb.poke(
      window.ship,
      'pokur',
      'pokur-client-action',
      {
        'leave-game': {
          'id': this.props.game.id,
        }
      },
      () => {},
      (err) => { console.log(err) }
    );
  }

  render() {
    const game = this.props.game;

    return <div className="game-wrapper">
      <GameInfo game={game} />
      <br />
      {game.whose_turn != window.ship
       ? <span></span>
       : <p>It's your turn!</p>}
      <GameAction game={game} myBet={this.props.myBet} handleBetChange={this.props.handleBetChange} />
      <br />
      <button onClick={() => this.leaveGame()}>
        Leave Game
      </button>
    </div>
  };
}

export default Game;
