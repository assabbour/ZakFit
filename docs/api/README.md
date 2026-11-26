# API ZakFit

URL locale `http://127.0.0.1:8080`. Envoyer les corps de requête avec
`Content-Type: application/json`. Pour les routes protégées, envoyer
`Authorization: Bearer <token>` avec le jeton obtenu à la connexion.

## Routes publiques

| Méthode | Route | Corps JSON | Réponse |
| --- | --- | --- | --- |
| GET | `/health/database` | — | `200` et `OK` si PostgreSQL répond |
| POST | `/auth/register` | `nom`, `email`, `password` | `201` sans corps, `409` si l’e-mail est déjà utilisé |
| POST | `/auth/login` | `email`, `password` | `200` avec `token`, `401` si les identifiants sont refusés |

## Routes protégées

| Méthode | Route | Corps JSON ou paramètre | Réponse |
| --- | --- | --- | --- |
| GET | `/auth/me` | — | Profil avec `id`, `nom` et `email` |
| GET | `/meals` | `date` facultatif | Liste des repas |
| POST | `/meals` | `nom`, `calories`, `consumedAt` | `201` avec le repas créé |
| PUT | `/meals/:id` | `nom`, `calories`, `consumedAt` | `200` avec le repas modifié |
| DELETE | `/meals/:id` | — | `204` sans corps |
| GET | `/activities` | `date` facultatif | Liste des activités |
| POST | `/activities` | `nom`, `durationMinutes`, `caloriesBurned` facultatif, `performedAt` | `201` avec l’activité créée |
| PUT | `/activities/:id` | Mêmes champs que pour la création | `200` avec l’activité modifiée |
| DELETE | `/activities/:id` | — | `204` sans corps |
| GET | `/goals` | — | Liste des objectifs |
| POST | `/goals` | `type`, `targetValue` | `201` avec l’objectif créé |
| PUT | `/goals/:id` | `type`, `targetValue` | `200` avec l’objectif modifié |
| DELETE | `/goals/:id` | — | `204` sans corps |
| GET | `/settings` | — | Fuseau horaire `timezone` du compte |
| PUT | `/settings` | `timezone`, par exemple `Europe/Paris` | `200` avec le fuseau enregistré |
| GET | `/dashboard` | — | Totaux du jour `caloriesConsumed` et `activityMinutes` |
| GET | `/dashboard/weekly` | — | Sept jours triés, avec `date` et les deux totaux |
| GET | `/dashboard/progress` | — | Progression par objectif avec `id`, `type`, `currentValue`, `targetValue` et `percentage` |

## Dates et validation

- `consumedAt` et `performedAt` utilisent des horodatages ISO 8601, par exemple `2026-11-26T10:00:00Z`.
- Le filtre `?date=2026-11-26` utilise la date locale dans le fuseau du compte. Sans filtre, les listes renvoient toutes les saisies du compte, de la plus récente à la plus ancienne.
- Les types d’objectif sont `calories_consumed` et `activity_minutes`. `targetValue` doit être un entier strictement positif.
- Une route protégée renvoie `401` si le jeton est absent, invalide ou expiré. Une modification ou suppression renvoie `404` si la ressource est introuvable pour le compte connecté. Une valeur invalide peut renvoyer `400`.
