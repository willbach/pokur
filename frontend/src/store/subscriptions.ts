import { SubscriptionRequestInterface } from "@urbit/http-api";
import { NavigateFunction } from "react-router-dom";
import { GetState, SetState } from "zustand";
import { Game } from "../types/Game";
import { Lobby } from "../types/Lobby";
import { Table } from "../types/Table";
import { PokurStore } from "./pokurStore";
export type SubscriptionPath = '/lobby-updates' | '/table-updates' | '/game-updates' | '/messages'

export const handleLobbyUpdate = (get: GetState<PokurStore>, set: SetState<PokurStore>) => (lobby: Lobby) => {
  console.log('Lobby Update:'.toUpperCase(), lobby)
  set({ lobby })
}
export const handleTableUpdate = (get: GetState<PokurStore>, set: SetState<PokurStore>, nav?: NavigateFunction) => async (table: Table | null) => {
  console.log('Table Update:'.toUpperCase(), table)
  if (!table) {
    if (nav && get().table) {
      await new Promise((resolve) => setTimeout(() => resolve(true), 200))
      const game = await get().getGame()

      set({ table: undefined })

      if (game) {
        nav('/game')
      }
    }
  } else {
    set({ table })
    get().getMessages()
  }

}
export const handleGameUpdate = (get: GetState<PokurStore>, set: SetState<PokurStore>) => ({ game, hand_rank }: { game: Game; hand_rank: string }) => {
  console.log('Game Update:'.toUpperCase(), game)
  set({ game })
}
export const handleNewMessage = (get: GetState<PokurStore>, set: SetState<PokurStore>) => (message: any) => {
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
  // TODO: err, quit handling (resubscribe?)
  return request
}
