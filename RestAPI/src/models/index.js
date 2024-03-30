const {Sequelize, DataTypes} = require('sequelize')

const envVars = process.env
const sequelize = new Sequelize(
    `postgres://${envVars.USER}:${envVars.PASS}@${envVars.DOMAIN_DB}:${envVars.PORT_DB}/${envVars.DB_NAME}`,
    {dialect: "postgres"}
)

sequelize.authenticate().then(() => {
    console.log(`Database connected to pkmntb`)
}).catch((err) => {
    console.log(err)
})

const db = {}
db.Sequelize = Sequelize
db.sequelize = sequelize

db.abilities = require('./abilityModel') (sequelize, DataTypes)
db.formats = require('./formatModel') (sequelize, DataTypes)
db.items = require('./itemModel') (sequelize, DataTypes)
db.matches = require('./matchModel') (sequelize, DataTypes)
db.natures = require('./natureModel') (sequelize, DataTypes)
db.pokemon = require('./pokemonModel') (sequelize, DataTypes)
db.selectedPokemon = require('./selectedPokemonModel') (sequelize, DataTypes)
db.teams = require('./teamModel') (sequelize, DataTypes)
db.tournaments = require('./tournamentModel') (sequelize, DataTypes)
db.trainers = require('./trainerModel') (sequelize, DataTypes)
db.types = require('./typeModel') (sequelize, DataTypes)

module.exports = db