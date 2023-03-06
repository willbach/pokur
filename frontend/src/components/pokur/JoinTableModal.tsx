import React, { useCallback, useEffect, useState } from 'react'
import Button from '../form/Button'
import Input from '../form/Input'
import Modal from '../popups/Modal';
import Col from '../spacing/Col'
import usePokurStore from '../../store/pokurStore'
import Text from '../text/Text';
import { useWalletStore } from '@uqbar/wallet-ui';
import Loader from '../popups/Loader';
import { fromUd, numToUd, tokenAmount } from '../../utils/number';
import { Table } from '../../types/Table';

interface JoinTableModalProps {
  show: boolean
  hide: () => void
}

const JoinTableModal = ({ show, hide }: JoinTableModalProps) => {
  const { joinTable, set, lobby } = usePokurStore()
  const { setInsetView, setMostRecentTransaction } = useWalletStore()
  const [tableId, setTableId] = useState('')
  const [error, setError] = useState('')
  const [invited, setInvited] = useState(false)
  const [waiting, setWaiting] = useState(false)
  const [buyInAmount, setBuyInAmount] = useState('')

  useEffect(() => {
    const params = new URLSearchParams(window.location.search)
    const inviteTable = params.get('invite')

    if (inviteTable) {
      setTableId(inviteTable)
      setInvited(true)
      setWaiting(!lobby[inviteTable])
    }
  }, [])

  useEffect(() => {
    if (lobby[tableId]) {
      setWaiting(false)
    }
  }, [lobby, tableId])

  const join = useCallback(async (e) => {
    e.preventDefault()
    try {
      setMostRecentTransaction(undefined)
      setInsetView('confirm-most-recent')
      set({ joinTableId: tableId })
      const buyIn = lobby[tableId]?.game_type.type === 'sng' ? '0' :
        numToUd(Number(buyInAmount) * Math.pow(10, 18))
      await joinTable(tableId, buyIn, false)
      setTableId('')
      hide()
    } catch (err) {
      setError('Invalid ID. Please try again.')
      set({ joinTableId: undefined })
    }
  }, [tableId, lobby, buyInAmount, joinTable, hide, setInsetView, setMostRecentTransaction, set])

  const targetTable : Table | undefined = lobby[tableId]
  const minBuy = targetTable && 'min_buy' in targetTable.game_type ? fromUd(targetTable.game_type.min_buy) : undefined
  const maxBuy = targetTable && 'max_buy' in targetTable.game_type ? fromUd(targetTable.game_type.max_buy) : undefined
  const buyIn = targetTable?.tokenized ? (
    'min_buy' in targetTable?.game_type ? `${Number(targetTable.game_type.min_buy)} - ${Number(targetTable.game_type.max_buy)} ${targetTable.tokenized.symbol}` :
    `${tokenAmount(targetTable?.tokenized?.amount)} ${targetTable?.tokenized.symbol}`
  ) : 'none'

  return (
    <Modal show={show} hide={hide} className='create-table-modal'>
      <Col style={{ alignItems: 'center' }}>
        <h3 style={{ marginTop: 0 }}>Join Table</h3>
        {invited && <h4>You have been invited to join a table!</h4>}
        <form onSubmit={join}>
          <Col style={{ alignItems: 'center' }}>
            <Input
              label='Table ID'
              placeholder='table'
              value={tableId}
              onChange={(e) => setTableId(e.target.value)}
              style={{ minWidth: 200 }}
            />
            {Boolean(targetTable) && <Text style={{ alignSelf: 'flex-start', marginTop: 4, marginBottom: 4 }}>Buy-in: {buyIn}</Text>}
            {targetTable?.game_type.type === 'cash' && (
              <Input
                label={`Buy-in amount`}
                placeholder='Buy-in amount'
                value={buyInAmount}
                min={minBuy}
                max={maxBuy}
                onChange={(e) => setBuyInAmount(e.target.value.replace(/[^0-9.]/g, ''))}
                required
              />
            )}
            {Boolean(error) && <Text style={{ color: 'red' }}>{error}</Text>}
            {waiting && <Loader style={{ margin: 8 }} />}
            <Button disabled={!targetTable} type='submit' variant='dark' style={{ marginTop: 16, alignSelf: 'center', width: '100%' }}>Join</Button>
            <Button onClick={hide} variant='dark' style={{ marginTop: 16, alignSelf: 'center', width: '100%' }}>Cancel</Button>
          </Col>
        </form>
      </Col>
    </Modal>
  )
}

export default JoinTableModal
