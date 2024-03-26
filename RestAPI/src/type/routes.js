const { Router } = require("express")
const controller = require("./controller")

const router = Router()

router.get("/", controller.getTypes)
router.get("/:id", controller.getTypeById)

module.exports = router
