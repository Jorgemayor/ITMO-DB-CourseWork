const pool = require('../../db')
const queries = require('./queries')

const getItems = (req, res) => {
    try {
        pool.query(queries.getItems, (error, results) => {
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

const getItemById = (req, res) => {
    try {
        const id = parseInt(req.params.id)
        pool.query(queries.getItemById, [id], (error, results) => {
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
    getItems,
    getItemById,
}
