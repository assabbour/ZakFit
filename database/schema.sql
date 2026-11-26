BEGIN;

CREATE TABLE users (
    id UUID PRIMARY KEY,
    nom TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE meals (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id),
    nom TEXT NOT NULL,
    calories INTEGER NOT NULL CHECK (calories >= 0),
    consumed_at TIMESTAMPTZ NOT NULL
);

CREATE TABLE activities (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id),
    nom TEXT NOT NULL,
    duration_minutes INTEGER NOT NULL CHECK (duration_minutes > 0),
    calories_burned INTEGER CHECK (calories_burned >= 0),
    performed_at TIMESTAMPTZ NOT NULL
);

CREATE TABLE goals (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id),
    type TEXT NOT NULL CHECK (type IN ('calories_consumed', 'activity_minutes')),
    target_value INTEGER NOT NULL CHECK (target_value > 0)
);

CREATE TABLE user_settings (
    user_id UUID PRIMARY KEY REFERENCES users(id),
    timezone TEXT NOT NULL
);

COMMIT;
