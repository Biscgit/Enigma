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
    machine_type INTEGER,
    rotors INTEGER[],

    character_pointer INTEGER,
    character_history CHAR[140][2],

    PRIMARY KEY (id),
    FOREIGN KEY (username) REFERENCES users(username)
);

-- Rotors
CREATE TABLE IF NOT EXISTS rotors (
    id SERIAL,
    machine_id SERIAL,
    rotor_type INTEGER,
    letter_shift INTEGER,
    rotor_position INTEGER,

    PRIMARY KEY (id),
    FOREIGN KEY (machine_id) REFERENCES machines(id)
);
