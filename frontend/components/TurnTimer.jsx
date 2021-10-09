import React, { useState, useEffect } from 'react';
import styles from './TurnTimer.module.css';

const TurnTimer = ({ countdown }) => {
  
  const [timeLeft, setTimeLeft] = useState(countdown);

  // useEffect(() => {
  //   if (localStorage.getItem("gameTimer")) {
  //     setTimeLeft(localStorage.getItem("gameTimer"));
  //   }
  // }, []);

  useEffect(() => {
    setTimeout(() => {
      if (timeLeft > 0) {
        setTimeLeft(timeLeft - 1);
        // localStorage.setItem("gameTimer", timeLeft - 1);
      }
    }, 1000);
  });

  return (
    <div className={styles.timer}>
      <div className={styles.countdown_bar}>
        <div className={styles.countdown_bar_filled} style={{width: `${(timeLeft / countdown) * 100}%`}}>
          {timeLeft > 0
           ? <p>{timeLeft}</p>
           : <p className={styles.blinking_red}>0</p>}
        </div>
      </div>
    </div>
  );
};

export default TurnTimer;