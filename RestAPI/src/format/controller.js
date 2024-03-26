const pool = require('../../db')
const queries = require('./queries')

const getFormats = (req, res) => {
    try {
        pool.query(queries.getFormats, (error, results) => {
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

const getFormatById = (req, res) => {
    try {
        const id = parseInt(req.params.id)
        pool.query(queries.getFormatById, [id], (error, results) => {
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
    getFormats,
    getFormatById,
}
