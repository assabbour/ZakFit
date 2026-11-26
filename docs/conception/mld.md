# Modèle logique des données — ZakFit

- UTILISATEUR (id, nom, email, password_hash, created_at)
- REPAS (id, user_id, nom, calories, consumed_at)
- ACTIVITE (id, user_id, nom, duration_minutes, calories_burned, performed_at)
- OBJECTIF (id, user_id, type, target_value)
- PARAMETRES (user_id, timezone)

## Clés et contraintes

- `id` est la clé primaire des tables UTILISATEUR, REPAS, ACTIVITE et OBJECTIF.
- `user_id` est obligatoire et référence `UTILISATEUR.id` dans REPAS, ACTIVITE, OBJECTIF et PARAMETRES.
- Dans PARAMETRES, `user_id` est aussi la clé primaire. Cela limite chaque compte à un seul jeu de paramètres. L’inscription crée le compte et ses paramètres ensemble.
- `UTILISATEUR.email` est unique.
- `ACTIVITE.calories_burned` peut être vide.
