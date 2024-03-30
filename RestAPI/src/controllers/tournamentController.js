const db = require("../models");

const Tournament = db.tournaments;

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

module.exports = {
    getTournaments,
};