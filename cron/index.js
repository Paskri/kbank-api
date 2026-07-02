const cron = require("node-cron");
const updateTransactions = require("./tasks");

let running = false;

cron.schedule(
  "*/10 * * * *",
  async () => {
    console.log("Launching Cron");
    if (running) {
      console.log("Synchronisation déjà en cours");
      return;
    }

    try {
      await updateTransactions();
    } catch (err) {
      console.error(err);
    } finally {
      running = false
    }
  },
  {
    timezone: "Europe/Paris"
  }
);

console.log("Cron initialisé");