import * as React from 'react'
import * as ReactDOM from 'react-dom'
import { Channel } from './js/channel.js'

declare global {
  interface Window {
    urb: Channel,
    ship: string
  }
}

function setTitle () {
  document.title = "Pokur ♠";
}

function render (): void {
  setTitle()
  ReactDOM.render((
    <>
      <p>greetings</p>
    </>
  ), document.querySelectorAll('#root')[0])
}

window.urb = new Channel()

// window.urb.subscribe(
//   window.ship,
//   'pokur',
//   '/challenges',
//   () => {},
//   (data: ChessUpdate) => onChessUpdate(data),
//   () => {},
//   () => {}
// )

// window.urb.subscribe(
//   window.ship,
//   'chess',
//   '/active-games',
//   () => {},
//   (data: ChessGameInfo) => onActiveGame(data),
//   () => {},
//   () => {}
// )

render()
