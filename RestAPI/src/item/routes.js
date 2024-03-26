const { Router } = require("express")
const controller = require("./controller")

const router = Router()

router.get("/", controller.getItems)
router.get("/:id", controller.getItemById)

module.exports = router
