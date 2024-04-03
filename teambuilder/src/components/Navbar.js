import React, { useState, useEffect } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { faBars, faTimes } from '@fortawesome/free-solid-svg-icons'
import { PokemonLogo } from './PokemonLogo'
import { Button } from './Button'
import './Navbar.css'
import {useAuthSession} from "../hooks/useAuthSession";
import {get} from "../utils/fetcher";

function Navbar() {
  const { session, logout } = useAuthSession();
  const [click, setClick] = useState(false)
  const [showButtons, setShowButtons] = useState(true)
  const handleClick = () => setClick(!click)
  const closeMobileMenu = () => setClick(false)
  let navigate  = useNavigate();

  const showButton = () => {
    if (window.innerWidth <= 960) {
      setShowButtons(false);
    } else {
      setShowButtons(true);
    }
  };

  const handleLogout = async () => {
    try {
      logout();
      closeMobileMenu();
      await get('/api/trainer/logout');
      navigate ('/');
    } catch (e) {
        console.error('Error logging out:', e);
    }
  };

  useEffect(() => {
    showButton();
  }, []);

  window.addEventListener('resize', showButton);

  return (
    <>
      <nav className='navbar'>
        <div className='navbar-container'>
          <Link to='/' className='navbar-logo' onClick={closeMobileMenu}>
            PKMN TB <PokemonLogo/>
          </Link>
          <div className='menu-icon' onClick={handleClick}>
            <FontAwesomeIcon icon={click ? faTimes : faBars} />
          </div>
          <ul className={click ? 'nav-menu active' : 'nav-menu'}>
            <li className='nav-item'>
              <Link to='/' className='nav-links' onClick={closeMobileMenu}>
                Home
              </Link>
            </li>
            <li className='nav-item'>
              <Link to='/teams' className='nav-links' onClick={closeMobileMenu}>
                Teams
              </Link>
            </li>
            <li className='nav-item'>
              <Link to='/tournaments' className='nav-links' onClick={closeMobileMenu}>
                Tournaments
              </Link>
            </li>
          </ul>
          {showButtons && (
              <>
                  {session ? (
                      <Button onClick={handleLogout} buttonStyle='btn--outline'>Log out</Button>
                  ) : (
                      <>
                          <Button to="/login" onClick={closeMobileMenu} buttonStyle='btn--outline'>Log in</Button>
                          <Button to="/register" onClick={closeMobileMenu} buttonStyle='btn--outline'>Sign up</Button>
                      </>
                  )}
              </>
          )}
        </div>
      </nav>
    </>
  )
}

export default Navbar
