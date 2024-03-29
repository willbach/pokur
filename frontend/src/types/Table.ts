import { CashGame, GameType, TournamentGame } from "./Game"

export interface CreateTokenized {
  metadata: string
  amount: number
  'bond-id': string
  symbol: string
}

export interface Tokenized {
  metadata: string
  amount: string
  bond_id: string
  symbol: string
}

export interface CreateTableValues {
  'min-players': number
  'max-players': number
  'game-type': GameType
  host: string
  'custom-host': string
  tokenized: CreateTokenized
  public: boolean
  'spectators-allowed': boolean
  'turn-time-limit': string // in seconds
  'starting-stack': number
  'round-duration'?: string // in minutes
  'starting-blinds'?: string
  'small-blind'?: number
  'big-blind'?: number
  'buy-ins': null,
  'min-buy': number,
  'max-buy': number,
  'chips-per-token': number,
  // 'current-round': number
  // 'round-is-over': boolean
}

export interface Table {
  id: string
  host_info: {
    address: string
    contract_id: string
    contract_town: string
    ship: string
  }
  leader: string
  players: string[]
  min_players: string
  max_players: string
  game_type: CashGame | TournamentGame
  tokenized: Tokenized | null
  bond_id: string | null
  spectators_allowed: boolean
  turn_time_limit: string
  is_active: boolean
  public: boolean
}
