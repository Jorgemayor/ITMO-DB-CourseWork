const { Router } = require("express")
const controller = require("./controller")

const router = Router()

router.get("/", controller.getTeams)
router.post("/", controller.addTeam)
router.get("/:id", controller.getTeamsByTrainer)
router.put("/:id", controller.updateTeam)
router.delete("/:id", controller.deleteTeam)

module.exports = router
