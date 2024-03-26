const pool = require('../../db')
const queries = require('./queries')

const getPokemon = (req, res) => {
    try {
        pool.query(queries.getPokemon, (error, results) => {
            if (error) throw error;
            res.status(200).json(results.rows)
        })
    } catch (error) {
        res.status(error.status || 500).json({
			status: error.status || 500,
			error: error,
		})
    }
}

const getPokemonById = (req, res) => {
    try {
        const id = parseInt(req.params.id)
        pool.query(queries.getPokemonById, [id], (error, results) => {
            if (error) throw error;
            res.status(200).json(results.rows)
        })
    } catch (error) {
        res.status(error.status || 500).json({
			status: error.status || 500,
			error: error,
		})
    }
}

module.exports = {
    getPokemon,
    getPokemonById,
}
