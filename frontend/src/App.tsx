import React, { useEffect, useState } from 'react';
import { BrowserRouter, Routes, Route } from "react-router-dom";
import { useWalletStore } from '@uqbar/wallet-ui';

import useExplorerStore from './store/pokurStore';
import LoadingOverlay from './components/popups/LoadingOverlay';
import LobbyView from './views/LobbyView';
import TableView from './views/TableView';
import GameView from './views/GameView';

import './App.scss'

function App() {
  const { init, setOurAddress, getHosts, loadingText } = useExplorerStore()
  const { initWallet, selectedAccount } = useWalletStore()
  const [redirectPath, setRedirectPath] = useState('')

  useEffect(() => {
    (async () => {
      initWallet({ prompt: true })
      getHosts()
      const initialRoute = await init()
      setRedirectPath(initialRoute || '')
      setRedirectPath('')
    })()
  }, []) // eslint-disable-line react-hooks/exhaustive-deps

  useEffect(() => {
    if (selectedAccount) setOurAddress(selectedAccount.rawAddress)
  }, [selectedAccount, setOurAddress])

  return (
    <BrowserRouter basename={'/apps/pokur'}>
      {/* <Navbar /> */}
      <Routes>
        <Route path="/" element={<LobbyView redirectPath={redirectPath} />} />
        <Route path="/table" element={<TableView redirectPath={redirectPath} />} />
        <Route path="/game" element={<GameView redirectPath={redirectPath} />} />
        <Route
          path="*"
          element={
            <main style={{ padding: "1rem" }}>
              <p>There's nothing here!</p>
            </main>
          }
        />
      </Routes>
      <LoadingOverlay loading={Boolean(loadingText)} text={loadingText || ''} />
    </BrowserRouter>
  );
}

export default App;
