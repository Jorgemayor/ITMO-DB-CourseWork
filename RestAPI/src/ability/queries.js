const getAbilities = "SELECT * FROM abilities"
const getAbilityById = "SELECT * FROM abilities WHERE id = $1"

module.exports = {
    getAbilities,
    getAbilityById,
}
