import * as React from 'react'
import * as ReactDOM from 'react-dom'
import ChallengeForm from './ChallengeForm.jsx'
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
      <ChallengeForm />
    </>
  ), document.querySelectorAll('#root')[0])
}

window.urb = new Channel()

render()