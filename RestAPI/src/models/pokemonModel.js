module.exports = (sequelize, DataTypes) => {
    const Pokemon = sequelize.define( "pokemon", {
        name: {
            type: DataTypes.TEXT,
            allowNull: false
        },
        base_stats: {
            type: DataTypes.JSON,
            allowNull: false
        },
        id_type_1: {
            type: DataTypes.SMALLINT,
            allowNull: false,
            references: {
                model: 'types',
                key: 'id',
            }
        },
        id_type_2: {
            type: DataTypes.SMALLINT,
            allowNull: true,
            references: {
                model: 'types',
                key: 'id',
            }
        },
        id_ability_1: {
            type: DataTypes.INTEGER,
            allowNull: false,
            references: {
                model: 'abilities',
                key: 'id',
            }
        },
        id_ability_2: {
            type: DataTypes.INTEGER,
            allowNull: true,
            references: {
                model: 'abilities',
                key: 'id',
            }
        },
        id_hidden_ability: {
            type: DataTypes.INTEGER,
            allowNull: true,
            references: {
                model: 'abilities',
                key: 'id',
            }
        },
        generation: {
            type: DataTypes.SMALLINT,
            allowNull: true
        },
    }, { timestamps: false, freezeTableName: true }, )
    return Pokemon
}