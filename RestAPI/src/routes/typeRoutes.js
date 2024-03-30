const { Router } = require("express")
const typeController = require('../controllers/typeController')
const { getTypes, getTypeById } = typeController

const router = Router()

router.get("/", getTypes)
router.get("/:id", getTypeById)

module.exports = router