const express = require("express");
const router = express.Router();
const execCobol = require("../functions/execCobol")

router.post("/", async (req, res) => {
  const { clientId, from, to, amount, message, } = req.body

  if (clientId === undefined || from === undefined || to === undefined || amount === undefined) {
    return res.status(400).json({
      success: false,
      message: 'Données manquantes',
    })
  }
  try {
    const transfer = await execCobol(
      "/app/cobol/bin/transfer",
      [clientId, from, to, 'TRANSFER', amount, message]
    );
    console.log(transfer)
    const result = (JSON.parse(transfer))
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