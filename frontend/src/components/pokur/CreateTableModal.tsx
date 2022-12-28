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
import { DEFAULT_HOST_DEV, DEFAULT_HOST_PROD, NUMBER_OF_PLAYERS, REMATCH_PARAMS_KEY, ROUND_TIMES, STACK_SIZES, STARTING_BLINDS, TURN_TIMES } from '../../utils/constants'
import { ListInput } from '../form/ListInput';

import './CreateTableModal.scss'

const BLANK_TABLE: CreateTableValues = {
  'game-type': 'sng',
  'host': 'Other',
  'custom-host': '',
  'min-players': 2,
  'max-players': 2,
  'starting-stack': 1500,
  'turn-time-limit': '~s20', // in seconds
  // tokenized: undefined,
  'tokenized': { metadata: '0x61.7461.6461.7465.6d2d.7367.697a', amount: 1, 'bond-id': DEFAULT_TOWN_TEST, symbol: 'ZIG' },
  'public': true,
  'spectators-allowed': true,
  'small-blind': 1,
  'big-blind': 2,
  'round-duration': '~m3', // in minutes
  'starting-blinds': '10/20',
}

const genBlankTable = (hosts: string[]) =>  ({ ...BLANK_TABLE, host: hosts[0] || 'Other' })

interface CreateTableModalProps {
  show: boolean
  hide: () => void
}

const CreateTableModal = ({ show, hide }: CreateTableModalProps) => {
  const { hosts, addHost, createTable, setLoading, invites, setInvites } = usePokurStore()
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
    } else if (tableForm['game-type'] === 'sng' && key === 'min-players') {
      setTableForm({
        ...tableForm,
        [key]: Number(e.target.value.replace(/[^0-9]/g, '')),
        "max-players": Number(e.target.value.replace(/[^0-9]/g, '')),
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
      const amount = tableForm.tokenized.amount * (decimals ? Math.pow(10, decimals) : 1)
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

      await createTable(formatedValues)
      localStorage.setItem(REMATCH_PARAMS_KEY, JSON.stringify(formatedValues))
      setTableForm(genBlankTable(newHosts))
      setMostRecentTransaction(undefined)
      setInsetView('confirm-most-recent')
      hide()
    } catch (err) {
      setLoading(null)
    }
  }, [tableForm, metadata, hosts, hide, createTable, setInsetView, setMostRecentTransaction, setLoading, addHost])

  return (
    <Modal show={show} hide={hide} className='create-table-modal'>
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
            <Col>
              <Select value={tableForm['host']} onChange={changeTableForm('host')}>
                {hosts.concat(['Other']).map(host => <option key={host} value={host}>{host}</option>)}
              </Select>
              {tableForm.host === 'Other' && (
                <Input style={{ marginTop: 4 }} value={tableForm['custom-host']} onChange={changeTableForm('custom-host')} />
              )}
            </Col>
          </Row>
          {tableForm['game-type'] === 'sng' ? (
            <Row>
              <label>Players</label>
              <Select value={tableForm['min-players']} onChange={changeTableForm('min-players', true)}>
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
            <Row style={{ marginTop: -4 }}>
              <label>Invites</label>
              <ListInput values={invites} setValues={setInvites} />
            </Row>
          )}

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
  )
}

export default CreateTableModal
