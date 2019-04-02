const List = Record = require("ramda")
const Random = require("lodash")
const express = require("express")
const bodyParser = require("body-parser")
const cors = require("cors")
const { Pool } = require("pg")

const app = express()
app.use(cors())
app.use(bodyParser.json())

const DATABASE_URL = "postgres://vikfroberg:7833@localhost:5432/arenan"
const pool = new Pool({ connectionString: process.env.DATABASE_URL || DATABASE_URL })



// PLAYERS


app.post("/players", async (req, res) => {
  const body =
    req.body

  const { rows } =
    await pool.query(
      "INSERT INTO players (name, health, damage) VALUES ($1, $2, $3) RETURNING *",
      [body.name, body.health, body.damage]
    )

  res.json(rows[0])
})


app.get("/players", async (req, res) => {
  console.log(req)

  const { rows } =
    await pool.query("SELECT * FROM players LIMIT 10")

  res.json(rows)
})


app.get("/players/:id", async (req, res) => {
  const { rows } =
    await pool.query(
      "SELECT * FROM players WHERE id = $1",
      [req.params.id]
    )

  res.json(rows[0])
})



// BATTLES


// app.post("/battles", async (req, res) => {
//   const body =
//     req.body

//   const { rows } =
//     await pool.query(
//       "SELECT * FROM players WHERE id IN ($1, $2) ORDER BY FIELD (id, $1, $2)",
//       [body.home_id, body.away_id]
//     )


//   const players = {
//     [rows[0].id]: rows[0],
//     [rows[1].id]: rows[1],
//   }

//   const fighters = {
//     [rows[0].id]: rows[0],
//     [rows[1].id]: rows[1],
//   }

//   while (Record.map(\health fighters
//   const initiator =
//     Random.sample(Record.values(players))

//   const taker =
//     List.find(player => player.id !== initiator.id, Record.values(players))

//   const round = []

//   if (initiator.health <= 0) {
//     round.push(
//       { type: "END"
//       , winner: taker
//       , looser: initiator
//       })
//   } else {
//     const damage =
//       Random.random(0, initiator.damage)

//     taker.health =
//       taker.health - damage

//     round.push(
//       { type: "ATTACK"
//       , initiator: initiator
//       , taker: taker
//       , damage: damage
//       })
//   }

//   if (taker.health <= 0) {
//     round.push(
//       { type: "END"
//       , winner: taker
//       , looser: initiator
//       })
//   } else {
//     const damage =
//       Random.random(0, taker.damage)

//     initiator.health =
//       initiator.health - damage

//     round.push(
//       { type: "ATTACK"
//       , initiator: taker
//       , taker: initiator
//       , damage: damage
//       })
//   }

//   const { rows } =
//     await pool.query(
//       "INSERT INTO players (name, health, damage) VALUES ($1, $2, $3) RETURNING *",
//       [body.name, body.health, body.damage]
//     )

//   res.json(rows[0])
// })


app.get("/players", async (req, res) => {
  const { rows } =
    await pool.query("SELECT * FROM players LIMIT 10")

  res.json(rows)
})


app.get("/players/:id", async (req, res) => {
  const { rows } =
    await pool.query(
      "SELECT * FROM players WHERE id = $1",
      [req.params.id]
    )

  res.json(rows[0])
})



// SERVER


app.listen(process.env.PORT || 5000, () => {
  console.log("http://localhost:5000")
})
