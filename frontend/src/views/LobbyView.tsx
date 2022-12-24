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

import './LobbyView.scss'

interface LobbyViewProps {
  redirectPath: string
}

const LobbyView = ({ redirectPath }: LobbyViewProps) => {
  const { lobby, addHost, subscribeToPath, setOurAddress, setLoading, setTable, zigFaucet } = usePokurStore()
  const { selectedAccount, assets, setInsetView } = useWalletStore()
  const nav = useNavigate()

  const [newHost, setNewHost] = useState('')
  const [hostError, setHostError] = useState(false)
  const [showNewTableModal, setShowNewTableModal] = useState(false)

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

  const submitNewHost = useCallback(async (e) => {
    try {
      await addHost(`~${newHost.replace(/~/g, '')}`)
      setNewHost('')
    } catch (error) {
      setHostError(true)
      e.preventDefault()
    }
  }, [newHost, setNewHost, addHost])

  return (
    <Col className='lobby-view'>
      <Row className='header'>
        <Row className='branding'>
          <img src={logo} alt='uqbar logo' />
          <Text mono>POKUR</Text>
        </Row>
        <Row>
          {selectedAccount && <Button onClick={() => zigFaucet(selectedAccount.rawAddress)}>
            Zig Faucet
          </Button>}
          {Object.values(assets[selectedAccount?.rawAddress || '0x0'] || {}).length > 0 && (
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
        {true ? (
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
      <CreateTableModal show={showNewTableModal} hide={() => setShowNewTableModal(false)} />
    </Col>
  )
}

export default LobbyView
