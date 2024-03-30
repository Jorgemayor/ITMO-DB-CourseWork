module.exports = (sequelize, DataTypes) => {
    const Type = sequelize.define( "types", {
        name: {
            type: DataTypes.STRING(10),
            allowNull: false
        },
        generation: {
            type: DataTypes.SMALLINT,
            allowNull: false
        },
    }, {timestamps: false}, )
    return Type
}