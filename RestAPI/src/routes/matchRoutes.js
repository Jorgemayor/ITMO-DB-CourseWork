const { Router } = require("express")
const matchController = require('../controllers/matchController')
const { getMatches, getMatchesByIdTournament } = matchController

const router = Router()

router.get("/", getMatches)
router.get("/:id", getMatchesByIdTournament)

module.exports = router