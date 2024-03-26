const { Router } = require("express")
const controller = require("./controller")

const router = Router()

router.get("/", controller.getTrainers)
router.get("/login", controller.logIn)
router.post("/signUp", controller.signUp)

module.exports = router
