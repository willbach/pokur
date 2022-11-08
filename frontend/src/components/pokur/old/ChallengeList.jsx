import React, { useState, useEffect } from 'react';
import styles from './ChallengeList.module.css';

const ChallengeList = ({ ob, urb, challenges, setChallenges, setSentChallenge, setGameMessages }) => {

  const acceptChallenge = (id) => {
    urb.poke({
      app: 'pokur',
      mark: 'pokur-client-action',
      json: {
        'accept-challenge': {
          'id': id,
        }
      },
    });
    setGameMessages("clear");
  };

  const declineChallenge = (id) => {
    urb.poke({
      app: 'pokur',
      mark: 'pokur-client-action',
      json: {
        'decline-challenge': {
          'id': id,
        }
      },
    });
    var newList = {...challenges};
    delete newList[id];
    setChallenges(newList);
  };

  const cancelChallenge = (id) => {
    urb.poke({
      app: 'pokur',
      mark: 'pokur-client-action',
      json: {
        'cancel-challenge': {
          'id': id,
        }
      },
    });
    setSentChallenge(false);
  };

  const trySpectate = (e) => {
    e.preventDefault();
    urb.poke({
      app: 'pokur',
      mark: 'pokur-client-action',
      json: {
        'subscribe': {
          'id': e.target.game_id.value,
          'host': e.target.game_host.value,
        }
      },
    });
    setGameMessages("clear");
  }

  return (
    <div className={styles.wrapper}>
      <form className={styles.spectate_form} onSubmit={e => trySpectate(e)}>
        <p>Spectate an active game</p>
        <input name="game_id" type="text" placeholder="game id" />
        <input name="game_host" 
               type="text"
               placeholder="~hosten" 
               onChange={e => {
                                 if (ob.isValidPatp(e.target.value)) {
                                   e.target.className = "valid";
                                 } else {
                                   e.target.className = "invalid";
                                 }
                                }}/>
        <input className={`${styles.button} ${styles.inline_button}`} type="submit" value="Spectate" />
      </form>
      <p className={styles.title}>Invites received:</p>
      <table className={styles.challenge_list}>
        <thead>
          <tr>
            <th>Challenger</th>
            <th>Host</th>
            <th>Players</th>
            <th>Type</th>
          </tr>
        </thead>
        <tbody>
          {
            Object.entries(challenges).map(([id, data]) => (
              <tr key={id}>
                <td>{data.challenger == '~'+window.ship ? "You" : data.challenger}</td>
                <td>{data.host}</td>
                <td>{
                  Object.entries(data.players).map(([player, player_data]) => (
                    <li key={player}>
                       <p className={styles.player_name}>
                         {player}
                       </p>
                       <p className={styles.player_response}>
                         {player_data.accepted ? "Accepted." : player_data.declined ? "Declined." : "Waiting.."}
                       </p>
                    </li>
                  ))
                  }</td>
                <td>{data.type}</td>
                <td>{data.challenger == '~'+window.ship 
                 ? <button className={`${styles.button} ${styles.full_width}`} onClick={() => cancelChallenge(id)}>
                     Cancel
                   </button>
                 : <>
                    <button className={styles.button} onClick={() => acceptChallenge(id)}>
                      Accept
                    </button>
                    <button className={styles.button} onClick={() => declineChallenge(id)}>
                      Decline
                    </button>
                   </>}</td>
              </tr>
            ))
          }
        </tbody>
      </table>
    </div>
  );
};

export default ChallengeList;
