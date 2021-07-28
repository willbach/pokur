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
    return <div id="game-info">
      <p>Game ID: {game.id}</p>
      <p>Host: {game.host}</p>
      <p>Hands played: {game.hands_played}</p>
      <p>SB/BB: ${game.min_bet / 2}/${game.min_bet}</p>
      <br />
      <br />
      <h2>{game.update_message}</h2>
      <p>Board:</p>
      <div className="board">
        {game.board.map(card => (
          <Card key={card.val+card.suit} val={card.val} suit={card.suit} />
          ))}
      </div>
      <p>Hand:</p>
      <div className="hand">
        {game.hand.map(card => (
          <Card key={card.val+card.suit} val={card.val} suit={card.suit} />
          ))}
      </div>
      <p>Your hand: {game.my_hand_rank}</p>
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
    </div>
  }
}

export default GameInfo;
