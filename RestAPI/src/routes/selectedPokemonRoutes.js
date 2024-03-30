const { Router } = require("express")
const selectedPokemonController = require('../controllers/selectedPokemonController')
const { getSelectedPokemonByIdTeam } = selectedPokemonController

const router = Router()

router.get("/:id", getSelectedPokemonByIdTeam)

module.exports = router