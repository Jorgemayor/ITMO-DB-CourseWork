const pool = require('../../db')
const queries = require('./queries')

const getTeams = (req, res) => {
    try {
        pool.query(queries.getTeams, (error, results) => {
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

const getTeamsById = (req, res) => {
    try {
        const id = parseInt(req.params.id)
        pool.query(queries.getTeamsById, [id], (error, results) => {
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

const getTeamsByTrainer = (req, res) => {
    try {
        const idTrainer = parseInt(req.params.id)
        pool.query(queries.getTeamsByTrainer, [idTrainer], (error, results) => {
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

const addTeam = (req, res) => {
    try {
        const { idTrainer, idFormat, name, private } = req.body
        pool.query(
            queries.addTeam,
            [idTrainer, idFormat, name, private],
            (error, results) => {
                if (error) throw error;
                res.status(201).send("Team created.")
            }
        )
    } catch (error) {
        res.status(error.status || 500).json({
			status: error.status || 500,
			error: error,
		})
    }
}

const updateTeam = (req, res) => {
    try {
        const id = parseInt(req.params.id)
        const { idFormat, name, private } = req.body
        pool.query(queries.getTeamsById, [id], (error, results) => {
            const teamNotFound = !results.rows.length
            if (teamNotFound) {
                res.send("Team not found")
            } else {
                pool.query(queries.updateTeam, [id, idFormat, name, private], (error, results) => {
                    if (error) throw error
                    res.status(200).send("Team updated.")
                })
            }
        })
    } catch (error) {
        res.status(error.status || 500).json({
			status: error.status || 500,
			error: error,
		})
    }
}

const deleteTeam = (req, res) => {
    try {
        const id = parseInt(req.params.id)
        pool.query(queries.getTeamsById, [id], (error, results) => {
            const teamNotFound = !results.rows.length
            if (teamNotFound) {
                res.send("Team not found")
            } else {
                pool.query(queries.deleteTeam, [id], (error, results) => {
                    if (error) throw error
                    res.status(200).send("Team deleted.")
                })
            }
        })
    } catch (error) {
        res.status(error.status || 500).json({
			status: error.status || 500,
			error: error,
		})
    }
    
}

module.exports = {
    getTeams,
    getTeamsByTrainer,
    addTeam,
    updateTeam,
    deleteTeam,
}
