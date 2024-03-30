const { Router } = require("express")
const natureController = require('../controllers/natureController')
const { getNatures, getNatureById } = natureController

const router = Router()

router.get("/", getNatures)
router.get("/:id", getNatureById)

module.exports = router