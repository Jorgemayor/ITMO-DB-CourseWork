const pool = require('../../db')
const queries = require('./queries')

const getMatches = (req, res) => {
    try {
        pool.query(queries.getMatches, (error, results) => {
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

const getMatchesByIdTournament = (req, res) => {
    try {
        const idTournament = parseInt(req.params.id)
        pool.query(queries.getMatchesByIdTournament, [idTournament], (error, results) => {
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
    getMatches,
    getMatchesByIdTournament,
}
