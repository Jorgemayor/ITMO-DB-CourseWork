const pool = require('../../db')
const queries = require('./queries')

const getTournaments = (req, res) => {
    try {
        pool.query(queries.getTournaments, (error, results) => {
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
    getTournaments,
}
