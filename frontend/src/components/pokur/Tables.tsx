import React, { useCallback, useEffect, useMemo, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { useWalletStore } from '@uqbar/wallet-ui'
import usePokurStore from '../../store/pokurStore'
import { Table } from '../../types/Table'
import { formatTimeLimit } from '../../utils/format'
import { getGameType } from '../../utils/game'
import Button from '../form/Button'
import Col from '../spacing/Col'
import Row from '../spacing/Row'
import Text from '../text/Text'
import Player from './Player'

import './Tables.scss'
import { fromUd } from '../../utils/number'

const TableRow = ({ table, onClick }: { table: Table, onClick: () => void }) => {
  const { id, leader, game_type, players, max_players, tokenized, turn_time_limit } = table
  const buyIn = tokenized ? `${tokenized?.amount.slice(0,-24)} ${tokenized.symbol}` : 'none'

  const blindDisplay = 'blinds_schedule' in game_type ?
    `${game_type.blinds_schedule[0][0]} / ${game_type.blinds_schedule[0][1]} ${game_type.round_duration}` :
    `${game_type.small_blind} / ${game_type.big_blind}`

  return (
    <tr className='table' onClick={onClick}>
      <td className='field'>{leader}...{id.slice(-4)}</td>
      <td className='field'>{getGameType(game_type.type)}</td>
      <td className='field'>{buyIn}</td>
      <td className='field'>{game_type.starting_stack}</td>
      <td className='field'>{blindDisplay}</td>
      <td className='field'>{players.length} / {max_players}</td>
      <td className='field'>{formatTimeLimit(turn_time_limit)}</td>
    </tr>
  )
}

interface TablesProps {
  tables: Table[]
}

const Tables = ({ tables }: TablesProps) => {
  const { joinTable, lobby, setTable, game } = usePokurStore()
  const { assets, selectedAccount, setMostRecentTransaction, setInsetView } = useWalletStore()
  const [joinTableId, setJoinTableId] = useState<string | undefined>()
  const nav = useNavigate()
  const [selected, setSelected] = useState<Table | undefined>()

  useEffect(() => {
    if (joinTableId && lobby[joinTableId]?.players.find(p => p.includes((window as any).ship))) {
      setTable(lobby[joinTableId])
      nav('/table')
      setInsetView()
    } else if (joinTableId && lobby[joinTableId]?.players?.length === Number(lobby[joinTableId]?.max_players)) {
      alert('Another player joined before you, please join a different table.')
      setJoinTableId(undefined)
    } else if (game && game.id === joinTableId) {
      nav('/game')
    }
  }, [lobby, joinTableId, setInsetView, game, nav, setTable])

  const join = useCallback((tableId) => async () => {
    setMostRecentTransaction(undefined)
    setInsetView('confirm-most-recent')
    setJoinTableId(tableId)
    joinTable(tableId)
  }, [joinTable, setMostRecentTransaction, setInsetView])

  const hasAsset = useMemo(() => Object.keys(assets).reduce((hasAccount, account) => {
    return hasAccount || Object.values(assets[account]).reduce((acc, asset) => {
      return acc || (asset?.data.metadata === selected?.tokenized?.metadata
        && fromUd(asset?.data.balance) >= fromUd(selected?.tokenized.amount) ? 
        account : '')
    }, '')
  }, ''), [assets, selected])

  const disableJoin = selected && hasAsset === selectedAccount?.rawAddress && selected.players.length >= Number(selected.max_players)

  return (
    <div className='tables'>
      <table className='grid-display'>
        <tbody>
          <tr className='fields'>
            <td className='field'>Game</td>
            <td className='field'>Type</td>
            <td className='field'>Buy-in</td>
            <td className='field'>Stack</td>
            <td className='field'>Blinds</td>
            <td className='field'>Plrs</td>
            <td className='field'>Turn Time</td>
          </tr>
          {tables.map(t => <TableRow key={t.id} table={t} onClick={() => setSelected(t)} />)}
        </tbody>
      </table>
      <Col className='table-details'>
        {selected && (
          <>
            <h3 style={{ marginBottom: 24 }}>
              {/* Table: {table.id.slice(0, 11)}...{table.id.slice(-4)} */}
              Table: {selected.id}
            </h3>
            <Row className='table-info' style={{ alignItems: 'center' }}>
              <h4>Organizer:</h4>
              <Player ship={selected.leader} />
            </Row>
            <Row className='table-info'>
              <h4>Type:</h4>
              <Text>{getGameType(selected.game_type.type)}</Text>
            </Row>
            <Row className='table-info'>
              <h4>Buy-in:</h4>
              <Text>{selected.tokenized ? `${selected.tokenized.amount.slice(0,-24)} ${selected.tokenized.symbol}` : 'none'}</Text>
            </Row>
            {!hasAsset && <Text style={{ color: 'red' }}>You do not have enough assets</Text>}
            {hasAsset && hasAsset !== selectedAccount?.rawAddress &&
              <Text style={{ color: 'darkorange' }}>Change to account starting with {hasAsset.slice(0, 11)}</Text>
            }
            <Row className='table-info'>
              <h4>Starting Stack:</h4>
              <Text>{selected.game_type.starting_stack}</Text>
            </Row>
            {'blinds_schedule' in selected.game_type && <Row className='table-info'>
              <h4>Starting Blinds:</h4>
              <Col style={{ alignItems: 'flex-start' }}>
                <Text style={{ whiteSpace: 'nowrap' }}>
                  {selected.game_type.blinds_schedule[0][0]} / {selected.game_type.blinds_schedule[0][1]}
                </Text>
              </Col>
            </Row>}
            {'round_duration' in selected.game_type && <Row className='table-info'>
              <h4>Blinds Increase:</h4>
              <Text>{formatTimeLimit(selected.game_type.round_duration)}</Text>
            </Row>}
            {'small_blind' in selected.game_type && <Row className='table-info'>
              <h4>Small Blind:</h4>
              <Text>{selected.game_type.small_blind}</Text>
            </Row>}
            {'big_blind' in selected.game_type && <Row className='table-info'>
              <h4>Big Blind:</h4>
              <Text>{selected.game_type.big_blind}</Text>
            </Row>}
            <Row className='table-info'>
              <h4>Turn Time:</h4>
              <Text>{formatTimeLimit(selected.turn_time_limit)}</Text>
            </Row>
            <Row className='table-info'>
              <h4>Spectators:</h4>
              <Text>{selected.spectators_allowed ? 'Yes' : 'No'}</Text>
            </Row>
            <div className='players'>
              <h4 style={{ margin: '4px 0' }}>Players: {selected.players.length}/{selected.max_players}</h4>
              {selected.players.map(ship => <Player key={ship} ship={ship} className='mt-8' />)}
            </div>
            <div className='table-menu'>

            </div>
            <Button disabled={disableJoin}
              variant='dark' style={{ marginTop: 16, alignSelf: 'center' }} onClick={join(selected.id)}>
              Join
            </Button>
          </>
        )}
      </Col>
    </div>
  )
}

export default Tables
