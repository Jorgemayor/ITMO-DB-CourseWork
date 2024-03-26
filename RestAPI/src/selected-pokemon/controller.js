const pool = require('../../db')
const queries = require('./queries')

const getSelectedPokemonByIdTeam = (req, res) => {
    try {
        const idTeam = parseInt(req.params.id)
        pool.query(queries.getSelectedPokemonByIdTeam, [idTeam], (error, results) => {
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
    getSelectedPokemonByIdTeam,
}
