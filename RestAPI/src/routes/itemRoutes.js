const { Router } = require("express")
const itemController = require('../controllers/itemController')
const { getItems, getItemById } = itemController

const router = Router()

router.get("/", getItems)
router.get("/:id", getItemById)

module.exports = router