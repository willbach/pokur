import { SubscriptionRequestInterface } from "@urbit/http-api";
import { GetState, SetState } from "zustand";
import { Lobby } from "../types/Lobby";
import { PokurStore } from "./pokurStore";
export type SubscriptionPath = '/lobby-updates' | '/table-updates' | '/game-updates' | '/messages'

export const handleLobbyUpdate = (get: GetState<PokurStore>, set: SetState<PokurStore>) => (lobby: Lobby) => {
  console.log('Lobby Update:'.toUpperCase(), lobby)
  set({ lobby })
}
export const handleTableUpdate = (get: GetState<PokurStore>, set: SetState<PokurStore>) => (table: any) => {
  console.log('Table Update:'.toUpperCase(), table)
  set({ table })
  get().getMessages()
}
export const handleGameUpdate = (get: GetState<PokurStore>, set: SetState<PokurStore>) => (game: any) => {
  console.log('Game Update:'.toUpperCase(), game)
  set({ game })
}
export const handleNewMessage = (get: GetState<PokurStore>, set: SetState<PokurStore>) => (message: any) => {
  console.log('New Message:'.toUpperCase(), message)
  set({ messages: get().messages.concat([message]) })
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
