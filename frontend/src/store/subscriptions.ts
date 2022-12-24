import { SubscriptionRequestInterface } from "@urbit/http-api";
import { NavigateFunction } from "react-router-dom";
import { GetState, SetState } from "zustand";
import { Game } from "../types/Game";
import { Lobby } from "../types/Lobby";
import { Message } from "../types/Message";
import { ONE_SECOND } from "../utils/constants";
import { abbreviateCard, playSounds } from '../utils/game';
import { PokurStore } from "./pokurStore";

export type SubscriptionPath = '/lobby-updates' | '/game-updates' | '/messages'

const newHandSound = new Audio('https://poker-app-distro.s3.us-east-2.amazonaws.com/new-hand.mov')

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
  const curGame = get().game

  if (gameUpdate.game) {
    const { game, hand_rank } = gameUpdate as { game: Game, hand_rank: string }
    set({ gameEndMessage: undefined })

    // Sounds
    playSounds(game, curGame)

    if (game.update_message && game.update_message !== curGame?.update_message) {
      set({ messages: [{ from: 'game-update', msg: game.update_message }].concat(get().messages) })
    }

    if (game.game_is_over) {
      console.log('GAME ENDED')
      set({ gameEndMessage: game.update_message })
    }

    if (JSON.stringify(curGame?.revealed_hands) !== JSON.stringify(game.revealed_hands) && Object.keys(game.revealed_hands).length) {
      set({
        messages: [{ from: 'game-update', msg: `Hands: ${
          Object.keys(game.revealed_hands).reduce((msg, p) =>
            msg + `${p}: ${game.revealed_hands[p].map(c => abbreviateCard(c)).join('')}. `
          , '')
        }` }].concat(get().messages)
      })
    }

    // Print board when hand ends
    if (curGame?.board.length && !game.board.length) {
      set({ messages: [{ from: 'game-update', msg: `Board: ${curGame?.board.map(c => abbreviateCard(c)).join('')}` }].concat(get().messages) })
    }

    // if hands should be revealed at hand end, reveal the hands and then update the game in 5 seconds
    if (Object.keys(game.revealed_hands || {}).length && !game.players.find(p => !p.folded && !p.left && p.stack === '0')) {
      set({ game: { ...curGame!, revealed_hands: game.revealed_hands, hand_rank } })
      setTimeout(() => {
        if (curGame?.hands_played !== game.hands_played) {
          newHandSound.play()
        }
        set({ game: { ...game, hand_rank, revealed_hands: {} } })
      }, 5 * ONE_SECOND)

    // when hand ends, pause for 2s
    } else if (curGame?.hands_played !== game.hands_played) {
      setTimeout(() => {
        newHandSound.play()
        set({ game: { ...game, hand_rank } })
      }, 3 * ONE_SECOND)
    } else {
      set({ game: { ...game, hand_rank } })
    }
  } else if (gameUpdate.id) {
    if (gameUpdate.id === curGame?.id) {
      const gameEndMessage = `Total winnings: ${2}. Placement:\n\n ${gameUpdate.placements.join(', ')}.`
      set({ messages: [{ from: 'game-update', msg: gameEndMessage }].concat(get().messages) })
      setTimeout(() => set({
        gameEndMessage,
        game: curGame ? { ...curGame, revealed_hands: {}, board: [] } : undefined
      }), 5 * ONE_SECOND)
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
  return request
}
