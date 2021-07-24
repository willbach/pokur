import React, { Component } from 'react';
import ChallengeForm from './components/ChallengeForm.jsx'
import ChallengeList from './components/ChallengeList.jsx'

class App extends Component {
  constructor(props) {
    super(props);
  }

  render() {
    return <>
      <ChallengeForm />
      <ChallengeList />
    </>
  };
}

export default App;
