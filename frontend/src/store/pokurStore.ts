import create from "zustand"
import api from "../api"
import { HardwareWallet, HardwareWalletType, HotWallet, processAccount, RawAccount } from "../types/Accounts"
import { Game } from "../types/Game"
import { Lobby } from "../types/Lobby"
import { Message } from "../types/Message"
import { CreateTableValues, Table } from "../types/Table"
import { TokenMetadataStore } from "../types/TokenMetadata"
import { createSubscription, handleGameUpdate, handleLobbyUpdate, handleNewMessage, handleTableUpdate, SubscriptionPath } from "./subscriptions"

export interface PokurStore {
  loadingText: string | null
  accounts: HotWallet[]
  importedAccounts: HardwareWallet[]
  metadata: TokenMetadataStore
  
  host?: string
  lobby: Lobby
  table?: Table
  game?: Game

  messages: Message[]
  mutedPlayers: string[]

  init: () => Promise<'/table' | '/game' | void>
  getMessages: () => Promise<void>
  getTable: () => Promise<void>
  getMutedPlayers: () => Promise<void>
  subscribeToPath: (path: SubscriptionPath) => Promise<number>
  setLoading: (loadingText: string | null) => void
  getAccounts: () => Promise<void>

  // pokur-player-action
  joinHost: (host: string) => Promise<void>
  leaveHost: () => Promise<void>
  createTable: (values: CreateTableValues) => Promise<void> // [%new-lobby parse-lobby]
  joinTable: (table: string) => Promise<void>
  leaveTable: (table: string) => Promise<void>
  startGame: (table: string) => Promise<void>
  leaveGame: (table: string) => Promise<void>
  kickPlayer: (table: string, player: string) => Promise<void>
  addEscrow: (values: string) => Promise<void>
  
  // pokur-message-action
  mutePlayer: (player: string) => Promise<void>
  sendMessage: (message: string) => Promise<void>

  // pokur-game-action
  check: (table: string) => Promise<void>
  fold: (table: string) => Promise<void>
  bet: (table: string, amount: number) => Promise<void>

  // pokur-host-action: TODO
}

