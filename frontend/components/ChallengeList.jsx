import React, { useState, useEffect } from 'react';
import styles from './ChallengeList.module.css';

const ChallengeList = ({ urb, setSentChallenge }) => {
  const [challenges, setChallenges] = useState({});
  const [sub, setSub] = useState();

  // subscribe to /challenge-updates
  useEffect(() => {
    if (!urb || sub) return;
    urb
      .subscribe({
        app: "pokur",
        path: "/challenge-updates",
        event: processChallengeUpdate,
        err: console.log,
        quit: console.log,
      })
      .then((subscriptionId) => {
        setSub(subscriptionId);
      });
  }, [urb]);

  const processChallengeUpdate = (data) => {
    if (data["update"] == "open" || data["update"] == "modify") {
      const newChallenge = {
        challenger: data["challenger"],
        players: data["players"],
        host: data["host"],
        type: data["type"],
      }
      setChallenges({ ...challenges, [data["id"]]: newChallenge});
    } else if (data["update"] == "close") {
      var newList = {...challenges};
      delete newList[data["id"]];
      setChallenges(newList);
    }
  };

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

  return (
    <div className={styles.wrapper}>
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
                 ? <button className={styles.button} onClick={() => cancelChallenge(id)}>
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
