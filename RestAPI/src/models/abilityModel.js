module.exports = (sequelize, DataTypes) => {
    const Ability = sequelize.define( "abilities", {
        name: {
            type: DataTypes.STRING,
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
    }, {timestamps: false}, )
    return Ability
}