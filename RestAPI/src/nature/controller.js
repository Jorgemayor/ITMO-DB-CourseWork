const pool = require('../../db')
const queries = require('./queries')

const getNatures = (req, res) => {
    try {
        pool.query(queries.getNatures, (error, results) => {
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

const getNatureById = (req, res) => {
    try {
        const id = parseInt(req.params.id)
        pool.query(queries.getNatureById, [id], (error, results) => {
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
    getNatures,
    getNatureById,
}
