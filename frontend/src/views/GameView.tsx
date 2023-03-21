import React, { useCallback, useEffect, useMemo, useState } from 'react'
import cn from 'classnames'
import { CSSTransition, TransitionGroup } from 'react-transition-group'
import { useNavigate } from 'react-router-dom'
import { CountdownCircleTimer } from 'react-countdown-circle-timer'
import { AccountSelector, HardwareWallet, HotWallet, useWalletStore } from '@uqbar/wallet-ui'
import { FaChevronDown, FaChevronUp } from 'react-icons/fa';

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
import { PLAYER_POSITIONS, REMATCH_PARAMS_KEY, REMATCH_LEADER_KEY, MOBILE_PLAYER_POSITIONS } from '../utils/constants'
import logo from '../assets/img/logo192.png'
import chipStack from '../assets/img/red-chips.png'
import { renderSigil } from '../utils/player'
import { fromUd } from '../utils/number'
import { getSecondsFromNow } from '../utils/time'
import TableBackground from '../components/pokur/TableBackground'
import { denominateAmount, getBB, isSelf, isShip } from '../utils/game'
import { Denomination } from '../types/Game'
import { Select } from '../components/form/Select'
import useWindowDimensions from '../utils/useWindowSize'

import './GameView.scss'
import { deSig } from '../utils/pongo'

interface GameViewProps {
  redirectPath: string
}

