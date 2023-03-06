import React, { useCallback, useEffect, useMemo, useState } from 'react'
import { DEFAULT_TOWN_TEST, useWalletStore } from "@uqbar/wallet-ui"
import Button from '../form/Button'
import Input from '../form/Input'
import { Select } from '../form/Select';
import Modal from '../popups/Modal';
import Col from '../spacing/Col'
import Row from '../spacing/Row';
import usePokurStore from '../../store/pokurStore'
import { CreateTableValues } from '../../types/Table';
import { getGameType } from '../../utils/game';
import { NUMBER_OF_PLAYERS, REMATCH_PARAMS_KEY, ROUND_TIMES, STACK_SIZES, STARTING_BLINDS, TURN_TIMES, BUY_INS, CASH_CHIPS_PER_TOKEN } from '../../utils/constants'
import { ListInput } from '../form/ListInput';

import './CreateTableModal.scss'

const BLANK_TABLE: CreateTableValues = {
  'game-type': 'sng',
  'host': 'Other',
  'custom-host': '',
  'min-players': 2,
  'max-players': 2,
  'turn-time-limit': '~s20', // in seconds
  'tokenized': { metadata: '0x61.7461.6461.7465.6d2d.7367.697a', amount: 1, 'bond-id': DEFAULT_TOWN_TEST, symbol: 'ZIG' },
  'public': true,
  'spectators-allowed': true,
  // sng
  'starting-blinds': '10/20',
  'starting-stack': 1500,
  'round-duration': '~m3', // in minutes
  // cash
  'big-blind': 0.01,
  'min-buy': 100, // denominated in BBs
  'max-buy': 200, // denominated in BBs
  // 'small-blind': 0.02,
  'chips-per-token': CASH_CHIPS_PER_TOKEN,
  'buy-ins': null, // always null
}

const genBlankTable = (hosts: string[]) =>  ({ ...BLANK_TABLE, host: hosts[0] || 'Other' })

interface CreateTableModalProps {
  show: boolean
  hide: () => void
}

