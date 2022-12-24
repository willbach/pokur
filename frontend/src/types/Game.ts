import { Card } from "./Card"
import { Player } from "./Player"
import { Pot } from "./Pot"

export type GameType = 'cash' | 'sng'

interface GameTypeInfo {
  type: GameType
  starting_stack: string
}

export interface CashGame extends GameTypeInfo {
  small_blind: string
  big_blind: string
}

export interface TournamentGame extends GameTypeInfo {
  round_duration: string
  blinds_schedule: string[][]
  current_round: string
  round_is_over: boolean
}

export interface Game {
  id: string
  game_is_over: boolean
  game_type: CashGame | TournamentGame
  turn_time_limit: string
  players: Player[]
  pots: Pot[]
  current_bet: string
  last_bet: string
  min_bet: string
  board: Card[]
  hand: Card[]
  current_turn: string
  dealer: string
  small_blind: string
  big_blind: string
  spectators_allowed: boolean
  spectators: string[]
  hands_played: string
  update_message: string
  revealed_hands: { [ship: string /*includes sig*/]: Card[] }
  hand_rank: string
  turn_start: string // hoon date
  last_action: null | 'fold' | 'check' | 'call' | 'raise'
  // update_message: {
  //   text: string
  //   winning_hand: Card[]
  // }
}
