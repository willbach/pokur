import React, { useState, useEffect } from 'react';

const TurnTimer = ({ countdown }) => {
  
  const [timeLeft, setTimeLeft] = useState(countdown);

  useEffect(() => {
      setTimeout(() => {
          setTimeLeft(timeLeft - 1);
      }, 1000);
  });

  return (
    <div className="timer">
      {timeLeft}
    </div>
  );
};

export default TurnTimer;