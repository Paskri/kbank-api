function mapTransactions(raw) {
  if (!raw) return [];

  const lines = raw
    .trim()
    .split(/\r?\n/)
    .map(l => l.trim())
    .filter(l => l && l !== '[' && l !== ']');

  const map = {};

  for (const line of lines) {
    const cleaned = line.replace(/,\s*$/, '');

    let t;
    try {
      t = JSON.parse(cleaned);
    } catch {
      continue;
    }

    const id = t.id;

    if (!map[id]) {
      map[id] = {
        id,
        clientId: t.clientId,
        type: normalizeType(t.type),
        amount: Number(t.amount),
        status: t.status?.trim(),
        reason: t.message?.trim(),
        date: t.date,
        time: t.time,

        // 💡 IMPORTANT : on ne met rien par défaut
        fromAccount: undefined,
        toAccount: undefined
      };
    }

    const tx = map[id];

    const type = normalizeType(t.type);

    if (type === "WITHDRAW") {
      tx.fromAccount = t.accountId;
    }

    if (type === "DEPOSIT") {
      tx.toAccount = t.accountId;
    }

    // statut final (dernière ligne gagnante)
    tx.status = t.status?.trim();
  }

  // 🔥 nettoyage final : on garde uniquement les transactions cohérentes
  return Object.values(map).filter(t => {
    if (t.type !== "TRANSFER") return true;

    // un transfer doit avoir les deux côtés
    return t.fromAccount && t.toAccount;
  });
}

function normalizeType(type) {
  if (!type) return "UNKNOWN";

  const t = type.trim();

  if (t.includes("WITHDRAW")) return "WITHDRAW";
  if (t.includes("DEPOSIT")) return "DEPOSIT";
  if (t.includes("TRANSFER")) return "TRANSFER";
  if (t.includes("PAYMENT")) return "PAYMENT";

  return t;
}
module.exports = mapTransactions