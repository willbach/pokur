import React from 'react';
import { sigil, reactRenderer } from '@tlon/sigil-js';
import { Card, TurnTimer } from '../components';

const GameInfo = ({ game, gameMessages }) => {

  const calcFullPot = (pot) => {
    const playerChips = game.chips;
    for (const [_, data] of Object.entries(playerChips)) {
        pot = pot + data.committed;
    }
    return pot
  };

  const recentMessages = gameMessages.length < 5 ? gameMessages : gameMessages.slice(0, 5);

  // this is to place the players in seating arrangements
  // that make sense for different amounts of players at the table
  const generateAlignedPlayers = (chips) => {
    // javascript sucks
    const chipsCopy = Object.assign({}, chips)
    // remove "us" from chips for this
    delete chipsCopy["~" + window.ship];
    const realPlayers = Object.keys(chipsCopy);
    var output;
    if (realPlayers.length == 1) {
      output = {
        "placeholder0": 0,
        "placeholder1": 1,
        "placeholder2": 2,
        [realPlayers[0]]: chipsCopy[realPlayers[0]],
      };
    } else if (realPlayers.length == 2) {
      output = {
        "placeholder0": 0,
        "placeholder1": 1,
        [realPlayers[0]]: chipsCopy[realPlayers[0]],
        "placeholder2": 2,
        "placeholder3": 3,
        [realPlayers[1]]: chipsCopy[realPlayers[1]],
      };
    } else if (realPlayers.length == 3) {
      output = {
        "placeholder0": 0,
        [realPlayers[0]]: chipsCopy[realPlayers[0]],
        "placeholder1": 1,
        [realPlayers[1]]: chipsCopy[realPlayers[1]],
        "placeholder2": 2,
        [realPlayers[2]]: chipsCopy[realPlayers[2]],
      };
    } else if (realPlayers.length == 4) {
      output = {
        "placeholder0": 0,
        [realPlayers[0]]: chipsCopy[realPlayers[0]],
        "placeholder1": 1,
        [realPlayers[1]]: chipsCopy[realPlayers[1]],
        "placeholder2": 2,
        [realPlayers[2]]: chipsCopy[realPlayers[2]],
        "placeholder3": 3,
        [realPlayers[3]]: chipsCopy[realPlayers[3]],
      };
    }
    return output
  };

  return (
    <>
      <div className="game-info">
        <p>Game ID: {game.id}</p>
        <p>Host: {"~" + game.host}</p>
        <p>Hands played: {game.hands_played}</p>
        <p>SB/BB: ${game.min_bet / 2}/${game.min_bet}</p>
      </div>
      <div className="update-messages">
          {
            recentMessages.map((message,i) => (
              <h3 key={i}>{message}</h3>
            ))
          }
        </div>
      <div className="game-table">
        {Object.entries(generateAlignedPlayers(game.chips)).map(([player, data]) => (
            player.slice(0, -1) == "placeholder"
            ? <div key={data} className="player-seat" style={{"display":"none"}}></div>
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
        <div className="board">
          {game.board.map(card => (
            <Card key={card.val+card.suit} val={card.val} suit={card.suit} />
            ))}
        </div>
        <h3>Pot: ${calcFullPot(game.pots[0].val)}</h3>
      </div>
    </>
  );
};

export default GameInfo;
