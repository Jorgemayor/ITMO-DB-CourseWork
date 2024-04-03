const { Router } = require("express")
const tournamentController = require('../controllers/tournamentController')
const { getTournaments, getTournamentTrainers } = tournamentController

const router = Router()

router.get("/", getTournaments)
router.get("/:id", getTournamentTrainers)

module.exports = router