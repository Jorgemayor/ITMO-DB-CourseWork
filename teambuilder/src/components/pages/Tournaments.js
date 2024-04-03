import React, { useState, useEffect } from 'react'
import TextField from '@mui/material/TextField'
import Autocomplete from '@mui/material/Autocomplete'
import {get} from "../../utils/fetcher"
import '../../App.css'

function Tournaments() {
  const [tournamentList, setTournamentList] = useState([])
  const [selectedTournament, setSelectedTournament] = useState(null);
  const [tournamentDetails, setTournamentDetails] = useState({});

  useEffect(() => {
    const fetchTournaments = async () => {
      try {
        const tournamentResponse = await get('http://localhost:3001/api/tournament')
        setTournamentList(tournamentResponse)
      } catch (error) {
        console.error('Error fetching data:', error)
      }
    }

    fetchTournaments()
  }, [])

  const handleTournamentChange = async (event, value) => {
    setSelectedTournament(value)
    if (value) {
      try {
        const tournamentDetailsResponse = await get(`http://localhost:3001/api/tournament/${value}`)
        setTournamentDetails(tournamentDetailsResponse.data)
      } catch (error) {
        console.error('Error fetching tournament details:', error)
      }
    } else {
      setTournamentDetails({})
    }
  }

  return (
    <>
      { tournamentList &&
        <div>
          <Autocomplete
            disablePortal
            id="combo-box-demo"
            options={tournamentList.map(tournament => tournament.name)}
            value={selectedTournament}
            onChange={handleTournamentChange}
            sx={{ width: 300 }}
            renderInput={(params) => <TextField {...params} label="Tournament" />}
          />
          {selectedTournament && <div>
            <h2>Tournament Details</h2>
            <p>Name: {selectedTournament}</p>
            <p>Number of players registered: {tournamentDetails.players}</p>
            <p>Format: {tournamentDetails.format}</p>
            <p>Generation: {tournamentDetails.generation}</p>
          </div> }
        </div>
      }
    </>
  )
}

export default Tournaments