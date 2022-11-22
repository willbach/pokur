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
      <h3>Tables ({tables.length})</h3>
      <Row className='tables'>
        {tables.map(t => (
          <Col key={t.id} className='table-tile' onClick={join(t.id)}>
            <Row>
              <Text style={{ marginRight: 4 }}>Creator:</Text>
              <Text>{t.leader}</Text>
            </Row>
            <Row>
              <Text style={{ marginRight: 4 }}>Type:</Text>
              <Text>{t.game_type.type}</Text>
            </Row>
            <Row>
              <Text style={{ marginRight: 4 }}>Stack:</Text>
              <Text>{t.game_type.starting_stack}</Text>
            </Row>
            <Row>
              <Text style={{ marginRight: 4 }}>Players:</Text>
              <Text>{t.players.length}/{t.max_players} (min {t.min_players})</Text>
            </Row>
            <Row>
              <Text style={{ marginRight: 4 }}>Turn Time:</Text>
              <Text>{formatTimeLimit(t.turn_time_limit)}</Text>
            </Row>
          </Col>
        ))}
      </Row>
    </>
  )
}

export default Tables
