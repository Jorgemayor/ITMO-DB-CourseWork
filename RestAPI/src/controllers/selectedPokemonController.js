const db = require("../models")

const SelectedPokemon = db.selectedPokemon
const Pokemon = db.pokemon
const Nature = db.natures
const Item = db.items

const getSelectedPokemonByIdTeam = async (req, res) => {
    try {
        const selectedPokemon = await SelectedPokemon.findAll({
            include: [
                {
                    model: Pokemon,
                    required: true
                },
                {
                    model: Nature,
                    required: true
                },
                {
                    model: Item,
                    required: true
                }
            ],
            where: {
                id_team: parseInt(req.params.id),
            }
        })
        return res.status(200).send(selectedPokemon);
    } catch(error) {
        console.log(error)
        res.status(error.status || 500).json({
			status: error.status || 500,
			error: error,
		})
    }
}

const addSelectedPokemon = async () => {
    try {
        const {
            id_pokemon,
            id_team,
            ability,
            id_nature,
            id_item,
            moveset,
            ivs,
            evs,
            shiny
        } = req.body

        const data = {
            id_pokemon,
            id_team,
            ability,
            id_nature,
            id_item,
            moveset,
            ivs,
            evs,
            shiny
        }
        const selectedPokemon = await SelectedPokemon.create(data)

        if (selectedPokemon) {
            return res.status(201).send(selectedPokemon)
        } else {
            return res.status(409).send("Details are not correct")
        }
    } catch(error) {
        console.log(error)
        res.status(error.status || 500).json({
			status: error.status || 500,
			error: error,
		})
    }
}

const updateSelectedPokemon = async () => {
    try {
        const id = parseInt(req.params.id)
        const {
            id_pokemon,
            id_team,
            ability,
            id_nature,
            id_item,
            moveset,
            ivs,
            evs,
            shiny
        } = req.body

        const data = {
            id_pokemon,
            id_team,
            ability,
            id_nature,
            id_item,
            moveset,
            ivs,
            evs,
            shiny
        }

        const selectedPokemon = await SelectedPokemon.update(data, {
            where: {
                id: id
            }
        })
        
        if(selectedPokemon && selectedPokemon[0] != 0) {
            return res.status(200).send("Pokemon updated")
        } else {
            return res.status(409).send("Details are not correct")
        }
    } catch(error) {
        console.log(error)
        res.status(error.status || 500).json({
			status: error.status || 500,
			error: error,
		})
    }
}

module.exports = {
    getSelectedPokemonByIdTeam,
    addSelectedPokemon,
    updateSelectedPokemon
}