module.exports = (sequelize, DataTypes) => {
    const TrainerTournament = sequelize.define('trainers_tournaments', {
        id_tournament: {
            type: DataTypes.INTEGER,
            allowNull: false,
            primaryKey: true
        },
        id_trainer: {
            type: DataTypes.INTEGER,
            allowNull: false,
            primaryKey: true
        },
    }, {timestamps: false, freezeTableName: true});
    
    TrainerTournament.removeAttribute('tournamentId');
    return TrainerTournament
}