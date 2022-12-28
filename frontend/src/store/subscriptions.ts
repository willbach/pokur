import { SubscriptionRequestInterface } from "@urbit/http-api";
import { NavigateFunction } from "react-router-dom";
import { GetState, SetState } from "zustand";
import { Game } from "../types/Game";
import { Lobby } from "../types/Lobby";
import { Message } from "../types/Message";
import { Table } from "../types/Table";
import { ONE_SECOND, REMATCH_LEADER_KEY, REMATCH_PARAMS_KEY } from "../utils/constants";
import { abbreviateCard, isSelf, playSounds } from '../utils/game';
import { tokenAmount } from '../utils/number'
import { PokurStore } from "./pokurStore";

export type SubscriptionPath = '/lobby-updates' | '/game-updates' | '/messages'

const newHandSound = new Audio('https://poker-app-distro.s3.us-east-2.amazonaws.com/new-hand.mov')

export const handleLobbyUpdate = (get: GetState<PokurStore>, set: SetState<PokurStore>, nav?: NavigateFunction) =>
async (update: Lobby | { id: string } | { from: string; table: Table }) => {
  console.log('Lobby Update:'.toUpperCase(), update)

  const { table } = get()

  if ('id' in update) {
    if (!isSelf(table?.leader)) {
      localStorage.removeItem(REMATCH_PARAMS_KEY)
      localStorage.setItem(REMATCH_LEADER_KEY, table?.leader || '')
    } else {
      localStorage.removeItem(REMATCH_LEADER_KEY)
    }
    await new Promise((resolve) => setTimeout(() => resolve(true), 100))
    const game = await get().getGame()

    if (game && nav) {
      for (let i = 1; i <= 3; i++) {
        setTimeout(() => set({ gameStartingIn: i * ONE_SECOND }), (4 - i) * ONE_SECOND + 1)
      }

      setTimeout(() => {
        nav('/game')
        set({ table: undefined, gameStartingIn: undefined })
      }, 4 * ONE_SECOND)
    }
  } else if ('from' in update) {
    set({ lobby: { ...get().lobby, [update.table.id]: update.table } })
  } else {
    if (table && (update as Lobby)[table.id]) {
      if ((update as Lobby)[table.id]?.players.find(ship => isSelf(ship))) {
        set({ table: (update as Lobby)[table.id] })
      }
    }
    set({ lobby: (update as Lobby) })
  }
}

export const handleGameUpdate = (get: GetState<PokurStore>, set: SetState<PokurStore>) =>
(gameUpdate: { game: Game, hand_rank?: string, placements?: {ship: string, winnings: string}[] }) => {
  console.log('Game Update:'.toUpperCase(), gameUpdate)
  const curGame = get().game

  const { game, hand_rank = '', placements } = gameUpdate
  set({ gameEndMessage: undefined })

  // Sounds
  playSounds(game, curGame)
  // TODO: show the last user action for 3 seconds

  if (game.update_message && game.update_message !== curGame?.update_message) {
    set({ messages: [{ from: 'game-update', msg: game.update_message }].concat(get().messages) })
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

  if (game.game_is_over && placements) {
    const gameEndMessage = `Winnings:\n\n ${placements.map(p => `${p.ship} - ${tokenAmount(p.winnings)}`).join(', ')}.`
    set({
      messages: [{ from: 'game-update', msg: gameEndMessage }].concat(get().messages),
      gameEndMessage
    })

    setTimeout(() => set({
      gameEndMessage,
      game: curGame ? { ...curGame, revealed_hands: {}, board: [] } : undefined
    }), 5 * ONE_SECOND)

  // if hands should be revealed at hand end, reveal the hands and then update the game in 5 seconds
  } else if (Object.keys(game.revealed_hands || {}).length && !game.players.find(p => !p.folded && !p.left && p.stack === '0')) {
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
    }, 4 * ONE_SECOND)
  } else {
    // Set the game
    set({ game: { ...game, hand_rank } })
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
