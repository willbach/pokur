import * as React from 'react'
import * as ReactDOM from 'react-dom'
import ChallengeForm from './ChallengeForm.jsx'
import ChallengeList from './ChallengeList.jsx'
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
      <ChallengeList />
    </>
  ), document.querySelectorAll('#root')[0])
}

window.urb = new Channel()

render()