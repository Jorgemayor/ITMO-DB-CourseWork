import React from 'react'
import { useParams } from 'react-router-dom'
import '../../App.css'

function TeamPreview() {

  const {id}= useParams()
  return (
    <>
      <h1 className='team-preview'>Team Preview # {id}</h1>
    </>
  )
}

export default TeamPreview