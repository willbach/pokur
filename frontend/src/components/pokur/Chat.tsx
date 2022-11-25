import React, { useCallback, useState } from 'react'
import { FaChevronCircleRight, FaChevronDown, FaChevronUp } from 'react-icons/fa';
import { sigil, reactRenderer } from '@tlon/sigil-js';
import usePokurStore from '../../store/pokurStore';
import Button from '../form/Button'
import Input from '../form/Input'
import Col from '../spacing/Col'
import './Chat.scss'
import Text from '../text/Text';
import Row from '../spacing/Row';

const Chat = () => {
  const { messages, sendMessage } = usePokurStore()
  const [newMsg, setNewMsg] = useState('')
  const [hide, setHide] = useState(false)

  const submitMsg = useCallback(async (e) => {
    e.preventDefault()
    await sendMessage(newMsg)
    setNewMsg('')
  }, [sendMessage, newMsg, setNewMsg])

  return (
    <Col className={`chat ${hide ? 'hidden' : 'shown'}`}>
      <Row className='hide' onClick={() => setHide(!hide)}>
        <Text>{hide ? 'Show' : 'Hide'} chat</Text>
        {hide ? <FaChevronUp /> : <FaChevronDown />}
      </Row>
      {!hide && (
       <>
        <Col className='messages'>
          {messages.map(({ from, msg }, i) => (
            <Col key={from + i} className={`message ${(window as any).ship === from.replace(/~/, '') ? 'self' : ''}`}>
              <div className='msg-text'>{msg}</div>
              <Row className='author'>
                <div className='sigil-container'>
                  {sigil({ patp: from, renderer: reactRenderer, size: 16, colors: ['black', 'white'] })}
                </div>
                <Text mono style={{ marginLeft: 4 }}>~{from.replace(/~/, '')}</Text>
              </Row>
            </Col>
          ))}
        </Col>
        <form onSubmit={submitMsg}>
          <Input value={newMsg} onChange={e => setNewMsg(e.target.value)} />
          <Button variant='dark' type='submit'>
            {/* <FaChevronCircleRight size={20} /> */}
            Send
          </Button>
        </form>
       </> 
      )}
    </Col>
  )
}

export default Chat
