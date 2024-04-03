import React, {useEffect, useState} from 'react'
import { Link } from 'react-router-dom'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { faEye, faPencil } from '@fortawesome/free-solid-svg-icons'
import '../../App.css'
import './Teams.css'
import {get} from "../../utils/fetcher";

function Teams() {
    const [teamList, setTeamList] = useState([])
    const [showTrainerTeams, setShowTrainerTeams] = useState(true)
    const trainerId = 1

    useEffect(() => {
        const fetchTeams = async () => {
            const url = showTrainerTeams ? `/api/team/trainer/${trainerId}` : '/api/team';
            try {
                const teamResponse = await get(url);
                setTeamList(teamResponse);
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
                                <Link to='/' className='navbar-logo'>
                                    <FontAwesomeIcon icon={showTrainerTeams ? faPencil : faEye} style={{color: "#000000"}}/>
                                </Link>
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
