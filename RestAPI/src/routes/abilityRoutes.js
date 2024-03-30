const { Router } = require("express")
const abilityController = require('../controllers/abilityController')
const { getAbilities, getAbilityById } = abilityController

const router = Router()

router.get("/", getAbilities)
router.get("/:id", getAbilityById)

module.exports = router