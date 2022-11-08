import React, { useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import api from '../api'
import Button from '../components/form/Button'
import Col from '../components/spacing/Col'
import Row from '../components/spacing/Row'
import Text from '../components/text/Text'
import usePokurStore from '../store/pokurStore'
import { formatTimeLimit } from '../utils/format'

import './TableView.scss'

const TableView = () => {
  const { table, leaveTable, startGame, subscribeToPath } = usePokurStore()
  const nav = useNavigate()

  useEffect(() => {
    // const tableSub = subscribeToPath('/table-updates')
    // return () => {
    //   tableSub.then((sub: number) => api.unsubscribe(sub))
    // }
  }, []) // eslint-disable-line react-hooks/exhaustive-deps

  return (
    <Col className='table-view'>
      <div className='background' />
      <Col className='content'>
        {!table ? (
          <>
            <h3>Table Not Found</h3>
            <Button variant='dark' style={{ marginTop: 16 }} onClick={() => nav('/')}>
              Return to Lobby
            </Button>
          </>
        ) : (
          <>
            <h3 style={{ marginBottom: 24 }}>
              {/* Table: {table.id.slice(0, 11)}...{table.id.slice(-4)} */}
              Table: {table.id}
            </h3>
            <Row style={{ alignItems: 'flex-start', width: '100%' }}>
              <Col style={{ width: '50%', alignItems: 'flex-start' }}>
                {/* <Row className='table-info'>
                  <h4>ID:</h4>
                  <Text>{table.id}</Text>
                </Row> */}
                <Row className='table-info'>
                  <h4>Leader:</h4>
                  <Text>{table.leader}</Text>
                </Row>
                <Row className='table-info'>
                  <h4>Type:</h4>
                  <Text>{table.game_type.type}</Text>
                </Row>
                <Row className='table-info'>
                  <h4>Starting Stack:</h4>
                  <Text>{table.game_type.starting_stack}</Text>
                </Row>
                {'round_duration' in table.game_type && <Row className='table-info'>
                  <h4>Round Duration:</h4>
                  <Text>{table.game_type.round_duration}</Text>
                </Row>}
                {'blinds_schedule' in table.game_type && <Row className='table-info'>
                  <h4>Blinds Schedule:</h4>
                  <Text>{JSON.stringify(table.game_type.blinds_schedule)}</Text>
                </Row>}
                {'small_blind' in table.game_type && <Row className='table-info'>
                  <h4>Small Blind:</h4>
                  <Text>{table.game_type.small_blind}</Text>
                </Row>}
                {'big_blind' in table.game_type && <Row className='table-info'>
                  <h4>Big Blind:</h4>
                  <Text>{table.game_type.big_blind}</Text>
                </Row>}
                {table.tokenized && <Row className='table-info'>
                  <h4>Tokenized:</h4>
                  <Text>{table.tokenized?.amount}</Text>
                </Row>}
                <Row className='table-info'>
                  <h4>Spectators:</h4>
                  <Text>{table.spectators_allowed ? 'Yes' : 'No'}</Text>
                </Row>
                {table.bond_id && <Row className='table-info'>
                  <h4>Bond ID:</h4>
                  <Text>{table.bond_id}</Text>
                </Row>}
                <Row className='table-info'>
                  <h4>Turn Time Limit:</h4>
                  <Text>{formatTimeLimit(table.turn_time_limit)}</Text>
                </Row>
              </Col>
              <Col style={{ width: '50%', alignItems: 'flex-start' }}>
                <div className='players'>
                  <h4>Players: {table.players.length}/{table.max_players} (min {table.min_players})</h4>
                  {table.players.map(p => (
                    <div key={p} className='player'>~{p}</div>
                  ))}
                </div>
                <div className='table-menu'>

                </div>
              </Col>
            </Row>
            <Row style={{ marginTop: 16 }}>
              {(window as any).ship === table.leader.slice(1) && (
                <Button disabled={table.players.length < Number(table.min_players)} variant='dark' style={{ marginRight: 16 }} onClick={() => startGame(table.id)}>
                  Start Game
                </Button>
              )}
              <Button variant='dark' onClick={async () => { nav('/'); leaveTable(table.id) }}>
                Leave Table
              </Button>
            </Row>
          </>
        )}
      </Col>
    </Col>
  )
}

export default TableView
