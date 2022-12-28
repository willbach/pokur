import React, { useCallback, useState } from 'react'
import Button from '../form/Button'
import Input from '../form/Input'
import Modal from '../popups/Modal';
import Col from '../spacing/Col'
import usePokurStore from '../../store/pokurStore'
import Text from '../text/Text';
import { useWalletStore } from '@uqbar/wallet-ui';

interface JoinTableModalProps {
  show: boolean
  hide: () => void
}

const JoinTableModal = ({ show, hide }: JoinTableModalProps) => {
  const { joinTable, setJoinTableId } = usePokurStore()
  const { setInsetView, setMostRecentTransaction } = useWalletStore()
  const [tableId, setTableId] = useState('')
  const [error, setError] = useState('')

  const join = useCallback(async (e) => {
    e.preventDefault()
    try {
      setMostRecentTransaction(undefined)
      setInsetView('confirm-most-recent')
      setJoinTableId(tableId)
      await joinTable(tableId, false)
      setTableId('')
      hide()
    } catch (err) {
      setError('Invalid ID. Please try again.')
      setJoinTableId(undefined)
    }
  }, [tableId, joinTable, hide, setInsetView, setMostRecentTransaction, setJoinTableId])

  return (
    <Modal show={show} hide={hide} className='create-table-modal'>
      <Col style={{ alignItems: 'center' }}>
        <h3 style={{ marginTop: 0 }}>Join Table</h3>
        <form onSubmit={join}>
        <Col style={{ alignItems: 'center' }}>
            <Input
              label='Table ID'
              placeholder='table'
              value={tableId}
              onChange={(e) => setTableId(e.target.value)}
              style={{ minWidth: 200 }}
            />
            {Boolean(error) && <Text style={{ color: 'red' }}>{error}</Text>}
            <Button type='submit' variant='dark' style={{ marginTop: 16, alignSelf: 'center', width: 100 }}>Join</Button>
          </Col>
        </form>
      </Col>
    </Modal>
  )
}

export default JoinTableModal
