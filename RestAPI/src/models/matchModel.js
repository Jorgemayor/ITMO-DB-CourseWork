module.exports = (sequelize, DataTypes) => {
    const Match = sequelize.define( "matches", {
        id_tournament: {
            type: DataTypes.INTEGER,
            allowNull: false,
            primaryKey: true,
            references: {
                model: 'tournaments',
                key: 'id'
            }
        },
        id_team_1: {
            type: DataTypes.INTEGER,
            allowNull: false,
            primaryKey: true,
            references: {
                model: 'teams',
                key: 'id'
            }
        },
        id_team_2: {
            type: DataTypes.INTEGER,
            allowNull: false,
            primaryKey: true,
            references: {
                model: 'teams',
                key: 'id'
            }
        },
        winner: {
            type: DataTypes.SMALLINT,
            allowNull: true
        },
    }, {timestamps: false}, )
    return Match
}