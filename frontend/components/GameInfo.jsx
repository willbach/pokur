import React from 'react';
import { sigil, reactRenderer } from '@tlon/sigil-js';
import { Card, TurnTimer } from '../components';

const GameInfo = ({ game }) => {

  const calcFullPot = (pot) => {
    const playerChips = game.chips;
    for (const [_, data] of Object.entries(playerChips)) {
        pot = pot + data.committed;
    }
    return pot
  };

  return (
    <>
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
        {Object.entries(game.chips).map(([player, data]) => (
            player == "~" + window.ship
            ? <span key={player}></span>
            : <div key={player} className={`player-seat ${"~" + game.whose_turn == player ? `their-turn` : ``}`}>
                <div className="name-display">
                  <p>{player}</p>
                </div>
                {player == "~" + game.whose_turn
                 ? <TurnTimer countdown={game.time_limit_seconds} />
                 : <></>}
                <div className="player-cards">
                  <div className="small-card hidden" />
                  <div className="small-card hidden" />
                </div>
                <p>${data.stack} 
                   {data.committed > 0 
                   ? <span>bet: ${data.committed} &nbsp;</span> 
                   : <span></span>}     
                   {data.left 
                   ? <span>(left game)</span> 
                   : data.folded ? <span>(folded) &nbsp;</span> 
                                 : <span></span>}
                </p>
              </div>
        ))}
        <div className="player-seat">
          <div className="player-cards">
          <div className="small-card hidden" />
          <div className="small-card hidden" />
          </div>
        </div>
        <div className="player-seat">
          <div className="player-cards">
          <div className="small-card hidden" />
          <div className="small-card hidden" />
          </div>
        </div>
        <div className="player-seat">
          <div className="player-cards">
          <div className="small-card hidden" />
          <div className="small-card hidden" />
          </div>
        </div>
        <div className="player-seat">
          <div className="player-cards">
          <div className="small-card hidden" />
          <div className="small-card hidden" />
          </div>
        </div>
        <div className="player-seat">
          <div className="player-cards">
          <div className="small-card hidden" />
          <div className="small-card hidden" />
          </div>
        </div>
        <div className="board">
          {game.board.map(card => (
            <Card key={card.val+card.suit} val={card.val} suit={card.suit} />
            ))}
        </div>
        <h3>Pot: ${calcFullPot(game.pot)}</h3>
      </div>
    </>
  );
};

export default GameInfo;
