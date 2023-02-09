CREATE SCHEMA football;
USE football;

CREATE TABLE players (
                         id INT AUTO_INCREMENT PRIMARY KEY,
                         name VARCHAR(50) NOT NULL,
                         team VARCHAR(50) NOT NULL,
                         nationality VARCHAR(50) NOT NULL
);

INSERT INTO players (name, team, nationality)
VALUES
    ('Lionel Messi', 'Paris Saint-Germain', 'Argentinian'),
    ('Cristiano Ronaldo', 'Al-Nassr', 'Portuguese'),
    ('Neymar Jr.', 'Paris Saint-Germain', 'Brazilian'),
    ('Kevin De Bruyne', 'Manchester City', 'Belgian'),
    ('Kylian Mbappe', 'Paris Saint-Germain', 'French'),
    ('Robert Lewandowski', 'Barcelona', 'Polish'),
    ('Sadio Mane', 'Bayern Munich', 'Senegalese'),
    ('Virgil van Dijk', 'Liverpool', 'Dutch'),
    ('Bernardo Silva', 'Manchester City', 'Portuguese'),
    ('Raheem Sterling', 'Chelsea', 'English');
