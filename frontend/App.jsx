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
    if (newGameState.in_game) {
      this.setState({
        inGame: true,
        gameData: newGameState,
      });
    } else {
      this.setState({
        inGame: false,
        gameData: null,
      });
    }
    
  }

  render() {
    return <>
      
      {this.state.inGame ? <Game game={this.state.gameData} />
              : <div><ChallengeForm />
                <ChallengeList /></div>}
    </>
  };
}

export default App;
