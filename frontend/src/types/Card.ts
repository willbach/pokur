export type Suit = 'spades' | 'hearts' | 'clubs' | 'diamonds'
export type CardValue = '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9' | '10' | 'J' | 'Q' | 'K' | 'A'

export interface Card {
  val: string
  suit: Suit
}
