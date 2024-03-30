const db = require("../models");

const Ability = db.abilities;

const getAbilities = async (req, res) => {
    try {
        const abilities = await Ability.findAll()
        return res.status(200).send(abilities);
    } catch(error) {
        console.log(error)
        res.status(error.status || 500).json({
			status: error.status || 500,
			error: error,
		})
    }
}

const getAbilityById = async (req, res) => {
    try {
        const ability = await Ability.findAll({
            where: {
                id: parseInt(req.params.id),
            }
        })
        return res.status(200).send(ability);
    } catch(error) {
        console.log(error)
        res.status(error.status || 500).json({
			status: error.status || 500,
			error: error,
		})
    }
}

module.exports = {
    getAbilities,
    getAbilityById,
};