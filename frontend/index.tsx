import * as React from 'react'
import * as ReactDOM from 'react-dom'
import App from './App.jsx'
import { Channel } from './js/channel.js'

declare global {
  interface Window {
    urb: Channel,
    ship: string
  }
}

function render (): void {
  ReactDOM.render((
    <>
      <App />
    </>
  ), document.querySelectorAll('#root')[0])
}

window.urb = new Channel()

render()