import React, { useState, useEffect } from 'react'
import axios from 'axios'
import '../../App.css'

function Teams() {

  const [teamList, setTeamList] = useState({})

  useEffect(() => {
    const fetchTeams = async () => {
      try {
        const teamResponse = await axios.get('localhost:3001/api/team')
        setTeamList(teamResponse.data)
        console.log(teamList)
      } catch (error) {
        console.error('Error fetching data:', error)
      }
    }

    fetchTeams()
  }, [])

  return (
    <>
      <h1 className='teams'>Teams</h1>
    </>
  )
}

export default Teams