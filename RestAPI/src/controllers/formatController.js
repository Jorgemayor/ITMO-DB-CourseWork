const db = require("../models");

const Format = db.formats;

const getFormats = async (req, res) => {
    try {
        const formats = await Format.findAll()
        return res.status(200).send(formats);
    } catch(error) {
        console.log(error)
        res.status(error.status || 500).json({
			status: error.status || 500,
			error: error,
		})
    }
}

const getFormatById = async (req, res) => {
    try {
        const format = await Format.findAll({
            where: {
                id: parseInt(req.params.id),
            }
        })
        return res.status(200).send(format);
    } catch(error) {
        console.log(error)
        res.status(error.status || 500).json({
			status: error.status || 500,
			error: error,
		})
    }
}

module.exports = {
    getFormats,
    getFormatById,
};