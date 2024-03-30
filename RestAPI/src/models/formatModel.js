module.exports = (sequelize, DataTypes) => {
    const Format = sequelize.define( "formats", {
        name: {
            type: DataTypes.STRING(30),
            allowNull: false
        },
        generation: {
            type: DataTypes.SMALLINT,
            allowNull: false
        },
        year: {
            type: DataTypes.SMALLINT,
            allowNull: false
        },
        rules: {
            type: DataTypes.JSON,
            allowNull: false
        },
    }, {timestamps: false}, )
    return Format
}