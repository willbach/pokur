import React, { useCallback, useEffect, useMemo, useState } from 'react'
import { useNavigate } from "react-router-dom"
import { AccountSelector, HardwareWallet, HotWallet, useWalletStore, DEFAULT_TOWN_TEST } from "@uqbar/wallet-ui"
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
import logo from '../assets/img/logo192.png'
import { getGameType } from '../utils/game';
import { DEFAULT_HOST_DEV, DEFAULT_HOST_PROD, NUMBER_OF_PLAYERS, ROUND_TIMES, STACK_SIZES, STARTING_BLINDS, TURN_TIMES } from '../utils/constants'



import './LobbyView.scss'

const BLANK_TABLE: CreateTableValues = {
  'game-type': 'sng',
  'host': process.env.NODE_ENV === 'production' ? DEFAULT_HOST_PROD : DEFAULT_HOST_DEV,
  'min-players': 2,
  'max-players': 2,
  'starting-stack': 1500,
  'turn-time-limit': '~s18', // in seconds
  // tokenized: undefined,
  'tokenized': { metadata: '0x61.7461.6461.7465.6d2d.7367.697a', amount: 1, 'bond-id': DEFAULT_TOWN_TEST, symbol: 'ZIG' },
  'public': true,
  'spectators-allowed': true,
  'small-blind': 1,
  'big-blind': 2,
  'round-duration': '~m3', // in minutes
  'starting-blinds': '10/20',
}

interface LobbyViewProps {
  redirectPath: string
}

