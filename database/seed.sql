BEGIN;

-- Compte fictif réservé aux tests SQL.
INSERT INTO users (id, nom, email, password_hash)
VALUES (
    '00000000-0000-4000-8000-000000000001',
    'Camille Test',
    'camille@example.test',
    'COMPTE_SQL_SANS_CONNEXION'
);

INSERT INTO user_settings (user_id, timezone)
VALUES ('00000000-0000-4000-8000-000000000001', 'Europe/Paris');

INSERT INTO meals (id, user_id, nom, calories, consumed_at)
VALUES
    ('00000000-0000-4000-8000-000000000011',
     '00000000-0000-4000-8000-000000000001',
     'Petit-déjeuner', 400, '2026-11-26 08:00:00+01'),
    ('00000000-0000-4000-8000-000000000012',
     '00000000-0000-4000-8000-000000000001',
     'Déjeuner', 650, '2026-11-26 12:30:00+01');

INSERT INTO activities (
    id, user_id, nom, duration_minutes, calories_burned, performed_at
)
VALUES (
    '00000000-0000-4000-8000-000000000021',
    '00000000-0000-4000-8000-000000000001',
    'Marche', 30, 120, '2026-11-26 17:30:00+01'
);

INSERT INTO goals (id, user_id, type, target_value)
VALUES
    ('00000000-0000-4000-8000-000000000031',
     '00000000-0000-4000-8000-000000000001',
     'calories_consumed', 2000),
    ('00000000-0000-4000-8000-000000000032',
     '00000000-0000-4000-8000-000000000001',
     'activity_minutes', 45);

COMMIT;
