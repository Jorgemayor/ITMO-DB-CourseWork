const getFormats = "SELECT * FROM formats"
const getFormatById = "SELECT * FROM formats WHERE id = $1"

module.exports = {
    getFormats,
    getFormatById,
}
