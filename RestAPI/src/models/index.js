const {Sequelize, DataTypes} = require('sequelize')

const sequelize = new Sequelize(`postgres://postgres:jorge@localhost:5432/pkmntb`, {dialect: "postgres"})

sequelize.authenticate().then(() => {
    console.log(`Database connected to pkmntb`)
}).catch((err) => {
    console.log(err)
})

const db = {}
db.Sequelize = Sequelize
db.sequelize = sequelize

db.trainers = require('./trainerModel') (sequelize, DataTypes)

module.exports = db