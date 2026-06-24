const express = require('express')
const execCobol = require("../functions/execCobol")
const router = express.Router()

router.post('/', async (req, res) => {
  const { clientId, account, move, amount, reason, } = req.body

  if (clientId === undefined || account === undefined || move === undefined || amount === undefined) {
    return res.status(400).json({
      success: false,
      message: 'Données manquantes',
    })
  }
  try {
    const cashMove = await execCobol(
      "/app/cobol/bin/expense",
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