import Loading from './components/Loading'
import './index.css'
import { ErrorBook } from './pages/ErrorBook'
import { FriendLinks } from './pages/FriendLinks'
import MobilePage from './pages/Mobile'
import TypingPage from './pages/Typing'
import { isOpenDarkModeAtom, refreshCustomWordBookAtom } from '@/store'
import 'animate.css'
import { useAtomValue, useSetAtom } from 'jotai'
import mixpanel from 'mixpanel-browser'
import process from 'process'
import React, { Suspense, lazy, useEffect, useState } from 'react'
import 'react-app-polyfill/stable'
import { createRoot } from 'react-dom/client'
import { HashRouter, Navigate, Route, Routes } from 'react-router-dom'
import {
  readCustomWordList,
  syncCustomWordBookCatalog,
} from '@/utils/customWordBook/localWordBookService'

const AnalysisPage = lazy(() => import('./pages/Analysis'))
const GalleryPage = lazy(() => import('./pages/Gallery-N'))
const CustomWordBookManagePage = lazy(() => import('./pages/CustomWordBook/ManagePage'))
const CustomWordBookAddPage = lazy(() => import('./pages/CustomWordBook/AddWordPage'))

const isArkWebEmbedded = REACT_APP_ARKWEB === 'true'

if (process.env.NODE_ENV === 'production') {
  mixpanel.init('bdc492847e9340eeebd53cc35f321691')
} else {
  mixpanel.init('5474177127e4767124c123b2d7846e2a', { debug: true })
}

function Root() {
  const darkMode = useAtomValue(isOpenDarkModeAtom)
  const refreshCustom = useAtomValue(refreshCustomWordBookAtom)
  const setRefreshCustom = useSetAtom(refreshCustomWordBookAtom)

  useEffect(() => {
    darkMode ? document.documentElement.classList.add('dark') : document.documentElement.classList.remove('dark')
  }, [darkMode])

  useEffect(() => {
    readCustomWordList()
    syncCustomWordBookCatalog()
    if (refreshCustom) {
      syncCustomWordBookCatalog()
      setRefreshCustom(false)
    }
  }, [refreshCustom, setRefreshCustom])

  const [isMobile, setIsMobile] = useState(!isArkWebEmbedded && window.innerWidth <= 600)

  useEffect(() => {
    if (isArkWebEmbedded) {
      return
    }
    const handleResize = () => {
      const isMobile = window.innerWidth <= 600
      if (!isMobile) {
        window.location.href = '/'
      }
      setIsMobile(isMobile)
    }

    window.addEventListener('resize', handleResize)
    return () => window.removeEventListener('resize', handleResize)
  }, [])

  return (
    <React.StrictMode>
      <HashRouter>
        <Suspense fallback={<Loading />}>
          <Routes>
            {isMobile ? (
              <Route path="/*" element={<Navigate to="/mobile" />} />
            ) : (
              <>
                <Route index element={<TypingPage />} />
                <Route path="/gallery" element={<GalleryPage />} />
                <Route path="/analysis" element={<AnalysisPage />} />
                <Route path="/error-book" element={<ErrorBook />} />
                <Route path="/friend-links" element={<FriendLinks />} />
                <Route path="/custom-wordbook/manage" element={<CustomWordBookManagePage />} />
                <Route path="/custom-wordbook/add" element={<CustomWordBookAddPage />} />
                <Route path="/*" element={<Navigate to="/" />} />
              </>
            )}
            <Route path="/mobile" element={<MobilePage />} />
          </Routes>
        </Suspense>
      </HashRouter>
    </React.StrictMode>
  )
}

const container = document.getElementById('root')

container && createRoot(container).render(<Root />)
