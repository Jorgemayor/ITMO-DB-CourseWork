const { Router } = require("express")
const selectedPokemonController = require('../controllers/selectedPokemonController')
const { getSelectedPokemonByIdTeam, addSelectedPokemon, updateSelectedPokemon } = selectedPokemonController

const router = Router()

router.get("/:id", getSelectedPokemonByIdTeam)
router.post("/", addSelectedPokemon)
router.put("/:id", updateSelectedPokemon)

module.exports = router