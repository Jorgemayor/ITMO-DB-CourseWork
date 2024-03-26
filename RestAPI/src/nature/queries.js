const getNatures = "SELECT * FROM natures"
const getNatureById = "SELECT * FROM natures WHERE id = $1"

module.exports = {
    getNatures,
    getNatureById,
}
