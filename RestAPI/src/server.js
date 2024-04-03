const express = require('express')
const dotenv = require('dotenv').config()
const cors = require('cors')
const cookieParser = require('cookie-parser')
const db = require('./models')

const abilityRoutes = require ('./routes/abilityRoutes')
const formatRoutes = require ('./routes/formatRoutes')
const itemRoutes = require ('./routes/itemRoutes')
const matchRoutes = require('./routes/matchRoutes')
const natureRoutes = require('./routes/natureRoutes')
const pokemonRoutes = require('./routes/pokemonRoutes')
const selectedPokemonRoutes = require('./routes/selectedPokemonRoutes')
const teamRoutes = require('./routes/teamRoutes')
const tournamentRoutes = require('./routes/tournamentRoutes')
const trainerRoutes = require ('./routes/trainerRoutes')
const typeRoutes = require('./routes/typeRoutes')

const PORT = process.env.PORT || 3000

const app = express()

// Middleware
app.use(cors())
app.use(express.json())
app.use(express.urlencoded({ extended: true }))
app.use(cookieParser())

// Synchronizing the database and forcing it to false so we dont lose data
db.sequelize.sync({ force: false }).then(() => {
    console.log("db has been re sync")
})

// Routes
app.use('/api/ability', abilityRoutes)
app.use('/api/format', formatRoutes)
app.use('/api/item', itemRoutes)
app.use('/api/match', matchRoutes)
app.use('/api/nature', natureRoutes)
app.use('/api/pokemon', pokemonRoutes)
app.use('/api/selectedPokemon', selectedPokemonRoutes)
app.use('/api/team', teamRoutes)
app.use('/api/tournament', tournamentRoutes)
app.use('/api/trainer', trainerRoutes)
app.use('/api/type', typeRoutes)

app.listen(PORT, () => console.log(`app listening on port ${PORT}`))