const CreateTableModal = ({ show, hide }: CreateTableModalProps) => {
  const { hosts, addHost, createTable, invites, set } = usePokurStore()
  const { assets, metadata, setInsetView, selectedAccount, setMostRecentTransaction } = useWalletStore()

  const [tableForm, setTableForm] = useState<CreateTableValues>(genBlankTable(hosts))

  const uniqueAssetList = useMemo(() => Object.values(assets[selectedAccount?.rawAddress || 'none'] || {}), [assets, selectedAccount])

  useEffect(() => {
    if (!show && hosts.length) {
      setTableForm(genBlankTable(hosts))
    }
  }, [show, hosts])

  const changeTableForm = useCallback((key: string, isNumeric: boolean = false, isBoolean = false) => (e: any) => {
    if (key.includes('tokenized')) {
      const [,tokenizedKey] = key.split('/')

      setTableForm({
        ...tableForm,
        tokenized: {
          ...(tableForm.tokenized || {}),
          [tokenizedKey]: isNumeric ? e.target.value.replace(/[^0-9.]/g, '') : e.target.value,
          symbol: tokenizedKey === 'metadata' ? metadata[e.target.value]?.data.symbol : tableForm.tokenized.symbol,
        }
      })
    } else if (key === 'min-players') {
      const min = Number(e.target.value.replace(/[^0-9]/g, ''))
      setTableForm({
        ...tableForm,
        [key]: min,
        "max-players": tableForm['max-players'] < min ? min : tableForm['max-players'],
      })
    } else if (key === 'max-players') {
      const max = Number(e.target.value.replace(/[^0-9]/g, ''))
      setTableForm({
        ...tableForm,
        [key]: max,
        "min-players": tableForm['min-players'] > max ? max : tableForm['min-players'],
      })
    } else {
      setTableForm({
        ...tableForm,
        [key]: isNumeric ? Number(e.target.value.replace(/[^0-9]/g, '')) : isBoolean ? e.target.value === 'yes' : e.target.value
      })
    }
  }, [metadata, tableForm, setTableForm])

  const submitNewTable = useCallback(async (e: any) => {
    e.preventDefault()

    try {
      const decimals = metadata[tableForm.tokenized.metadata]?.data.decimals
      const amount = (tableForm.tokenized?.amount || 1) * (decimals ? Math.pow(10, decimals) : 1)
      const newHost = `~${tableForm['custom-host'].replace('~', '')}`

      const formatedValues = {
        ...tableForm,
        tokenized: { ...tableForm.tokenized, amount },
        host: tableForm.host === 'Other' ? newHost : tableForm.host
      }

      const newHosts = [...hosts];

      if (tableForm.host === 'Other') {
        try {
          await addHost(newHost)
        } catch (err) {
          return alert(`Could not join ${newHost}, please ensure it is a valid host and try again.`)
        }
        newHosts.push(newHost)
      }

      set({ secondaryLoadingText: 'Waiting on transaction confirmation to create table...' })
      await createTable(formatedValues)
      localStorage.setItem(REMATCH_PARAMS_KEY, JSON.stringify(formatedValues))
      setTableForm(genBlankTable(newHosts))
      setMostRecentTransaction(undefined)
      setInsetView('confirm-most-recent')
      hide()
    } catch (err) {
      set({ secondaryLoadingText: null })
    }
  }, [tableForm, metadata, hosts, hide, createTable, setInsetView, setMostRecentTransaction, addHost, set])

  return (
    <Modal show={show} hide={hide} className='create-table-modal'>
      <Col>
        <h3 style={{ marginTop: 0 }}>Create New Table</h3>
        <form className="create-table" onSubmit={submitNewTable}>
          <Row>
            <label>Game Type</label>
            <Select value={tableForm['game-type']} onChange={(e) => {
              const gameSpecificInfo = e.target.value === 'cash' ?
                { ...tableForm, 'game-type': 'cash', 'big-blind': 0.01, 'round-duration': undefined, 'blinds-schedule': undefined, 'max-players': 4 } :
                { ...tableForm, 'game-type': 'sng', 'small-blind': undefined, 'big-blind': undefined, 'round-duration': '~m5'  }
              setTableForm(gameSpecificInfo as any)
            }}>
              {['sng', 'cash'].map(gt => <option key={gt} value={gt}>{getGameType(gt)}</option>)}
            </Select>
          </Row>
          <Row>
            <label>Host</label>
            <Col>
              <Select value={tableForm['host']} onChange={changeTableForm('host')}>
                {hosts.concat(['Other']).map(host => <option key={host} value={host}>{host}</option>)}
              </Select>
              {tableForm.host === 'Other' && (
                <Input style={{ marginTop: 4 }} value={tableForm['custom-host']} onChange={changeTableForm('custom-host')} />
              )}
            </Col>
          </Row>
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
          <Row>
            <label>Turn Time</label>
            <Select value={tableForm['turn-time-limit']} onChange={changeTableForm('turn-time-limit')}>
              {TURN_TIMES.map(tt => <option key={tt.value} value={tt.value}>{tt.display}</option>)}
            </Select>
          </Row>
          
          <Row>
            <label>Buy-in Token</label>
            <Select value={tableForm.tokenized?.metadata} onChange={changeTableForm('tokenized/metadata')}>
              {uniqueAssetList.map(ua => <option key={ua.id} value={ua?.data.metadata}>{metadata[ua?.data.metadata]?.data.symbol}</option>)}
            </Select>
          </Row>
          {tableForm['game-type'] === 'sng' ? (
            <>
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
                <label>Min Buy-in (BBs)</label>
                <Select value={tableForm['min-buy']} onChange={changeTableForm('min-buy', true)}>
                  {BUY_INS.map(bi => <option key={bi} value={bi}>{bi}</option>)}
                </Select>
                {/* <Input value={tableForm['min-buy']} onChange={changeTableForm('min-buy', true)} /> */}
              </Row>
              <Row>
                <label>Max Buy-in (BBs)</label>
                <Select value={tableForm['max-buy']} onChange={changeTableForm('max-buy', true)}>
                  {BUY_INS.map(bi => <option key={bi} value={bi}>{bi}</option>)}
                </Select>
                {/* <Input value={tableForm['max-buy']} onChange={changeTableForm('max-buy', true)} /> */}
              </Row>
            </>
          )}

          <Row>
            <label>Spectators Allowed</label>
            <Select value={tableForm['spectators-allowed'] ? 'yes' : 'no'} onChange={changeTableForm('spectators-allowed', false, true)}>
              {['yes', 'no'].map(sa => <option key={sa} value={sa}>{sa}</option>)}
            </Select>
          </Row>
          <Row>
            <label>Public</label>
            <Select value={tableForm['public'] ? 'yes' : 'no'} onChange={changeTableForm('public', false, true)}>
              {['yes', 'no'].map(sa => <option key={sa} value={sa}>{sa}</option>)}
            </Select>
          </Row>
          {!tableForm.public && (
            <Row style={{ marginTop: -4, width: 280 }}>
              <label style={{ width: 60 }}>Invites</label>
              <ListInput values={invites} setValues={(invites: string[]) => set({ invites })} />
            </Row>
          )}

          <Button type='submit' variant='dark' style={{ marginBottom: 24 }}>Create</Button>
        </form>
      </Col>
    </Modal>
  )
}

export default CreateTableModal
