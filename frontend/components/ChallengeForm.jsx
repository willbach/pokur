import React, { useState } from 'react';

const ChallengeForm = ({ urb, sentChallenge, setSentChallenge }) => {
  const [sendToList, setSendToList] = useState({0:''});
  const [addPlayerText, setAddPlayerText] = useState("Add Player");

  const handleChange = (target) => {
    const id = target.id;
    setSendToList({...sendToList, [id]: target.value });
  };

  const addToInput = () => {
    var n = Object.keys(sendToList).length;
    if (n >= 7) {
      setAddPlayerText("8 player maximum for cash games");
    } else {
      setSendToList({...sendToList, [n]: '' });
    }
  };

  const handleSubmit = (e) => {
    if (!sentChallenge) {
      e.preventDefault();
      const to = Object.values(sendToList);
      urb.poke({
        app: 'pokur',
        mark: 'pokur-client-action',
        json: {
          'issue-challenge': {
            'to': to,
            'host': e.target.host.value,
            'type': e.target.gameType.value,
            'min-bet': parseInt(e.target.minBet.value),
            'starting-stack': parseInt(e.target.stackSize.value),
            'turn-time-limit': "s" + parseInt(e.target.turnTimer.value),
            'time-limit-seconds': parseInt(e.target.turnTimer.value),
          }
        }
      });
      setSentChallenge(true);
    } else {
      console.log("error: already have a sent challenge");
    }
  };

  return (
    <div>
      <p>Send a challenge poke</p>
      <form onSubmit={e => handleSubmit(e)}>
        {Object.entries(sendToList).map(([i, data]) => ( 
          <label key={i}>
            <br />
            To: 
            <input name="to" id={i} type="text" value={data} onChange={e => handleChange(e.target)} />
        </label>
        ))}
        <button onClick={() => addToInput()}>
          {addPlayerText}
        </button>
        <br />
        <label>
          Host ship: 
          <input name="host" type="text"/>
        </label>
        <br />
        <label>
          Min. bet / big blind size: $
          <input name="minBet" type="number"/>
        </label>
        <br />
        <label>
          Starting stack size: $
          <input name="stackSize" type="number"/>
        </label>
        <br />
        <label>
          Game type: 
          <select name="gameType">
            <option value="cash">Cash</option>
            <option value="tournament">Tournament (not yet functional)</option>
          </select>
        </label>
        <label>
          Turn time limit (in seconds):
          <input name="turnTimer" type="number"/>
        </label>
        <br />
        <input type="submit" value="Submit" />
      </form>
    </div>
  );
};

export default ChallengeForm;
