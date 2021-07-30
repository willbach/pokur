import React, { Component } from 'react';
import { Card } from '../components';

class GameInfo extends Component {

  constructor(props) {
    super(props);
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
    return <>
      <div className="game-info">
        <p>Game ID: {game.id}</p>
        <p>Host: {"~" + game.host}</p>
        <p>Hands played: {game.hands_played}</p>
        <p>SB/BB: ${game.min_bet / 2}/${game.min_bet}</p>
      </div>
      <div className="update-message">
          <h3>{game.update_message}</h3>
        </div>
      <div className="game-table">
        <p>Chip counts:</p>
        {Object.entries(game.chips).map(([player, data]) => (
            player == "~" + window.ship
            ? <span key={player}></span>
            : <li key={player}><span>{player}: ${data.stack} &nbsp;</span> 
                {data.committed > 0 
                ? <span>bet: ${data.committed} &nbsp;</span> 
                : <span></span>}     
                {data.left 
                ? <span>(left game)</span> 
                : data.folded ? <span>(folded) &nbsp;</span> 
                              : <span></span>}</li>
        ))}
        <div className="board">
          {game.board.map(card => (
            <Card key={card.val+card.suit} val={card.val} suit={card.suit} />
            ))}
        </div>
        <h3>Pot: ${this.calcFullPot(game.pot)}</h3>
      </div>
    </>
  }
}

export default GameInfo;
