import React, { useCallback } from 'react'
import { useNavigate } from 'react-router-dom'
import usePokurStore from '../../store/pokurStore'
import { Table } from '../../types/Table'
import { formatTimeLimit } from '../../utils/format'
import Col from '../spacing/Col'
import Row from '../spacing/Row'
import Text from '../text/Text'

import './Tables.scss'

interface TablesProps {
  tables: Table[]
}

const Tables = ({ tables }: TablesProps) => {
  const { joinTable, getTable } = usePokurStore()
  const nav = useNavigate()

  const join = useCallback((tableId) => async () => {
    await joinTable(tableId)
    await getTable()
    nav('/table')
  }, [joinTable, getTable, nav])

  return (
    <>
      <h3>Tables</h3>
      <Row className='tables'>
        {tables.map(t => (
          <Col key={t.id} className='table-tile' onClick={join(t.id)}>
            <Row>
              <Text>Creator:</Text>
              <Text>{t.leader}</Text>
            </Row>
            <Row>
              <Text>Type:</Text>
              <Text>{t.game_type.type}</Text>
            </Row>
            <Row>
              <Text>Stack:</Text>
              <Text>{t.game_type.starting_stack}</Text>
            </Row>
            <Row>
              <Text>Player Min/Max:</Text>
              <Text>{t.min_players} / {t.max_players}</Text>
            </Row>
            <Row>
              <Text>Turn Time:</Text>
              <Text>{formatTimeLimit(t.turn_time_limit)}</Text>
            </Row>
          </Col>
        ))}
      </Row>
    </>
  )
}

export default Tables
