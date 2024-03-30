const db = require("../models");

const Nature = db.natures;

const getNatures = async (req, res) => {
    try {
        const natures = await Nature.findAll()
        return res.status(200).send(natures);
    } catch(error) {
        console.log(error)
        res.status(error.status || 500).json({
			status: error.status || 500,
			error: error,
		})
    }
}

const getNatureById = async (req, res) => {
    try {
        const nature = await Nature.findAll({
            where: {
                id: parseInt(req.params.id),
            }
        })
        return res.status(200).send(nature);
    } catch(error) {
        console.log(error)
        res.status(error.status || 500).json({
			status: error.status || 500,
			error: error,
		})
    }
}

module.exports = {
    getNatures,
    getNatureById,
};