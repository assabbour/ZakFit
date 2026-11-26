# Modèle physique des données — ZakFit

Base de données retenue : PostgreSQL.

| Table | Colonnes et types |
| --- | --- |
| users | id UUID, nom TEXT, email TEXT, password_hash TEXT, created_at TIMESTAMPTZ |
| meals | id UUID, user_id UUID, nom TEXT, calories INTEGER, consumed_at TIMESTAMPTZ |
| activities | id UUID, user_id UUID, nom TEXT, duration_minutes INTEGER, calories_burned INTEGER, performed_at TIMESTAMPTZ |
| goals | id UUID, user_id UUID, type TEXT, target_value INTEGER |
| user_settings | user_id UUID, timezone TEXT |

## Contraintes

- `id` est la clé primaire de `users`, `meals`, `activities` et `goals`.
- `user_id` référence `users.id` dans les quatre tables liées au compte.
- `user_settings.user_id` est aussi sa clé primaire. L’API crée le compte et ses paramètres dans la même transaction.
- Toutes les colonnes sont obligatoires, sauf `activities.calories_burned`.
- `users.email` est unique.
- `meals.calories` et `activities.calories_burned`, si renseignée, sont supérieures ou égales à zéro.
- `activities.duration_minutes` et `goals.target_value` sont strictement positives.
- `goals.type` accepte `calories_consumed` (kcal par jour) ou `activity_minutes` (minutes par jour).

## Dates et fuseau horaire

Les dates sont stockées en `TIMESTAMPTZ`. Le fuseau enregistré dans
`user_settings.timezone` sert à déterminer le début et la fin de chaque
journée du tableau de bord.
