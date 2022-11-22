import React, { useCallback, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import usePokurStore from '../../store/pokurStore'
import { Table } from '../../types/Table'
import { formatTimeLimit } from '../../utils/format'
import Button from '../form/Button'
import Col from '../spacing/Col'
import Row from '../spacing/Row'
import Text from '../text/Text'
import Player from './Player'

import './Tables.scss'

const TableRow = ({ table, onClick }: { table: Table, onClick: () => void }) => {
  const { leader, game_type, players, min_players, max_players, tokenized, turn_time_limit } = table
  const buyIn = tokenized ? `${tokenized?.amount} ${tokenized?.metadata}` : 'none'

  const blindDisplay = 'blinds_schedule' in game_type ?
    `${game_type.blinds_schedule[0][0]} / ${game_type.blinds_schedule[0][0]}` :
    `${game_type.small_blind} / ${game_type.big_blind}`


  return (
    <tr className='table' onClick={onClick}>
      <td className='field'>{leader}</td>
      <td className='field'>{game_type.type}</td>
      <td className='field'>{buyIn}</td>
      <td className='field'>{game_type.starting_stack}</td>
      <td className='field'>{blindDisplay}</td>
      <td className='field'>{players.length}</td>
      <td className='field'>{min_players}</td>
      <td className='field'>{max_players}</td>
      <td className='field'>{formatTimeLimit(turn_time_limit)}</td>
    </tr>
  )
}

interface TablesProps {
  tables: Table[]
}

const Tables = ({ tables }: TablesProps) => {
  const { joinTable, getTable } = usePokurStore()
  const nav = useNavigate()
  const [selected, setSelected] = useState<Table | undefined>()

  const join = useCallback((tableId) => async () => {
    await joinTable(tableId)
    await getTable()
    nav('/table')
  }, [joinTable, getTable, nav])

  return (
    <div className='tables'>
      <table className='grid-display'>
        <tr className='fields'>
          <td className='field'>Creator</td>
          <td className='field'>Type</td>
          <td className='field'>Buy-in</td>
          <td className='field'>Stack</td>
          <td className='field'>Blinds</td>
          <td className='field'>Plrs</td>
          <td className='field'>Min</td>
          <td className='field'>Max</td>
          <td className='field'>Turn Time</td>
        </tr>
        {tables.map(t => <TableRow table={t} onClick={() => setSelected(t)} />)}
      </table>
      <Col className='table-details'>
        {selected && (
          <>
            <h3 style={{ marginBottom: 24 }}>
              {/* Table: {table.id.slice(0, 11)}...{table.id.slice(-4)} */}
              Table: {selected.id}
            </h3>
            <Row className='table-info' style={{ alignItems: 'center' }}>
              <h4>Leader:</h4>
              <Player ship={selected.leader} />
            </Row>
            <Row className='table-info'>
              <h4>Type:</h4>
              <Text>{selected.game_type.type}</Text>
            </Row>
            <Row className='table-info'>
              <h4>Starting Stack:</h4>
              <Text>{selected.game_type.starting_stack}</Text>
            </Row>
            {'round_duration' in selected.game_type && <Row className='table-info'>
              <h4>Round Duration:</h4>
              <Text>{selected.game_type.round_duration}</Text>
            </Row>}
            {'blinds_schedule' in selected.game_type && <Row className='table-info'>
              <h4>Blinds Schedule:</h4>
              <Col style={{ alignItems: 'flex-start' }}>
                {selected.game_type.blinds_schedule.map(([big, small], i) => (
                  <Text key={big + i} style={{ whiteSpace: 'nowrap' }}>
                    Round {i + 1}: {big} / {small}
                  </Text>
                ))}
              </Col>
            </Row>}
            {'small_blind' in selected.game_type && <Row className='table-info'>
              <h4>Small Blind:</h4>
              <Text>{selected.game_type.small_blind}</Text>
            </Row>}
            {'big_blind' in selected.game_type && <Row className='table-info'>
              <h4>Big Blind:</h4>
              <Text>{selected.game_type.big_blind}</Text>
            </Row>}
            {selected.tokenized && <Row className='table-info'>
              <h4>Tokenized:</h4>
              <Text>{selected.tokenized?.amount}</Text>
            </Row>}
            <Row className='table-info'>
              <h4>Spectators:</h4>
              <Text>{selected.spectators_allowed ? 'Yes' : 'No'}</Text>
            </Row>
            {selected.bond_id && <Row className='table-info'>
              <h4>Bond ID:</h4>
              <Text>{selected.bond_id}</Text>
            </Row>}
            <Row className='table-info'>
              <h4>Turn Time Limit:</h4>
              <Text>{formatTimeLimit(selected.turn_time_limit)}</Text>
            </Row>
            <div className='players'>
              <h4 style={{ margin: '4px 0' }}>Players: {selected.players.length}/{selected.max_players} (min {selected.min_players})</h4>
              {selected.players.map(ship => <Player key={ship} ship={ship} className='mt-8' />)}
            </div>
            <div className='table-menu'>

            </div>
            <Button variant='dark' style={{ marginTop: 16, alignSelf: 'center' }} onClick={join(selected.id)}>
              Join
            </Button>
          </>
        )}
      </Col>
    </div>
  )
}

export default Tables
