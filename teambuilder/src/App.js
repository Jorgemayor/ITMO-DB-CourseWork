import React from 'react'
import Navbar from './components/Navbar'
import Footer from './components/Footer'
import Home from './components/pages/Home'
import Teams from './components/pages/Teams'
import TeamPreview from './components/pages/TeamPreview'
import Tournaments from './components/pages/Tournaments'
import Login from './components/pages/Login'
import { BrowserRouter as Router, Route, Routes } from 'react-router-dom'
import './App.css'
import Register from "./components/pages/Register";

function App() {
  return (
    <>
      <Router>
        <Navbar/>
        <Routes>
          <Route path='/' exact element={ <Home />}></Route>
          <Route path='/teams' element={<Teams/>}></Route>
          <Route path='/teams/:id' element={<TeamPreview/>}></Route>
          <Route path='/tournaments' element={<Tournaments/>}></Route>
          <Route path='/login' element={<Login/>}></Route>
          <Route path='/register' element={<Register/>}></Route>
        </Routes>
        <Footer/>
      </Router>
    </>
  )
}

export default App
