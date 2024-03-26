const getSelectedPokemonByIdTeam = "SELECT * FROM selected_pokemon WHERE id_team = $1"

module.exports = {
    getSelectedPokemonByIdTeam,
}
