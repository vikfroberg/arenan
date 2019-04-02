require("dotenv").config()
const cors = require("micro-cors")()
const { json } = require("micro")
const { Pool } = require("pg")

module.exports = cors(async (req, res) => {
  const body = await json(req)
  const pool = new Pool()
  const { rows } = await pool.query(
    "INSERT INTO players (name, health, damage) VALUES ($1, $2, $3) RETURNING *",
    [body.name, body.health, body.damage]
  )
  await pool.end()
  return rows[0]
})
