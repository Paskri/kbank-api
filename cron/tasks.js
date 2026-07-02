const path = require("path");
const execCobol = require("../functions/execCobol")

async function updateTransactions() {

  console.log('cron task executed: ', new Date())
  const COBOL_BIN = path.join(__dirname, "..", "cobol", "bin");
  console.log(COBOL_BIN, path.join(COBOL_BIN, "payments-batch"))
  await execCobol(path.join(COBOL_BIN, "payments-batch"));
  // récupérer le fichier produit 
}

module.exports = updateTransactions
