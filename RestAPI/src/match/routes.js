const { Router } = require("express")
const controller = require("./controller")

const router = Router()

router.get("/", controller.getMatches)
router.get("/:id", controller.getMatchesByIdTournament)

module.exports = router
