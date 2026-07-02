const express = require("express");
const router = express.Router();
const execCobol = require("../functions/execCobol")
const path = require("path");

router.get("/", async (req, res) => {
  const COBOL_BIN = path.join(__dirname, "..", "cobol", "bin");
  try {

    const transactions = await execCobol(path.join(COBOL_BIN, "waiting-tr"));
    const result = transactions
      .trim()
      .split(/\r?\n/)
      .map(l => l.trim())
      .filter(l => l.length > 0)
      .filter(l => l !== '[' && l !== ']')
      .map(l => {
        const cleaned = l.replace(/,\s*$/, '');
        try {
          return JSON.parse(cleaned);
        } catch (e) {
          console.error("Parse error line:", cleaned);
          return null;
        }
      })
      .filter(Boolean);

    res.json(result);

  } catch (err) {
    console.error("COBOL error:", err);
    res.status(500).json({
      success: false,
      message: "COBOL execution failed",
      details: err.stderr || err.message
    });
  }
});

module.exports = router;