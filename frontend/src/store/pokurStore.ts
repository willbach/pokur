import { NavigateFunction } from "react-router-dom"
import create from "zustand"
import api from "../api"
import { Game } from "../types/Game"
import { Lobby } from "../types/Lobby"
import { Message } from "../types/Message"
import { CreateTableValues, Table } from "../types/Table"
import { SNG_BLINDS } from "../utils/constants"
import { numToUd } from "../utils/number"
import { getPayoutAmounts } from '../utils/game'
import { createSubscription, handleGameUpdate, handleLobbyUpdate, handleNewMessage, SubscriptionPath } from "./subscriptions"

export interface LastAction {
  [ship: string]: string
}

export interface PokurStore {
  loadingText: string | null
  secondaryLoadingText: string | null
  
  hosts: string[]
  lobby: Lobby
  invites: string[]
  joinTableId?: string
  table?: Table
  game?: Game
  lastAction: LastAction

  messages: Message[]
  mutedPlayers: string[]
  gameEndMessage?: string
  gameStartingIn?: number

  init: () => Promise<'/table' | '/game' | '/' | void>
  getHosts: () => Promise<string[]>
  getMessages: () => Promise<void>
  getOurTable: () => Promise<Table | undefined>
  getTable: (id: string) => Promise<Table | undefined>
  getGame: () => Promise<Game | undefined>
  getMutedPlayers: () => Promise<void>
  setJoinTableId: (joinTableId?: string) => void
  subscribeToPath: (path: SubscriptionPath, nav?: NavigateFunction) => Promise<number>
  setLoading: (loadingText: string | null) => void
  setSecondaryLoading: (secondaryLoadingText: string | null) => void
  zigFaucet: (address: string) => Promise<void>

  // pokur-player-action
  addHost: (who: string) => Promise<void>
  removeHost: (who: string) => Promise<void>
  createTable: (values: CreateTableValues) => Promise<void> // [%new-lobby parse-lobby]
  sendInvite: (ship: string) => Promise<void>
  setInvites: (invites: string[]) => void
  joinTable: (table: string, isPublic?: boolean) => Promise<void>
  setTable: (table: Table) => void
  leaveTable: (table: string) => Promise<void>
  startGame: (table: string) => Promise<void>
  leaveGame: (table: string) => Promise<void>
  kickPlayer: (table: string, player: string) => Promise<void>
  addEscrow: (values: string) => Promise<void>
  setOurAddress: (address: string) => Promise<void>
  
  // pokur-message-action
  mutePlayer: (player: string) => Promise<void>
  sendMessage: (msg: string) => Promise<void>

  // pokur-game-action
  check: (table: string) => Promise<void>
  fold: (table: string) => Promise<void>
  bet: (table: string, amount: number) => Promise<void>
}

