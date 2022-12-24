import { useCallback, useEffect, useMemo, useState } from "react"
import { CountdownCircleTimer } from 'react-countdown-circle-timer'
import usePokurStore from "../../store/pokurStore"
import { isSelf } from "../../utils/game"
import { fromUd } from "../../utils/number"
import Button from "../form/Button"
import Input from "../form/Input"
import Col from "../spacing/Col"
import Row from "../spacing/Row"
import Text from "../text/Text"

import './GameActions.scss'

interface GameActionsProps {
  pots: {
    amount: number
    players_in: string[]
  }[]
  secondsLeft: number
}

const GameActions = ({ pots, secondsLeft }: GameActionsProps) => {
  const { game, check, fold, bet } = usePokurStore()
  const [lock, setLock] = useState(false)

  const minBet = Number(game?.min_bet ? game.min_bet.replace(/[^0-9]/g, '') : '20')
  const currentBet = useMemo(() => fromUd(game?.current_bet), [game])
  const me = useMemo(() => game?.players.find(({ ship }) => ship === (window as any).ship), [game])
  const committed = useMemo(() => fromUd(me?.committed), [me])
  const isTurn = useMemo(() => isSelf(game?.current_turn), [game])
  const canCheck = useMemo(() => me?.committed === game?.current_bet, [game, me])
  const myStack = useMemo(() => fromUd(me?.stack), [me])
  const largestStack = useMemo(() => game?.players.reduce((largest, { ship, stack, committed, folded, left }) =>
    ship.includes((window as any).ship) || folded || left ? largest : Math.max(largest, fromUd(stack) + fromUd(committed))
  , 0) || myStack, [game, myStack])
  const maxBet = Math.min(myStack + committed, largestStack)
  const minRaise = Math.min(minBet + currentBet, maxBet)
  const callAmount = currentBet - committed

  const [myBet, setMyBet] = useState(minRaise)

  useEffect(() => {
    if (game && !game.current_turn.includes((window as any).ship)) {
      setLock(false)
      setMyBet(minRaise)
    }
  }, [game, minRaise])
  
  const betAction = useCallback(async () => {
    if (game && myBet && Number(myBet) > 0) {
      if ((Number(myBet) - committed) < Number(game.min_bet) && myBet !== maxBet) {
        return window.alert(`Your raise must be at least ${Number(game.min_bet) + committed}`)
      }
      setLock(true)
      try {
        await bet(game.id, Math.min(maxBet, myBet) - committed)
      } catch (err) {
        setLock(false)
      }
    }
  }, [game, myBet, maxBet, committed, bet])

  const checkAction = useCallback(async () => {
    if (game) {
      setLock(true)
      try {
        await check(game.id)
      } catch (err) {
        setLock(false)
      }
    }
  }, [game, check])

  const callAction = useCallback(async () => {
    if (game) {
      setLock(true)
      try {
        await bet(game.id, callAmount)
      } catch (err) {
        setLock(false)
      }
    }
  }, [game, callAmount, bet])

  const foldAction = useCallback(async () => {
    if (game) {
      setLock(true)
      try {
        await fold(game.id)
      } catch (err) {
        setLock(false)
      }
    }
  }, [game, fold])

  const quickBet = useCallback((amount: '1/2' | '3/4' | 'pot') => async () => {
    if (amount === '1/2') {
      setMyBet(Math.min(callAmount + Number(pots[0].amount) / 2, maxBet))
    } else if (amount === '3/4') {
      setMyBet(Math.min(callAmount + Number(pots[0].amount) * 3 / 4, maxBet))
    } else {
      setMyBet(Math.min(callAmount + Number(pots[0].amount), maxBet))
    }
  }, [maxBet, callAmount, pots, setMyBet])

  return (
    <Col className='game-actions'>
      {isTurn && !lock && (
        <>
          <Row className='quick-bet'>
            <Row className='bet-buttons'>
              {Number(game?.pots[0].amount || 0) > 0 && (
                <>
                  <Button disabled={Number(pots[0].amount) / 2 < minRaise} onClick={quickBet('1/2')}>
                    1 / 2
                  </Button>
                  <Button disabled={Number(pots[0].amount) / 4 * 3 < minRaise} onClick={quickBet('3/4')}>
                    3 / 4
                  </Button>
                  <Button disabled={Number(pots[0].amount) < minRaise} onClick={quickBet('pot')}>
                    Pot
                  </Button>
                </>
              )}
            </Row>
            <Row style={{ fontSize: 20, color: 'white', fontWeight: 600, marginBottom: 4, justifyContent: 'flex-end' }}>
              <Row style={{ width: 140, justifyContent: 'space-between', color: 'white' }}>
                <Text style={{ fontSize: 18 }}>Time Left:</Text>
                <CountdownCircleTimer
                  key={(game?.current_turn ?? 'ship') + (game?.turn_start ?? 'now')}
                  isPlaying
                  trailColor='#383838s'
                  duration={secondsLeft}
                  colors={['#ffffff', '#ff0000']}
                  colorsTime={[secondsLeft, 0]}
                  size={40}
                  strokeWidth={4}
                >
                  {({ remainingTime }) => remainingTime}
                </CountdownCircleTimer>
              </Row>
            </Row>
          </Row>
          <Row className='bet-amount'>
            <Input
              className="bet-slider"
              type="range"
              value={myBet}
              onChange={e => setMyBet(Number(e.target.value.replace(/[^0-9]/g, '')))}
              min={minRaise}
              max={maxBet}
              containerStyle={{ width: 'calc(100% - 100px)', marginRight: 8 }}
            />
            <Input
              className="bet-text"
              placeholder='your bet'
              value={myBet}
              onChange={e =>
                setMyBet(
                  Math.min(maxBet, Number(e.target.value.replace(/[^0-9]/g, '')))
                )
              }
              min={minRaise}
              max={maxBet}
            />
          </Row>
          <Row className='buttons'>
            <Button onClick={foldAction}>
              Fold
            </Button>
            <Button onClick={canCheck ? checkAction : callAction}>
              {canCheck ? 'Check' : `Call ${callAmount}`}
            </Button>
            <Button onClick={betAction}>
              {currentBet > 0 ? `Raise to ${myBet}` : `Bet ${myBet}`}
            </Button>
          </Row>
        </>
      )}
    </Col>
  )
}

export default GameActions
