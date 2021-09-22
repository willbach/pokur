import React, { useState, useEffect } from 'react';

const ChallengeList = (urb) => {
  const [challenges, setChallenges] = useState({});
  const [sub, setSub] = useState();

  // subscribe to /challenge-updates
  useEffect(() => {
    if (!urb.urb || sub) return;
    urb.urb
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
  }, [urb, sub]);

  const processChallengeUpdate = (data) => {
    console.log(data);
    if (data["update"] == "open") {
      const newChallenge = {
        challenger: data["challenger"],
        host: data["host"],
        type: data["type"],
      }
      console.log(newChallenge);
      setChallenges({ ...challenges, [data["id"]]: newChallenge});
    } else if (data["update"] == "close") {
      var newList = {...challenges};
      delete newList[data["id"]];
      setChallenges(newList);
    }
  }

  const acceptChallenge = (id, from) => {
    urb.urb.poke({
      app: 'pokur',
      mark: 'pokur-client-action',
      json: {
        'accept-challenge': {
          'from': from,
          'id': id,
        }
      },
    });
  }

  const cancelChallenge = (id, from) => {
    urb.urb.poke({
      app: 'pokur',
      mark: 'pokur-client-action',
      json: {
        'cancel-challenge': {
          'id': id,
        }
      },
    });
  }

  return (
    <div>
      <h2>Active Challenges</h2>
      <table className="challenge-list">
        <thead>
          <tr>
            <th>Challenger</th>
            <th>Host</th>
            <th>Type</th>
          </tr>
        </thead>
        <tbody>
          {
            Object.entries(challenges).map(([id, data]) => (
              <tr key={id}>
                <td>{data.challenger == '~'+window.ship ? "You" : data.challenger}</td>
                <td>{data.host}</td>
                <td>{data.type}</td>
                <td>{data.challenger == '~'+window.ship 
                 ? <button onClick={() => cancelChallenge(id, data.challenger)}>
                     Cancel
                   </button>
                 : <button onClick={() => acceptChallenge(id, data.challenger)}>
                     Accept
                   </button>}</td>
              </tr>
            ))
          }
        </tbody>
      </table>
    </div>
  );
}

export default ChallengeList;
