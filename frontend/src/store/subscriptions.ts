import { SubscriptionRequestInterface } from "@urbit/http-api";
import { NavigateFunction } from "react-router-dom";
import { GetState, SetState } from "zustand";
import { Lobby } from "../types/Lobby";
import { Message } from "../types/Message";
import { ONE_SECOND } from "../utils/constants";
import { PokurStore } from "./pokurStore";
import flopSound from '../assets/sound/flop.mov'
import turnSound from '../assets/sound/turn.mov'
import foldSound from '../../assets/sound/fold.mov'
import checkSound from '../../assets/sound/check.mov'
import betSound from '../../assets/sound/bet.mp3'
import callSound from '../../assets/sound/call.mp3'

export type SubscriptionPath = '/lobby-updates' | '/game-updates' | '/messages'

export const handleLobbyUpdate = (get: GetState<PokurStore>, set: SetState<PokurStore>, nav?: NavigateFunction) => async (lobby: Lobby) => {
  console.log('Lobby Update:'.toUpperCase(), lobby)

  const { table } = get()

  if (table) {
    if (lobby[table.id]) {
      set({ table: lobby[table.id] })
    } else {
      if (nav && get().table) {
        await new Promise((resolve) => setTimeout(() => resolve(true), 200))
        const game = await get().getGame()
  
        if (game) {
          for (let i = 1; i <= 4; i++) {
            setTimeout(() => set({ gameStartingIn: i * ONE_SECOND }), (5 - i) * ONE_SECOND + 1)
          }

          setTimeout(() => {
            set({ table: undefined, gameStartingIn: undefined })
            nav('/game')
          }, 5 * ONE_SECOND)
        }
      }
    }
  }
  set({ lobby })
}

export const handleGameUpdate = (get: GetState<PokurStore>, set: SetState<PokurStore>) => (gameUpdate: any) => {
  console.log('Game Update:'.toUpperCase(), gameUpdate)

  if (gameUpdate.game) {
    const { game, hand_rank } = gameUpdate

    // sounds
    if (game.board.length && get().game?.board.length !== undefined) {
      const curBoardLength = get().game?.board.length

      if (curBoardLength === 0 && game.board.length === 3) {
        new Audio(flopSound).play()
      } else if (game.board.length === (curBoardLength || 0) + 1) {
        new Audio(turnSound).play()
      }
    }

    if (game.update_message && game.update_message !== get().game?.update_message) {
      set({ messages: [{ from: 'game-update', msg: game.update_message }].concat(get().messages) })
    }
  
    if (game.game_is_over) {
      console.log('GAME ENDED')
      set({ gameEndMessage: game.update_message })
    }

    // if hands should be revealed, reveal the hands and then update the game in 4 seconds
    if (Object.keys(game.revealed_hands || {}).length) {
      set({ game: { ...get().game!, revealed_hands: game.revealed_hands, hand_rank } })
      setTimeout(() => {
        set({ game: { ...game, hand_rank, revealed_hands: {} } })
      }, 4 * ONE_SECOND)
    } else {
      set({ game: { ...game, hand_rank } })
    }
  } else if (gameUpdate.id) {
    if (gameUpdate.id === get().game?.id) {
      const gameEndMessage = `Game has ended. Placement:\n\n ${gameUpdate.placements.join(', ')}`
      set({ messages: [{ from: 'game-update', msg: gameEndMessage }].concat(get().messages) })
      setTimeout(() => set({ gameEndMessage }), 5 * ONE_SECOND)
    }
  }
}
export const handleNewMessage = (get: GetState<PokurStore>, set: SetState<PokurStore>) => (message: Message) => {
  console.log('New Message:'.toUpperCase(), message)
  set({ messages: [message].concat(get().messages) })
}

export function createSubscription(app: string, path: string, e: (data: any) => void): SubscriptionRequestInterface {
  const request = {
    app,
    path,
    event: e,
    err: () => console.warn('SUBSCRIPTION ERROR'),
    quit: () => {
      throw new Error('subscription clogged')
    }
  }
  // TODO: err, quit handling (resubscribe?)
  return request
}
