import React from 'react'
import './Footer.css'
import { Link } from 'react-router-dom'
import { PokemonLogo } from './PokemonLogo'

function Footer() {
  return (
    <div className='footer-container'>
      <section className='footer-subscription'>
        <p className='footer-subscription-heading'>
          Support the best team builder tool on BuyMeACoffee!
        </p>
      </section>
      <section className='social-media'>
        <div className='social-media-wrap'>
          <div className='footer-logo'>
            <Link to='/' className='social-logo'>
              PKMN TB <PokemonLogo/>
            </Link>
          </div>
          <small className='website-rights'>PKMN TB © 2024</small>
        </div>
      </section>
    </div>
  )
}

export default Footer