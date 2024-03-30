const db = require("../models");

const Pokemon = db.pokemon;

const getPokemon = async (req, res) => {
    try {
        const pokemon = await Pokemon.findAll()
        return res.status(200).send(pokemon);
    } catch(error) {
        console.log(error)
        res.status(error.status || 500).json({
			status: error.status || 500,
			error: error,
		})
    }
}

const getPokemonById = async (req, res) => {
    try {
        const pokemon = await Pokemon.findAll({
            where: {
                id: parseInt(req.params.id),
            }
        })
        return res.status(200).send(pokemon);
    } catch(error) {
        console.log(error)
        res.status(error.status || 500).json({
			status: error.status || 500,
			error: error,
		})
    }
}

module.exports = {
    getPokemon,
    getPokemonById,
};