const usePokurStore = create<PokurStore>((set, get) => ({
  loadingText: 'Loading Pokur...',
  secondaryLoadingText: null,

  hosts: [],
  lobby: {},
  invites: [],
  messages: [],
  mutedPlayers: [],
  lastAction: {},

  init: async () => {
    set({ loadingText: 'Loading Pokur...' })
    const { subscribeToPath, getMessages, getMutedPlayers, getOurTable } = get()

    try {
      subscribeToPath('/messages')

      const [game, table] = await Promise.all([
        api.scry({ app: 'pokur', path: '/game' }),
        getOurTable(),
        getMessages(),
        getMutedPlayers(),
      ])

      set({ loadingText: null, game, table, gameEndMessage: game.game_is_over ? 'The game has ended.' : undefined })

      if (game) {
        return '/game'
      } else if (table) {
        return '/table'
      } else {
        return '/'
      }

    } catch (err) {
      console.warn('INIT ERROR:', err)
      set({ loadingText: null })
    }
  },
  getHosts: async () => {
    const hosts = Object.keys(await api.scry<{ [host: string]: any }>({ app: 'pokur', path: '/known-hosts' }))
    set({ hosts })
    return hosts
  },
  getMessages: async () => {
    const messages = await api.scry({ app: 'pokur', path: '/messages' })
    set({ messages })
  },
  getOurTable: async () => {
    const ourTable = await api.scry({ app: 'pokur', path: '/our-table' })

    if (ourTable) {
      const table = await get().getTable(ourTable)
      set({ table })
      return table
    }

    set({ table: undefined })
  },
  getTable: async (id: string) => {
    const table = await api.scry<Table>({ app: 'pokur', path: `/table/${id}` })
    set({ table })
    return table
  },
  getGame: async () => {
    const game = await api.scry<Game | undefined>({ app: 'pokur', path: '/game' })
    set({ game })
    return game
  },
  getMutedPlayers: async () => {
    const mutedPlayers = await api.scry({ app: 'pokur', path: '/muted-players' })
    set({ mutedPlayers })
  },
  setJoinTableId: (joinTableId?: string) => set({ joinTableId }),
  subscribeToPath: (path: SubscriptionPath, nav?: NavigateFunction) => {
    switch (path) {
      case '/lobby-updates':
        return api.subscribe(createSubscription('pokur', path, handleLobbyUpdate(get, set, nav)))
      case '/game-updates':
        return api.subscribe(createSubscription('pokur', path, handleGameUpdate(get, set)))
      case '/messages':
        return api.subscribe(createSubscription('pokur', path, handleNewMessage(get, set)))
    }
  },
  setLoading: (loadingText: string | null) => set({ loadingText }),
  setSecondaryLoading: (secondaryLoadingText: string | null) => set({ secondaryLoadingText }),
  zigFaucet: async (address: string) => {
    try {
      await api.poke({ app: 'uqbar', mark: 'uqbar-action', json: { 'open-faucet': { town: '0x0', 'send-to': address } } })
    } catch (err) {
      alert('An error occurred. Note that you can only request zigs from the faucet once per hour.')
    }
  },
  addHost: async (who: string) => {
    const json = { 'find-host': { who } }
    await api.poke({ app: 'pokur', mark: 'pokur-player-action', json })
    set({ hosts: get().hosts.concat([who]) })
  },
  removeHost: async (who: string) => {
    const json = { 'remove-host': { who } }
    await api.poke({ app: 'pokur', mark: 'pokur-player-action', json })
    set({ hosts: get().hosts.filter(h => h !== who) })
  },
  createTable: async (values: CreateTableValues) => {
    const tokenized = { ...values.tokenized, amount: numToUd(Number(values.tokenized.amount)) }
    const json: any = {
      'new-table': { ...values, tokenized, id: '~2000.1.1' }
    }

    if (values['game-type'] === 'cash') {
      json['new-table']['game-type'] = { cash: {...values, type: values['game-type'] } }
    } else {
      json['new-table']['game-type'] = { sng: {
        ...values,
        'blinds-schedule': values["starting-blinds"] === '10/20' ?
          [{ small: 10, big: 20 }, ...SNG_BLINDS] : SNG_BLINDS,
        type: values['game-type'],
        payouts: getPayoutAmounts(values["min-players"]),
        'current-round': 0,
        'round-is-over': false
      } }
    }

    console.log('CREATE TABLE:', json)
    await api.poke({ app: 'pokur', mark: 'pokur-player-action', json })
    setTimeout(async () => {
      get().getOurTable()
      setTimeout(() => set({ loadingText: null }), 200)
    }, 200)
  },
  sendInvite: async (ship: string) => {
    const json = { 'send-invite': { to: ship } }
    await api.poke({ app: 'pokur', mark: 'pokur-player-action', json })
  },
  setInvites: (invites: string[]) => set({ invites }),
  joinTable: async (table: string, isPublic = false) => {
    const json = { 'join-table': { id: table, public: isPublic } }
    await api.poke({ app: 'pokur', mark: 'pokur-player-action', json })
  },
  setTable: (table: Table) => set({ table }),
  leaveTable: async (table: string) => {
    const json = { 'leave-table': { id: table } }
    await api.poke({ app: 'pokur', mark: 'pokur-player-action', json })
    const interval = setInterval(async () => {
      const table = await get().getOurTable()
      if (!table) {
        clearInterval(interval)
      }
    }, 500)
  },
  startGame: async (table: string) => {
    const json = { 'start-game': { id: table } }
    await api.poke({ app: 'pokur', mark: 'pokur-player-action', json })
  },
  leaveGame: async (table: string) => {
    if (get().game?.id === table) {
      const json = { 'leave-game': { id: table } }
      await api.poke({ app: 'pokur', mark: 'pokur-player-action', json })
    }

    set({ game: undefined, messages: [] })
  },
  kickPlayer: async (table: string, player: string) => {
    const json = { 'kick-player': { id: table, who: player } }
    await api.poke({ app: 'pokur', mark: 'pokur-player-action', json })
  },
  addEscrow: async (values: string) => {
    const json = { 'add-escrow': values }
    await api.poke({ app: 'pokur', mark: 'pokur-player-action', json })
  },
  setOurAddress: async (address: string) => {
    const json = { 'set-our-address': { address } }
    await api.poke({ app: 'pokur', mark: 'pokur-player-action', json })
  },
  mutePlayer: async (player: string) => {
    const json = { 'mute-player': { who: player } }
    await api.poke({ app: 'pokur', mark: 'pokur-message-action', json })
  },
  sendMessage: async (msg: string) => {
    const json = { 'send-message': { msg } }
    await api.poke({ app: 'pokur', mark: 'pokur-message-action', json })
  },
  check: async (table: string) => {
    const json = { check: { 'game-id': table } }
    console.log('CHECK:', json)
    await api.poke({ app: 'pokur', mark: 'pokur-game-action', json })
  },
  fold: async (table: string) => {
    const json = { fold: { 'game-id': table } }
    console.log('FOLD:', json)
    await api.poke({ app: 'pokur', mark: 'pokur-game-action', json })
  },
  bet: async (table: string, amount: number) => {
    const json = { bet: { 'game-id': table, amount } }
    console.log('BET:', json)
    await api.poke({ app: 'pokur', mark: 'pokur-game-action', json })
  },
}))

export default usePokurStore
