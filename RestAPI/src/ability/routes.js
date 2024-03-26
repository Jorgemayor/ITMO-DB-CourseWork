const { Router } = require("express")
const controller = require("./controller")

const router = Router()

router.get("/", controller.getAbilities)
router.get("/:id", controller.getAbilityById)

module.exports = router
