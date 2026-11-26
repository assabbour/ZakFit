# Diagramme de cas d’utilisation — ZakFit

```mermaid
flowchart TB
    U["Utilisateur"]

    subgraph Z["ZakFit"]
        direction TB
        INS(["Créer un compte"])
        CON(["Se connecter"])
        DASH(["Consulter le tableau de bord"])
        REP(["Gérer ses repas"])
        ACT(["Gérer ses activités"])
        OBJ(["Gérer ses objectifs"])
        HIST(["Consulter son historique"])
        PARAM(["Modifier ses paramètres"])
        DEC(["Se déconnecter"])
    end

    U --- INS
    U --- CON
    U --- DASH
    U --- REP
    U --- ACT
    U --- OBJ
    U --- HIST
    U --- PARAM
    U --- DEC
```

## Règles d’accès

- L’inscription et la connexion sont accessibles sans session.
- Les autres actions nécessitent une session active.
- Chaque utilisateur consulte et modifie uniquement ses propres données.
