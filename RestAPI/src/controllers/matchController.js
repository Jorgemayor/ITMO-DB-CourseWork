const db = require("../models");

const Match = db.matches;

const getMatches = async (req, res) => {
    try {
        const matches = await Match.findAll()
        return res.status(200).send(matches);
    } catch(error) {
        console.log(error)
        res.status(error.status || 500).json({
			status: error.status || 500,
			error: error,
		})
    }
}

const getMatchesByIdTournament = async (req, res) => {
    try {
        const match = await Match.findAll({
            where: {
                id_tournament: parseInt(req.params.id),
            }
        })
        return res.status(200).send(match);
    } catch(error) {
        console.log(error)
        res.status(error.status || 500).json({
			status: error.status || 500,
			error: error,
		})
    }
}

module.exports = {
    getMatches,
    getMatchesByIdTournament,
};