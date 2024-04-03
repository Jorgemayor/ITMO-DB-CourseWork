const {Sequelize, DataTypes} = require('sequelize')

const envVars = process.env
const sequelize = new Sequelize(
    `postgres://${envVars.PG_USER}:${envVars.PG_PASS}@${envVars.DOMAIN_DB}:${envVars.PORT_DB}/${envVars.DB_NAME}`,
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
db.trainerTournaments = require('./trainerTournamentModel') (sequelize, DataTypes)

db.teams.belongsTo(db.formats, { foreignKey: 'id_format' })
db.selectedPokemon.belongsTo(db.pokemon, { foreignKey: 'id_pokemon' })
db.selectedPokemon.belongsTo(db.natures, { foreignKey: 'id_nature' })
db.selectedPokemon.belongsTo(db.items, { foreignKey: 'id_item' })

db.tournaments.hasMany(db.trainerTournaments);
db.trainerTournaments.belongsTo(db.tournaments);

db.trainers.hasMany(db.trainerTournaments);
db.trainerTournaments.belongsTo(db.trainers);

module.exports = db
