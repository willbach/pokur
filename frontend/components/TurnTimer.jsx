import React, { useState, useEffect } from 'react';

const TurnTimer = ({ countdown }) => {
  
  const [timeLeft, setTimeLeft] = useState(countdown);

  useEffect(() => {
    setTimeout(() => {
      if (timeLeft > 0) {
        setTimeLeft(timeLeft - 1);
      }
    }, 1000);
  });

  return (
    <div className="timer">
      <div className="countdown-bar">
        <div className="countdown-bar-filled" style={{width: `${(timeLeft / countdown) * 100}%`}}>
          {timeLeft > 0
           ? <p>{timeLeft}</p>
           : <p className="blinking-red">0</p>}
        </div>
      </div>
    </div>
  );
};

export default TurnTimer;