import React from 'react'
import { LastAction } from '../../store/pokurStore';
import { renderShip, renderSigil } from '../../utils/player';
import Row from "../spacing/Row"
import Text from '../text/Text'

import './Player.scss'

interface PlayerProps extends React.HTMLAttributes<HTMLDivElement> {
  ship: string;
  lastAction?: LastAction
  className?: string;
  alt?: boolean
  hideSigil?: boolean
}

const Player = ({ ship, className, lastAction = {}, alt = false, hideSigil = false, children }: PlayerProps) => {
  return (
    <Row key={ship} className={`player ${className || ''}`}>
      {!hideSigil && <div className='sigil-container'>
        {renderSigil({ ship, alt })}
      </div>}
      <Text key={ship} className={`ship ${alt ? 'alt' : ''}`}>
        {lastAction[ship] || renderShip(ship.replace(/~/, ''))}
      </Text>
    </Row>
  )
}

export default Player
