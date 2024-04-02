import React, { useState, useEffect } from 'react'
import axios from 'axios'
import '../../App.css'
import './Teams.css'

function Teams() {

  const [teamList, setTeamList] = useState([])
  const [showTrainerTeams, setShowTrainerTeams] = useState(true)
  const trainerId = 1

  useEffect(() => {
    const fetchTeams = async () => {
      try {
        let url = ''
        if (showTrainerTeams) {
          url = `http://localhost:3001/api/team/trainer/${trainerId}`
        } else {
          url = 'http://localhost:3001/api/team'
        }
        const teamResponse = await axios.get(url)
        setTeamList(teamResponse.data)
      } catch (error) {
        console.error('Error fetching data:', error)
      }
    }

    fetchTeams()
  }, [showTrainerTeams])

  const changeTeams = () => {
    setShowTrainerTeams(!showTrainerTeams)
  }

  return (
    <>
      <button onClick={changeTeams}>
        {showTrainerTeams ? 'Show public teams' : 'Show trainer teams'}
      </button>
      <div className="table-container">
        <h2>Teams</h2>
        <table className="table">
          <thead>
            <tr>
              <th>Name</th>
              <th>Format</th>
              {showTrainerTeams && <th>Privacy</th>}
              <th>Generation</th>
              <th>Action</th>
            </tr>
          </thead>
          <tbody>
            {teamList && teamList.map(team => (
              <tr key={team.id}>
                <td>{team.name}</td>
                <td>{team.format.name}</td>
                {showTrainerTeams && <td>{team.private ? "Yes" : "No"}</td>}
                <td>{team.format.generation}</td>
                <td>
                  <button>
                    {showTrainerTeams ? 'Edit' : 'See'}
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </>
  )
}

export default Teams