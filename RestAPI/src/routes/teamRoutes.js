const { Router } = require("express")
const teamController = require('../controllers/teamController')
const { getTeams, getTeamById, getTeamsByTrainer, addTeam, updateTeam, deleteTeam } = teamController

const router = Router()

router.get("/", getTeams)
router.get("/id/:id", getTeamById)
router.get("/trainer/:id", getTeamsByTrainer)
router.post("/", addTeam)
router.put("/:id", updateTeam)
router.delete("/:id", deleteTeam)

module.exports = router