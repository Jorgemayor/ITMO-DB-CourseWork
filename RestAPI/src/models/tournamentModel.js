module.exports = (sequelize, DataTypes) => {
    const Tournament = sequelize.define( "tournaments", {
        name: {
            type: DataTypes.STRING(25),
            allowNull: false
        },
        id_format: {
            type: DataTypes.INTEGER,
            allowNull: false,
            references: {
                model: 'formats',
                key: 'id',
            }
        },
    }, {timestamps: false}, )
    return Tournament
}