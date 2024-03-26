const getMatches = "SELECT * FROM matches"
const getMatchesByIdTournament = "SELECT * FROM matches WHERE id_tournament = $1"

module.exports = {
    getMatches,
    getMatchesByIdTournament,
}
