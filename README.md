# ZakFit

ZakFit est une application iOS de suivi des repas, des activités physiques
et des objectifs personnels. Le tableau de bord présente les données saisies
et la progression vers les objectifs.

## Organisation du projet

- `backend/` — API REST en Swift avec Vapor, Fluent et authentification JWT.
- `ios/` — application SwiftUI connectée à l’API.
- `database/` — schéma SQL et données fictives pour les tests.
- `docs/` — conception, maquettes Figma, documentation API et vérification.

## Étapes de réalisation

1. Conception et maquettes.
2. Base de données et données fictives.
3. API Vapor.
4. Application iOS SwiftUI.
5. Vérification et démonstration.

## Tester la base de données en local

Prérequis : PostgreSQL 16 en cours d’exécution sur `localhost:5432`.

Depuis la racine du projet, exécuter ces commandes une fois sur une base neuve :

```bash
createdb -h localhost -p 5432 zakfit &&
psql -h localhost -p 5432 -d zakfit -v ON_ERROR_STOP=1 -f database/schema.sql &&
psql -h localhost -p 5432 -d zakfit -v ON_ERROR_STOP=1 -f database/seed.sql
```

Pour vérifier les données chargées :

```bash
psql -h localhost -p 5432 -d zakfit -c 'SELECT nom, calories FROM meals ORDER BY consumed_at;'
```

Les deux repas de Camille totalisent 1 050 kcal. Le compte Camille sert
aux vérifications SQL. Le compte de démonstration pour SwiftUI sera créé
à la demande par une commande Vapor.
