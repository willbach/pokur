import { Card } from "../types/Card"
import { Game } from "../types/Game"
import { capitalizeSpine } from "./format"

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

export const isSelf = (ship?: string) => ship && (window as any).ship.replace('~', '') === ship.replace('~', '')

export const abbreviateCard = ({ val, suit }: Card) => (val === '10' ? val : val.slice(0, 1).toUpperCase()) + suit.slice(0,1)

export const playSounds = (game: Game, curGame?: Game) => {
  if (game.board.length && curGame?.board.length !== undefined) {
    const curBoardLength = curGame?.board.length

    if (curBoardLength === 0 && game.board.length === 3) {
      flopSound.play()
    } else if (game.board.length === (curBoardLength || 0) + 1) {
      turnSound.play()
    }
  }
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
}
