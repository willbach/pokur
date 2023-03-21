import React, { useCallback, useEffect, useState } from 'react'
import Button from '../form/Button'
import Input from '../form/Input'
import Modal from '../popups/Modal';
import Col from '../spacing/Col'
import usePokurStore from '../../store/pokurStore'
import Text from '../text/Text';
import Loader from '../popups/Loader';
import { addSig } from '../../utils/pongo';

const SpectateTableModal = () => {
  const { set, spectateTable, spectateTableInfo, showSpectate, lobby } = usePokurStore()
  const [tableId, setTableId] = useState('')
  const [host, setHost] = useState('')
  const [error, setError] = useState('')
  const [waitingToJoin, setWaitingToJoin] = useState(false)

  useEffect(() => {
    if ((!lobby[spectateTableInfo.table] || Boolean(lobby[spectateTableInfo.table].is_active)) && spectateTableInfo.table) {
      set({ joinTableId: spectateTableInfo.table })
      spectateTable(spectateTableInfo.table, spectateTableInfo.host)
        .catch(() => set({ secondaryLoadingText: null }))
    }
  }, [lobby, spectateTableInfo, set, spectateTable])

  useEffect(() => {
    setWaitingToJoin(spectateTableInfo.table.length > 0)
  }, [spectateTableInfo])

  const spectate = useCallback(async (e) => {
    e.preventDefault()

    try {
      if (lobby[tableId] && !lobby[tableId].is_active) {
        set({ spectateTableInfo: { table: tableId, host: addSig(host) } })
      } else {
        set({ joinTableId: tableId, spectateTableInfo: { table: tableId, host: addSig(host) }, secondaryLoadingText: 'Joining as a spectator...' })
        await spectateTable(tableId, addSig(host))
      }
    } catch (err) {
      setError('Invalid ID or host. Please try again.')
      set({ spectateTableInfo: { table: '', host: '' } })
    }
  }, [tableId, host, lobby, spectateTable, set])

  const hide = useCallback(() => {
    set({ showSpectate: undefined, spectateTableInfo: { table: '', host: '' } })
    setWaitingToJoin(false)
  }, [])

  return (
    <Modal show={Boolean(showSpectate)} hide={hide} className='create-table-modal'>
      <Col style={{ alignItems: 'center' }}>
        <h3 style={{ marginTop: 0 }}>Spectate Table</h3>
        <form onSubmit={spectate}>
        <Col style={{ alignItems: 'center' }}>
            <Input
              label='Table ID'
              placeholder='table'
              value={tableId}
              onChange={(e) => setTableId(e.target.value)}
              style={{ minWidth: 200 }}
            />
            <Input
              containerStyle={{ marginTop: 8 }}
              label='Host Ship'
              placeholder='host'
              value={host}
              onChange={(e) => setHost(e.target.value)}
              style={{ minWidth: 200 }}
            />
            {Boolean(error) && <Text style={{ color: 'red' }}>{error}</Text>}
            {waitingToJoin ? (
              <Col style={{ margin: 8, alignItems: 'center' }}>
                Waiting to join game as a spectator...
                <Loader style={{ marginTop: 8 }} />
              </Col>
            ) : (
              <Button type='submit' variant='dark' style={{ marginTop: 16, alignSelf: 'center', width: '100%' }}>Spectate</Button>
            )}
            <Button onClick={hide} variant='dark' style={{ marginTop: 16, alignSelf: 'center', width: '100%' }}>Cancel</Button>
          </Col>
        </form>
      </Col>
    </Modal>
  )
}

export default SpectateTableModal
