const db = require("../models");

const SelectedPokemon = db.selectedPokemon;

const getSelectedPokemonByIdTeam = async (req, res) => {
    try {
        const selectedPokemon = await SelectedPokemon.findAll({
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

module.exports = {
    getSelectedPokemonByIdTeam,
};