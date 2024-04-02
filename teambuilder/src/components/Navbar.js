import React, { useState, useEffect } from 'react'
import { Link } from 'react-router-dom'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { faBars, faTimes } from '@fortawesome/free-solid-svg-icons'
import { PokemonLogo } from './PokemonLogo'
import { Button } from './Button'
import './Navbar.css'

function Navbar() {
  const [click, setClick] = useState(false)
  const [button, setButton] = useState(true)

  const handleClick = () => setClick(!click)
  const closeMobileMenu = () => setClick(false)

  const showButton = () => {
    if (window.innerWidth <= 960) {
      setButton(false);
    } else {
      setButton(true);
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
            <li>
              <Link to='/login' className='nav-links-mobile' onClick={closeMobileMenu}>
                Log in
              </Link>
            </li>
          </ul>
          {button && <Button buttonStyle='btn--outline'>Log in</Button>}
        </div>
      </nav>
    </>
  )
}

export default Navbar
