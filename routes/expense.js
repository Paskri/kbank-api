const express = require('express')
const execCobol = require("../functions/execCobol")
const path = require("path");
const router = express.Router()

router.post('/', async (req, res) => {
  const { clientId, account, move, amount, reason, } = req.body
  const COBOL_BIN = path.join(__dirname, "..", "cobol", "bin");
  process.env.ACCOUNT_FILE = path.join(COBOL_DATA, "accounts-ind.dat");
  process.env.TRANSACTION_FILE = path.join(COBOL_DATA, "transactions.dat");
  process.env.TR_COUNTER_FILE = path.join(COBOL_DATA, "tr-counter.dat");

  if (clientId === undefined || account === undefined || move === undefined || amount === undefined) {
    return res.status(400).json({
      success: false,
      message: 'Données manquantes',
    })
  }
  try {
    const cashMove = await execCobol(
      path.join(COBOL_BIN, "expense"),
      [clientId, account, move, amount, reason]
    );
    console.log(cashMove)
    const result = (JSON.parse(cashMove))
    if (result.success) {
      return res.json(result);
    }

    return res.status(422).json({
      success: false,
      message: "Une erreur - s'est produite dans le traitement de votre demande.",
      details: result.message
    })


  } catch (err) {
    console.error("COBOL error:", err);
    res.status(500).json({
      success: false,
      message: "COBOL execution failed",
      details: err.stderr || err.message
    });
  }
})

module.exports = router