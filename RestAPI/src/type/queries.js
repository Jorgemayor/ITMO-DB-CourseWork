const getTypes = "SELECT * FROM types"
const getTypeById = "SELECT * FROM types WHERE id = $1"

module.exports = {
    getTypes,
    getTypeById,
}
