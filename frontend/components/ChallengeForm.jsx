import React, { Component } from 'react';


class ChallengeForm extends Component {

  constructor(props) {
    super(props);

    this.state = {
      to: '',
      host: '',
      type: 'cash'
    }

    this.handleChange = this.handleChange.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);
  }

  handleChange(event) {
    const target = event.target;
    const value = target.value;
    const name = target.name;

    this.setState({
      [name]: value
    });
  }

  handleSubmit(event) {
    window.urb.poke(
      window.ship,
      'pokur',
      'pokur-client-action',
      {
        'issue-challenge': {
          'to': this.state.to,
          'host': this.state.host,
          'type': this.state.type
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
        <label>
          To:
          <input name="to" type="text" value={this.state.to} onChange={this.handleChange} />
        </label>
        <label>
          Host ship:
          <input name="host" type="text" value={this.state.host} onChange={this.handleChange} />
        </label>
        <label>
          Game type:
          <select value={this.state.type} onChange={this.handleChange}>
            <option value="cash">Cash</option>
            <option value="tournament">Tournament (not yet functional)</option>
          </select>
        </label>
        <input type="submit" value="Submit" />
      </form>
    </div>
  };
}

export default ChallengeForm;