const usePokurStore = create<PokurStore>((set, get) => ({
  loadingText: 'Loading Pokur...',
  accounts: [],
  importedAccounts: [],
  metadata: {},

  host: undefined,
  lobby: {},
  table: undefined,
  game: undefined,
  messages: [],
  mutedPlayers: [],

  init: async () => {
    set({ loadingText: 'Loading Pokur...' })
    const { subscribeToPath, getMessages, getMutedPlayers, getAccounts } = get()

    try {
      subscribeToPath('/messages')

      const [host, game, table] = await Promise.all([
        api.scry({ app: 'pokur', path: '/host' }),
        api.scry({ app: 'pokur', path: '/game' }),
        api.scry({ app: 'pokur', path: '/table' }),
        getMessages(),
        getMutedPlayers(),
        // getAccounts(),
      ])

      console.log('game & table:', game, table)

      set({ loadingText: null, host: host?.host, game, table })

      if (game) {
        return '/game'
      } else if (table) {
        return '/table'
      }

    } catch (err) {
      console.warn('INIT ERROR:', err)
      set({ loadingText: null })
    }
  },
  getMessages: async () => {
    const messages = await api.scry({ app: 'pokur', path: '/messages' })
    set({ messages })
  },
  getTable: async () => {
    const table = await api.scry({ app: 'pokur', path: '/table' })
    set({ table })
  },
  getMutedPlayers: async () => {
    const mutedPlayers = await api.scry({ app: 'pokur', path: '/muted-players' })
    set({ mutedPlayers })
  },
  subscribeToPath: (path: SubscriptionPath) => {
    switch (path) {
      case '/lobby-updates':
        return api.subscribe(createSubscription('pokur', path, handleLobbyUpdate(get, set)))
      case '/table-updates':
        return api.subscribe(createSubscription('pokur', path, handleTableUpdate(get, set)))
      case '/game-updates':
        return api.subscribe(createSubscription('pokur', path, handleGameUpdate(get, set)))
      case '/messages':
        return api.subscribe(createSubscription('pokur', path, handleNewMessage(get, set)))
    }
  },
  setLoading: (loadingText: string | null) => set({ loadingText }),
  getAccounts: async () => {
    const accountData = await api.scry<{[key: string]: RawAccount}>({ app: 'wallet', path: '/accounts' }) || {}
    const allAccounts = Object.values(accountData).map(processAccount).sort((a, b) => a.nick.localeCompare(b.nick))

    const { accounts, importedAccounts } = allAccounts.reduce(({ accounts, importedAccounts }, cur) => {
      if (cur.imported) {
        const [nick, type] = cur.nick.split('//')
        importedAccounts.push({ ...cur, type: type as HardwareWalletType, nick })
      } else {
        accounts.push(cur)
      }
      return { accounts, importedAccounts }
    }, { accounts: [] as HotWallet[], importedAccounts: [] as HardwareWallet[] })

    set({ accounts, importedAccounts, loadingText: null })
  },
  getMetadata: async () => {
    const rawMetadata = await api.scry<any>({ app: 'wallet', path: '/token-metadata' })
    const metadata = Object.keys(rawMetadata).reduce((acc: { [key: number]: any }, cur) => {
      const newKey = Number(cur.toString().replace(/\./g, ''))
      acc[newKey] = rawMetadata[cur]
      return acc
    }, {})
    set({ metadata })
  },
  joinHost: async (host: string) => {
    const json = { 'join-host': { host } }
    await api.poke({ app: 'pokur', mark: 'pokur-player-action', json })
  },
  leaveHost: async () => {
    const json = { 'leave-host': null }
    await api.poke({ app: 'pokur', mark: 'pokur-player-action', json })
    set({ host: undefined })
  },
  createTable: async (values: CreateTableValues) => {
    set({ loadingText: 'Creating table...' })
    const json: any = {
      'new-table': { ...values, tokenized: null, id: '~2000.1.1' }
    }

    if (values['game-type'] === 'cash') {
      json['new-table']['game-type'] = { cash: {...values, type: values['game-type'] } }
    } else {
      json['new-table']['game-type'] = { tournament: {...values, type: values['game-type'] } }
    }

    console.log(1)
    await api.poke({ app: 'pokur', mark: 'pokur-player-action', json })
    console.log(2)
    setTimeout(async () => {
      const table = await api.scry({ app: 'pokur', path: '/table' })
      console.log(3, table)
      set({ table, loadingText: null })
    }, 500)
  },
  joinTable: async (table: string) => {
    const json = { 'join-table': { id: table } }
    await api.poke({ app: 'pokur', mark: 'pokur-player-action', json })
  },
  leaveTable: async (table: string) => {
    const json = { 'leave-table': { id: table } }
    await api.poke({ app: 'pokur', mark: 'pokur-player-action', json })
    set({ table: undefined })
  },
  startGame: async (table: string) => {
    const json = { 'start-game': { id: table } }
    await api.poke({ app: 'pokur', mark: 'pokur-player-action', json })
  },
  leaveGame: async (table: string) => {
    const json = { 'leave-game': { id: table } }
    await api.poke({ app: 'pokur', mark: 'pokur-player-action', json })
    set({ game: undefined })
  },
  kickPlayer: async (table: string, player: string) => {
    const json = { 'kick-player': { id: table, who: player } }
    await api.poke({ app: 'pokur', mark: 'pokur-player-action', json })
  },
  addEscrow: async (values: string) => {
    const json = { 'add-escrow': values }
    await api.poke({ app: 'pokur', mark: 'pokur-player-action', json })
  },
  mutePlayer: async (player: string) => {
    const json = { 'mute-player': { who: player } }
    await api.poke({ app: 'pokur', mark: 'pokur-message-action', json })
  },
  sendMessage: async (message: string) => {
    const json = { 'send-message': { message } }
    await api.poke({ app: 'pokur', mark: 'pokur-message-action', json })
  },
  check: async (table: string) => {
    const json = { 'check': { 'game-id': table } }
    await api.poke({ app: 'pokur', mark: 'pokur-game-action', json })
  },
  fold: async (table: string) => {
    const json = { 'fold': { 'game-id': table } }
    await api.poke({ app: 'pokur', mark: 'pokur-game-action', json })
  },
  bet: async (table: string, amount: number) => {
    const json = { 'bet': { 'game-id': table, amount } }
    await api.poke({ app: 'pokur', mark: 'pokur-game-action', json })
  },
}))

export default usePokurStore
