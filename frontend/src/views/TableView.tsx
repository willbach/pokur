import React, { useEffect } from 'react'
import { useNavigate, useLocation } from 'react-router-dom'
import { AccountSelector } from '@uqbar/wallet-ui'
import api from '../api'
import Button from '../components/form/Button'
import Player from '../components/pokur/Player'
import Col from '../components/spacing/Col'
import Row from '../components/spacing/Row'
import Text from '../components/text/Text'
import usePokurStore from '../store/pokurStore'
import { formatTimeLimit } from '../utils/format'
import { getGameType } from '../utils/game'
import { ONE_SECOND } from '../utils/constants'
import TableBackground from '../components/pokur/TableBackground'
import { tokenAmount } from '../utils/number'

import './TableView.scss'

interface TableViewProps {
  redirectPath: string
}

const TableView = ({ redirectPath }: TableViewProps) => {
  const { table, gameStartingIn, leaveTable, startGame, subscribeToPath, setOurAddress } = usePokurStore()
  const nav = useNavigate()
  const location = useLocation()

  useEffect(() => {
    const lobbySub = subscribeToPath('/lobby-updates', nav)
    return () => {
      lobbySub.then((sub: number) => api.unsubscribe(sub))
    }
  }, []) // eslint-disable-line react-hooks/exhaustive-deps

  useEffect(() => redirectPath ? nav(redirectPath) : undefined, [redirectPath]) // eslint-disable-line react-hooks/exhaustive-deps

  const buyIn = table?.tokenized ? `${tokenAmount(table.tokenized?.amount)} ${table.tokenized.symbol}` : 'none'
  const gameStarting = gameStartingIn !== undefined

  return (
    <Col className='table-view'>
      <TableBackground />
      <div style={{ position: 'absolute', top: 16, right: 16 }}>
        <AccountSelector onSelectAccount={(a: any) => setOurAddress(a.rawAddress)} />
      </div>
      <Col className='content'>
        {!table ? (
          <>
            <h3>
              {location.search.includes('new=true') ?
                'Table is being set up...' :
                'Table Cancelled or Not Found'
              }
            </h3>
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
              <Col style={{ width: '70%', alignItems: 'flex-start' }}>
                {/* <Row className='table-info'>
                  <h4>ID:</h4>
                  <Text>{table.id}</Text>
                </Row> */}
                <Row className='table-info' style={{ alignItems: 'center' }}>
                  <h4>Organizer:</h4>
                  <Player ship={table.leader} />
                </Row>
                <Row className='table-info'>
                  <h4>Type:</h4>
                  <Text>{getGameType(table.game_type.type)}</Text>
                </Row>
                {table.tokenized && <Row className='table-info'>
                  <h4>Buy-in:</h4>
                  <Text>{buyIn}</Text>
                </Row>}
                <Row className='table-info'>
                  <h4>Starting Stack:</h4>
                  <Text>{table.game_type.starting_stack}</Text>
                </Row>
                {'round_duration' in table.game_type && <Row className='table-info'>
                  <h4>Blinds Increase Every:</h4>
                  <Text>{formatTimeLimit(table.game_type.round_duration)}</Text>
                </Row>}
                {'blinds_schedule' in table.game_type && <Row className='table-info'>
                  <h4>Starting Blinds:</h4>
                  <Col style={{ alignItems: 'flex-start' }}>
                    <Text style={{ whiteSpace: 'nowrap' }}>
                      {table.game_type.blinds_schedule[0][0]} / {table.game_type.blinds_schedule[0][1]}
                    </Text>
                  </Col>
                </Row>}
                {'small_blind' in table.game_type && <Row className='table-info'>
                  <h4>Small Blind:</h4>
                  <Text>{table.game_type.small_blind}</Text>
                </Row>}
                {'big_blind' in table.game_type && <Row className='table-info'>
                  <h4>Big Blind:</h4>
                  <Text>{table.game_type.big_blind}</Text>
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
              <Col style={{ width: '30%', alignItems: 'flex-start' }}>
                <div className='players'>
                  <h4>Players: {table.players.length}/{table.max_players}</h4>
                  {table.players.map(ship => <Player key={ship} ship={ship} className='mt-8' />)}
                </div>
                <div className='table-menu'>

                </div>
              </Col>
            </Row>
            <Row style={{ marginTop: 16 }}>
              {(window as any).ship === table.leader.slice(1) && (
                <Button disabled={table.players.length < Number(table.min_players) || gameStarting}
                  variant='dark' style={{ marginRight: 16 }} onClick={() => startGame(table.id)}>
                  Start Game
                </Button>
              )}
              <Button disabled={gameStarting} onClick={async () => { await leaveTable(table.id); setTimeout(() => nav('/'), 500) }}>
                Leave Table
              </Button>
            </Row>
            {gameStarting && (
              <h4 style={{ marginTop: 16 }}>
                Game starts in {(gameStartingIn || 0) / ONE_SECOND} second{(gameStartingIn || 0) / ONE_SECOND > 1 ? 's' : ''}
              </h4>
            )}
          </>
        )}
      </Col>
    </Col>
  )
}

export default TableView
