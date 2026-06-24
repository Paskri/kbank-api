const express = require("express");
const router = express.Router();
const execCobol = require("../functions/execCobol");

router.get("/:ownerId", async (req, res) => {
  const { ownerId } = req.params

  const stdout = await execCobol("/app/cobol/bin/client-accounts", [ownerId])

  try {
    const result = stdout
      .trim()
      .split(/\r?\n/)
      .filter(l => l.includes("|"))
      .filter(l => l.length > 0)
      .map(line => {
        const [accountId, accountType, ownerId, iban, balance, accountCur] = line.split("|");
        return {
          accountId: accountId?.trim(),
          accountType: accountType?.trim(),
          ownerId: ownerId?.trim(),
          iban: iban?.trim(),
          balance: balance?.trim(),
          accountCur: accountCur?.trim()
        };
      })
      .filter(r => r.id !== "");

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