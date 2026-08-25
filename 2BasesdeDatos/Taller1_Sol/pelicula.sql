-- =============================================================================
-- DISEÑO DE BASE DE DATOS RELACIONAL NORMALIZADA (1NF, 2NF, 3NF)
-- Caso de Estudio: Base de Datos de Películas (Taller 1)
-- =============================================================================

-- SCRIPT DDL: Creación de Tablas, Claves Primarias (PK) y Claves Foráneas (FK)
-- Compatible con PostgreSQL / MySQL / SQLite

-- NOTA DE NORMALIZACIÓN:
-- 1. Primera Forma Normal (1NF): Se garantiza la atomicidad. Los campos multivalor
--    'reparto' y 'genero' se extraen a tablas independientes relacionadas mediante tablas puente.
-- 2. Segunda Forma Normal (2NF): Se eliminan dependencias parciales. Todas las tablas
--    puente tienen claves primarias compuestas y dependen enteramente de ellas.
-- 3. Tercera Forma Normal (3NF): Se eliminan dependencias transitivas. 
--    * El 'nacimiento director' dependía de 'director' (se extrae la tabla 'directores').
--    * El 'país' dependía de 'código país' (se extrae la tabla 'paises' resolviendo redundancias).
--    * La 'duracion' se estandariza a minutos enteros (INTEGER) para corregir formatos inconsistentes.

-- =============================================================================
-- 1. CREACIÓN DE TABLAS MAESTRAS (INDependientes)
-- =============================================================================

-- Tabla de Países (3NF: Resuelve inconsistencias como 'USA', 'Estados Unidos' y 'E. Unidos')
CREATE TABLE paises (
    codigo_pais VARCHAR(5) PRIMARY KEY, -- Ej: 'USA', 'ESP', 'ITA'
    nombre_pais VARCHAR(100) NOT NULL UNIQUE
);

-- Tabla de Directores (3NF: Elimina la dependencia transitiva de fecha de nacimiento respecto a la película)
CREATE TABLE directores (
    id_director SERIAL PRIMARY KEY,
    nombre_director VARCHAR(150) NOT NULL UNIQUE,
    fecha_nacimiento DATE
);

-- Tabla de Actores (1NF: Atomicidad de la lista original de 'reparto')
CREATE TABLE actores (
    id_actor SERIAL PRIMARY KEY,
    nombre_actor VARCHAR(150) NOT NULL UNIQUE
);

-- Tabla de Géneros (1NF: Atomicidad del campo multivalor 'genero')
CREATE TABLE generos (
    id_genero SERIAL PRIMARY KEY,
    nombre_genero VARCHAR(100) NOT NULL UNIQUE
);

-- =============================================================================
-- 2. CREACIÓN DE LA TABLA PRINCIPAL
-- =============================================================================

-- Tabla de Películas
CREATE TABLE peliculas (
    id_pelicula SERIAL PRIMARY KEY,
    titulo VARCHAR(255) NOT NULL,
    sinopsis TEXT,
    fecha_estreno DATE,
    id_director INT NOT NULL,
    codigo_pais VARCHAR(5) NOT NULL,
    duracion_minutos INT NOT NULL, -- Estandarizado a minutos enteros (Ej: 1h58min -> 118)
    calificacion DECIMAL(3, 2),    -- Permite valores como 4.5, 3.8, etc.
    CONSTRAINT fk_pelicula_director FOREIGN KEY (id_director) REFERENCES directores(id_director) ON DELETE CASCADE,
    CONSTRAINT fk_pelicula_pais FOREIGN KEY (codigo_pais) REFERENCES paises(codigo_pais) ON DELETE CASCADE
);

-- =============================================================================
-- 3. CREACIÓN DE TABLAS DE RELACIÓN MUCHOS A MUCHOS (N:M)
-- =============================================================================

-- Tabla Puente: Películas y Actores (N:M)
-- Una película tiene muchos actores; un actor participa en muchas películas.
CREATE TABLE pelicula_actor (
    id_pelicula INT NOT NULL,
    id_actor INT NOT NULL,
    CONSTRAINT pk_pelicula_actor PRIMARY KEY (id_pelicula, id_actor),
    CONSTRAINT fk_puente_pelicula FOREIGN KEY (id_pelicula) REFERENCES peliculas(id_pelicula) ON DELETE CASCADE,
    CONSTRAINT fk_puente_actor FOREIGN KEY (id_actor) REFERENCES actores(id_actor) ON DELETE CASCADE
);

-- Tabla Puente: Películas y Géneros (N:M)
-- Una película puede pertenecer a varios géneros; un género agrupa varias películas.
CREATE TABLE pelicula_genero (
    id_pelicula INT NOT NULL,
    id_genero INT NOT NULL,
    CONSTRAINT pk_pelicula_genero PRIMARY KEY (id_pelicula, id_genero),
    CONSTRAINT fk_puente_peli FOREIGN KEY (id_pelicula) REFERENCES peliculas(id_pelicula) ON DELETE CASCADE,
    CONSTRAINT fk_puente_genero FOREIGN KEY (id_genero) REFERENCES generos(id_genero) ON DELETE CASCADE
);


-- =============================================================================
-- 4. INSERCIÓN DE DATOS NORMALIZADOS DE MUESTRA (Basado en el PDF)
-- =============================================================================

