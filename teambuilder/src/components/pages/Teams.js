import React, {useEffect, useState} from 'react'
import { useNavigate, Link } from 'react-router-dom'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { faEye, faPencil } from '@fortawesome/free-solid-svg-icons'
import '../../App.css'
import './Teams.css'
import {get} from "../../utils/fetcher";
import {useAuthSession} from "../../hooks/useAuthSession";
import Button from '@mui/material/Button';

function Teams() {
    const { session } = useAuthSession();
    const navigate = useNavigate()
    const [teamList, setTeamList] = useState([])
    const [showTrainerTeams, setShowTrainerTeams] = useState(false)

    useEffect(() => {
        const fetchTeams = async () => {
            const url = (session && showTrainerTeams) ? `/api/team/trainer/${session.session.id}` : '/api/team';
            try {
                const teamResponse = await get(url)
                setTeamList(teamResponse);
            } catch (error) {
                console.error('Error fetching data:', error)
            }
        }
        fetchTeams()
    }, [showTrainerTeams, session])

    const changeTeams = () => {
        setShowTrainerTeams(!showTrainerTeams)
    }

    return (
        <>
            { session &&
                <Button
                    onClick={changeTeams}
                    variant="contained"
                    style={{ 'backgroundColor': '#000000', 'color': '#ffffff', 'border': '2px solid #ffffff'}}>
                    {showTrainerTeams ? 'Show public teams' : 'Show trainer teams'}
                </Button>
            }
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
                                <Link to={team.id} className='navbar-logo' onClick={navigate(team.id)}>
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
