import React, { Component } from 'react';

class ChallengeForm extends Component {

  constructor(props) {
    super(props);

    this.state = {
      toInputs: {
        0: '',
      },
      host: '',
      minBet: 40,
      stackSize: 1000,
      type: 'cash',
    }

    this.handleChange = this.handleChange.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);
  }

  handleChange(event) {
    const target = event.target;
    const value = target.value;
    const name = target.name;
    
    if (name == "to") {
      const id = target.id;
      this.setState({
        toInputs: {...this.state.toInputs, [id]: value },
      });
    } else {
      this.setState({
        [name]: value,
      });
    }
  }

  addToInput() {
    var n = Object.keys(this.state.toInputs).length;
    this.setState({
      toInputs: {...this.state.toInputs, [n]: '' },
    });
  }

  handleSubmit(event) {
    const to = Object.values(this.state.toInputs);
    window.urb.poke(
      window.ship,
      'pokur',
      'pokur-client-action',
      {
        'issue-challenge': {
          'to': to,
          'host': this.state.host,
          'type': this.state.type,
          'min-bet': parseInt(this.state.minBet),
          'starting-stack': parseInt(this.state.stackSize),
        }
      },
      () => {},
      (err) => { console.log(err) }
    );

    event.preventDefault();
  }

  render() {
    return <div>
      <p>Send a challenge poke</p>
      <form onSubmit={this.handleSubmit}>
        {Object.entries(this.state.toInputs).map(([i, data]) => ( 
          <label>
            <br />
            To: 
            <input name="to" id={i} key={i} type="text" value={data} onChange={this.handleChange} />
        </label>
        ))}
        <button onClick={() => this.addToInput()}>
          Invite another ship
        </button>
        <br />
        <label>
          Host ship: 
          <input name="host" type="text" value={this.state.host} onChange={this.handleChange} />
        </label>
        <br />
        <label>
          Min. bet / big blind size: $
          <input name="minBet" type="number" value={this.state.value} onChange={this.handleChange} />
        </label>
        <br />
        <label>
          Starting stack size: $
          <input name="stackSize" type="number" value={this.state.value} onChange={this.handleChange} />
        </label>
        <br />
        <label>
          Game type: 
          <select name="type" value={this.state.type} onChange={this.handleChange}>
            <option value="cash">Cash</option>
            <option value="tournament">Tournament (not yet functional)</option>
          </select>
        </label>
        <br />
        <input type="submit" value="Submit" />
      </form>
    </div>
  };
}

export default ChallengeForm;
