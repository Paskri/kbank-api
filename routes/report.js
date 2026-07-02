const fs = require("fs/promises");
const path = require("path");
const express = require("express");
const router = express.Router();

router.get("/", async (req, res) => {
  const file_path = path.join(__dirname, "..", "cobol", "data", "payment-report.txt");
  try {
    const data = await fs.readFile(file_path, "utf8");
    res.setHeader("Content-Type", "text/plain");
    res.send(data);

  } catch (err) {
    if (err.code === "ENOENT") {
      return res.status(404).send("Fichier introuvable");
    }
    res.status(500).send("Erreur lecture fichier");
  }
});

module.exports = router