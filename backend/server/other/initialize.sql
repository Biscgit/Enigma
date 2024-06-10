-- Users
CREATE TABLE IF NOT EXISTS users (
    username TEXT,
    password TEXT,

    PRIMARY KEY (username)
);

-- Machines
CREATE TABLE IF NOT EXISTS machines (
    id SERIAL,
    username TEXT,
    name TEXT,
    machine_type INTEGER,
    reflector JSON,

    character_pointer INTEGER,
    character_history JSON ARRAY[140],

    plugboard_enabled BOOLEAN,
    plugboard_config JSON ARRAY[10],

    PRIMARY KEY (id, username),
    FOREIGN KEY (username) REFERENCES users(username),

    CHECK (array_length(character_history, 1) <= 140),
    CHECK (array_length(plugboard_config, 1) <= 10)
);

-- Rotors
CREATE TABLE IF NOT EXISTS rotors (
    id SERIAL,
    username TEXT,
    machine_id SERIAL,
    scramble_alphabet TEXT,
    machine_type INTEGER,
    letter_shift TEXT,
    rotor_position TEXT,
    place INTEGER,

    PRIMARY KEY (id),
    FOREIGN KEY (machine_id, username) REFERENCES machines(id, username)
);
