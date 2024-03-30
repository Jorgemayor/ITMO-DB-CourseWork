const { Router } = require("express")
const formatController = require('../controllers/formatController')
const { getFormats, getFormatById } = formatController

const router = Router()

router.get("/", getFormats)
router.get("/:id", getFormatById)

module.exports = router