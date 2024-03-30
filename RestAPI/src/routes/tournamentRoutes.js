const { Router } = require("express")
const tournamentController = require('../controllers/tournamentController')
const { getTournaments } = tournamentController

const router = Router()

router.get("/", getTournaments)

module.exports = router