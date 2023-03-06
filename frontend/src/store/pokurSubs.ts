import { SubscriptionRequestInterface } from "@urbit/http-api";
import { NavigateFunction } from "react-router-dom";
import { GetState, SetState } from "zustand";
import { Card } from "../types/Card";
import { Game } from "../types/Game";
import { Lobby } from "../types/Lobby";
import { Message } from "../types/Message";
import { Table, Tokenized } from "../types/Table";
import { ONE_SECOND, REMATCH_LEADER_KEY, REMATCH_PARAMS_KEY } from "../utils/constants";
import { abbreviateCard, denominateUpdateMessage, getWinnerInfo, isSelf, playSounds, showLastAction } from '../utils/game';
import { tokenAmount } from '../utils/number'
import { PokurStore } from "./pokurStore";

export type SubscriptionPath = '/lobby-updates' | '/game-updates' | '/messages'

interface GameUpdate {
  game: Game
  hand_rank?: string
  placements?: {ship: string, winnings: string}[]
  tokenized?: Tokenized
  last_board?: Card[]
}

const newHandSound = new Audio('https://poker-app-distro.s3.us-east-2.amazonaws.com/new-hand.mov')
newHandSound.volume = 0.5

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

export const handleGameUpdate = (get: GetState<PokurStore>, set: SetState<PokurStore>) => (gameUpdate: GameUpdate) => {
  console.log('Game Update:'.toUpperCase(), gameUpdate)
  const curGame = get().game

  const { game, hand_rank = '', placements, tokenized, last_board } = gameUpdate
  set({ gameEndMessage: undefined })

  function showLastBoard() {
    if (curGame && last_board?.length) {
      const len = Math.max(curGame.board.length, 3)

      const { winner, winning_hand } = getWinnerInfo(game, curGame)

      set({
        game: {
          ...game,
          players: curGame.players,
          board: last_board.slice(0, len),
          hide_actions: true,
          hand: curGame?.hand || game.hand,
          winner, winning_hand,
          hand_rank: curGame.hand_rank,
        }
      })

      for (let i = 1; i <= 5 - len; i++) {
        setTimeout(() =>
          set({
            game: {
              ...game,
              players: curGame.players,
              board: last_board.slice(0, len + i),
              hide_actions: true,
              hand: curGame?.hand || game.hand,
              winner, winning_hand,
              hand_rank: curGame.hand_rank,
            }
          }),
          ONE_SECOND / 2 * i
        )
      }
    }
  }

  if (curGame?.turn_start === game.turn_start) {
    if (game.update_message && game.update_message !== curGame?.update_message) {
      set({ messages: [{ from: 'game-update', msg: game.update_message }].concat(get().messages) })
    }
    return
  }

  // Sounds
  playSounds(game, curGame)
  // Show the last user action for 3 seconds
  showLastAction(game, set, curGame)

  if (game.game_is_over && placements) {
    showLastBoard()

    setTimeout(() => {
      const gameEndMessage =
        game.game_type.type === 'cash' ? 'The game has ended.' :
        `Winnings:\n\n ${placements.map(p => `${p.ship} - ${tokenAmount(p.winnings)} ${tokenized?.symbol || 'ZIG'}`).join(', ')}.`

      set({
        gameEndMessage,
        game: { ...game, hand: curGame?.hand || [] },
        messages: [{ from: 'game-update', msg: gameEndMessage }].concat(get().messages),
      })
    }, 8 * ONE_SECOND)

  // if hands should be revealed at hand end, reveal the hands and then update the game in 5 seconds, but update current_player immediately
  } else if (Object.keys(game.revealed_hands || {}).length && !game.players.find(p => !p.folded && !p.left && p.stack === '0')) {
    const { winner, winning_hand } = getWinnerInfo(game, curGame)
    set({ game: { ...curGame!, revealed_hands: game.revealed_hands, current_turn: game.current_turn, winner, winning_hand } })

    if (last_board?.length) {
      showLastBoard()
    }

    setTimeout(() => {
      if (curGame?.hands_played !== game.hands_played) {
        newHandSound.play()
      }
      set({ game: { ...game, hand_rank, revealed_hands: {} } })
    }, 5 * ONE_SECOND)
  } else {
    // Set the game
    if (curGame && curGame?.hands_played !== game.hands_played) {
      newHandSound.play()
    }

    set({ game: { ...game, hand_rank } })
  }

  // Messages Start
  if (game.update_message && game.update_message !== curGame?.update_message) {
    const msg = denominateUpdateMessage(game, get().denomination)
    set({ messages: [{ from: 'game-update', msg }].concat(get().messages) })
  }

  game.players.forEach(({ left, ship }) => {
    if (left && !curGame?.players.find(p => p.ship === ship && p.left)) {
      set({ messages: [{ from: 'game-update', msg: `${ship} left the game` }].concat(get().messages) })
    }
  })

  if (JSON.stringify(curGame?.revealed_hands) !== JSON.stringify(game.revealed_hands) && Object.keys(game.revealed_hands).length) {
    set({
      messages: [{ from: 'game-update', msg: `Hands: ${
        Object.keys(game.revealed_hands).reduce((msg, p) =>
          msg + `${p}: ${game.revealed_hands[p].map(c => abbreviateCard(c)).join('')}. `
        , '')
      }` }].concat(get().messages)
    })
  }

  if (last_board?.length && !game.board.length) {
    set({ messages: [{ from: 'game-update', msg: `Board: ${last_board.map(c => abbreviateCard(c)).join('')}` }].concat(get().messages) })
  } else if (curGame?.board.length && !game.board.length) {
    set({ messages: [{ from: 'game-update', msg: `Board: ${curGame?.board.map(c => abbreviateCard(c)).join('')}` }].concat(get().messages) })
  }
  // Messages End
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
