import { useCallback, useEffect, useMemo, useState } from "react"
import usePokurStore from "../../store/pokurStore"
import Button from "../form/Button"
import Input from "../form/Input"
import Col from "../spacing/Col"
import Row from "../spacing/Row"

import './GameActions.scss'

const GameActions = () => {
  const { game, check, fold, bet } = usePokurStore()
  const [myBet, setMyBet] = useState(game?.current_bet || '2')

  useEffect(() => {
    if (game) {
      const me = game?.players.find(({ ship }) => ship === (window as any).ship)
      setMyBet(String(Number(game.current_bet) - Number(me?.committed)))
    }
  }, [game]) // eslint-disable-line react-hooks/exhaustive-deps

  const me = useMemo(() => game?.players.find(({ ship }) => ship === (window as any).ship), [game])
  const isTurn = useMemo(() => game?.current_turn?.slice(1) === (window as any).ship, [game])
  const canCheck = useMemo(() => me?.committed === game?.current_bet, [game, me])

  const betAction = useCallback(async () => {
    if (game && myBet && Number(myBet) > 0) {
      const totalBet = Number(myBet) + Number(me!.committed)
      const curBet = Number(game.current_bet)
      if (totalBet < curBet) {
        return window.alert(`Your bet must be at least the current bet of ${curBet}`)
      } else if (totalBet > curBet && totalBet / curBet < 2) {
        return window.alert(`Your bet must be equal to or 2x the current bet of ${curBet}`)
      }
      await bet(game.id, Number(myBet) + Number(game.current_bet) - Number(me?.committed || 0))
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
    <Col className='game-actions'>
      {isTurn && (
        <>
          <Row className='bet-amount'>
            <Input
              className="bet-slider"
              type="range"
              defaultValue={Number(game?.current_bet || 2)}
              value={myBet}
              onChange={e => setMyBet(e.target.value.replace(/[^0-9]/g, ''))}
              min={Number(game?.current_bet || 2)}
              max={Number(me?.stack || 100)}
              containerStyle={{ width: 'calc(100% - 100px)', marginRight: 8 }}
            />
            <Input
              className="bet-text"
              placeholder='your bet'
              value={myBet}
              onChange={e => setMyBet(e.target.value.replace(/[^0-9]/g, ''))}
              min={Number(game?.current_bet || 2)}
              max={Number(me?.stack || 100)}
            />
          </Row>
          <Row className='buttons'>
            <Button onClick={foldAction}>
              Fold
            </Button>
            <Button onClick={canCheck ? checkAction : callAction}>
              {canCheck ? 'Check' : `Call ${game?.current_bet}`}
            </Button>
            <Button onClick={betAction}>
              {Number(game?.current_bet || 0) > 0 ? `Raise ${myBet}` : `Bet ${myBet}`}
            </Button>
          </Row>
        </>
      )}
    </Col>
  )
}

export default GameActions
