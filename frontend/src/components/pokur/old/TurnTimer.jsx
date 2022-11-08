import React, { useState, useEffect } from 'react';
import styles from './TurnTimer.module.css';

const TurnTimer = ({ length }) => {
  const [timeLeft, setTimeLeft] = useState(length);
  
  useEffect(() => {
    const interval = setInterval(() => {
      if (timeLeft > 0) {
        setTimeLeft(timeLeft - 1);
      }
    }, 1000);
    return () => clearInterval(interval);
  });

  return (
    <div className={styles.timer}>
      <div className={styles.countdown_bar}>
        <div className={styles.countdown_bar_filled} style={{width: `${(timeLeft / length) * 100}%`}}>
          {timeLeft > 0
           ? <p>{timeLeft}</p>
           : <p className={styles.blinking_red}>0</p>}
        </div>
      </div>
    </div>
  );
};

export default TurnTimer;