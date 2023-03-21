import React, { useCallback, useState } from 'react'
import Button from '../form/Button'
import Input from '../form/Input'
import Modal from '../popups/Modal';
import Col from '../spacing/Col'
import usePokurStore from '../../store/pokurStore'
import Text from '../text/Text';
import { useWalletStore, ZIGS_CONTRACT } from '@uqbar/wallet-ui';
import { addSig } from '../../utils/pongo';

interface AddHostModalProps {
  show: boolean
  hide: () => void
}

const AddHostModal = ({ show, hide }: AddHostModalProps) => {
  const { addHost, becomeHost, removeHost, hosts, set } = usePokurStore()
  const { selectedAccount, assets } = useWalletStore()
  const [host, setHost] = useState('')
  const [error, setError] = useState('')

  // 0x4f2d.5f04.07c5.cdb0.cd34.6adc.8bf5.0c7e.8e19.ddc8
  const hasZigs = Boolean(selectedAccount && Object.values(assets[selectedAccount?.rawAddress || ''] || {})?.[0]?.contract === ZIGS_CONTRACT)
  const isHost = hosts.includes(addSig((window as any).ship))

  const change = useCallback(async (e) => {
    e.preventDefault()
    try {
      await addHost(addSig(host))
      setHost('')
      hide()
    } catch (err) {
      setError('Invalid ID. Please try again.')
      setHost('')
    }
  }, [host, setHost, addHost, hide])

  const become = useCallback(async (e) => {
    e.preventDefault()
    if (selectedAccount?.rawAddress) {
      set({ secondaryLoadingText: 'Becoming a host...' })
      try {
        await becomeHost(selectedAccount.rawAddress)
        hide()
      } catch (err) {
        setError('Error trying to become host, please ensure you have zigs and try again.')
        setHost('')
      }
      set({ secondaryLoadingText: null})
    }
  }, [selectedAccount, becomeHost, hide, set])

  const removeSelf = useCallback(async (e) => {
    set({ secondaryLoadingText: 'Removing you as a host...' })
    e.preventDefault()
    try {
      await removeHost(addSig((window as any).ship))
      hide()
    } catch (err) {
      setError('Error trying to remove host, please try again.')
      setHost('')
    }
    set({ secondaryLoadingText: null })
  }, [removeHost, hide, set])

  return (
    <Modal show={show} hide={hide} className='create-table-modal'>
      <Col style={{ alignItems: 'center' }}>
        <h3 style={{ marginTop: 0 }}>Add Host</h3>
        <form onSubmit={change}>
        <Col style={{ alignItems: 'center' }}>
            <Input
              label='New Host'
              placeholder='Host ship'
              value={host}
              onChange={(e) => { setHost(e.target.value); setError('') }}
              style={{ minWidth: 200 }}
            />
            {Boolean(error) && <Text style={{ color: 'red', maxWidth: 200 }}>{error}</Text>}
            <Button type='submit' variant='dark' style={{ marginTop: 16, alignSelf: 'center', width: '100%' }}>Add Host</Button>
            {hasZigs && !isHost && <Button onClick={become} variant='dark' style={{ marginTop: 16, alignSelf: 'center', width: '100%' }}>Become Host</Button>}
            {isHost && <Button onClick={removeSelf} variant='dark' style={{ marginTop: 16, alignSelf: 'center', width: '100%' }}>Remove Self as Host</Button>}
            <Button onClick={hide} variant='dark' style={{ marginTop: 16, alignSelf: 'center', width: '100%' }}>Cancel</Button>
          </Col>
        </form>
      </Col>
    </Modal>
  )
}

export default AddHostModal
