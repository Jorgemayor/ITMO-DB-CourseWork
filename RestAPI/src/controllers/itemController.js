const db = require("../models");

const Item = db.items;

const getItems = async (req, res) => {
    try {
        const items = await Item.findAll()
        return res.status(200).send(items);
    } catch(error) {
        console.log(error)
        res.status(error.status || 500).json({
			status: error.status || 500,
			error: error,
		})
    }
}

const getItemById = async (req, res) => {
    try {
        const item = await Item.findAll({
            where: {
                id: parseInt(req.params.id),
            }
        })
        return res.status(200).send(item);
    } catch(error) {
        console.log(error)
        res.status(error.status || 500).json({
			status: error.status || 500,
			error: error,
		})
    }
}

module.exports = {
    getItems,
    getItemById,
};