const LobbyView = ({ redirectPath }: LobbyViewProps) => {
  const { host, lobby, joinHost, createTable, subscribeToPath, setOurAddress, setLoading, setTable } = usePokurStore()
  const { assets, metadata, setInsetView, selectedAccount, setMostRecentTransaction } = useWalletStore()
  const nav = useNavigate()

  const [newHost, setNewHost] = useState('')
  const [hostError, setHostError] = useState(false)
  const [showNewTableModal, setShowNewTableModal] = useState(false)
  const [tableForm, setTableForm] = useState<CreateTableValues>(BLANK_TABLE)

  const uniqueAssetList = useMemo(() => Object.values(assets[selectedAccount?.rawAddress || 'none'] || {}), [assets, selectedAccount])
  
  useEffect(() => {
    const lobbySub = subscribeToPath('/lobby-updates')
    return () => {
      lobbySub.then((sub: number) => api.unsubscribe(sub))
    }
  }, []) // eslint-disable-line react-hooks/exhaustive-deps

  useEffect(() => redirectPath ? nav(redirectPath) : undefined, [redirectPath]) // eslint-disable-line react-hooks/exhaustive-deps

  useEffect(() => {
    const table = Object.values(lobby).find(({ leader }) => leader.includes((window as any).ship))
    if (table) {
      setInsetView()
      setTable(table)
      nav('/table?new=true')
      setLoading(null)
    }
  }, [lobby, setInsetView, nav, setLoading, setTable])

  const changeTableForm = useCallback((key: string, isNumeric: boolean = false) => (e: any) => {
    if (key.includes('tokenized')) {
      const [,tokenizedKey] = key.split('/')

      setTableForm({
        ...tableForm,
        tokenized: {
          ...(tableForm.tokenized || {}),
          [tokenizedKey]: isNumeric ? Number(e.target.value.replace(/[^0-9]/g, '')) : e.target.value,
          symbol: tokenizedKey === 'metadata' ? metadata[e.target.value]?.data.symbol : tableForm.tokenized.symbol,
        }
      })
    } else {
      setTableForm({ ...tableForm, [key]: isNumeric ? Number(e.target.value.replace(/[^0-9]/g, '')) : e.target.value })
    }
  }, [metadata, tableForm, setTableForm])

  const submitNewTable = useCallback(async (e: any) => {
    e.preventDefault()

    try {
      const decimals = metadata[tableForm.tokenized.metadata]?.data.decimals
      const amount = tableForm.tokenized.amount * (decimals ? Math.pow(10, decimals) : 1)

      const formatedValues = {
        ...tableForm,
        tokenized: { ...tableForm.tokenized, amount }
      }
      await createTable(formatedValues)
      setTableForm(BLANK_TABLE)
      setMostRecentTransaction(undefined)
      setInsetView('confirm-most-recent')
      setShowNewTableModal(false)
    } catch (err) {
      setLoading(null)
    }
  }, [tableForm, metadata, createTable, setInsetView, setMostRecentTransaction, setLoading])

  const submitNewHost = useCallback(async (e) => {
    try {
      await joinHost(`~${newHost.replace(/~/g, '')}`)
      setNewHost('')
    } catch (error) {
      setHostError(true)
      e.preventDefault()
    }
  }, [newHost, setNewHost, joinHost])

  return (
    <Col className='lobby-view'>
      <Row className='header'>
        <Row className='branding'>
          <img src={logo} alt='uqbar logo' />
          <Text mono>POKUR</Text>
        </Row>
        <Row>
          {true && (
            <Button style={{ margin: 'auto 16px' }} onClick={() => setShowNewTableModal(true)}>
              Create Table
            </Button>
          )}
          <Col style={{ paddingRight: 16 }}>
            <AccountSelector onSelectAccount={(a: HotWallet | HardwareWallet) => setOurAddress(a.rawAddress)} />
            {/* {Boolean(host) ? (
              <>
                <h3 className='host'>Lobby: ~{host} {host === (window as any).ship ? '(you)' : ''}</h3>
                <Button onClick={leaveHost} style={{ margin: '8px 16px 8px', padding: '4px 10px', fontSize: 16 }}>
                  Change Lobby
                </Button>
              </>
              ) : (
              <>
                <h3 className='host'>Lobby: ~{host} {host === (window as any).ship ? '(you)' : ''}</h3>
              </>
            )} */}
          </Col>
        </Row>
      </Row>

      <Col className='main'>
        {true || Boolean(host) ? (
          <>
            {Object.keys(lobby).length > 0 ? (
              <Tables tables={Object.values(lobby)} />
            ) : (
              <h3>No tables under this host</h3>
            )}
          </>
        ) : (
          <>
            <h3 style={{ marginTop: 24 }}>Connect to a Lobby:</h3>
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
              {hostError && <Text style={{ color: 'red' }}>Error connecting to lobby, please try again.</Text>}
              <Button variant='dark' style={{ margin: '12px 0' }} type='submit'>
                Connect
              </Button>
            </form>
          </>
        )}
      </Col>
      <Modal show={showNewTableModal} hide={() => setShowNewTableModal(false)}>
        <Col style={{ minWidth: 400 }}>
          <h3 style={{ marginTop: 0 }}>Create New Table</h3>
          <form className="create-table" onSubmit={submitNewTable}>
            <Row>
              <label>Game Type</label>
              <Select value={tableForm['game-type']} onChange={(e) => {
                const gameSpecificInfo = e.target.value === 'cash' ?
                  { ...tableForm, 'game-type': 'cash', 'small-blind': 1, 'big-blind': 2, 'round-duration': undefined, 'blinds-schedule': undefined } :
                  { ...tableForm, 'game-type': 'sng', 'small-blind': undefined, 'big-blind': undefined, 'round-duration': '~m5'  }
                setTableForm(gameSpecificInfo as any)
              }}>
                {['sng'].map(gt => <option key={gt} value={gt}>{getGameType(gt)}</option>)}
              </Select>
            </Row>
            <Row>
              <label>Host</label>
              <Input value={tableForm.host} onChange={changeTableForm('host')} />
            </Row>
            {tableForm['game-type'] === 'sng' ? (
              <Row>
                <label>Players</label>
                <Select value={tableForm['min-players']} onChange={(e) => { changeTableForm('min-players', true)(e); changeTableForm('max-players', true)}}>
                  {NUMBER_OF_PLAYERS.map(nop => <option key={nop} value={nop}>{nop}</option>)}
                </Select>
              </Row>
            ) : (
              <>
                <Row>
                  <label>Min Players</label>
                  <Select value={tableForm['min-players']} onChange={changeTableForm('min-players', true)}>
                    {NUMBER_OF_PLAYERS.map(nop => <option key={nop} value={nop}>{nop}</option>)}
                  </Select>
                </Row>
                <Row>
                  <label>Max Players</label>
                  <Select value={tableForm['max-players']} onChange={changeTableForm('max-players', true)}>
                    {NUMBER_OF_PLAYERS.map(nop => <option key={nop} value={nop}>{nop}</option>)}
                  </Select>
                </Row>
              </>
            )}
            <Row>
              <label>Turn Time</label>
              <Select value={tableForm['turn-time-limit']} onChange={changeTableForm('turn-time-limit')}>
                {TURN_TIMES.map(tt => <option key={tt.value} value={tt.value}>{tt.display}</option>)}
              </Select>
            </Row>
            
            {tableForm['game-type'] === 'sng' ? (
              <>
                <Row>
                  <label>Buy-in Token</label>
                  <Select value={tableForm.tokenized?.metadata} onChange={changeTableForm('tokenized/metadata')}>
                    {uniqueAssetList.map(ua => <option key={ua.id} value={ua?.data.metadata}>{metadata[ua?.data.metadata]?.data.symbol}</option>)}
                  </Select>
                </Row>
                <Row>
                  <label>Buy-in Amount</label>
                  <Input value={tableForm.tokenized?.amount} onChange={changeTableForm('tokenized/amount', true)} />
                </Row>
                <Row>
                  <label>Starting Stack</label>
                  <Select value={tableForm['starting-stack']} onChange={changeTableForm('starting-stack', true)}>
                    {STACK_SIZES.map(s => <option key={s} value={s}>{s}</option>)}
                  </Select>
                </Row>
                <Row>
                  <label>Blinds Increase Every</label>
                  <Select value={tableForm['round-duration']} onChange={changeTableForm('round-duration')}>
                    {ROUND_TIMES.map(rd => <option key={rd.value} value={rd.value}>{rd.display}</option>)}
                  </Select>
                </Row>
                <Row>
                  <label>Starting Blinds</label>
                  <Select value={tableForm['starting-blinds']} onChange={changeTableForm('starting-blinds')}>
                    {STARTING_BLINDS.map(sb => <option key={sb} value={sb}>{sb}</option>)}
                  </Select>
                </Row>
              </>
            ) : (
              <>
                <Row>
                  <label>Big Blind</label>
                  <Input value={tableForm['big-blind']} onChange={changeTableForm('big-blind', true)} />
                </Row>
                <Row>
                  <label>Small Blind</label>
                  <Input value={tableForm['small-blind']} onChange={changeTableForm('small-blind', true)} />
                </Row>
              </>
            )}

            <Row>
              <label>Public</label>
              <Select value={tableForm['public'] ? 'yes' : 'no'} onChange={(e) => changeTableForm('public')(e.target.value === 'yes')}>
                {['yes', 'no'].map(sa => <option key={sa} value={sa}>{sa}</option>)}
              </Select>
            </Row>
            <Row>
              <label>Spectators Allowed</label>
              <Select value={tableForm['spectators-allowed'] ? 'yes' : 'no'} onChange={(e) => changeTableForm('spectators-allowed')(e.target.value === 'yes')}>
                {['yes', 'no'].map(sa => <option key={sa} value={sa}>{sa}</option>)}
              </Select>
            </Row>
            <Button type='submit' variant='dark' style={{ marginBottom: 24 }}>Create</Button>
            {/* {Object.keys(tableForm).map(key => (
              tableForm[key as CreateTableKey] === undefined ? null :
              <Row key={key} style={key === 'blinds-schedule' ? { flexDirection: 'column', alignItems: 'flex-start' } : {}}>
                <label>{capitalizeSpine(key)}</label>
                {renderInput(key)}
              </Row>
            ))} */}
          </form>
        </Col>
      </Modal>
    </Col>
  )
}

export default LobbyView
