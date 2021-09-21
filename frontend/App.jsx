import React, { Component } from 'react';
import { ChallengeForm, ChallengeList, Game } from './components';
import UrbitInterface from '@urbit/http-api';
const api = useApi();


class App extends Component {
  constructor(props) {
    super(props);

    this.state = {
      inGame: false,
      gameData: null,
      myBet: 0,
    }

    this.updateGameState = this.updateGameState.bind(this);

    // window.urb.subscribe(
    //   window.ship,
    //   'pokur',
    //   '/game',
    //   (err) => console.log(err),
    //   (data) => this.updateGameState(data),
    //   () => console.log("Sub Quit")
    // );
    api.subscribe('pokur', '/game');
  }

  updateGameState(newGameState) {
    if (newGameState.in_game) {
      this.setState({
        inGame: true,
        gameData: newGameState,
        myBet: newGameState.current_bet > 0 
              ? newGameState.current_bet + newGameState.last_bet
              : newGameState.min_bet
      });
    } else {
      this.setState({
        inGame: false,
        gameData: null,
      });
    }
  }

  handleBetChange = event => {
    this.setState({
      myBet: event.target.value,
    });
  }

  render() {
    return <>
      <header>
        <p>Pokur -- play Texas hold 'em on Urbit</p>
        <a href="/">Return to Landscape</a> 
      </header>
      {this.state.inGame ? <Game game={this.state.gameData} 
                                 myBet={this.state.myBet} 
                                 handleBetChange={this.handleBetChange} />
              : <div><ChallengeForm />
                <ChallengeList /></div>}
    </>
  };
}

export default App;