-- A. Insertar Países Unificados (Soluciona inconsistencias)
INSERT INTO paises (codigo_pais, nombre_pais) VALUES
('USA', 'Estados Unidos'),
('ESP', 'España'),
('ITA', 'Italia');

-- B. Insertar Directores (Con sus respectivas fechas de nacimiento)
INSERT INTO directores (nombre_director, fecha_nacimiento) VALUES
('Gabriele Muccino', '1967-05-20'),
('Orson Welles', '1915-05-06'),
('Tim Burton', '1958-08-25'),
('Garry Marshall', '1934-11-13'),
('Marcel Barrena', '1981-10-15'),
('Giuseppe Tornatore', '1956-05-27'); -- Corrección de formato de fecha '27/051956' a '1956-05-27'

-- C. Insertar Actores Únicos (Extraídos de las listas de reparto de cada película)
INSERT INTO actores (nombre_actor) VALUES
('Will Smith'), ('Thandie Newton'), ('Jaden Smith'),        -- En busca de la felicidad
('Orson Welles'), ('Joseph Cotten'), ('Dorothy Comingore'), -- Ciudadano Kane
('Ewan McGregor'), ('Albert Finney'), ('Jessica Lange'),    -- Big Fish
('Anne Hathaway'), ('Julie Andrews'), ('Hector Elizondo'),  -- Princesa por sorpresa 2
('Dani Rovira'), ('Karra Elejalde'), ('Alexandra Jiménez'), -- 100 metros
('Philippe Noiret'), ('Jacques Perrin'), ('Salvatore Cascio'), -- Cinema Paradiso
('Johnny Depp'), ('Mia Wasikowska'), ('Matt Lucas');        -- Alicia en el país de las maravillas

-- D. Insertar Géneros Únicos
INSERT INTO generos (nombre_genero) VALUES
('Comedia dramática'),
('Biografía'),
('Aventura'),
('Romántico'),
('Familia'),
('Suspense'),
('Fantasía');

-- E. Insertar Películas (Estandarizando duraciones a minutos enteros)
-- 1. En busca de la felicidad: 1h58min = 118 min
-- 2. Ciudadano Kane: 119min = 119 min
-- 3. Big Fish: 2h05min = 125 min
-- 4. Princesa por sorpresa 2: 113min = 113 min
-- 5. 100 metros: 1h49min = 109 min
-- 6. Cinema Paradiso: 124min = 124 min
-- 7. Alicia en el país de las maravillas: 1h48min = 108 min
INSERT INTO peliculas (id_pelicula, titulo, sinopsis, fecha_estreno, id_director, codigo_pais, duracion_minutos, calificacion) VALUES
(1, 'En busca de la felicidad', 'Chris Gardner, un joven padre de familia, está tratando de ganarse la vida.', '2007-02-02', 1, 'USA', 118, 4.5),
(2, 'Ciudadano Kane', 'Charles Foster Kane (Orson Welles) lo ha tenido todo en la vida: dinero, fama, prestigio...', '1996-02-21', 2, 'USA', 119, 4.0),
(3, 'Big Fish, El gran pez', 'Edward Bloom ha llevado una vida repleta de historias sorprendentes...', '2004-03-05', 3, 'USA', 125, 4.3),
(4, 'Princesa por sorpresa 2', 'La trama tiene como personaje central a Mia, una mujer apuesta y decidida...', '2004-12-17', 4, 'USA', 113, 3.0),
(5, '100 metros', 'Ramón Arroyo (Dani Rovira) es un padre de familia que vive para el trabajo...', '2016-11-04', 5, 'ESP', 109, 4.2),
(6, 'Cinema Paradiso', 'En esta historia de amor por el cine, Salvatore Di Vita recuerda su niñez...', '1989-12-15', 6, 'ITA', 124, 4.4),
(7, 'Alicia en el país de las maravillas', 'Alicia tiene 19 años y está a punto de recibir una propuesta de matrimonio...', '2010-04-16', 3, 'USA', 108, 3.8);

-- F. Asociar Películas con sus respectivos Actores (Relación Muchos a Muchos)
INSERT INTO pelicula_actor (id_pelicula, id_actor) VALUES
(1, 1), (1, 2), (1, 3),   -- En busca de la felicidad
(2, 4), (2, 5), (2, 6),   -- Ciudadano Kane
(3, 7), (3, 8), (3, 9),   -- Big Fish
(4, 10), (4, 11), (4, 12), -- Princesa por sorpresa 2
(5, 13), (5, 14), (5, 15), -- 100 metros
(6, 16), (6, 17), (6, 18), -- Cinema Paradiso
(7, 19), (7, 20), (7, 21); -- Alicia en el país de las maravillas

-- G. Asociar Películas con sus respectivos Géneros (Relación Muchos a Muchos)
INSERT INTO pelicula_genero (id_pelicula, id_genero) VALUES
(1, 1), (1, 2), -- En busca de la felicidad: Comedia dramática, Biografía
(2, 1),         -- Ciudadano Kane: Comedia dramática
(3, 1), (3, 3), -- Big Fish: Comedia dramática, Aventura
(4, 4), (4, 5), (4, 6), (4, 1), -- Princesa por sorpresa 2: Romántico, Familia, Suspense, Comedia dramática
(5, 1),         -- 100 metros: Comedia dramática
(6, 1),         -- Cinema Paradiso: Comedia dramática
(7, 7), (7, 3), (7, 5); -- Alicia en el país de las maravillas: Fantasía, Aventura, Familia
