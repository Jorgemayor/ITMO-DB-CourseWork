module.exports = (sequelize, DataTypes) => {
    const Nature = sequelize.define( "natures", {
        name: {
            type: DataTypes.STRING(15),
            allowNull: false
        },
        stat_up: {
            type: DataTypes.STRING(3),
            allowNull: false
        },
        stat_down: {
            type: DataTypes.STRING(3),
            allowNull: false
        },
    }, {timestamps: false}, )
    return Nature
}