const GameView = ({ redirectPath }: GameViewProps) => {
  const { lobby, game, gameEndMessage, lastAction, denomination,
    leaveGame, subscribeToPath, createTable, joinTable, set, setOurAddress } = usePokurStore()
  const { setInsetView, setMostRecentTransaction } = useWalletStore()
  const nav = useNavigate()
  const { width } = useWindowDimensions()
  const isMobile = width <= 800
  const [showChat, setShowChat] = useState(!isMobile)

  useEffect(() => {
    const gameSub = subscribeToPath('/game-updates')
    const lobbySub = subscribeToPath('/lobby-updates')
    return () => {
      lobbySub.then((sub: number) => api.unsubscribe(sub))
      gameSub.then((sub: number) => api.unsubscribe(sub))
    }
  }, []) // eslint-disable-line react-hooks/exhaustive-deps

  useEffect(() => redirectPath ? nav(redirectPath) : undefined, [redirectPath]) // eslint-disable-line react-hooks/exhaustive-deps

  const chooseDenomination = useCallback((denomination: Denomination) => set({ denomination }), [set])

  const leave = useCallback((skipConfirmation = false) => async () => {
    if (skipConfirmation || window.confirm('Are you sure you want to leave the game?')) {
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

  const bigBlind = getBB(game?.game_type)
  const dnmAmnt = useCallback((amount: number | string) => denominateAmount(amount, bigBlind, denomination), [bigBlind, denomination])
  
  const computedPots = useMemo(() =>
  (game?.pots || []).map(
    (p, i, a) => i !== a.length - 1 ? { ...p, amount: fromUd(p?.amount) } :
    { ...p, amount: fromUd(p?.amount) + (game?.players || []).reduce((acc, pl) => acc + fromUd(pl.committed), 0) }
    )
    , [game])
    
  const isSpectator = !Boolean(game?.players.find(({ ship }) => deSig(ship) === deSig((window as any).ship)))
  const secondsLeft = getSecondsFromNow(game?.turn_start, game?.turn_time_limit)
  const rematchParams = localStorage.getItem(REMATCH_PARAMS_KEY)
  const rematchLeader = localStorage.getItem(REMATCH_LEADER_KEY)
  const rematchId = Object.values(lobby).find(
    t => rematchLeader === t.leader && !t.public && JSON.stringify(game?.game_type) === JSON.stringify(t.game_type)
  )?.id
  
  const canRematch = Boolean(rematchParams || rematchId)
  const rematch = useCallback(async () => {
    if (game && rematchParams) {
      await leaveGame(game.id)
      nav('/')
      setMostRecentTransaction(undefined)
      setInsetView('confirm-most-recent')
      set({ invites: game.players.map(({ ship }) => ship).filter(s => !isSelf(s)) })
      createTable({ ...JSON.parse(rematchParams), public: false })
    } else if (game && rematchId) {
      await leaveGame(game.id)
      nav('/')
      setMostRecentTransaction(undefined)
      setInsetView('confirm-most-recent')
      set({ joinTableId: rematchId })
      joinTable(rematchId, '0', false)
    }
  }, [
    rematchParams, rematchId, game,
    nav, leaveGame, createTable, joinTable, setInsetView, setMostRecentTransaction, set
  ])

  const playersRemaining = game?.players.filter(({ left, committed, stack }) => !left && (fromUd(committed) + fromUd(stack) > 0)).length ?? 2

  return (
    <Col className={cn('game-view', Boolean(gameEndMessage) && 'game-over')}>
      {!game ? (
        <>
          <TableBackground />
          <Col className='content'>
            <h3>Game Ended</h3>
            {Boolean(gameEndMessage) && <>
              <p>{gameEndMessage}</p>
              <p>Payouts will be made from the escrow contract soon.</p>
              <p>The original table organizer can initiate a rematch, this may take up to a minute.</p>
            </>}
            <Button variant='dark' style={{ marginTop: 16 }} onClick={() => nav('/')}>
              Return to Lobby
            </Button>
          </Col>
          <Row className='top-nav'>
            <Row className='game-id'>
              Game Over
            </Row>
            <AccountSelector onSelectAccount={(a: HotWallet | HardwareWallet) => setOurAddress(a.rawAddress)} />
          </Row>
        </>
      ) : (
        <Col className="game">
          {Boolean(gameEndMessage) && (
            <Col className='game-end-popup'>
              <h3>Game Ended</h3>
              {Boolean(gameEndMessage) && <>
                <p>{gameEndMessage}</p>
                <p>Payouts will be made from the escrow contract soon.</p>
              </>}
              <Row style={{ marginTop: 16 }}>
                {/* <Button variant='dark' disabled={!canRematch} style={{ width: 150, marginRight: 16 }} onClick={rematch}>
                  Rematch
                </Button> */}
                <Button variant='dark' style={{ width: 150 }} onClick={leave(true)}>
                  Return to Lobby
                </Button>
              </Row>
            </Col>
          )}
          <div className='players'>
            <TableBackground />
            <Col className="center-table">
              <Row className='branding'>
                <img src={logo} alt='uqbar logo' />
                <Text mono className='logo-text'>POKUR</Text>
              </Row>
              <Col className='pots'>
                {Boolean(computedPots[0]?.amount) && String(computedPots[0]?.amount) !== '0' && (
                  <Text className='pot'>{game.pots.length > 1 ? 'Main ' : ''}Pot: {denomination === '$' ? '$' : ''}{dnmAmnt(computedPots[0]?.amount || '0')} {denomination === 'BB' ? 'BB' : ''}</Text>
                )}

                {computedPots.length > 1 && (
                  computedPots.map((p, i) => (
                    i === 0 ? null :
                    <Text className='pot' key={String(p?.amount) + i}>Side Pot #{i}: {dnmAmnt(p.amount)}</Text>
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
              const hand = game.revealed_hands[`~${p.ship}`]
              const folded = p.folded
              const winner = isShip(game?.winner, p.ship) ? 'Winner' : undefined
              
              const buttonIndicator = game?.game_is_over ? '' :
                playersRemaining === 2 && game?.dealer.includes(p.ship) ? 'D' :
                playersRemaining === 2 ? '' :
                game?.big_blind.includes(p.ship) ? 'BB' :
                game?.small_blind.includes(p.ship) ? 'SB' :
                game?.dealer.includes(p.ship) ? 'D' : ''

              return (
                <Col className={`player-display ${(isMobile ? MOBILE_PLAYER_POSITIONS : PLAYER_POSITIONS)[`${ind + 1}${playerOrder.length}`]}`} key={p.ship}>
                  <Row className='cards'>
                    {isSelf(p.ship) && !folded ? (
                      <>
                        {game?.hand.map(c => <CardDisplay key={c.suit + c.val} card={c} size="small" />)}
                      </>
                    ) : hand ? (
                      <>
                        {hand.map(c => <CardDisplay key={c.suit + c.val} card={c} size="small" />)}
                      </>
                    ) : (
                      <>
                        {!folded && <Row style={{ position: 'absolute', top: isMobile ? -6 : -12, zIndex: 0 }}>
                          {[1, 2].map(a => <div key={a} className='blank-card' />)}
                        </Row>}
                        <div className='sigil-container avatar' style={{ zIndex: 1 }}>
                          {renderSigil({ ship: p.ship, className: 'avatar-sigil', colors: [folded ? 'grey' : 'black', 'white'], size: isMobile ? 36 : 60 })}
                        </div>
                      </>
                    )}
                  </Row>
                  <div className={cn(
                    'player-info',
                    game?.winner ?
                      Boolean(winner) && !gameEndMessage && 'winner' :
                      curTurn && !gameEndMessage && 'current-turn',
                    folded && 'folded'
                  )}>
                    <Player hideSigil ship={p.ship} altDisplay={lastAction[p.ship] || winner} />
                    <Text className='stack' bold>{p.left ? 'Left' : `${denomination === '$' ? '$' : ''}${dnmAmnt(p.stack)} ${denomination === 'BB' ? 'BB' : ''}`}</Text>
                  </div>
                  <Row className='bet'>
                    {Boolean(buttonIndicator) ? (
                      <div className={cn('button-indicator', buttonIndicator === 'D' && 'dealer')}>
                        {buttonIndicator}
                      </div>
                    ) : Number(p.committed) > 0 ? (
                      <img src={chipStack} className='chip-stack' alt='chips' />
                    ) : null}
                    {Number(p.committed) > 0 && <div className='amount'>Bet: {dnmAmnt(p.committed)}</div>}
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
                  {game?.hand_rank && game.hand_rank.length > 1 && isSelf(p.ship) && (
                    <Text className='hand-rank'>{game?.hand_rank}</Text>
                  )}
                  {Boolean(winner) && Boolean(game?.winning_hand) && (
                    <Text className='hand-rank'>{game?.winning_hand}</Text>
                  )}
                </Col>
              )
            })}
          </div>
          <div className='table' />
          {showChat && (
            <Chat className={`${isMobile ? 'mobile' : 'fixed'} in-game`} height={isMobile ? '40vh' : 160} />
          )}
          {!Object.keys(game?.revealed_hands || {}).length && !gameEndMessage && !isSpectator && (
            <GameActions pots={computedPots} secondsLeft={secondsLeft} denomination={denomination} bigBlind={bigBlind} />
          )}
        </Col>
      )}
      {Boolean(game) && (
        <Row className='top-nav'>
          <Col>
            <Text oneLine className='game-id'>
              Game: {game?.id}
            </Text>
            {isMobile && (
              <Button variant='unstyled' style={{
                marginLeft: 8,
                height: 32,
                width: 32,
                borderRadius: 16,
                backgroundColor: 'white',
                paddingTop: showChat ? 2 : 6,
              }} onClick={() => setShowChat(!showChat)}>
                {showChat ? (
                  <FaChevronUp />
                ) : (
                  <FaChevronDown />
                )}
              </Button>
            )}
          </Col>
          <Col style={{ alignItems: 'flex-end' }}>
            <Button onClick={leave()}>
              Leave
            </Button>
            <Row style={{ marginTop: 4 }}>
              {/* <Text bold style={{ color: 'white', marginRight: 4 }}>Denomination:</Text> */}
              <Select value={denomination} onChange={e => chooseDenomination(e.target.value as Denomination)}>
                {(['$', 'BB'] as Denomination[]).map(d => <option key={d} value={d}>{d}</option>)}
              </Select>
            </Row>
          </Col>
        </Row>
      )}
    </Col>
  )
}

export default GameView
