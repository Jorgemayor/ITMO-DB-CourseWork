const { Router } = require("express")
const controller = require("./controller")

const router = Router()

router.get("/:id", controller.getSelectedPokemonByIdTeam)

module.exports = router
