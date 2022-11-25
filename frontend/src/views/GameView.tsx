import React, { useCallback, useEffect, useMemo } from 'react'
import { CSSTransition, TransitionGroup } from 'react-transition-group'
import { useNavigate } from 'react-router-dom'
import { sigil, reactRenderer } from '@tlon/sigil-js'
import api from '../api'
import Button from '../components/form/Button'
import Col from '../components/spacing/Col'
import Row from '../components/spacing/Row'
import Text from '../components/text/Text'
import usePokurStore from '../store/pokurStore'
import Chat from '../components/pokur/Chat';
import CardDisplay from '../components/pokur/Card';
import Player from '../components/pokur/Player'
import GameActions from '../components/pokur/GameActions'
import { PLAYER_POSITIONS } from '../utils/constants'
import logo from '../assets/img/logo192.png'

import './GameView.scss'

interface GameViewProps {
  redirectPath: string
}

const GameView = ({ redirectPath }: GameViewProps) => {
  const { game, leaveGame, subscribeToPath } = usePokurStore()
  const nav = useNavigate()

  useEffect(() => {
    const gameSub = subscribeToPath('/game-updates')
    return () => {
      gameSub.then((sub: number) => api.unsubscribe(sub))
    }
  }, []) // eslint-disable-line react-hooks/exhaustive-deps

  useEffect(() => redirectPath ? nav(redirectPath) : undefined, [redirectPath]) // eslint-disable-line react-hooks/exhaustive-deps

  useEffect(() => !game ? nav('/') : undefined, [game, nav])

  const leave = useCallback(async () => {
    if (window.confirm('Are you sure you want to leave the game?')) {
      await leaveGame(game?.id!)
      nav('/')
    }
  }, [nav, game, leaveGame])

  const playerOrder = useMemo(() => {
    if (!game?.players)
      return []

    const ourIndex = game.players.map(({ ship }) => ship).indexOf((window as any).ship)
    const newOrder = game.players.slice(ourIndex).concat(game.players.slice(0, ourIndex))
    return newOrder
  }, [game])

  console.log('GAME:', game)

  return (
    <Col className='game-view'>
      {!game || game.game_is_over ? (
        <Col className='content'>
          <h3>{game?.game_is_over ? 'Game Ended' : 'Game Not Found'}</h3>
          <Button variant='dark' style={{ marginTop: 16 }} onClick={() => nav('/')}>
            Return to Lobby
          </Button>
        </Col>
      ) : (
        <Col className="game">
          <div className='players'>
            <Col className="center-table">
              <Row className='branding'>
                <img src={logo} alt='uqbar logo' />
                <Text mono>POKUR</Text>
              </Row>
              <Col className='pots'>
                {Boolean(game?.pots[0]?.amount) && game?.pots[0].amount !== '0' && (
                  <Text className='pot'>Main Pot: {game.pots[0]?.amount || '0'}</Text>
                )}

                {game.pots.length < 2 && (
                  game.pots.map((p, i) => (
                    i === 0 ? null :
                    <Text className='pot' key={p.amount + i}>Side Pot #{i}: {p.amount}</Text>
                  ))
                )}
              </Col>
              <TransitionGroup component="div" className='cards'>
                {game.board.map(c => (
                  <CSSTransition key={c.suit + c.val} timeout={700} classNames="card-container">
                    <CardDisplay card={c} size="large" />
                  </CSSTransition>
                ))}
              </TransitionGroup>
            </Col>

            {playerOrder.map((p, ind) => {
              const curTurn = game.current_turn.includes(p.ship)
              const buttonIndicator = game?.big_blind.includes(p.ship) ? 'BB' :
                game?.small_blind.includes(p.ship) ? 'SB' :
                game?.dealer.includes(p.ship) ? 'D' : ''

              return (
                <Col className={`player-display ${PLAYER_POSITIONS[`${ind + 1}${playerOrder.length}`]}`} key={p.ship}>
                  <Row className='cards'>
                    {(window as any).ship === p.ship && false ? (
                      <>
                        {game?.hand.map(c => <CardDisplay key={c.suit + c.val} card={c} size="small" />)}
                      </>
                    ) : p.left ? (
                      <Text bold style={{ whiteSpace: 'nowrap' }}>Left the game</Text>
                    ) : (
                      <div className='sigil-container avatar'>
                        {sigil({ patp: p.ship, renderer: reactRenderer, class: 'avatar-sigil', colors: ['black', 'white'] })}
                      </div>
                    )}
                  </Row>
                  <div className='player-info'>
                    <Player hideSigil ship={p.ship} />
                    <Text className='stack' bold>${p.stack}</Text>
                  </div>
                  <Row className='bet'>
                    {Boolean(buttonIndicator) && <div className='button-indicator'>{buttonIndicator}</div>}
                    {Number(p.committed) > 0 && <div>Bet: {p.committed}</div>}
                  </Row>
                </Col>
              )
            })}
          </div>
          <div className='table' />
          <Chat />
          {game.current_turn.includes((window as any).ship) && <GameActions />}
        </Col>
      )}
      {Boolean(game) && (
        <Row className='top-nav'>
          <Row className='game-id'>
            Game: {game?.id}
          </Row>
          <Button onClick={leave}>
            Leave Game
          </Button>
        </Row>
      )}
    </Col>
  )
}

export default GameView
