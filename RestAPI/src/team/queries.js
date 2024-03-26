const getTeams = "SELECT * FROM teams"
const getTeamsById = "SELECT * FROM teams WHERE id = $1"
const getTeamsByTrainer = "SELECT * FROM teams WHERE id_trainer = $1"
const addTeam = "INSERT INTO teams (id_trainer, id_format, name, private) VALUES ($1, $2, $3, $4)"
const updateTeam = "UPDATE teams SET id_format=$2, name=$3, private=$4 WHERE id = $1"
const deleteTeam = "DELETE FROM teams WHERE id = $1"

module.exports = {
    getTeams,
    getTeamsById,
    getTeamsByTrainer,
    addTeam,
    updateTeam,
    deleteTeam,
}
