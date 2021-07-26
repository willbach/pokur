import React, { Component } from 'react';

class ChallengeList extends Component {

  constructor(props) {
    super(props);

    this.state = {
      challenges: {},
    }

    this.acceptChallenge = this.acceptChallenge.bind(this);

    window.urb.subscribe(
      window.ship,
      'pokur',
      '/challenge-updates',
      (err) => console.log(err),
      (data) => this.processChallengeUpdate(data),
      () => console.log("Sub Quit")
    );
  }

  acceptChallenge(id, from) {
    window.urb.poke(
        window.ship,
        'pokur',
        'pokur-client-action',
        {
          'accept-challenge': {
            'from': from,
            'game-id': id,
          }
        },
        () => {},
        (err) => { console.log(err) }
      );
  }

  processChallengeUpdate(data) {
    console.log(data)
    if (data["update"] == "open") {
      const newChallenge = {
        challenger: data["challenger"],
        host: data["host"],
        type: data["type"],
      }
      this.setState({
        challenges: { ...this.state.challenges, [data["id"]]: newChallenge}
      });
    } else if (data["update"] == "close") {
      var newList = {...this.state.challenges};
      delete newList[data["id"]];
      this.setState({
        challenges: newList,
      });
    }
  }

  render() {
    return <div>
      <h2>Active Challenges</h2>
      <table className="challenge-list">
        <thead>
          <tr>
            <th>Challenger</th>
            <th>Host</th>
            <th>Type</th>
          </tr>
        </thead>
        <tbody>
          {
            Object.entries(this.state.challenges).map(([id, data]) => (
              <tr key={id}>
                <td>{data.challenger == '~'+window.ship ? "You" : data.challenger}</td>
                <td>{data.host}</td>
                <td>{data.type}</td>
                <td>{data.challenger == '~'+window.ship 
                 ? <span></span> 
                 : <button onClick={() => this.acceptChallenge(id, data.challenger)}>
                     Accept Challenge
                   </button>}</td>
              </tr>
            ))
          }
        </tbody>
      </table>
    </div>
  };
}

export default ChallengeList;
