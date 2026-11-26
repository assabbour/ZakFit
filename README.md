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

## Démarrer l’API Vapor

Prérequis sur Mac : Swift 6.3 ou supérieur et PostgreSQL 16 en cours
d’exécution. Sur un clone neuf, créer la base `zakfit` et appliquer
`database/schema.sql` en suivant la section « Tester la base de données
en local ». Le chargement de `database/seed.sql` est facultatif.

Depuis la racine du dépôt, configurer les variables dans le Terminal :

```bash
export DATABASE_HOST=localhost
export DATABASE_PORT=5432
export DATABASE_NAME=zakfit
printf 'Rôle PostgreSQL : '
read -r DATABASE_USERNAME
printf 'Mot de passe PostgreSQL (Entrée si aucun) : '
read -rs DATABASE_PASSWORD
printf '\n'
export DATABASE_USERNAME DATABASE_PASSWORD
export JWT_SECRET="$(openssl rand -hex 32)"

cd backend
swift run
```

Saisir le rôle PostgreSQL utilisé pour créer la base et ses tables.
Conserver le même onglet pour redémarrer l’API avec la même clé JWT.
Une nouvelle clé invalide les jetons signés avec la précédente.

Attendre le message `Server started`, puis vérifier l’API et la connexion
à PostgreSQL depuis un deuxième onglet :

```bash
curl -fsS http://127.0.0.1:8080/health/database
```

Résultat attendu : `OK`.

Pour un client web, définir `CORS_ALLOWED_ORIGINS` avant `swift run`, par
exemple `export CORS_ALLOWED_ORIGINS=http://localhost:3000`. Séparer les
origines par des virgules si plusieurs doivent être autorisées.
