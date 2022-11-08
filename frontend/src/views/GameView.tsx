import React, { useEffect } from 'react'
import api from '../api'
import Col from '../components/spacing/Col'
import usePokurStore from '../store/pokurStore'

import './GameView.scss'

const GameView = () => {
  const { subscribeToPath } = usePokurStore()

  useEffect(() => {
    const gameSub = subscribeToPath('/game-updates')
    return () => {
      gameSub.then((sub: number) => api.unsubscribe(sub))
    }
  }, []) // eslint-disable-line react-hooks/exhaustive-deps

  return (
    <Col className='game-view'>
      <div className='background' />
      <Col className='content'>
        <h2>Welcome to Pokur</h2>

      </Col>
    </Col>
  )
}

export default GameView
