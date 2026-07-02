const express = require("express");
const cors = require("cors");

require("./cron");

const app = express();

app.use(cors({
  origin: ["http://localhost:3001", "https://kbank.krieg.fr"]
}));

app.use(express.json());

app.use("/clients", require("./routes/clients"));
app.use("/transfer", require("./routes/transfer"));
app.use("/expense", require("./routes/expense"))
app.use("/accounts", require("./routes/accounts"));
app.use("/cash-move", require("./routes/cash-move"));
app.use("/alltrans", require("./routes/alltrans"));
app.use("/waiting-tr", require("./routes/waiting-tr"));
app.use("/report", require("./routes/report"));

app.listen(3000, "0.0.0.0", () => {    ///localhost
  console.log("API running on port 3000");
});