const getTrainers = "SELECT * FROM trainers"
const checkEmailAvailable = "SELECT * FROM trainers WHERE email=$1"
const checkUserAvailable = "SELECT * FROM trainers WHERE username=$1"
const createUser = "INSERT INTO trainers (username, email, password) VALUES ($1, $2, $3)"
const updatePassword = "UPDATE trainers SET password=$2 WHERE id = $1"
const getPass = "SELECT password FROM trainers WHERE username=$1"

module.exports = {
    getTrainers,
    checkEmailAvailable,
    checkUserAvailable,
    createUser,
    updatePassword,
    getPass,
}
