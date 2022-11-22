import React from 'react'
import { sigil, reactRenderer } from '@tlon/sigil-js'
import Row from "../spacing/Row"
import Text from '../text/Text'

import './Player.scss'

interface PlayerProps {
  ship: string;
  className?: string;
  alt?: boolean
}

const Player = ({ ship, className, alt = false }: PlayerProps) => {
  return (
    <Row key={ship} className={`player ${className || ''}`}>
      <div className='sigil-container'>
        {sigil({ patp: ship, renderer: reactRenderer, size: 24, colors: alt ? ['white', 'black'] : ['black', 'white'] })}
      </div>
      <Text key={ship} className={`ship ${alt ? 'alt' : ''}`}>~{ship.replace(/~/, '')}</Text>
    </Row>
  )
}

export default Player
