require("dotenv").config()
const cors = require("micro-cors")()
const { Pool } = require("pg")

module.exports = cors(async () => {
  const pool = new Pool()
  const { rows } = await pool.query("SELECT * FROM players")
  await pool.end()
  return rows
})
