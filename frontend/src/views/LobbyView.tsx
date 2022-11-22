import React, { useCallback, useEffect, useState } from 'react'
import { useNavigate } from "react-router-dom";
import api from '../api'
import Button from '../components/form/Button'
import Input from '../components/form/Input'
import { Select } from '../components/form/Select';
import Tables from '../components/pokur/Tables';
import Modal from '../components/popups/Modal';
import Col from '../components/spacing/Col'
import Row from '../components/spacing/Row';
import Text from '../components/text/Text'
import usePokurStore from '../store/pokurStore'
import { CreateTableValues } from '../types/Table';
import { capitalizeSpine } from '../utils/format';
import { numToUd } from '../utils/number';

import './LobbyView.scss'

type CreateTableKey = 'min-players'
  | 'max-players'
  | 'game-type'
  | 'tokenized'
  | 'public'
  | 'spectators-allowed'
  | 'turn-time-limit'
  | 'starting-stack'
  | 'small-blind'
  | 'big-blind'
  | 'round-duration'
  | 'blinds-schedule'

const BLANK_TABLE: CreateTableValues = {
  'game-type': 'cash',
  'min-players': 2,
  'max-players': 8,
  'starting-stack': 1000,
  'turn-time-limit': '~m1', // in seconds
  // tokenized: undefined,
  'public': true,
  'spectators-allowed': true,
  'small-blind': 1,
  'big-blind': 2,
  'round-duration': undefined, // in minutes
  'blinds-schedule': undefined,
}

const turnTimes = [
  { display: '15 seconds', value: '~s15' },
  { display: '30 seconds', value: '~s30' },
  { display: '45 seconds', value: '~s45' },
  { display: '1 minute', value: '~m1' },
  { display: '1.5 minutes', value: '~s90' },
  { display: '2 minutes', value: '~m2' },
]

const roundTimes = [
  { display: '5 minutes', value: '~m5' },
  { display: '10 minutes', value: '~m10' },
  { display: '15 minutes', value: '~m15' },
  { display: '20 minutes', value: '~m20' },
  { display: '25 minutes', value: '~m25' },
  { display: '30 minutes', value: '~m30' },
]

const numberOfPlayers = [2, 3, 4, 5, 6, 7, 8]

interface LobbyViewProps {
  redirectPath: string
}

