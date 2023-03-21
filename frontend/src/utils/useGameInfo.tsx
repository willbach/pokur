import { useCallback, useMemo } from "react"
import usePokurStore from "../store/pokurStore"
import { Denomination } from "../types/Game"
import { denominateAmount, isSelf } from "./game"
import { fromUd } from "./number"

export default function useGameInfo(denomination: Denomination, bigBlind: number) {
  const { game } = usePokurStore()

  const me = useMemo(() => game?.players.find(({ ship }) => ship === (window as any).ship), [game])
  const isTurn = useMemo(() => isSelf(game?.current_turn), [game])
  const canCheck = useMemo(() => me?.committed === game?.current_bet, [game, me])
  const dnmAmnt = useCallback((amount?: number | string) => denominateAmount(amount, bigBlind, denomination), [denomination, bigBlind])
  const currentBet = useMemo(() => dnmAmnt(game?.current_bet), [game, dnmAmnt])
  const myStack = useMemo(() => dnmAmnt(me?.stack), [me, dnmAmnt])
  const committed = useMemo(() => dnmAmnt(me?.committed), [me, dnmAmnt])
  const callAmountDisplay = Math.min(currentBet - committed, myStack)
  const minBet = useMemo(() => dnmAmnt(game?.min_bet) || 20, [game, dnmAmnt])
  const myTotal = useMemo(() => myStack + committed, [myStack, committed])
  const largestStack = useMemo(() => dnmAmnt(game?.players.reduce((largest, { ship, stack, committed, folded, left }) =>
    ship.includes((window as any).ship) || folded || left ? largest : Math.max(largest, fromUd(stack) + fromUd(committed))
  , 0) || (myTotal)), [game, myTotal, dnmAmnt])

  const maxBet = Math.min(myTotal, largestStack)
  const minRaise = Math.min(minBet + currentBet, maxBet)
  const callAmountChips = useMemo(() => fromUd(game?.current_bet) - fromUd(me?.committed), [game, me])

  return {
    minBet,
    currentBet,
    me,
    committed,
    isTurn,
    canCheck,
    myStack,
    myTotal,
    largestStack,
    maxBet,
    minRaise,
    callAmountDisplay,
    callAmountChips
  }
}
