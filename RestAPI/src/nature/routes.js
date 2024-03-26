const { Router } = require("express")
const controller = require("./controller")

const router = Router()

router.get("/", controller.getNatures)
router.get("/:id", controller.getNatureById)

module.exports = router
