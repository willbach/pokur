import React from 'react'
import { Card } from '../../types/Card'
import { SUIT_DISPLAY, VAL_DISPLAY } from '../../utils/constants'
import './Card.scss'

interface CardProps {
  card: Card
  size: string
}

const CardDisplay = ({ card: { suit, val }, size }: CardProps) => {
  const color = SUIT_DISPLAY[suit][1]
  const value = VAL_DISPLAY[val]
  const suitIcon = SUIT_DISPLAY[suit][0]

  return (
      <div className={`card ${color} ${size}`}>
        <div className='card-top'>
          <div className={`card-value ${size}`}>{value}</div>
          <div className={`card-suit ${size}`}>{suitIcon}</div>
        </div>
        <div className='card-bottom'>
          <div className={`card-value ${size}`}>{value}</div>
          <div className={`card-suit ${size}`}>{suitIcon}</div>
        </div>
      </div>
  )
}

export default CardDisplay
