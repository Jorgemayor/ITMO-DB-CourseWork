const { Router } = require("express")
const trainerController = require('../controllers/trainerController')
const { signup, login, loggingOut } = trainerController
const trainerAuth = require('../middleware/trainerAuth')

const router = Router()

router.post('/signup', trainerAuth.saveTrainer, signup)
router.post('/login', login )
router.get('/logout', loggingOut)

module.exports = router
