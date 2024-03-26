const express = require('express')
const dotenv = require('dotenv').config()
const cookieParser = require('cookie-parser')
const db = require('./src/models')

const trainerRoutes = require ('./src/routes/trainerRoutes')

const PORT = process.env.PORT || 3000

const app = express()

// Middleware
app.use(express.json())
app.use(express.urlencoded({ extended: true }))
app.use(cookieParser())

/* const abilityRoutes = require('./src/ability/routes')
const formatRoutes = require('./src/format/routes')
const itemRoutes = require('./src/item/routes')
const matchRoutes = require('./src/match/routes')
const natureRoutes = require('./src/nature/routes')
const pokemonRoutes = require('./src/pokemon/routes')
const selectedPokemonRoutes = require('./src/selected-pokemon/routes')
const teamRoutes = require('./src/team/routes')
const tournamentRoutes = require('./src/tournament/routes')
const typeRoutes = require('./src/type/routes')

app.use('/api/v1/ability', abilityRoutes)
app.use('/api/v1/format', formatRoutes)
app.use('/api/v1/item', itemRoutes)
app.use('/api/v1/match', matchRoutes)
app.use('/api/v1/nature', natureRoutes)
app.use('/api/v1/pokemon', pokemonRoutes)
app.use('/api/v1/selectedPokemon', selectedPokemonRoutes)
app.use('/api/v1/team', teamRoutes)
app.use('/api/v1/tournament', tournamentRoutes)
app.use('/api/v1/type', typeRoutes) */

// Synchronizing the database and forcing it to false so we dont lose data
db.sequelize.sync({ force: false }).then(() => {
    console.log("db has been re sync")
})

// Routes
app.use('/api/trainer', trainerRoutes)

app.listen(PORT, () => console.log(`app listening on port ${PORT}`));