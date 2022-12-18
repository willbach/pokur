import React from 'react'
import { formatShip, renderSigil } from '../../utils/player';
import Row from "../spacing/Row"
import Text from '../text/Text'

import './Player.scss'

interface PlayerProps {
  ship: string;
  className?: string;
  alt?: boolean
  hideSigil?: boolean
}

const Player = ({ ship, className, alt = false, hideSigil = false }: PlayerProps) => {
  return (
    <Row key={ship} className={`player ${className || ''}`}>
      {!hideSigil && <div className='sigil-container'>
        {renderSigil({ ship, alt })}
      </div>}
      <Text key={ship} className={`ship ${alt ? 'alt' : ''}`}>{formatShip(ship.replace(/~/, ''))}</Text>
    </Row>
  )
}

export default Player
