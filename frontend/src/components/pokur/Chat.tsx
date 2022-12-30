import React, { useCallback, useRef, useState } from 'react'
import { FaChevronDown, FaChevronUp } from 'react-icons/fa';
import usePokurStore from '../../store/pokurStore';
import Button from '../form/Button'
import Input from '../form/Input'
import Col from '../spacing/Col'
import Text from '../text/Text';
import Row from '../spacing/Row';
import { renderShip } from '../../utils/player';

import './Chat.scss'

interface ChatProps {
  height: number;
  className?: string;
}

const Chat = ({ height, className = '' }: ChatProps) => {
  const { messages, sendMessage } = usePokurStore()
  const scrollRef = useRef<HTMLDivElement>(null)
  const [newMsg, setNewMsg] = useState('')
  const [hide, setHide] = useState(false)
  const [atBottom, setAtBottom] = useState(true)

  const submitMsg = useCallback(async (e) => {
    e.preventDefault()
    await sendMessage(newMsg)
    setNewMsg('')
  }, [sendMessage, newMsg, setNewMsg])

  const onScroll = useCallback((e: any) => {
    setAtBottom((e.target?.scrollTop ?? 0) >= 0)
  }, [])

  const scrollToEnd = useCallback(() => {
    scrollRef.current?.scrollTo({ top: 0 })
  }, [scrollRef])

  return (
    <Col className={`chat ${hide ? 'hidden' : 'shown'} ${className}`} style={{ maxHeight: height }}>
      <Row className='hide' onClick={() => setHide(!hide)}>
        <Text>{hide ? 'Show' : 'Hide game'} chat</Text>
        {hide ? <FaChevronUp /> : <FaChevronDown />}
      </Row>
      {!hide && (
      <>
        <div className='messages' onScroll={onScroll} ref={scrollRef}>
          {messages.map(({ from, msg }, i, arr) => from === 'game-update' ? (
            <Row key={from + i} className='game-update'>
              <span className='msg-text'>{msg}</span>
            </Row>
          ) : (
            <Row key={from + i} className={`message ${(window as any).ship === from.replace(/~/, '') ? 'self' : ''}`}>
              {(from !== arr[i + 1]?.from) && <span className='author'>
                <Text mono style={{ marginLeft: 4 }}>{renderShip(from)}:</Text>
              </span>}
              <span className='msg-text'>{msg}</span>
            </Row>
          ))}
        </div>
        <form onSubmit={submitMsg}>
          <Input value={newMsg} onChange={e => setNewMsg(e.target.value)} />
          <Button variant='dark' type='submit'>
            {/* <FaChevronCircleRight size={20} /> */}
            Send
          </Button>
        </form>
      </> 
      )}
      {!atBottom && (
        <Button className='scroll-button' onClick={scrollToEnd}>
          <FaChevronDown />
        </Button>
      )}
    </Col>
  )
}

export default Chat
