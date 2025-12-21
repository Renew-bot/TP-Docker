-- Création de la table items
CREATE TABLE IF NOT EXISTS items (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT
);

-- Insertion de données de test
INSERT INTO items (name, description) VALUES
    ('Item 1', 'Ceci est le premier element'),
    ('Item 2', 'Ceci est le deuxieme element'),
    ('Item 3', 'Ceci est le troisieme element'),
    ('Item 4', 'Element de test pour la demo'),
    ('Item 5', 'Dernier element de la liste initiale');
