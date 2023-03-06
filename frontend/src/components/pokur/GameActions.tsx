import { useCallback, useEffect, useRef, useState } from "react"
import { CountdownCircleTimer } from 'react-countdown-circle-timer'
import usePokurStore from "../../store/pokurStore"
import { Denomination } from "../../types/Game"
import useGameInfo from "../../utils/useGameInfo"
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
  denomination: Denomination
  bigBlind: number
}

const GameActions = ({ pots, secondsLeft, denomination, bigBlind }: GameActionsProps) => {
  const { game, check, fold, bet } = usePokurStore()
  const { currentBet, committed, isTurn, canCheck, myTotal, maxBet, minRaise, callAmountDisplay, callAmountChips } =
    useGameInfo(denomination, bigBlind)

  const turnRef = useRef<string | undefined>(game?.turn_start)
  const [lock, setLock] = useState(false)
  const [myBet, setMyBet] = useState(minRaise)
  const [actionError, setActionError] = useState('')

  const isBBDenomination = denomination === 'BB'

  useEffect(() => {
    if (game && (turnRef.current !== game.turn_start)) {
      setMyBet(minRaise)
    }
    if (game && game.current_turn.includes((window as any).ship)) {
      setLock(false)
    }
    turnRef.current = game?.turn_start
  }, [game, minRaise])

  const getAmount = useCallback((amount: number) => {
    return denomination === 'BB' ? Math.round(bigBlind * amount) : amount
  }, [denomination, bigBlind])

  const lockActions = useCallback(async (promise: Promise<void>) => {
    setLock(true)
    setActionError('')
      try {
        await promise
      } catch (err) {
        setActionError('Error placing bet, please try again')
        setLock(false)
      }
  }, [setLock])
  
  const betAction = useCallback(async () => {
    if (game && myBet && myBet > 0) {
      if (myBet < minRaise && myBet !== maxBet) {
        return window.alert(`Your raise must be at least ${Math.min(minRaise, maxBet)}`)
      }
      await lockActions(bet(game.id, getAmount(Math.min(maxBet, myBet) - committed)))
      setMyBet(minRaise)
    }
  }, [game, myBet, maxBet, committed, minRaise, bet, lockActions, getAmount])

  const checkAction = useCallback(async () => {
    if (game) {
      await lockActions(check(game.id))
    }
  }, [game, check, lockActions])

  const callAction = useCallback(async () => {
    if (game) {
      await lockActions(bet(game.id, callAmountChips))
    }
  }, [game, callAmountChips, bet, lockActions])

  const foldAction = useCallback(async () => {
    if (game) {
      await lockActions(fold(game.id))
    }
  }, [game, fold, lockActions])

  const quickBet = useCallback((amount: '1/2' | '3/4' | 'pot') => async () => {
    if (amount === '1/2') {
      setMyBet(Math.min(callAmountDisplay + Math.round(pots[0].amount / 2), maxBet))
    } else if (amount === '3/4') {
      setMyBet(Math.min(callAmountDisplay + Math.round(pots[0].amount * 3 / 4), maxBet))
    } else {
      setMyBet(Math.min(callAmountDisplay + pots[0].amount, maxBet))
    }
  }, [maxBet, callAmountDisplay, pots, setMyBet])

  return (
    <Col className='game-actions'>
      {isTurn && !lock && !game?.hide_actions && (
        <>
          <Row className='quick-bet'>
            <Row className='bet-buttons'>
              {Number(game?.pots[0]?.amount || 0) > 0 && (
                <>
                  <Button disabled={pots[0].amount / 2 < minRaise} onClick={quickBet('1/2')}>
                    1 / 2
                  </Button>
                  <Button disabled={pots[0].amount / 4 * 3 < minRaise} onClick={quickBet('3/4')}>
                    3 / 4
                  </Button>
                  <Button disabled={pots[0].amount < minRaise} onClick={quickBet('pot')}>
                    Pot
                  </Button>
                </>
              )}
            </Row>
            <Row style={{ fontSize: 20, color: 'white', fontWeight: 600, marginBottom: 4, justifyContent: 'flex-end' }}>
              <Col style={{ alignItems: 'flex-end' }}>
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
                <div style={{ height: 24 }}>
                  {actionError && (
                    <Text style={{ marginTop: 8, color: 'red' }}>{actionError}</Text>
                  )}
                </div>
              </Col>
            </Row>
          </Row>
          <Row className='bet-amount'>
            <Input
              className="bet-slider"
              type="range"
              value={myBet}
              onChange={e => setMyBet(Number(e.target.value.replace(isBBDenomination ? /[^0-9.]/g : /[^0-9]/g, '')))}
              min={minRaise}
              max={maxBet}
              step={isBBDenomination ? '0.1' : '1'}
              containerStyle={{ width: 'calc(100% - 100px)', marginRight: 8 }}
            />
            <Input
              className="bet-text"
              placeholder='your bet'
              type="number"
              step={isBBDenomination ? '0.1' : '1'}
              value={myBet}
              onChange={e =>
                setMyBet(
                  Math.min(maxBet, Number(e.target.value.replace(/[^0-9]/g, '')))
                )
              }
              min={minRaise}
              max={maxBet}
              onFocus={() => setMyBet(0)}
            />
          </Row>
          <Row className='buttons'>
            <Button onClick={foldAction}>
              Fold
            </Button>
            <Button onClick={canCheck ? checkAction : callAction}>
              {canCheck ? 'Check' : `Call ${callAmountDisplay}`}
            </Button>
            <Button onClick={betAction} disabled={currentBet >= myTotal}>
              {currentBet > 0 ? `Raise to ${myBet}` : `Bet ${myBet}`}
            </Button>
          </Row>
        </>
      )}
    </Col>
  )
}

export default GameActions
