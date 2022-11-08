import React, { useEffect, useState } from 'react';
import { BrowserRouter, Routes, Route } from "react-router-dom";
import useExplorerStore from './store/pokurStore';
import Navbar from './components/nav/Navbar';
import LoadingOverlay from './components/popups/LoadingOverlay';

import LobbyView from './views/LobbyView';
import TableView from './views/TableView';
import GameView from './views/GameView';

import './App.scss'

function App() {
  const { init, loadingText } = useExplorerStore()
  const [redirectPath, setRedirectPath] = useState('')

  useEffect(() => {
    (async () => {
      const initialRoute = await init()
      setRedirectPath(initialRoute || '')
      setRedirectPath('')
    })()
  }, []) // eslint-disable-line react-hooks/exhaustive-deps

  return (
    <BrowserRouter basename={'/apps/pokur'}>
      {/* <Navbar /> */}
      <Routes>
        <Route path="/" element={<LobbyView redirectPath={redirectPath} />} />
        <Route path="/table" element={<TableView />} />
        <Route path="/game" element={<GameView />} />
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
