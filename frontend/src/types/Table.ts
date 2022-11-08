import { CashGame, GameType, TournamentGame } from "./Game"

export interface CreateTableValues {
  'min-players': number
  'max-players': number
  'game-type': GameType
  tokenized?: boolean
  public: boolean
  'spectators-allowed': boolean
  'turn-time-limit': string // in seconds
  'starting-stack': number
  'small-blind'?: number
  'big-blind'?: number
  'round-duration'?: string // in minutes
  'blinds-schedule'?: { small: number, big: number }[]
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
  tokenized: {
    metadata: string
    amount: string
  } | null
  bond_id: string | null
  spectators_allowed: boolean
  turn_time_limit: string
}
