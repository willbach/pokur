import React, { useState } from 'react'
import { AccountSelector } from '@uqbar/wallet-ui'
import Row from '../spacing/Row'
import Link from './Link'
import logo from '../../assets/img/uqbar-logo-text.png'
import { isMobileCheck } from '../../utils/dimensions'

import './Navbar.scss'

const Navbar = () => {
  const [open, setOpen] = useState(false)
  const isMobile = isMobileCheck()

  return (
    <Row className='navbar'>
      <Row style={{ width: '100%', justifyContent: 'space-between' }}>
        <Link className={'nav-link logo'} href="/">
          <img src={logo} alt="Uqbar Logo" />
        </Link>
        <Row>
          <Link className={`nav-link ${window.location.pathname === `${process.env.PUBLIC_URL}/` || window.location.pathname === process.env.PUBLIC_URL ? 'selected' : ''}`} href="/">
            Home
          </Link>
        </Row>
      </Row>
    </Row>
  )
}

export default Navbar
