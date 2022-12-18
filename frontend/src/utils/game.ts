import { capitalizeSpine } from "./format"

export const getGameType = (type: string) => {
  if (type === 'sng')
    return 'SNG'

  return capitalizeSpine(type)
}

export const getPayoutAmounts = (numPlayers: number) => {
  if (numPlayers >= 9) {
    return [50, 30, 20]
  } else if (numPlayers >= 4) {
    return [65, 35]
  }
  return [100]
}

export const isSelf = (ship?: string) => ship && (window as any).ship === ship.replace('~', '')
