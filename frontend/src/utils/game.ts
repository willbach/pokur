import { SetState } from "zustand"
import { PokurStore } from "../store/pokurStore"
import { Card } from "../types/Card"
import { Game } from "../types/Game"
import { ONE_SECOND } from "./constants"
import { capitalize, capitalizeSpine } from "./format"

const flopSound = new Audio('https://poker-app-distro.s3.us-east-2.amazonaws.com/flop.mov')
const turnSound = new Audio('https://poker-app-distro.s3.us-east-2.amazonaws.com/turn.mov')
const foldSound = new Audio('https://poker-app-distro.s3.us-east-2.amazonaws.com/fold.mov')
const checkSound = new Audio('https://poker-app-distro.s3.us-east-2.amazonaws.com/check.mov')
const raiseSound = new Audio('https://poker-app-distro.s3.us-east-2.amazonaws.com/bet.mp3')
const callSound = new Audio('https://poker-app-distro.s3.us-east-2.amazonaws.com/call.mp3')

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
