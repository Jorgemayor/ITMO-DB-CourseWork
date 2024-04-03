import React, { useState, useEffect } from 'react'
import axios from 'axios'
import '../../App.css'

function Tournaments() {
  const [tournamentList, setTournamentList] = useState([])

  useEffect(() => {
    const fetchTournaments = async () => {
      try {
        const tournamentResponse = await axios.get('http://localhost:3001/api/tournament')
        setTournamentList(tournamentResponse.data)
      } catch (error) {
        console.error('Error fetching data:', error)
      }
    }

    fetchTournaments()
  }, [])

  useEffect(() => {
    console.log(tournamentList)
  }, [tournamentList])

  return (
    <>
      
    </>
  )
}

export default Tournaments