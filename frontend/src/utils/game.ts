import { SetState } from "zustand"
import { PokurStore } from "../store/pokurStore"
import { Card } from "../types/Card"
import { CashGame, Denomination, Game, TournamentGame } from "../types/Game"
import { ONE_SECOND } from "./constants"
import { capitalize, capitalizeSpine } from "./format"
import { fromUd } from "./number"

const flopSound = new Audio('https://poker-app-distro.s3.us-east-2.amazonaws.com/flop.mov')
flopSound.volume = 0.5
const turnSound = new Audio('https://poker-app-distro.s3.us-east-2.amazonaws.com/turn.mov')
turnSound.volume = 0.5
const foldSound = new Audio('https://poker-app-distro.s3.us-east-2.amazonaws.com/fold.mov')
foldSound.volume = 0.5
const checkSound = new Audio('https://poker-app-distro.s3.us-east-2.amazonaws.com/check.mov')
checkSound.volume = 0.5
const raiseSound = new Audio('https://poker-app-distro.s3.us-east-2.amazonaws.com/bet.mp3')
raiseSound.volume = 0.5
const callSound = new Audio('https://poker-app-distro.s3.us-east-2.amazonaws.com/call.mp3')
callSound.volume = 0.5

export const getGameType = (type: string) => {
  if (type === 'sng')
    return 'SNG'

  return capitalizeSpine(type)
}

export const getPayoutAmounts = (numPlayers: number) => {
  if (numPlayers >= 9) {
    return [50, 30, 20]
  } else if (numPlayers >= 4) {
    return [65, 35]
  }
  return [100]
}

export const isShip = (ship1?: string, ship2?: string) => ship1 && ship2 && ship1.replace('~', '') === ship2.replace('~', '')
export const isSelf = (ship?: string) => isShip((window as any).ship, ship)

export const abbreviateCard = ({ val, suit }: Card) => (val === '10' ? val : val.slice(0, 1).toUpperCase()) + suit.slice(0,1)

export const playSounds = (game: Game, curGame?: Game) => {
  if (game.last_action) {
    if (game.last_action.includes('fold')) {
      foldSound.play()
    } else if (game.last_action.includes('check')) {
      checkSound.play()
    } else if (game.last_action.includes('call')) {
      callSound.play()
    } else if (game.last_action.includes('raise')) {
      raiseSound.play()
    }
  }
  if (game.board.length && curGame?.board.length !== undefined) {
    const curBoardLength = curGame?.board.length

    if (curBoardLength === 0 && game.board.length === 3) {
      setTimeout(() => flopSound.play(), 100)
    } else if (game.board.length === (curBoardLength || 0) + 1) {
      setTimeout(() => turnSound.play(), 100)
    }
  }
}

export const showLastAction = (game: Game, set: SetState<PokurStore>, curGame?: Game) => {
  if (game.last_action && curGame?.current_turn) {
    set({ lastAction: { [curGame.current_turn.replace('~', '')]: capitalize(game.last_action.replace(/~/g, '')) || '' } })
    setTimeout(() => set({ lastAction: {} }), 3 * ONE_SECOND)
  }
}

export const getWinnerInfo = (game: Game, curGame?: Game) => {
  let winner: string | undefined, winning_hand: string | undefined
  if (game.update_message && game.update_message !== curGame?.update_message && game.update_message.includes('wins pot of')) {
    winner = game.update_message.split(' wins pot of')[0]?.slice(-4)
    winning_hand = game.update_message.split('with hand ').pop()?.replace('. ', '')
  }

  return { winner, winning_hand }
}

export const getBB = (gameType?: CashGame | TournamentGame) => {
  if (!gameType) {
    return 20
  } else if ('big_blind' in gameType) {
    return fromUd(gameType.big_blind)
  }

  try {
    return fromUd((gameType.blinds_schedule[Number(gameType.current_round)] || gameType.blinds_schedule[gameType.blinds_schedule.length - 1])[1])
  } catch (err) {
    return 20
  }
}

export const denominateAmount = (amount?: number | string, bigBlind?: number | string, denom?: Denomination) => {
  if (!amount || !bigBlind || !denom) {
    return 0
  }
  
  const a = typeof amount === 'string' ? fromUd(amount) : amount
  const bb = typeof bigBlind === 'string' ? fromUd(bigBlind) : bigBlind
  return denom === '$' ? a : Math.round(a / bb * 100) / 100
}

export const denominateUpdateMessage = (game: Game, denomination: Denomination) : string => {
  const { update_message, game_type } = game
  if (denomination === 'BB') {
    const bigBlind = getBB(game?.game_type)

    return update_message.replace(
      /wins pot of \$?[0-9.]+\./,
      (match: string) =>
        match.replace(/\$?[0-9.]+/, (num: string) => `${Math.round(Number(num.replace(/[$.]/g, '')) / bigBlind)} BB.` )
    )
  }

  return update_message
}
