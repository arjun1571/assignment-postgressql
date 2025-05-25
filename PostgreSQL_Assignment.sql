-- Active: 1748106248941@@127.0.0.1@5432@conservation_db
CREATE DATABASE conservation_db;

CREATE TABLE rangers (
    ranger_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    region VARCHAR(100) NOT NULL
);

INSERT INTO
    rangers (name, region)
VALUES (
        'Alice Green',
        'Northern Hills'
    ),
    ('Bob White', 'River Delta'),
    (
        'Carol King',
        'Mountain Range'
    );

CREATE TABLE species (
    species_id SERIAL PRIMARY KEY,
    common_name VARCHAR(100) NOT NULL,
    scientific_name VARCHAR(100) NOT NULL,
    discovery_date DATE,
    conservation_status VARCHAR(50)
);

SELECT * FROM species;

INSERT INTO
    species (
        common_name,
        scientific_name,
        discovery_date,
        conservation_status
    )
VALUES (
        'Snow Leopard',
        'Panthera uncia',
        '1775-01-01',
        'Endangered'
    ),
    (
        'Bengal Tiger',
        'Panthera tigris tigris',
        '1758-01-01',
        'Endangered'
    ),
    (
        'Red Panda',
        'Ailurus fulgens',
        '1825-01-01',
        'Vulnerable'
    ),
    (
        'Asiatic Elephant',
        'Elephas maximus indicus',
        '1758-01-01',
        'Endangered'
    );

CREATE TABLE sightings (
    sighting_id SERIAL PRIMARY KEY,
    species_id INTEGER REFERENCES species (species_id),
    ranger_id INTEGER REFERENCES rangers (ranger_id),
    sighting_time TIMESTAMP NOT NULL,
    location VARCHAR(100) NOT NULL,
    notes TEXT
);

SELECT * FROM sightings;

INSERT INTO
    sightings (
        species_id,
        ranger_id,
        location,
        sighting_time,
        notes
    )
VALUES (
        1,
        1,
        'Peak Ridge',
        '2024-05-10 07:45:00',
        'Camera trap image captured'
    ),
    (
        2,
        2,
        'Bankwood Area',
        '2024-05-12 16:20:00',
        'Juvenile seen'
    ),
    (
        3,
        3,
        'Bamboo Grove East',
        '2024-05-15 09:10:00',
        'Feeding observed'
    ),
    (
        1,
        2,
        'Snowfall Pass',
        '2024-05-18 18:30:00',
        NULL
    );

-- Problems -----> 1  start

INSERT INTO
    rangers (name, region)
VALUES ('Derek Fox', 'Coastal Plains');

SELECT * FROM rangers;

-- Problems -----> 1  end

-- Problems -----> 2  start

SELECT COUNT(DISTINCT species_id) AS unique_species_count
FROM sightings;

-- Problems -----> 2  end

-- Problems -----> 3  start

SELECT
    sighting_id,
    species_id,
    ranger_id,
    location,
    sighting_time,
    notes
FROM sightings
WHERE
    location LIKE '%Pass%';

-- Problems -----> 3  end

-- Problems -----> 4  start

SELECT r.name, COUNT(s.sighting_id) AS total_sightings
FROM rangers r
    LEFT JOIN sightings s ON r.ranger_id = s.ranger_id
GROUP BY
    r.ranger_id,
    r.name
ORDER BY total_sightings DESC, r.name;
-- Problems -----> 4  end

-- Problems -----> 5  start
SELECT s.common_name
FROM species s
    LEFT JOIN sightings si ON s.species_id = si.species_id
WHERE
    si.sighting_id IS NULL;
-- Problems -----> 5  end

-- Problems -----> 6  start
SELECT s.common_name, sighting_time, r.name
FROM
    sightings si
    JOIN species s ON si.species_id = s.species_id
    JOIN rangers r ON si.ranger_id = r.ranger_id
ORDER BY sighting_time DESC
LIMIT 2;
-- Problems -----> 6  end

-- Problems -----> 7  start
ALTER TABLE species ADD COLUMN IF NOT EXISTS discovery_year INTEGER;

SELECT * FROM species;

ALTER TABLE species ADD COLUMN discovery_year INTEGER;

UPDATE species
SET
    discovery_year = EXTRACT(
        YEAR
        FROM discovery_date
    );

WITH
    updated AS (
        UPDATE species
        SET
            conservation_status = 'Historic'
        WHERE
            discovery_year < 1800
        RETURNING
            *
    )
SELECT 'AffectedRows : ' || COUNT(*) AS update_result
FROM updated;
-- Problems -----> 7  end

-- Problems -----> 8  start
SELECT
    sighting_id,
    CASE
        WHEN EXTRACT(
            HOUR
            FROM sighting_time
        ) < 12 THEN 'Morning'
        WHEN EXTRACT(
            HOUR
            FROM sighting_time
        ) BETWEEN 12 AND 17  THEN 'Afternoon'
        ELSE 'Evening'
    END AS time_of_day
FROM sightings
ORDER BY sighting_id;

-- Problems -----> 8  end

-- Problems -----> 9  start
WITH
    deleted_rangers AS (
        DELETE FROM rangers
        WHERE
            ranger_id NOT IN (
                SELECT DISTINCT
                    ranger_id
                FROM sightings
                WHERE
                    ranger_id IS NOT NULL
            )
        RETURNING
            *
    )
SELECT 'AffectedRows : ' || COUNT(*) AS delete_result
FROM deleted_rangers;
-- Problems -----> 9  end