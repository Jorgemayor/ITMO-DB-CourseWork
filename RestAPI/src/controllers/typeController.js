const db = require("../models");

const Type = db.types;

const getTypes = async (req, res) => {
    try {
        const types = await Type.findAll()
        return res.status(200).send(types);
    } catch(error) {
        console.log(error)
        res.status(error.status || 500).json({
			status: error.status || 500,
			error: error,
		})
    }
}

const getTypeById = async (req, res) => {
    try {
        const type = await Type.findAll({
            where: {
                id: parseInt(req.params.id),
            }
        })
        return res.status(200).send(type);
    } catch(error) {
        console.log(error)
        res.status(error.status || 500).json({
			status: error.status || 500,
			error: error,
		})
    }
}

module.exports = {
    getTypes,
    getTypeById,
};