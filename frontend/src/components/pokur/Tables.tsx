import React, { useCallback, useEffect, useMemo, useState } from 'react'
import cn from 'classnames'
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
import { fromUd, tokenAmount, numToUd } from '../../utils/number'
import Input from '../form/Input'
import CreateTableModal from './CreateTableModal'
import JoinTableModal from './JoinTableModal'
import AddHostModal from './AddHostModal'
import useWindowDimensions from '../../utils/useWindowSize'
import { addSig } from '../../utils/pongo'
import { CASH_CHIPS_PER_TOKEN } from '../../utils/constants'
import SpectateTableModal from './SpectateTableModal'

import './Tables.scss'

interface TableRowProps {
  table: Table
  selected: boolean
  onClick: () => void
  isMobile: boolean
}

const TableRow = ({ table, selected, isMobile, onClick }: TableRowProps) => {
  const { id, leader, game_type, players, max_players, tokenized, turn_time_limit } = table
  const buyIn = tokenized ? (
    'min_buy' in game_type ? `${Number(game_type.min_buy)} - ${Number(game_type.max_buy)} ${tokenized.symbol}` :
    `${tokenAmount(tokenized?.amount)} ${tokenized.symbol}`
  ) : 'none'

  const startingStack = 'starting_stack' in game_type ? game_type.starting_stack : `x${game_type.chips_per_token}`

  const blindDisplay = 'blinds_schedule' in game_type ?
    `${game_type.blinds_schedule[0][0]} / ${game_type.blinds_schedule[0][1]} ${game_type.round_duration}` :
    `${game_type.small_blind} / ${game_type.big_blind}`
  return (
    <tr className={cn('table', selected && 'selected', !table.public && 'private')} onClick={onClick}>
      {!isMobile && <td className='field'>{leader}...{id.slice(-4)}</td>}
      <td className='field'>{getGameType(game_type.type)}</td>
      <td className='field'>{buyIn}</td>
      {!isMobile && <td className='field'>{startingStack}</td>}
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
  const { lobby, joinTable, spectateTable, addHost, set } = usePokurStore()
  const { assets, selectedAccount, setMostRecentTransaction, setInsetView } = useWalletStore()
  const [selected, setSelected] = useState<Table | undefined>()
  const [showJoinTableModal, setShowJoinTableModal] = useState(false)
  const [showCreateTableModal, setShowCreateTableModal] = useState(false)
  const [showAddHostModal, setShowAddHostModal] = useState(false)
  const [buyInAmount, setBuyInAmount] = useState('')
  const { width } = useWindowDimensions()
  const isMobile = width <= 800

  useEffect(() => {
    const params = new URLSearchParams(window.location.search)

    if (params.get('invite')) {
      setShowJoinTableModal(true)
    }

    const host = params.get('host')
    if (host) {
      addHost(addSig(host))
    }
  }, [])

  useEffect(() => {
    if (selected && !lobby[selected.id]) {
      setSelected(undefined)
    }
  }, [lobby, selected])

  const join = useCallback((t: Table) => async () => {
    if ('min_buy' in t.game_type && 'max_buy' in t.game_type && (!buyInAmount || isNaN(Number(buyInAmount)) || Number(buyInAmount) < fromUd(t.game_type.min_buy) / CASH_CHIPS_PER_TOKEN || Number(buyInAmount) > fromUd(t.game_type.max_buy) / CASH_CHIPS_PER_TOKEN)) {
      return window.alert(`Buy in must be between ${t.game_type.min_buy} and ${t.game_type.max_buy}`)
    }

    set({ secondaryLoadingText: 'Waiting on transaction confirmation to join table...' })
    setMostRecentTransaction(undefined)
    setInsetView('confirm-most-recent')
    set({ joinTableId: t.id })
    const buyIn = t.game_type.type === 'sng' ? '0' :
      numToUd(Number(buyInAmount) * Math.pow(10, 18))
    await joinTable(t.id, buyIn, t.public)
  }, [buyInAmount, joinTable, setMostRecentTransaction, setInsetView, set])

  const joinAsSpectator = useCallback((t: Table) => async () => {
    if (lobby[t.id] && !lobby[t.id].is_active) {
      set({ showSpectate: true, spectateTableInfo: { table: t.id, host: addSig(t.host_info.ship) } })
    } else {
      set({ joinTableId: t.id, secondaryLoadingText: 'Joining as a spectator...' })
      await spectateTable(t.id, addSig(t.host_info.ship))
    }
  }, [lobby, spectateTable, set])

  const hasAsset = useMemo(() => Object.keys(assets).reduce((hasAccount, account) => {
    return hasAccount || Object.values(assets[account] || {}).reduce((acc, asset) => {
      return acc || (asset?.data.metadata === selected?.tokenized?.metadata
        && fromUd(asset?.data.balance) >= fromUd(selected?.tokenized?.amount) ? 
        account : '')
    }, '')
  }, ''), [assets, selected])

  const hasZigs = Object.values(assets[selectedAccount?.rawAddress || '0x0'] || {}).length > 0
  const disableJoin = selected && (!hasAsset || hasAsset !== selectedAccount?.rawAddress || selected.players.length >= Number(selected.max_players))

  return (
    <div className='tables'>
      <Col className='list'>
        <Col>
          <Row className="activity-buttons">
            <Button disabled={!hasZigs} variant='dark' onClick={() => setShowCreateTableModal(true)} style={{ minWidth: 64 }}>
              Create
            </Button>
            <Button disabled={!hasZigs} variant='dark' onClick={() => setShowJoinTableModal(true)} style={{ minWidth: 64 }}>
              Join
            </Button>
            <Button variant='dark' onClick={() => set({ showSpectate: true })}>
              Spectate
            </Button>
            <Button variant='dark' onClick={() => setShowAddHostModal(true)}>
              Add Host
            </Button>
          </Row>
          <table className='grid-display'>
            <tbody>
              <tr className='fields'>
                {!isMobile && <td className='field'>Game</td>}
                <td className='field'>Type</td>
                <td className='field'>Buy-in</td>
                {!isMobile && <td className='field'>Stack</td>}
                <td className='field'>Blinds</td>
                <td className='field'>Plrs</td>
                <td className='field'>Turn Time</td>
              </tr>
              {tables.map(t => <TableRow key={t.id} table={t} selected={selected?.id === t.id} onClick={() => setSelected(t)} isMobile={isMobile} />)}
            </tbody>
          </table>
        </Col>
        {/* <iframe title='Pokur Chat' src={window.location.origin + POKUR_CHAT} className='pokur-chat' /> */}
      </Col>
      <Col className='table-details'>
        {selected && (
          <>
            <h3 style={{ marginBottom: 8 }}>
              {/* Table: {table.id.slice(0, 11)}...{table.id.slice(-4)} */}
              Table: {selected.id}
            </h3>
            {!selected.public && <Row className='invite'>Private invite</Row>}
            {selected.game_type.type === 'cash' && (
              <Input
                placeholder='Buy-in amount'
                value={buyInAmount}
                min={'min_buy' in selected.game_type ? fromUd(selected.game_type.min_buy) : undefined}
                max={'max_buy' in selected.game_type ? fromUd(selected.game_type.max_buy) : undefined}
                onChange={(e) => setBuyInAmount(e.target.value.replace(/[^0-9.]/g, ''))}
                required
              />
            )}
            <Row>
              <Button disabled={disableJoin}
                variant='dark' style={{ marginTop: 8, marginBottom: 8, alignSelf: 'center' }} onClick={join(selected)}>
                Join
              </Button>
              {selected?.spectators_allowed && (
                <Button variant='dark' style={{ marginTop: 8, marginBottom: 8, marginLeft: 16, alignSelf: 'center' }} onClick={joinAsSpectator(selected)}>
                  Spectate
                </Button>
              )}
            </Row>
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
              <Text>
                {selected.tokenized ? (
                  'min_buy' in selected.game_type ? `${Number(selected.game_type.min_buy)} - ${Number(selected.game_type.max_buy)} ${selected.tokenized.symbol}` :
                  `${tokenAmount(selected.tokenized?.amount)} ${selected.tokenized.symbol}`
                ) : 'none'}
              </Text>
            </Row>
            {!hasAsset && <Text style={{ color: 'red' }}>You do not have enough assets</Text>}
            {hasAsset && hasAsset !== selectedAccount?.rawAddress &&
              <Text style={{ color: 'darkorange' }}>Change to account starting with {hasAsset.slice(0, 11)}</Text>
            }
            <Row className='table-info'>
              <h4>Starting Stack:</h4>
              <Text>{'starting_stack' in selected.game_type ? selected.game_type.starting_stack : `x${selected.game_type.chips_per_token}`}</Text>
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
          </>
        )}
      </Col>
      <CreateTableModal show={showCreateTableModal} hide={() => setShowCreateTableModal(false)} />
      <JoinTableModal show={showJoinTableModal} hide={() => setShowJoinTableModal(false)} />
      <AddHostModal show={showAddHostModal} hide={() => setShowAddHostModal(false)} />
      <SpectateTableModal />
    </div>
  )
}

export default Tables
