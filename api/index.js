const express = require("express")
const bodyParser = require("body-parser")
const cors = require("cors")
const { Pool } = require("pg")
const { Main } = require("./main")

const app = express()
app.use(cors())
app.use(bodyParser.json())

const DATABASE_URL = process.env.DATABASE_URL || "postgres://vikfroberg:7833@localhost:5432/arenan"
const pool = new Pool({ connectionString:  DATABASE_URL })

app.all("*", (req, res) => {
  const [pathname, query] = req.originalUrl.split("?")

  const app = Main.worker({
    pathname: req.method + pathname,
    search: query ? "?" + query : "",
    body: req.body,
  })

  app.ports.sendJson.subscribe(([status, body]) => res.status(status).json(body))
  app.ports.dbQuery.subscribe(([name, query, data]) => {
    pool.query(query, data, (err, result) => {
      if (err) {
        console.log(err)
      } else {
        app.ports.dbResult.send([name, result.rows])
      }
    })
  })
})

app.listen(process.env.PORT || 5000, () => {
  console.log("http://localhost:5000")
})
