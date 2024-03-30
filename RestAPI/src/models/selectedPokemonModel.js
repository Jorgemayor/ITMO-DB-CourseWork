module.exports = (sequelize, DataTypes) => {
    const SelectedPokemon = sequelize.define( "selected_pokemon", {
        id_pokemon: {
            type: DataTypes.INTEGER,
            allowNull: false,
            references: {
                model: 'pokemon',
                key: 'id',
            }
        },
        id_team: {
            type: DataTypes.INTEGER,
            allowNull: false,
            references: {
                model: 'teams',
                key: 'id',
            }
        },
        ability: {
            type: DataTypes.SMALLINT,
            allowNull: false
        },
        id_nature: {
            type: DataTypes.INTEGER,
            allowNull: false,
            references: {
                model: 'natures',
                key: 'id',
            }
        },
        id_item: {
            type: DataTypes.INTEGER,
            allowNull: false,
            references: {
                model: 'items',
                key: 'id',
            }
        },
        moveset: {
            type: DataTypes.JSON,
            allowNull: false
        },
        ivs: {
            type: DataTypes.JSON,
            allowNull: false
        },
        evs: {
            type: DataTypes.JSON,
            allowNull: false
        },
        shiny: {
            type: DataTypes.BOOLEAN,
            allowNull: true
        },
    }, { timestamps: false, freezeTableName: true }, )
    return SelectedPokemon
}