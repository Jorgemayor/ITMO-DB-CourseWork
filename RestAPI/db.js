const Pool = require('pg').Pool

const pool = new Pool({
    user: "postgres",
    host: "localhost",
    database: "pkmntb",
    password: "jorge",
    port: 5432,
})

module.exports = pool
