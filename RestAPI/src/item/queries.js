const getItems = "SELECT * FROM items"
const getItemById = "SELECT * FROM items WHERE id = $1"

module.exports = {
    getItems,
    getItemById,
}
