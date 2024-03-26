const { Router } = require("express")
const controller = require("./controller")

const router = Router()

router.get("/", controller.getPokemon)
router.get("/:id", controller.getPokemonById)

module.exports = router
