import React from 'react'
import './Cards.css'
import CardItem from './CardItem'

function Cards() {
  return (
    <div className='cards'>
      <h1>New services available in the web!</h1>
      <div className='cards__container'>
        <div className='cards__wrapper'>
          <ul className='cards__items'>
            <CardItem
              src='images/img-9.jpg'
              text='Create your own competitive Pokémon team'
              label='Teams'
              path='/teams'
            />
            <CardItem
              src='images/img-2.jpg'
              text='Manage your teams'
              label='Teams'
              path='/teams'
            />
          </ul>
          <ul className='cards__items'>
            <CardItem
              src='images/img-3.jpg'
              text='Register for tournaments in the platform'
              label='Tournaments'
              path='/tournaments'
            />
            <CardItem
              src='images/img-4.jpg'
              text="Check other player's teams"
              label='Teams'
              path='/teams'
            />
            <CardItem
              src='images/img-8.jpg'
              text='And much more comming!'
              label='Home'
              path='/'
            />
          </ul>
        </div>
      </div>
    </div>
  )
}

export default Cards