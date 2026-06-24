# Fichier : accounts.dat

**Type :** INDEXED (ISAM)

**Description :** Stockage des comptes bancaires associés aux clients de KBank.

| Position | Taille | Champ        |
| -------- | ------ | ------------ |
| 1        | 4      | ACCOUNT-ID   |
| 5        | 8      | ACCOUNT-TYPE |
| 13       | 4      | OWNER-ID     |
| 17       | 27     | IBAN         |
| 44       | 10     | BALANCE      |
| 54       | 3      | ACCOUNT-CUR  |

**Longueur totale : 56 caractères**

---

## Exemple d'enregistrement

```text
0001CURRENT 0001FR76123456789012345678901230000012500EUR
```

## Détail des champs

| Champ        | Valeur                      |
| ------------ | --------------------------- |
| ACCOUNT-ID   | 0001                        |
| ACCOUNT-TYPE | CURRENT                     |
| OWNER-ID     | 0001                        |
| IBAN         | FR7612345678901234567890123 |
| BALANCE      | 0000012500                  |
| ACCOUNT-CUR  | EUR                         |

---

## Structure COBOL

```cobol
FD ACCOUNTS-FILE.

01 ACCOUNT-RECORD.
   05 ACCOUNT-ID       PIC 9(4).
   05 ACCOUNT-TYPE     PIC X(8).
   05 OWNER-ID         PIC 9(4).
   05 IBAN             PIC X(27).
   05 BALANCE          PIC 9(10).
   05 ACCOUNT-CUR      PIC X(3).
```

## Description des champs

- **ACCOUNT-ID** : identifiant unique du compte.
- **ACCOUNT-TYPE** : type de compte (`CURRENT`, `SAVINGS`).
- **OWNER-ID** : identifiant du propriétaire du compte.
- **IBAN** : numéro IBAN du compte.
- **BALANCE** : solde du compte exprimé en centimes.
- **ACCOUNT-CUR** : devise du compte (`EUR`).

## Exemple de données

| ACCOUNT-ID | ACCOUNT-TYPE | OWNER-ID | Devise |
| ---------- | ------------ | -------- | ------ |
| 0001       | CURRENT      | 0001     | EUR    |
| 0002       | SAVINGS      | 0001     | EUR    |
| 0003       | CURRENT      | 0002     | EUR    |
| 0004       | SAVINGS      | 0002     | EUR    |

Chaque client dispose de deux comptes : un compte courant (**CURRENT**) et un compte épargne (**SAVINGS**). Les comptes sont stockés dans un fichier indexé ISAM afin de permettre un accès rapide par identifiant.
