const getPokemon = "SELECT * FROM pokemon"
const getPokemonById = "SELECT * FROM pokemon WHERE id = $1"

module.exports = {
    getPokemon,
    getPokemonById,
}
