const pool = require('../../db')
const queries = require('./queries')

const getTypes = (req, res) => {
    try {
        pool.query(queries.getTypes, (error, results) => {
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

const getTypeById = (req, res) => {
    try {
        const id = parseInt(req.params.id)
        pool.query(queries.getTypeById, [id], (error, results) => {
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
    getTypes,
    getTypeById,
}
