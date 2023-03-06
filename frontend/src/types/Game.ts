import { Card } from "./Card"
import { Player } from "./Player"
import { Pot } from "./Pot"

export type GameType = 'cash' | 'sng'

export type Denomination = '$' | 'BB'

interface GameTypeInfo {
  type: GameType
}

export interface CashGame extends GameTypeInfo {
  small_blind: string
  big_blind: string
  min_buy: string
  max_buy: string
  chips_per_token: string
}

export interface TournamentGame extends GameTypeInfo {
  round_duration: string
  blinds_schedule: string[][]
  current_round: string
  round_is_over: boolean
  starting_stack: string
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
  hide_actions: boolean
  winner?: string
  winning_hand?: string
  // update_message: {
  //   text: string
  //   winning_hand: Card[]
  // }
}

export const mockGame: Game = {
  id: '~2023.2.15..15.40.03..83ad',
  game_is_over: false,
  game_type: {
    type: 'sng',
    starting_stack: '1500',
    round_duration: '~m10',
    blinds_schedule: [['10', '20']],
    current_round: '1',
    round_is_over: false,
  },
  turn_time_limit: '~m1',
  players: [
    // { ship: 'nec', stack: '1500', committed: '100', acted: false, folded: false, left: false },
    // { ship: 'fabnev-hinmur', stack: '1500', committed: '100', acted: false, folded: false, left: false },
    // { ship: 'hodzod-walrus', stack: '1500', committed: '100', acted: false, folded: false, left: false },
    // { ship: 'habsul-rignyr', stack: '1500', committed: '100', acted: false, folded: false, left: false },
    { ship: 'timluc-miptev', stack: '1500', committed: '100', acted: false, folded: false, left: false },
    { ship: 'sillus-mallus', stack: '1500', committed: '100', acted: false, folded: false, left: false },
    { ship: 'hosted-labweb', stack: '1500', committed: '100', acted: false, folded: false, left: false },
    { ship: 'dachus-tiprel', stack: '1500', committed: '100', acted: false, folded: false, left: false },
    { ship: 'wolnyl-pasreg', stack: '1500', committed: '100', acted: false, folded: false, left: false },
    { ship: 'hocwyn-tipwex', stack: '1500', committed: '100', acted: false, folded: false, left: false },
  ],
  pots: [
    {
      amount: '900',
      players_in: [
        // 'nec',
        // 'fabnev-hinmur',
        // 'hodzod-walrus',
        // 'hapsul-rignyr',
        'timluc-miptev',
        'sillus-mallus',
        'hosted-labweb',
        'dachus-tiprel',
        'wolnyl-pasreg',
        'hocwyn-tipwex'
      ]
    }
  ],
  current_bet: '100',
  last_bet: '100',
  min_bet: '100',
  board: [
    { val: '2', suit: 'spades'},
    { val: '2', suit: 'hearts'},
    { val: '2', suit: 'clubs'},
    { val: '2', suit: 'diamonds'},
    { val: '3', suit: 'spades'},
  ],
  hand: [
    { val: '4', suit: 'spades'},
    { val: '5', suit: 'hearts'},
  ],
  current_turn: 'fabnev-hinmur',
  dealer: 'wolnyl-pasreg',
  small_blind: 'hocwyn-tipwex',
  big_blind: 'timluc-miptev',
  spectators_allowed: true,
  spectators: [],
  hands_played: '0',
  update_message: '',
  revealed_hands: {},
  hand_rank: 'Two Pair',
  turn_start: '~2020.8.28..20.42.44..e384',
  last_action: 'call',
  hide_actions: false,
}
