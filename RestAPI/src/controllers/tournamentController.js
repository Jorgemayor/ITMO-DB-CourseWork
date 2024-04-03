const db = require("../models");

const Tournament = db.tournaments;
const Trainer = db.trainers;
const TrainerTournament = db.trainerTournaments;

const getTournaments = async (req, res) => {
    try {
        const tournaments = await Tournament.findAll()
        return res.status(200).send(tournaments);
    } catch(error) {
        console.log(error)
        res.status(error.status || 500).json({
			status: error.status || 500,
			error: error,
		})
    }
}

const getTournamentTrainers = async (req, res) => {
    try {
        const tournament = await Tournament.findAll({
            include: {
                model: TrainerTournament,
                include: Trainer
              },
            where: {
                id: parseInt(req.params.id),
            }
        })
        return res.status(200).send(tournament);
    } catch(error) {
        console.log(error)
        res.status(error.status || 500).json({
			status: error.status || 500,
			error: error,
		})
    }
}

module.exports = {
    getTournaments,
    getTournamentTrainers
};