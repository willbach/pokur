import React from 'react';
import { sigil, reactRenderer } from '@tlon/sigil-js';
import styles from './GameInfo.module.css';
import GameUpdates from './GameUpdates';
import Card from './Card';
import TurnTimer from './TurnTimer';

const GameInfo = ({ game, gameMessages }) => {

  const calcFullPot = (pot) => {
    const playerChips = game.chips;
    for (const [_, data] of Object.entries(playerChips)) {
        pot = pot + data.committed;
    }
    return pot
  };

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
        [realPlayers[0]]: chipsCopy[realPlayers[0]],
        "placeholder1": 1,
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
      <div className={styles.game_info}>
        <p>Game ID: {game.id}</p>
        <p>Host: {"~" + game.host}</p>
        <p>Hands played: {game.hands_played}</p>
        <p>SB/BB: ${game.min_bet / 2}/${game.min_bet}</p>
      </div>
      <GameUpdates messages={gameMessages} />
      <div className={styles.game_table}>
        {Object.entries(generateAlignedPlayers(game.chips)).map(([player, data]) => (
            player.slice(0, -1) == "placeholder"
            ? <div key={data} className={styles.player_seat} style={{"display":"none"}}></div>
            : <div key={player} className={`${styles.player_seat} ${"~" + game.whose_turn == player ? styles.their_turn : ``}`}>
                <div className={styles.player_info_top}>
                  <div className={styles.sigil}>
                  {window.ship.length <= 13
                    ? sigil({
                       patp: player,
                       renderer: reactRenderer,
                       size: 40,
                       colors: ['black', 'green'],
                     })
                    : sigil({
                     patp: "zod",
                     renderer: reactRenderer,
                     size: 40,
                     colors: ['black', 'green'],
                   })}
                   </div>
                   <div className={styles.name_display}>
                    <p>{player}</p>
                    <p>{data.left 
                     ? <span>(left game)</span> 
                     : data.folded ? <span>(folded)</span> 
                                   : <span></span>}</p>
                   </div>
                </div>
                <div className={styles.player_info_bot}>
                  <div className={styles.player_cards}>
                    <div className={styles.small_card} />
                    <div className={styles.small_card} />
                  </div>
                  <div className={styles.chips}>
                    <p>Chips: ${data.stack}</p>
                    <p>
                      {data.committed > 0 
                      ? <span>Bet: ${data.committed}</span> 
                      : <span></span>}     
                    </p>
                  </div>
                </div>
                <div className={styles.timer}>
                  {(player == "~" + game.whose_turn) && !game.game_is_over
                     ? <TurnTimer length={game.time_limit_seconds} />
                     : <></>}
                </div>
                {"~" + game.dealer == player 
                 ? <div className={styles.dealer_btn}>D</div>
                 : <></>
                      }
              </div>
        ))}
        <div className={styles.board}>
          {game.board.map(card => (
            <Card key={card.val+card.suit} val={card.val} suit={card.suit} size="large" />
            ))}
        </div>
        <h3>Pot: ${calcFullPot(game.pots[0].val)}</h3>
        {game.dealer == window.ship 
          ? <div className={styles.dealer_btn}>D</div>
          : <></>
        }
      </div>
    </>
  );
};

export default GameInfo;
