# Fichier : clients.dat

**Type :** LINE SEQUENTIAL

**Description :** Fichier des clients de KBank contenant les informations d’identité nécessaires à la gestion des comptes.

| Position | Taille | Champ        |
| -------- | ------ | ------------ |
| 1        | 4      | CLIENT-ID    |
| 5        | 20     | CLIENT-NAME  |
| 25       | 20     | CLIENT-FIRST |

**Longueur totale : 44 caractères**

---

## Exemple d’enregistrement

```text id="cl9x21"
0001DUPONT              PASCAL
```

## Détail des champs

| Champ        | Valeur |
| ------------ | ------ |
| CLIENT-ID    | 0001   |
| CLIENT-NAME  | DUPONT |
| CLIENT-FIRST | PASCAL |

---

## Structure COBOL

```cobol id="cb7k11"
FD CLIENT-FILE.

01 CLIENT-REC.
   05 CLIENT-ID     PIC 9(4).
   05 CLIENT-NAME   PIC X(20).
   05 CLIENT-FIRST  PIC X(20).
```

## Description des champs

- **CLIENT-ID** : identifiant unique du client.
- **CLIENT-NAME** : nom de famille du client.
- **CLIENT-FIRST** : prénom du client.

Ce fichier constitue la base de référence des clients utilisés dans l’ensemble des traitements bancaires (comptes, transactions, historique).
