const express = require("express");
const router = express.Router();
const execCobol = require("../functions/execCobol")

router.get("/", async (req, res) => {

  try {
    const transactions = await execCobol("/app/cobol/bin/alltrans");
    const result = transactions
      .trim()
      .split(/\r?\n/)
      .map(l => l.trim())
      .filter(l => l.length > 0)
      .filter(l => l !== '[' && l !== ']')
      .map(l => {
        // enlève la virgule finale COBOL
        const cleaned = l.replace(/,\s*$/, '');
        return JSON.parse(cleaned);
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