import React, { useCallback, useEffect, useMemo, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import api from '../api'
import Button from '../components/form/Button'
import Col from '../components/spacing/Col'
import Row from '../components/spacing/Row'
import Text from '../components/text/Text'
import usePokurStore from '../store/pokurStore'
import Chat from '../components/pokur/Chat';
import CardDisplay from '../components/pokur/Card';
import Input from '../components/form/Input';

import './GameView.scss'
import Player from '../components/pokur/Player'

interface GameViewProps {
  redirectPath: string
}

const GameView = ({ redirectPath }: GameViewProps) => {
  const { game, leaveGame, subscribeToPath, check, fold, bet } = usePokurStore()
  const nav = useNavigate()
  const [myBet, setMyBet] = useState('0')

  useEffect(() => {
    const gameSub = subscribeToPath('/game-updates')
    return () => {
      gameSub.then((sub: number) => api.unsubscribe(sub))
    }
  }, []) // eslint-disable-line react-hooks/exhaustive-deps

  useEffect(() => redirectPath ? nav(redirectPath) : undefined, [redirectPath]) // eslint-disable-line react-hooks/exhaustive-deps

  useEffect(() => {
    if (game) {
      const me = game?.players.find(({ ship }) => ship === (window as any).ship)
      setMyBet(String(Number(game.current_bet) - Number(me?.committed)))
    }
  }, [game]) // eslint-disable-line react-hooks/exhaustive-deps

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
    return game.players.slice(ourIndex).concat(game.players.slice(0, ourIndex))
  }, [game])

  const me = useMemo(() => game?.players.find(({ ship }) => ship === (window as any).ship), [game])
  const isTurn = useMemo(() => game?.current_turn?.slice(1) === (window as any).ship, [game])
  const canCheck = useMemo(() => me?.committed === game?.current_bet, [game, me])

  console.log('GAME:', game)

  const betAction = useCallback(async () => {
    if (game && myBet && Number(myBet) > 0) {
      const totalBet = Number(myBet) + Number(me!.committed)
      const curBet = Number(game.current_bet)
      if (totalBet < curBet) {
        return window.alert(`Your bet must be at least the current bet of ${curBet}`)
      } else if (totalBet > curBet && totalBet / curBet < 2) {
        return window.alert(`Your bet must be equal to or 2x the current bet of ${curBet}`)
      }
      await bet(game.id, Number(myBet))
    }
  }, [game, myBet, me, bet])

  const checkAction = useCallback(async () => {
    if (game) {
      check(game.id)
    }
  }, [game, check])

  const callAction = useCallback(async () => {
    if (game) {
      await bet(game.id, Number(game.current_bet) - Number(me!.committed))
    }
  }, [game, me, bet])

  const foldAction = useCallback(async () => {
    if (game) {
      fold(game.id)
    }
  }, [game, fold])

  return (
    <Col className='game-view'>
      <div className='background' />
      {!game || game.game_is_over ? (
        <Col className='content'>
          <h3>{game?.game_is_over ? 'Game Ended' : 'Game Not Found'}</h3>
          <Button variant='dark' style={{ marginTop: 16 }} onClick={() => nav('/')}>
            Return to Lobby
          </Button>
        </Col>
      ) : (
        <Col className="game">
          <Col className="center-table">
            <Row className="cards">
              {game.board.map(c => (
                <CardDisplay key={c.suit + c.val} card={c} size="large" />
              ))}
            </Row>
            <Col className='pots'>
              {game.pots.length < 2 ? (
                <Text className='pot'>Pot: {game.pots[0]?.amount || '0'}</Text>
              ) : (
                game.pots.map((p, i) => (
                  <Text className='pot' key={p.amount + i}>Pot #{i + 1}: {p.amount}</Text>
                ))
              )}
            </Col>
          </Col>

          <div className='bets-container'>
            <div className={`bets p${playerOrder.length}`}>
              {playerOrder.map(p => (
                <Col className='bet' key={p.ship}>
                  <Row>
                    {p.folded ? (
                      <Text className='bet-text'>Folded</Text>
                    ) : (
                      <Text className='bet-text'>Bet: {p.committed}</Text>
                    )}
                  </Row>
                </Col>
              ))}
            </div>
          </div>

          <div className={`players p${playerOrder.length}`}>
            {playerOrder.map(p => {
              const curTurn = game.current_turn.replace(/~/, '') === p.ship

              return (
                <Col className='player' key={p.ship}>
                  <Row className='cards'>
                    {(window as any).ship === p.ship ? (
                      <>
                        {game.hand.map(c => <CardDisplay key={c.suit + c.val} card={c} size="small" />)}
                      </>
                    ) : p.left ? (
                      <Text bold style={{ color: 'white', whiteSpace: 'nowrap' }}>Left the game</Text>
                    ) : (
                      <>
                        <div className='blank-card'/>
                        <div className='blank-card'/>
                      </>
                    )}
                  </Row>
                  <Player ship={p.ship} className={`player-name ${curTurn ? 'current' : ''}`} alt={!curTurn} />
                  <Text bold style={{ color: 'white', whiteSpace: 'nowrap' }}>Stack: {p.stack}</Text>
                </Col>
              )
            })}
          </div>

          <Row className='game-actions'>
            {isTurn && (
              <>
                <Input
                  placeholder='your bet'
                  value={myBet}
                  onChange={e => setMyBet(e.target.value.replace(/[^0-9]/g, ''))}
                  min={game.current_bet}
                />
                <Button onClick={betAction}>
                  Bet
                </Button>
                <Button onClick={canCheck ? checkAction : callAction}>
                  {canCheck ? 'Check' : 'Call'}
                </Button>
                <Button onClick={foldAction}>
                  Fold
                </Button>
              </>
            )}
            </Row>
          <Chat />
        </Col>
      )}
      {Boolean(game) && (
        <Row className='top-nav'>
          <Button onClick={leave}>
            Leave Game
          </Button>
          <Row className='game-id'>
            Game: {game?.id}
          </Row>
          <div />
        </Row>
      )}
    </Col>
  )
}

export default GameView
