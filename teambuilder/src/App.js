import React from 'react'
import Navbar from './components/Navbar'
import './App.css'
import Home from './components/pages/Home'
import Teams from './components/pages/Teams'
import Tournaments from './components/pages/Tournaments'
import Login from './components/pages/Login'
import { BrowserRouter as Router, Route, Routes } from 'react-router-dom' 

function App() {
  return (
    <>
      <Router>
        <Navbar/>
        <Routes>
          <Route path='/' exact element={ <Home />}></Route>
          <Route path='/teams' element={<Teams/>}></Route>
          <Route path='/tournaments' element={<Tournaments/>}></Route>
          <Route path='/login' element={<Login/>}></Route>
        </Routes>
      </Router>
    </>
  )
}

export default App
