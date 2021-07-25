import React, { Component } from 'react';
import ChallengeForm from './components/ChallengeForm.jsx'
import ChallengeList from './components/ChallengeList.jsx'
import Game from './components/Game.jsx'

class App extends Component {
  constructor(props) {
    super(props);

    this.state = {
      inGame: false,
      gameData: null,
    }

    this.updateGameState = this.updateGameState.bind(this);

    window.urb.subscribe(
      window.ship,
      'pokur',
      '/game',
      (err) => console.log(err),
      (data) => this.updateGameState(data),
      () => console.log("Sub Quit")
    );
  }

  updateGameState(newGameState) {
    this.setState({
      inGame: true,
      gameData: newGameState,
    });
  }

  render() {
    return <>
      <ChallengeForm />
      <ChallengeList />
      {this.state.inGame ? <Game game={this.state.gameData}/>
              : <span></span>}
    </>
  };
}

export default App;
