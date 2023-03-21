import React, { useCallback, useEffect, useState } from 'react'
import Button from '../form/Button'
import Modal from '../popups/Modal';
import Col from '../spacing/Col'
import Row from '../spacing/Row';
import usePokurStore from '../../store/pokurStore'

import './ShareTableModal.scss'
import { Chats } from '../../types/Pongo';
import api from '../../api';
import Loader from '../popups/Loader';
import { addSig, getChatName } from '../../utils/pongo';
import Text from '../text/Text';

interface ShareTableModalProps {
  show: boolean
  hide: () => void
}

const ShareTableModal = ({ show, hide }: ShareTableModalProps) => {
  const { table, set } = usePokurStore()

  const [pongoChats, setPongoChats] = useState<Chats | null>()
  const [selectedChats, setSelectedChats] = useState<string[]>([])

  useEffect(() => {
    const getChats = async () => {
      try {
        const chats = (await api.scry<{ conversations: Chats }>({ app: 'pongo', path: '/conversations' })).conversations
        setPongoChats(chats)
      } catch {
        hide()
      }
    }

    getChats()
  }, [])

  const select = useCallback((chatId: string) => (e: any) => {
    if (selectedChats.includes(chatId)) {
      setSelectedChats(selectedChats.filter(ch => ch !== chatId))
    } else {
      setSelectedChats(selectedChats.concat([chatId]))
    }
  }, [selectedChats])

  const submitInvites = useCallback((e: any) => {
    e.preventDefault()
    e.stopPropagation()

    if (table) {
      set({ loadingText: 'Sharing table link...' })
      selectedChats.forEach(async (convo) => {
        const timesent = new Date().getTime()
        const identifier = `-${timesent}`
        const content = `/apps/pokur?invite=${table?.id}&host=${addSig(table.host_info.ship)}`
  
        try {
          const json = { 'send-message': { convo, kind: 'app-link', content, identifier, reference: null, mentions: [] } }
          await api.poke({ app: 'pongo', mark: 'pongo-action', json })
        } catch {
          window.alert('Something went wrong, please try again.')
        } finally {
          set({ loadingText: null })
        }

        setSelectedChats([])
        hide()
      })
    }
      
  }, [table, selectedChats, hide, set])

  return (
    <Modal show={show} hide={hide} className='share-table-modal' style={{ width: 300, minWidth: 300 }}>
      <Col>
        <h3 style={{ marginTop: 0 }}>Share Table Link</h3>
        <form className="select-invites" onSubmit={submitInvites}>
          {!pongoChats ?
          <Loader /> :
          <>
            <h4>Share to chat(s):</h4>
            <Col className='chats-list'>
              {Object.keys(pongoChats).map(chatId => {
                const selected = selectedChats.includes(chatId)

                return (
                  <Row key={chatId} className={`chat ${selected ? 'selected' : ''}`} onClick={select(chatId)}>
                    <input type="checkbox" checked={selected} readOnly />
                    <Text oneLine bold className='group-name'>{getChatName((window as any).ship, pongoChats[chatId])}</Text>
                  </Row>
                )
              })}
            </Col>
          </>
          }

          <Button type='submit' variant='dark' style={{ marginTop: 16 }}>Share Invite Link</Button>
        </form>
      </Col>
    </Modal>
  )
}

export default ShareTableModal
