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
      <GameInfo game={game} />
      <br />
      {game.whose_turn != window.ship
       ? <p>Waiting for {game.whose_turn} to play</p>
       : <div>
           <p>It's your turn!</p>
           <GameAction game={game} myBet={this.props.myBet} handleBetChange={this.props.handleBetChange} />
         </div>}
      <br />
      <button onClick={() => this.leaveGame()}>
        Leave Game
      </button>
    </div>
  };
}

export default Game;
