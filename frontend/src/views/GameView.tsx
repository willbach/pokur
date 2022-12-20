import React, { useCallback, useEffect, useMemo, useState } from 'react'
import { CSSTransition, TransitionGroup } from 'react-transition-group'
import { useNavigate } from 'react-router-dom'
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
import { renderSigil } from '../utils/player'
import { fromUd } from '../utils/number'
import { CountdownCircleTimer } from 'react-countdown-circle-timer'
import { getSecondsFromNow } from '../utils/time'

import './GameView.scss'

interface GameViewProps {
  redirectPath: string
}

const GameView = ({ redirectPath }: GameViewProps) => {
  const { game, gameEndMessage, leaveGame, subscribeToPath } = usePokurStore()
  const nav = useNavigate()

  useEffect(() => {
    const gameSub = subscribeToPath('/game-updates')
    return () => {
      gameSub.then((sub: number) => api.unsubscribe(sub))
    }
  }, []) // eslint-disable-line react-hooks/exhaustive-deps

  useEffect(() => redirectPath ? nav(redirectPath) : undefined, [redirectPath]) // eslint-disable-line react-hooks/exhaustive-deps

  const leave = useCallback(async () => {
    if (window.confirm('Are you sure you want to leave the game?')) {
      try {
        await leaveGame(game?.id!)
      } catch (err) {}
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
  const gameOver = game?.game_is_over || (gameEndMessage && !game)

  const computedPots = useMemo(() =>
    (game?.pots || []).map(
      (p, i, a) => i !== a.length - 1 ? { ...p, amount: fromUd(p.amount) } :
        { ...p, amount: fromUd(p.amount) + (game?.players || []).reduce((acc, pl) => acc + fromUd(pl.committed), 0) }
    )
  , [game])

  const secondsLeft = getSecondsFromNow(game?.turn_start, game?.turn_time_limit)

  return (
    <Col className={`game-view ${gameOver ? 'game-over' : ''}`}>
      {!game ? (
        <Col className='content'>
          <h3>{gameOver ? 'Game Ended' : 'Game Not Found'}</h3>
          {Boolean(gameEndMessage) && <>
            <p>{gameEndMessage}</p>
            <p>Payouts will be made from the escrow contract soon.</p>
          </>}
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
                {Boolean(computedPots[0]?.amount) && String(computedPots[0].amount) !== '0' && (
                  <Text className='pot'>{game.pots.length > 1 ? 'Main ' : ''}Pot: {computedPots[0]?.amount || '0'}</Text>
                )}

                {computedPots.length > 1 && (
                  computedPots.map((p, i) => (
                    i === 0 ? null :
                    <Text className='pot' key={String(p.amount) + i}>Side Pot #{i}: {p.amount}</Text>
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

            {playerOrder.map((p, ind, arr) => {
              const curTurn = game.current_turn.includes(p.ship)
              const isSelf = (window as any).ship === p.ship
              const hand = game.revealed_hands[`~${p.ship}`]
              
              const buttonIndicator = arr.length === 2 && game?.dealer.includes(p.ship) ? 'D' :
                arr.length === 2 ? '' :
                game?.big_blind.includes(p.ship) ? 'BB' :
                game?.small_blind.includes(p.ship) ? 'SB' :
                game?.dealer.includes(p.ship) ? 'D' : ''

              return (
                <Col className={`player-display ${PLAYER_POSITIONS[`${ind + 1}${playerOrder.length}`]}`} key={p.ship}>
                  <Row className='cards'>
                    {isSelf ? (
                      <>
                        {game?.hand.map(c => <CardDisplay key={c.suit + c.val} card={c} size="small" />)}
                      </>
                    ) : hand ? (
                      <>
                        {hand.map(c => <CardDisplay key={c.suit + c.val} card={c} size="small" />)}
                      </>
                    ) : (
                      <div className='sigil-container avatar'>
                        {renderSigil({ ship: p.ship, className: 'avatar-sigil' })}
                      </div>
                    )}
                  </Row>
                  <div className={`player-info ${curTurn ? 'current-turn' : ''}`}>
                    <Player hideSigil ship={p.ship} />
                    <Text className='stack' bold>{p.left ? 'Left the game' : `$${p.stack}`}</Text>
                  </div>
                  <Row className='bet'>
                    {Boolean(buttonIndicator) && <div className='button-indicator'>{buttonIndicator}</div>}
                    {Number(p.committed) > 0 && <div>Bet: {p.committed}</div>}
                  </Row>
                  {curTurn && !isSelf && !hand && (
                    <div className='turn-timer'>
                      <CountdownCircleTimer
                        key={secondsLeft}
                        isPlaying
                        trailColor='#545454'
                        duration={secondsLeft}
                        colors={['#ffffff', '#ff0000']}
                        colorsTime={[secondsLeft, 0]}
                        size={64}
                        strokeWidth={3}
                      />
                    </div>
                  )}
                </Col>
              )
            })}
          </div>
          <div className='table' />
          <Chat />
          {game.current_turn.includes((window as any).ship) && !Object.keys(game?.revealed_hands || {}).length &&
            <GameActions pots={computedPots} secondsLeft={secondsLeft} />
          }
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
