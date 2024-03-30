module.exports = (sequelize, DataTypes) => {
    const Team = sequelize.define( "teams", {
        id_trainer: {
            type: DataTypes.INTEGER,
            allowNull: false,
            references: {
                model: 'trainers',
                key: 'id',
            }
        },
        id_format: {
            type: DataTypes.INTEGER,
            allowNull: false,
            references: {
                model: 'formats',
                key: 'id',
            }
        },
        name: {
            type: DataTypes.TEXT,
            allowNull: false
        },
        private: {
            type: DataTypes.BOOLEAN,
            allowNull: true
        },
    }, {timestamps: false}, )
    return Team
}