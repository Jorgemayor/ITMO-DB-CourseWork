const { Router } = require("express")
const pokemonController = require('../controllers/pokemonController')
const { getPokemon, getPokemonById } = pokemonController

const router = Router()

router.get("/", getPokemon)
router.get("/:id", getPokemonById)

module.exports = router