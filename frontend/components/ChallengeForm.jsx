import React, { useState } from 'react';
import styles from './ChallengeForm.module.css';

const ChallengeForm = ({ urb, sentChallenge, setSentChallenge }) => {
  const [sendToList, setSendToList] = useState({0:''});
  const [addPlayerText, setAddPlayerText] = useState("Add Player");
  const [showCashOptions, setShowCashOptions] = useState(false);

  const handleChange = (target) => {
    const id = target.id;
    setSendToList({...sendToList, [id]: target.value });
  };

  const showOrHideCashOptions = (target) => {
    if (target.value == "cash") {
      setShowCashOptions(true);
    } else {
      setShowCashOptions(false);
    }
  };

  const addToInput = (e) => {
    e.preventDefault();
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
      var json;
      if (e.target.gameType.value == "cash") {
        json = {
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
      } else {
        json = {
          'issue-challenge': {
            'to': to,
            'host': e.target.host.value,
            'type': e.target.gameType.value,
            'min-bet': 0,
            'starting-stack': 0,
            'turn-time-limit': "s" + parseInt(e.target.turnTimer.value),
            'time-limit-seconds': parseInt(e.target.turnTimer.value),
          }
        }
      }
      urb.poke({
        app: 'pokur',
        mark: 'pokur-client-action',
        json: json,
      });
      setSentChallenge(true);
    } else {
      console.log("error: already have a sent challenge");
    }
  };

  return (
    <div className={styles.wrapper}>
      <p className={styles.title}>Start a game</p>
      <form onSubmit={e => handleSubmit(e)} className={styles.form}>
        <label>To:</label>
        {Object.entries(sendToList).map(([i, data]) => ( 
            <input key={i} name="to" id={i} type="text"  placeholder="~zod" value={data} onChange={e => handleChange(e.target)} />
        ))}
        <button className={styles.button} onClick={e => addToInput(e)}>
          {addPlayerText}
        </button>
        <br />
        <label>
          Host ship: 
          <input name="host" type="text" placeholder="~zod"/>
        </label>
        <br />
        <br />
        <label>
          Game type: 
          <select name="gameType" onChange={e => showOrHideCashOptions(e.target)}>
            <option value="turbo">Turbo Tournament</option>
            <option value="fast">Fast Tournament</option>
            <option value="slow">Slow Tournament</option>
            <option value="cash">Cash</option>
          </select>
        </label>
        <br />
        {showCashOptions
        ?
        <>
        <label>
          Min. bet / big blind size: $
          <input name="minBet" type="number"/>
        </label>
        <br />
        <label>
          Starting stack size: $
          <input name="stackSize" type="number"/>
        </label>
        </>
        : <></>
        }
        <br />
        <label>
          Turn time limit (in seconds):
          <input name="turnTimer" type="number" placeholder="60"/>
        </label>
        <br />
        <input className={styles.button} type="submit" value="Submit" />
      </form>
    </div>
  );
};

export default ChallengeForm;
