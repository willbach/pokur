import React, { useCallback, useEffect, useState } from 'react'
import { useNavigate } from "react-router-dom"
import { AccountSelector, HardwareWallet, HotWallet, useWalletStore } from "@uqbar/wallet-ui"
import api from '../api'
import Button from '../components/form/Button'
import Input from '../components/form/Input'
import Tables from '../components/pokur/Tables';
import Col from '../components/spacing/Col'
import Row from '../components/spacing/Row';
import Text from '../components/text/Text'
import usePokurStore from '../store/pokurStore'
import logo from '../assets/img/logo192.png'
import CreateTableModal from '../components/pokur/CreateTableModal'
import JoinTableModal from '../components/pokur/JoinTableModal'
import { REQUESTED_ZIGS_KEY } from '../utils/constants'
import Modal from '../components/popups/Modal'

import './LobbyView.scss'

interface LobbyViewProps {
  redirectPath: string
}

const LobbyView = ({ redirectPath }: LobbyViewProps) => {
  const { lobby, joinTableId, game,
    addHost, subscribeToPath, setOurAddress, setLoading, setTable, zigFaucet, setJoinTableId, setSecondaryLoading } = usePokurStore()
  const { selectedAccount, assets, setInsetView } = useWalletStore()
  const nav = useNavigate()

  const [newHost, setNewHost] = useState('')
  const [hostError, setHostError] = useState(false)
  const [showCreateTableModal, setShowCreateTableModal] = useState(false)
  const [showJoinTableModal, setShowJoinTableModal] = useState(false)
  const [showZigsModal, setShowZigsModal] = useState(false)
  const [requestedZigs, setRequestedZigs] = useState(Boolean(sessionStorage.getItem(REQUESTED_ZIGS_KEY)))

  useEffect(() => {
    const lobbySub = subscribeToPath('/lobby-updates')
    return () => {
      lobbySub.then((sub: number) => api.unsubscribe(sub))
    }
  }, []) // eslint-disable-line react-hooks/exhaustive-deps

  useEffect(() => {
    if (joinTableId && lobby[joinTableId]?.players.find(p => p.includes((window as any).ship))) {
      setTable(lobby[joinTableId])
      nav('/table')
      setInsetView()
      setSecondaryLoading(null)
    } else if (joinTableId && lobby[joinTableId]?.players?.length === Number(lobby[joinTableId]?.max_players)) {
      alert('Another player joined before you, please join a different table.')
      setJoinTableId(undefined)
      setSecondaryLoading(null)
    } else if (game && game.id === joinTableId) {
      nav('/game')
    }
  }, [lobby, joinTableId, game, setInsetView, nav, setTable, setJoinTableId, setSecondaryLoading])

  useEffect(() => redirectPath ? nav(redirectPath) : undefined, [redirectPath]) // eslint-disable-line react-hooks/exhaustive-deps

  useEffect(() => {
    const table = Object.values(lobby).find(
      ({ leader, players }) => leader.includes((window as any).ship) && players.find(p => p.replace('~', '') === (window as any).ship)
    )
    if (table) {
      setInsetView()
      setTable(table)
      nav('/table?new=true')
      setLoading(null)
      setSecondaryLoading(null)
    }
  }, [lobby, setInsetView, nav, setLoading, setTable, setSecondaryLoading])

  const submitNewHost = useCallback(async (e) => {
    try {
      await addHost(`~${newHost.replace(/~/g, '')}`)
      setNewHost('')
    } catch (error) {
      setHostError(true)
      e.preventDefault()
    }
  }, [newHost, setNewHost, addHost])

  const requestZigs = useCallback(() => {
    if (selectedAccount) {
      zigFaucet(selectedAccount.rawAddress)
      sessionStorage.setItem(REQUESTED_ZIGS_KEY, 'true')
      setRequestedZigs(true)
      setShowZigsModal(true)
    }
  }, [selectedAccount, zigFaucet])

  return (
    <Col className='lobby-view'>
      <Row className='header'>
        <Row className='branding'>
          <img src={logo} alt='uqbar logo' />
          <Text mono>POKUR</Text>
        </Row>
        <Row>
          {selectedAccount && <Button style={{ marginRight: 16 }} onClick={requestZigs} disabled={requestedZigs}>
            Zig Faucet
          </Button>}
          <Button style={{ marginRight: 16 }} onClick={() => setShowJoinTableModal(true)}>
            Join Table
          </Button>
          {Object.values(assets[selectedAccount?.rawAddress || '0x0'] || {}).length > 0 && (
            <Button style={{ marginRight: 16 }} onClick={() => setShowCreateTableModal(true)}>
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
        {true ? (
          <Tables tables={Object.values(lobby)} />
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
      <CreateTableModal show={showCreateTableModal} hide={() => setShowCreateTableModal(false)} />
      <JoinTableModal show={showJoinTableModal} hide={() => setShowJoinTableModal(false)} />
      <Modal show={showZigsModal} hide={() => setShowZigsModal(false)}>
        <Col style={{ alignItems: 'center' }}>
          <h3 style={{ marginBottom: 0 }}>Zigs Requested!</h3>
          <p>You should receive ~3 ZIGs in the next few minutes.<br/>
          If you don't see it in your wallet, try refreshing the page.</p>
          <Button variant='dark' onClick={() => setShowZigsModal(false)}>OK</Button>
        </Col>
      </Modal>
    </Col>
  )
}

export default LobbyView
