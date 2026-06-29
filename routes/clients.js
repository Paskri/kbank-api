const express = require("express");
const execCobol = require("../functions/execCobol")
const path = require("path");
const router = express.Router();

router.get("/", async (req, res) => {
  const COBOL_BIN = path.join(__dirname, "..", "cobol", "bin");

  try {
    const clientsRaw = await execCobol(path.join(COBOL_BIN, "clients"));
    const clients = clientsRaw
      .trim()
      .split(/\r?\n/)
      .filter(l => l.includes("|"))
      .map(line => {
        const [id, name, firstName] = line.split("|");
        return {
          id: id?.trim(),
          name: name?.trim(),
          firstName: firstName?.trim(),
          accounts: []
        };
      })
      .filter(r => r.id !== "");

    for (const client of clients) {
      const accountsRaw = await execCobol(path.join(COBOL_BIN, "client-accounts"),
        [client.id]);

      client.accounts = accountsRaw
        .trim()
        .split(/\r?\n/)
        .filter(l => l.includes("|"))
        .map(line => {
          const [
            accountId,
            accountType,
            ownerId,
            iban,
            balance,
            accountCur
          ] = line.split("|");

          return {
            accountId: accountId?.trim(),
            accountType: accountType?.trim(),
            ownerId: ownerId?.trim(),
            iban: iban?.trim(),
            balance: Number(balance),
            accountCur: accountCur?.trim()
          };
        });
      const oldSolution = true
      for (const account of client.accounts) {
        const transactionsRaw = await execCobol(
          path.join(COBOL_BIN, "transactions"),
          [account.accountId]
        );
        account.transactions = transactionsRaw
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
      };
    };

    res.json(clients);
  } catch (err) {
    console.error("COBOL error:", err);
    res.status(500).json({
      success: false,
      message: "COBOL execution failed",
      details: err.stderr || err.message
    });
  };
});

module.exports = router;
