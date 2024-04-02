const db = require("../models");

const Team = db.teams;
const Format = db.formats

const getTeams = async (req, res) => {
    try {
        const teams = await Team.findAll({
            include: { model: Format },
            where: {
                private: false,
            }
        })
        return res.status(200).send(teams)
    } catch(error) {
        console.log(error)
        res.status(error.status || 500).json({
			status: error.status || 500,
			error: error,
		})
    }
}

const getTeamById = async (req, res) => {
    try {
        const team = await Team.findAll({
            where: {
                id: parseInt(req.params.id),
            }
        })
        return res.status(200).send(team);
    } catch(error) {
        console.log(error)
        res.status(error.status || 500).json({
			status: error.status || 500,
			error: error,
		})
    }
}

const getTeamsByTrainer = async (req, res) => {
    try {
        const teams = await Team.findAll({
            include: { model: Format },
            where: {
                id_trainer: parseInt(req.params.id),
            }
        })
        return res.status(200).send(teams)
    } catch(error) {
        console.log(error)
        res.status(error.status || 500).json({
			status: error.status || 500,
			error: error,
		})
    }
}

const addTeam = async (req, res) => {
    try {
        const { id_trainer, id_format, name, private } = req.body
        const data = {
            id_trainer,
            id_format,
            name,
            private,
        }
        const team = await Team.create(data);

        if (team) {
            return res.status(201).send(team);
        } else {
            return res.status(409).send("Details are not correct")
        }
    } catch(error) {
        console.log(error)
        res.status(error.status || 500).json({
			status: error.status || 500,
			error: error,
		})
    }
}

const updateTeam = async (req, res) => {
    try {
        const id = parseInt(req.params.id)
        const { id_format, name, private } = req.body
        const data = {
            id_format,
            name,
            private
        }

        const team = await Team.update(data, {
            where: {
                id: id
            }
        });
        
        if(team && team[0] != 0) {
            return res.status(200).send("Team updated")
        } else {
            return res.status(409).send("Details are not correct")
        }
    } catch(error) {
        console.log(error)
        res.status(error.status || 500).json({
			status: error.status || 500,
			error: error,
		})
    }
}

const deleteTeam = async (req, res) => {
    try {
        const id = parseInt(req.params.id)
        const team = await Team.destroy({
            where: {
                id: id
            }
        });

        if(team) {
            return res.status(200).send("Team deleted")
        } else {
            return res.status(409).send("Details are not correct")
        }
    } catch(error) {
        console.log(error)
        res.status(error.status || 500).json({
			status: error.status || 500,
			error: error,
		})
    }
}

module.exports = {
    getTeams,
    getTeamById,
    getTeamsByTrainer,
    addTeam,
    updateTeam,
    deleteTeam,
};