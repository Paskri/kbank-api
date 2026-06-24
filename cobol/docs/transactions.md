# Fichier : transactions.dat

**Type :** LINE SEQUENTIAL

**Description :** Historique complet des opérations bancaires (dépôts, retraits, virements internes, virements externes et paiements par carte).

| Position | Taille | Champ                |
| -------- | ------ | -------------------- |
| 1        | 6      | TR-ID                |
| 7        | 4      | TR-ACCOUNT-ID        |
| 11       | 4      | TR-FROM-ID           |
| 15       | 4      | TR-TO-ID             |
| 19       | 4      | TR-CLIENT-ID         |
| 23       | 10     | TR-DATE (YYYY-MM-DD) |
| 33       | 8      | TR-HOUR (HH:MM:SS)   |
| 41       | 10     | TR-TYPE              |
| 51       | 10     | TR-AMOUNT            |
| 61       | 10     | TR-STATUS            |
| 71       | 100    | TR-REASON            |

**Longueur totale : 170 caractères**

---

## Exemple d'enregistrement

```text
00000100020002000300012026-06-2314:30:00TRANSFER 0000015000EXECUTED Virement compte courant vers épargne
```

## Détail des champs

| Champ         | Valeur                               |
| ------------- | ------------------------------------ |
| TR-ID         | 000001                               |
| TR-ACCOUNT-ID | 0002                                 |
| TR-FROM-ID    | 0002                                 |
| TR-TO-ID      | 0003                                 |
| TR-CLIENT-ID  | 0001                                 |
| TR-DATE       | 2026-06-23                           |
| TR-HOUR       | 14:30:00                             |
| TR-TYPE       | TRANSFER                             |
| TR-AMOUNT     | 0000015000                           |
| TR-STATUS     | EXECUTED                             |
| TR-REASON     | Virement compte courant vers épargne |

---

## Structure COBOL

```cobol
FD TRANSACTION-FILE.

01 TRANSACTION-RECORD.
   05 TR-ID         PIC X(6).
   05 TR-ACCOUNT-ID PIC X(4).
   05 TR-FROM-ID    PIC X(4).
   05 TR-TO-ID      PIC X(4).
   05 TR-CLIENT-ID  PIC X(4).
   05 TR-DATE       PIC X(10).
   05 TR-HOUR       PIC X(8).
   05 TR-TYPE       PIC X(10).
   05 TR-AMOUNT     PIC 9(10).
   05 TR-STATUS     PIC X(10) VALUE SPACES.
   05 TR-REASON     PIC X(100).
```

## Description des champs

- **TR-ID** : identifiant unique de la transaction.
- **TR-ACCOUNT-ID** : compte principal concerné par l'opération.
- **TR-FROM-ID** : compte débiteur.
- **TR-TO-ID** : compte créditeur.
- **TR-CLIENT-ID** : client ayant initié l'opération.
- **TR-DATE** : date de création de l'opération.
- **TR-HOUR** : heure de création de l'opération.
- **TR-TYPE** : type d'opération (`DEPOSIT`, `WITHDRAWAL`, `TRANSFER`, `CARD-PAYMENT`, etc.).
- **TR-AMOUNT** : montant de l'opération en centimes.
- **TR-STATUS** : état de traitement (`PENDING`, `EXECUTED`, `REJECTED`).
- **TR-REASON** : motif ou libellé de l'opération.

Cette structure unique permet de gérer l'ensemble des mouvements bancaires du système KBank au sein d'un seul fichier séquentiel.
