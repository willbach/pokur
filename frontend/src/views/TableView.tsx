import React, { useCallback, useEffect, useState } from 'react'
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
import { getGameType, isSelf } from '../utils/game'
import { ONE_SECOND } from '../utils/constants'
import TableBackground from '../components/pokur/TableBackground'
import { tokenAmount } from '../utils/number'
import Chat from '../components/pokur/Chat'

import './TableView.scss'
import useWindowDimensions from '../utils/useWindowSize'
import ShareTableModal from '../components/pokur/ShareTableModal'

interface TableViewProps {
  redirectPath: string
}

const TableView = ({ redirectPath }: TableViewProps) => {
  const { table, gameStartingIn, invites,
    leaveTable, startGame, subscribeToPath, setOurAddress, sendInvite, set } = usePokurStore()
  const nav = useNavigate()
  const location = useLocation()
  const [leaving, setLeaving] = useState(false)
  const [starting, setStarting] = useState(false)
  const [showShareModal, setShowShareModal] = useState(false)
  const { width } = useWindowDimensions()
  const isMobile = width <= 800

  const leave = useCallback(() => {
    if (table && (!isSelf(table.leader) || window.confirm('Are you sure you want to leave?'))) {
      setLeaving(true)
      leaveTable(table.id).catch(() => setLeaving(false))
    }
  }, [table, leaveTable])

  useEffect(() => {
    if (invites && table?.leader.includes((window as any).ship)) {
      Promise.all(
        invites.map(ship => sendInvite(`~${ship.replace('~', '')}`))
      )
      .catch(console.warn)
      .finally(() => set({ invites: [] }))
    }

    const lobbySub = subscribeToPath('/lobby-updates', nav)
    return () => {
      lobbySub.then((sub: number) => api.unsubscribe(sub))
    }
  }, []) // eslint-disable-line react-hooks/exhaustive-deps

  useEffect(() => redirectPath ? nav(redirectPath) : undefined, [redirectPath]) // eslint-disable-line react-hooks/exhaustive-deps

  useEffect(() => {
    if (!table) {
      set({ messages: [] })
      nav('/')
    } else if (!table.players.includes(table.leader.replace('~', ''))) {
      leave()
      window.alert('The table organizer left.')
    }
  }, [table, nav, leave, set])

  const buyIn = table?.tokenized ? `${tokenAmount(table.tokenized?.amount)} ${table.tokenized.symbol}` : 'none'
  const gameStarting = gameStartingIn !== undefined || starting

  return (
    <Col className='table-view'>
      <TableBackground />
      <div style={{ position: 'absolute', top: 16, right: 16 }}>
        <AccountSelector onSelectAccount={(a: any) => setOurAddress(a.rawAddress)} />
      </div>
      <Col className='content'>
        {!table ? (
          <Col style={{ padding: 24, width: '100%', height: '100%' }}>
            <h3>
              {location.search.includes('new=true') ?
                'Table is being set up...' :
                'Table Cancelled or Not Found'
              }
            </h3>
            <Button variant='dark' style={{ marginTop: 16 }} onClick={() => nav('/')}>
              Return to Lobby
            </Button>
          </Col>
        ) : (
          <Row style={{ width: '100%', height: '100%' }}>
            {/* <iframe title='Pokur Chat' src={window.location.origin + POKUR_CHAT} className='pokur-chat' /> */}
            <Col style={{ width: '100%', alignItems: 'center', padding: 16, overflow: 'scroll', maxHeight: '80vh' }}>
              <h3 style={{ marginBottom: 24 }}>
                {/* Table: {table.id.slice(0, 11)}...{table.id.slice(-4)} */}
                Table: {table.id}
              </h3>
              <Row style={{ alignItems: 'flex-start', width: '100%', flexDirection: isMobile ? 'column' : undefined }}>
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
                    <Text>{'starting_stack' in table.game_type ? table.game_type.starting_stack : `x${table.game_type.chips_per_token}`}</Text>
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
                <Col style={{ width: isMobile ? '100%' : '30%', alignItems: 'flex-start' }}>
                  <h4>Players: {table.players.length}/{table.max_players}</h4>
                  <Col className='players'>
                    {table.players.map(ship => <Player key={ship} ship={ship} className='mt-8' />)}
                  </Col>
                  <div className='table-menu'>

                  </div>
                </Col>
              </Row>
              <Row style={{ marginTop: 16 }}>
                <Button disabled={gameStarting || leaving} style={{ marginRight: 16 }} variant='dark' onClick={() => setShowShareModal(true)}>
                  Share Table
                </Button>
                {(window as any).ship === table.leader.slice(1) && (
                  <Button disabled={table.players.length < Number(table.min_players) || gameStarting}
                    variant='dark' style={{ marginRight: 16 }} onClick={() => {startGame(table.id); setStarting(true)}}>
                    Start Game
                  </Button>
                )}
                <Button disabled={gameStarting || leaving} onClick={leave}>
                  Leave Table
                </Button>
              </Row>
              {gameStartingIn !== undefined && (
                <h4 style={{ marginTop: 8 }}>
                  Game starts in {(gameStartingIn || 0) / ONE_SECOND} second{(gameStartingIn || 0) / ONE_SECOND > 1 ? 's' : ''}
                </h4>
              )}
              <div style={{ width: 'calc(100% + 32px)', margin: '16px 0 -16px' }}>
                <Chat height={180} />
              </div>
            </Col>
          </Row>
        )}
      </Col>
      <ShareTableModal show={showShareModal} hide={() => setShowShareModal(false)} />
    </Col>
  )
}

export default TableView
