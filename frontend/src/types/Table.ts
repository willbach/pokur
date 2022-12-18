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
  tokenized: CreateTokenized
  public: boolean
  'spectators-allowed': boolean
  'turn-time-limit': string // in seconds
  'starting-stack': number
  'small-blind'?: number
  'big-blind'?: number
  'round-duration'?: string // in minutes
  'starting-blinds'?: string
  // 'current-round': number
  // 'round-is-over': boolean
}

export interface Table {
  id: string
  leader: string
  players: string[]
  min_players: string
  max_players: string
  game_type: CashGame | TournamentGame
  tokenized: Tokenized | null
  bond_id: string | null
  spectators_allowed: boolean
  turn_time_limit: string
}