const LobbyView = ({ redirectPath }: LobbyViewProps) => {
  const { host, lobby, joinHost, leaveHost, createTable, subscribeToPath } = usePokurStore()
  const nav = useNavigate()

  const [newHost, setNewHost] = useState('')
  const [hostError, setHostError] = useState(false)
  const [showNewTableModal, setShowNewTableModal] = useState(false)
  const [tableForm, setTableForm] = useState<CreateTableValues>(BLANK_TABLE)

  useEffect(() => {
    const lobbySub = subscribeToPath('/lobby-updates')
    return () => {
      lobbySub.then((sub: number) => api.unsubscribe(sub))
    }
  }, []) // eslint-disable-line react-hooks/exhaustive-deps

  useEffect(() => redirectPath ? nav(redirectPath) : undefined, [redirectPath]) // eslint-disable-line react-hooks/exhaustive-deps

  const changeTableForm = useCallback((key: string, isNumeric = false) => (e: any) => {
    setTableForm({ ...tableForm, [key]: isNumeric ? Number(e.target.value.replace(/[^0-9]/g, '')) : e.target.value })
  }, [tableForm, setTableForm])

  const submitNewTable = useCallback(async (e: any) => {
    e.preventDefault()

    try {
      await createTable(tableForm)
      setTableForm(BLANK_TABLE)

      nav('/table?new=true')
    } catch (err) {}
  }, [tableForm, createTable, nav])

  const submitNewHost = useCallback(async (e) => {
    try {
      await joinHost(`~${newHost.replace(/~/g, '')}`)
      setNewHost('')
    } catch (error) {
      setHostError(true)
      e.preventDefault()
    }
  }, [newHost, setNewHost, joinHost])

  const renderInput = (key: string) => {
    const k = key as CreateTableKey
    
    switch (k) {
      case 'game-type':
        return (
          <Select value={tableForm[k]} onChange={(e) => {
            const gameSpecificInfo = e.target.value === 'cash' ?
              { ...tableForm, 'game-type': 'cash', 'small-blind': 1, 'big-blind': 2, 'round-duration': undefined, 'blinds-schedule': undefined } :
              { ...tableForm, 'game-type': 'tournament', 'small-blind': undefined, 'big-blind': undefined, 'round-duration': '~m10', 'blinds-schedule': [{ big: 2, small: 1 }]  }
            setTableForm(gameSpecificInfo as any)
            // changeTableForm(key)(e)
          }}>
            {['cash', 'tournament'].map(gt => <option key={gt} value={gt}>{gt}</option>)}
          </Select>
        )
      case 'public':
      case 'spectators-allowed':
        return (
          <Select value={tableForm[k] ? 'yes' : 'no'} onChange={(e) => changeTableForm(key)(e.target.value === 'yes')}>
            {['yes', 'no'].map(sa => <option key={sa} value={sa}>{sa}</option>)}
          </Select>
        )
      case 'turn-time-limit':
        return (
          <Select value={tableForm[k]} onChange={changeTableForm(k)}>
            {turnTimes.map(tt => <option key={tt.value} value={tt.value}>{tt.display}</option>)}
          </Select>
        )
      case 'round-duration':
        return (
          <Select value={tableForm[k]} onChange={changeTableForm(k)}>
            {roundTimes.map(rd => <option key={rd.value} value={rd.value}>{rd.display}</option>)}
          </Select>
        )
      case 'min-players':
      case 'max-players':
        return (
          <Select value={tableForm[k]} onChange={changeTableForm(k, true)}>
            {numberOfPlayers.map(nop => <option key={nop} value={nop}>{nop}</option>)}
          </Select>
        )
      case 'blinds-schedule':
        const changeSchedule = (round: number, blind: 'big' | 'small') => (e: any) => {
          const newVals = { ...tableForm }
          newVals['blinds-schedule']![round][blind] = Number(e.target.value.replace(/[^0-9]/g, ''))
          setTableForm(newVals)
        }

        const addRound = (e: any) => {
          e.preventDefault()
          e.stopPropagation()
          const newVals = { ...tableForm }
          newVals['blinds-schedule']!.push({ big: 2, small: 1 })
          setTableForm(newVals)
        }

        return (
          <>
            {tableForm['blinds-schedule']!.map((bs, i) => (
              <Col key={`round${i}`} style={{ marginTop: 8 }}>
                <Text bold>Round {i + 1}</Text>
                <Row>
                  <label>Big Blind</label>
                  <Input value={tableForm['blinds-schedule']![i].big} onChange={changeSchedule(i, 'big')} />
                </Row>
                <Row>
                  <label>Small Blind</label>
                  <Input value={tableForm['blinds-schedule']![i].small} onChange={changeSchedule(i, 'small')} />
                </Row>
              </Col>
            ))}
            <Button variant='dark' style={{ padding: '2px 4px', alignSelf: 'flex-start' }} onClick={addRound}>
              Add Round
            </Button>
          </>
        )
      default:
        const value = tableForm[k]?.toString()
        return (
          <Input key={key} value={value} onChange={changeTableForm(key, true)} />
        )
    }
  }

  return (
    <>
      <Col className='lobby-view'>
        <div className='background' />
        <Col className='content'>
          <h2>Welcome to Pokur</h2>
          {Boolean(host) ? (
            <>
              <h3 style={{ marginRight: 8 }}>Host: ~{host} {host === (window as any).ship ? '(you)' : ''}</h3>
              <Button onClick={leaveHost} variant='dark' style={{ margin: '8px 0 16px', padding: '3px 8px', fontSize: 14 }}>
                Change Host
              </Button>
              {Object.keys(lobby).length > 0 ? (
                <Tables tables={Object.values(lobby)} />
              ) : (
                <Text>No tables under this host</Text>
              )}
              <Button variant='dark' style={{ marginTop: 16 }} onClick={() => setShowNewTableModal(true)}>
                Create Table
              </Button>
            </>
          ) : (
            <>
              <h3 style={{ marginTop: 24 }}>Connect to a Host:</h3>
              <form onSubmit={submitNewHost}>
                <Input
                  placeholder='~sampel-palnet'
                  containerStyle={{ marginTop: 12 }}
                  value={newHost}
                  onChange={(e) => {
                    setNewHost(e.target.value.toLowerCase().replace(/[^a-z-~]/gi, ''))
                    setHostError(false)
                  }}
                />
                {hostError && <Text style={{ color: 'red' }}>Error saving host, please try again.</Text>}
                <Button variant='dark' style={{ margin: '12px 0' }} type='submit'>
                  Connect
                </Button>
              </form>
            </>
          )}
        </Col>
      </Col>
      <Modal show={showNewTableModal} hide={() => setShowNewTableModal(false)}>
        <Col style={{ minWidth: 400 }}>
          <h3 style={{ marginTop: 0 }}>Create New Table</h3>
          <form className="create-table" onSubmit={submitNewTable}>
            {Object.keys(tableForm).map(key => (
              tableForm[key as CreateTableKey] === undefined ? null :
              <Row key={key} style={key === 'blinds-schedule' ? { flexDirection: 'column', alignItems: 'flex-start' } : {}}>
                <label>{capitalizeSpine(key)}</label>
                {renderInput(key)}
              </Row>
            ))}
            <Button type='submit' variant='dark' style={{ marginBottom: 24 }}>Create</Button>
          </form>
        </Col>
      </Modal>
    </>
  )
}

export default LobbyView
