module.exports = (sequelize, DataTypes) => {
    const Item = sequelize.define( "items", {
        name: {
            type: DataTypes.STRING(30),
            allowNull: false
        },
        description: {
            type: DataTypes.TEXT,
            allowNull: false
        },
        generation: {
            type: DataTypes.SMALLINT,
            allowNull: false
        },
        unavailable_from: {
            type: DataTypes.SMALLINT,
            allowNull: true
        },
    }, {timestamps: false}, )
    return Item
}