module.exports = (sequelize, DataTypes) => {
    const Trainer = sequelize.define( "trainer", {
        username: {
            type: DataTypes.STRING,
            unique: true,
            allowNull: false
        },
        email: {
            type: DataTypes.STRING,
            unique: true,
            isEmail: true,
            allowNull: false
        },
        password: {
            type: DataTypes.STRING,
            allowNull: false
        },
    }, {timestamps: true}, )
    return Trainer
}