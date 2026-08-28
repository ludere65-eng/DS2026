-- =============================================================================
-- SCRIPT UNIFICADO: BASE DE DATOS DE CINE NORMALIZADA Y CONSULTAS DE PRÁCTICA
-- Diseñado para: MySQL (Contenerizado con Docker) y administración con DBeaver
-- Basado en: Diseño Relacional de Películas (Modelado en 1NF, 2NF y 3NF)
-- Autor: Generado por Gemini Notebook
-- =============================================================================

-- =============================================================================
-- FASE 0: PREPARACIÓN DEL ENTORNO DE TRABAJO
-- =============================================================================
DROP DATABASE IF EXISTS cine_db;
CREATE DATABASE cine_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE cine_db;

-- =============================================================================
-- FASE 1: CREACIÓN DE TABLAS MAESTRAS (INDependientes)
-- =============================================================================

-- A. Tabla de Países (3NF: Resuelve redundancias e inconsistencias de escritura)
CREATE TABLE paises (
    codigo_pais VARCHAR(5) NOT NULL,
    nombre_pais VARCHAR(100) NOT NULL,
    CONSTRAINT pk_paises PRIMARY KEY (codigo_pais),
    CONSTRAINT uq_nombre_pais UNIQUE (nombre_pais)
) ENGINE=InnoDB;

-- B. Tabla de Directores (3NF: Elimina dependencia transitiva de nacimiento respecto a película)
CREATE TABLE directores (
    id_director INT NOT NULL AUTO_INCREMENT,
    nombre_director VARCHAR(150) NOT NULL,
    fecha_nacimiento DATE NULL,
    CONSTRAINT pk_directores PRIMARY KEY (id_director),
    CONSTRAINT uq_nombre_director UNIQUE (nombre_director)
) ENGINE=InnoDB;

-- C. Tabla de Actores (1NF: Descompone la lista multivalor original de 'reparto' para dar atomicidad)
CREATE TABLE actores (
    id_actor INT NOT NULL AUTO_INCREMENT,
    nombre_actor VARCHAR(150) NOT NULL,
    CONSTRAINT pk_actores PRIMARY KEY (id_actor),
    CONSTRAINT uq_nombre_actor UNIQUE (nombre_actor)
) ENGINE=InnoDB;

-- D. Tabla de Géneros (1NF: Descompone el campo multivalor original 'genero')
CREATE TABLE generos (
    id_genero INT NOT NULL AUTO_INCREMENT,
    nombre_genero VARCHAR(100) NOT NULL,
    CONSTRAINT pk_generos PRIMARY KEY (id_genero),
    CONSTRAINT uq_nombre_genero UNIQUE (nombre_genero)
) ENGINE=InnoDB;


-- =============================================================================
-- FASE 2: CREACIÓN DE LA TABLA DE HECHOS / PRINCIPAL (Entidad Débil / Dependiente)
-- =============================================================================

-- E. Tabla de Películas
CREATE TABLE peliculas (
    id_pelicula INT NOT NULL AUTO_INCREMENT,
    titulo VARCHAR(255) NOT NULL,
    sinopsis TEXT NULL,
    fecha_estreno DATE NULL,
    id_director INT NOT NULL,
    codigo_pais VARCHAR(5) NOT NULL,
    duracion_minutos INT NOT NULL, -- Estandarizado a minutos enteros (Ej: 1h58min -> 118)
    calificacion DECIMAL(3, 2) NULL, -- Permite valores fraccionarios detallados como 4.50 o 3.80
    CONSTRAINT pk_peliculas PRIMARY KEY (id_pelicula),
    CONSTRAINT fk_pelicula_director FOREIGN KEY (id_director) 
        REFERENCES directores(id_director) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_pelicula_pais FOREIGN KEY (codigo_pais) 
        REFERENCES paises(codigo_pais) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;


-- =============================================================================
-- FASE 3: CREACIÓN DE TABLAS PUENTE PARA RELACIONES MUCHOS A MUCHOS (N:M)
-- =============================================================================

-- F. Tabla Puente: Películas y Actores (N:M)
-- Una película tiene múltiples actores de reparto; un actor puede actuar en muchas películas.
CREATE TABLE pelicula_actor (
    id_pelicula INT NOT NULL,
    id_actor INT NOT NULL,
    CONSTRAINT pk_pelicula_actor PRIMARY KEY (id_pelicula, id_actor),
    CONSTRAINT fk_puente_pelicula_actor FOREIGN KEY (id_pelicula) 
        REFERENCES peliculas(id_pelicula) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_puente_actor_pelicula FOREIGN KEY (id_actor) 
        REFERENCES actores(id_actor) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- G. Tabla Puente: Películas y Géneros (N:M)
-- Una película puede clasificarse en varios géneros; un género agrupa múltiples películas.
CREATE TABLE pelicula_genero (
    id_pelicula INT NOT NULL,
    id_genero INT NOT NULL,
    CONSTRAINT pk_pelicula_genero PRIMARY KEY (id_pelicula, id_genero),
    CONSTRAINT fk_puente_pelicula_genero FOREIGN KEY (id_pelicula) 
        REFERENCES peliculas(id_pelicula) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_puente_genero_pelicula FOREIGN KEY (id_genero) 
        REFERENCES generos(id_genero) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;


-- =============================================================================
-- FASE 4: INSERCIÓN DE DATOS DE MUESTRA (DML DE DATOS NORMALIZADOS)
-- =============================================================================

-- 1. Insertar Países (Garantiza unicidad técnica sin nombres duplicados o variantes)
INSERT INTO paises (codigo_pais, nombre_pais) VALUES
('USA', 'Estados Unidos'),
('ESP', 'España'),
('ITA', 'Italia');

-- 2. Insertar Directores (Con fechas unificadas en formato estándar AAAA-MM-DD)
INSERT INTO directores (id_director, nombre_director, fecha_nacimiento) VALUES
(1, 'Gabriele Muccino', '1967-05-20'),
(2, 'Orson Welles', '1915-05-06'),
(3, 'Tim Burton', '1958-08-25'),
(4, 'Garry Marshall', '1934-11-13'),
(5, 'Marcel Barrena', '1981-10-15'),
(6, 'Giuseppe Tornatore', '1956-05-27');

-- 3. Insertar Actores Únicos
INSERT INTO actores (id_actor, nombre_actor) VALUES
(1, 'Will Smith'), (2, 'Thandie Newton'), (3, 'Jaden Smith'),
(4, 'Orson Welles'), (5, 'Joseph Cotten'), (6, 'Dorothy Comingore'),
(7, 'Ewan McGregor'), (8, 'Albert Finney'), (9, 'Jessica Lange'),
(10, 'Anne Hathaway'), (11, 'Julie Andrews'), (12, 'Hector Elizondo'),
(13, 'Dani Rovira'), (14, 'Karra Elejalde'), (15, 'Alexandra Jiménez'),
(16, 'Philippe Noiret'), (17, 'Jacques Perrin'), (18, 'Salvatore Cascio'),
(19, 'Johnny Depp'), (20, 'Mia Wasikowska'), (21, 'Matt Lucas');

-- 4. Insertar Géneros Únicos
INSERT INTO generos (id_genero, nombre_genero) VALUES
(1, 'Comedia dramática'),
(2, 'Biografía'),
(3, 'Aventura'),
(4, 'Romántico'),
(5, 'Familia'),
(6, 'Suspense'),
(7, 'Fantasía');

-- 5. Insertar Películas (Estandarizadas a minutos enteros para evitar redundancias)
INSERT INTO peliculas (id_pelicula, titulo, sinopsis, fecha_estreno, id_director, codigo_pais, duracion_minutos, calificacion) VALUES
(1, 'En busca de la felicidad', 'Chris Gardner, un joven padre de familia, está tratando de ganarse la vida.', '2007-02-02', 1, 'USA', 118, 4.50),
(2, 'Ciudadano Kane', 'Charles Foster Kane (Orson Welles) lo ha tenido todo en la vida: dinero, fama, prestigio...', '1996-02-21', 2, 'USA', 119, 4.00),
(3, 'Big Fish, El gran pez', 'Edward Bloom ha llevado una vida repleta de historias sorprendentes...', '2004-03-05', 3, 'USA', 125, 4.30),
(4, 'Princesa por sorpresa 2', 'La trama tiene como personaje central a Mia, una mujer apuesta y decidida...', '2004-12-17', 4, 'USA', 113, 3.00),
(5, '100 metros', 'Ramón Arroyo (Dani Rovira) es un padre de familia que vive para el trabajo...', '2016-11-04', 5, 'ESP', 109, 4.20),
(6, 'Cinema Paradiso', 'En esta historia de amor por el cine, Salvatore Di Vita recuerda su niñez...', '1989-12-15', 6, 'ITA', 124, 4.40),
(7, 'Alicia en el país de las maravillas', 'Alicia tiene 19 años y está a punto de recibir una propuesta de matrimonio...', '2010-04-16', 3, 'USA', 108, 3.80);

-- 6. Relacionar Películas con Actores de Reparto (Asociaciones Muchos a Muchos)
INSERT INTO pelicula_actor (id_pelicula, id_actor) VALUES
(1, 1), (1, 2), (1, 3),      -- En busca de la felicidad (Smith, Newton, Smith Jr)
(2, 4), (2, 5), (2, 6),      -- Ciudadano Kane (Welles, Cotten, Comingore)
(3, 7), (3, 8), (3, 9),      -- Big Fish (McGregor, Finney, Lange)
(4, 10), (4, 11), (4, 12),   -- Princesa por sorpresa 2 (Hathaway, Andrews, Elizondo)
(5, 13), (5, 14), (5, 15),   -- 100 metros (Rovira, Elejalde, Jiménez)
(6, 16), (6, 17), (6, 18),   -- Cinema Paradiso (Noiret, Perrin, Cascio)
(7, 19), (7, 20), (7, 21);   -- Alicia en el país de las maravillas (Depp, Wasikowska, Lucas)

-- 7. Relacionar Películas con sus Géneros Correspondientes (Asociaciones Muchos a Muchos)
INSERT INTO pelicula_genero (id_pelicula, id_genero) VALUES
(1, 1), (1, 2),              -- En busca de la felicidad: Comedia dramática, Biografía
(2, 1),                      -- Ciudadano Kane: Comedia dramática
(3, 1), (3, 3),              -- Big Fish: Comedia dramática, Aventura
(4, 4), (4, 5), (4, 6), (4, 1), -- Princesa por sorpresa 2: Romántico, Familia, Suspense, Comedia dramática
(5, 1),                      -- 100 metros: Comedia dramática
(6, 1),                      -- Cinema Paradiso: Comedia dramática
(7, 7), (7, 3), (7, 5);      -- Alicia en el país de las maravillas: Fantasía, Aventura, Familia


-- =============================================================================
-- FASE 5: LIBRERÍA COMPLETA DE CONSULTAS DE PRÁCTICA (DQL)
-- =============================================================================

-- -----------------------------------------------------------------------------
-- CONSULTA 1: FILTRADO Y ORDENAMIENTO BÁSICO
-- Objetivo: Obtener películas del nuevo milenio (estrenadas después del 2000)
-- que tengan una excelente calificación (mayor a 4.0), ordenadas descendentemente.
-- DBeaver tip: Ejecute con Ctrl + Enter teniendo el cursor sobre la consulta.
-- -----------------------------------------------------------------------------
SELECT 
    titulo, 
    fecha_estreno, 
    calificacion, 
    duracion_minutos
FROM peliculas
WHERE fecha_estreno >= '2001-01-01' 
  AND calificacion > 4.0
ORDER BY calificacion DESC;


-- -----------------------------------------------------------------------------
-- CONSULTA 2: RECONSTRUCCIÓN DEL MODELO NORMALIZADO (INNER JOIN CLÁSICO)
-- Objetivo: Cruzar la tabla principal 'peliculas' con 'directores' y 'paises'
-- para recuperar los nombres reales en lugar de los códigos numéricos o IDs.
-- -----------------------------------------------------------------------------
SELECT 
    p.id_pelicula,
    p.titulo,
    d.nombre_director,
    pa.nombre_pais AS pais_origen,
    p.calificacion
FROM peliculas p
INNER JOIN directores d ON p.id_director = d.id_director
INNER JOIN paises pa ON p.codigo_pais = pa.codigo_pais
ORDER BY p.id_pelicula;


-- -----------------------------------------------------------------------------
-- CONSULTA 3: CONSULTANDO RELACIONES MUCHOS A MUCHOS (PARTE I - ACTORES DE REPARTO)
-- Objetivo: Listar todos los actores que participaron en la película 'Big Fish, El gran pez'.
-- Se requiere atravesar la tabla puente 'pelicula_actor'.
-- -----------------------------------------------------------------------------
SELECT 
    p.titulo AS pelicula,
    a.nombre_actor AS actor_reparto
FROM peliculas p
INNER JOIN pelicula_actor pa ON p.id_pelicula = pa.id_pelicula
INNER JOIN actores a ON pa.id_actor = a.id_actor
WHERE p.titulo LIKE 'Big Fish%';


-- -----------------------------------------------------------------------------
-- CONSULTA 4: CONCATENACIÓN DE FILAS (GROUP_CONCAT EN RELACIÓN N:M)
-- Objetivo: Listar cada película junto con todos sus géneros correspondientes, 
-- pero agrupados en una sola celda y separados por comas para mejorar la legibilidad.
-- DBeaver tip: Ideal para vistas consolidadas de datos relacionales en una sola fila.
-- -----------------------------------------------------------------------------
SELECT 
    p.titulo AS pelicula,
    GROUP_CONCAT(g.nombre_genero ORDER BY g.nombre_genero SEPARATOR ', ') AS generos
FROM peliculas p
INNER JOIN pelicula_genero pg ON p.id_pelicula = pg.id_pelicula
INNER JOIN generos g ON pg.id_genero = g.id_genero
GROUP BY p.id_pelicula, p.titulo;


-- -----------------------------------------------------------------------------
-- CONSULTA 5: AGREGACIÓN DE DATOS (GROUP BY)
-- Objetivo: Conocer la cantidad total de películas filmadas y la calificación 
-- promedio obtenida, agrupadas por su respectivo país de origen.
-- -----------------------------------------------------------------------------
SELECT 
    pa.nombre_pais AS pais,
    COUNT(p.id_pelicula) AS total_peliculas,
    ROUND(AVG(p.calificacion), 2) AS calificacion_promedio
FROM peliculas p
INNER JOIN paises pa ON p.codigo_pais = pa.codigo_pais
GROUP BY pa.nombre_pais
ORDER BY total_peliculas DESC;


-- -----------------------------------------------------------------------------
-- CONSULTA 6: FILTRADO DE GRUPOS AGREGADOS (HAVING)
-- Objetivo: Identificar qué países tienen una calificación promedio superior 
-- a 4.0 estrellas en el catálogo de películas.
-- Nota: 'WHERE' filtra antes de agrupar; 'HAVING' filtra después de agrupar.
-- -----------------------------------------------------------------------------
SELECT 
    pa.nombre_pais AS pais,
    ROUND(AVG(p.calificacion), 2) AS calificacion_promedio
FROM peliculas p
INNER JOIN paises pa ON p.codigo_pais = pa.codigo_pais
GROUP BY pa.nombre_pais
HAVING calificacion_promedio > 4.0
ORDER BY calificacion_promedio DESC;


-- -----------------------------------------------------------------------------
-- CONSULTA 7: SUBCONSULTAS DE COMPARACIÓN DINÁMICA
-- Objetivo: Seleccionar de forma automática todas las películas cuya calificación 
-- individual sea mayor que la media de calificación de toda la videoteca entera.
-- -----------------------------------------------------------------------------
SELECT 
    titulo, 
    calificacion
FROM peliculas
WHERE calificacion > (SELECT AVG(calificacion) FROM peliculas)
ORDER BY calificacion DESC;


-- -----------------------------------------------------------------------------
-- CONSULTA 8: OPERADORES DE BÚSQUEDA DE TEXTO FLEXIBLE (LIKE)
-- Objetivo: Buscar cualquier película que contenga la palabra clave 'felicidad' 
-- o 'historia' tanto en su título como dentro de su campo de sinopsis.
-- -----------------------------------------------------------------------------
SELECT 
    titulo, 
    sinopsis, 
    calificacion
FROM peliculas
WHERE titulo LIKE '%felicidad%' 
   OR sinopsis LIKE '%vida%'
ORDER BY calificacion DESC;


-- -----------------------------------------------------------------------------
-- CONSULTA 9: EL "GRAN JOIN" MULTITABLA UNIFICADO
-- Objetivo: Generar un reporte consolidado masivo que muestre el título de la película,
-- el director, el país, y dos listas consolidadas: una de géneros y otra de actores.
-- Resuelve todas las uniones de la base de datos de manera limpia en un solo set.
-- -----------------------------------------------------------------------------
SELECT 
    p.titulo AS pelicula,
    d.nombre_director AS director,
    pa.nombre_pais AS pais,
    p.duracion_minutos AS duracion,
    p.calificacion,
    (
        SELECT GROUP_CONCAT(g.nombre_genero SEPARATOR ', ') 
        FROM pelicula_genero pg 
        JOIN generos g ON pg.id_genero = g.id_genero 
        WHERE pg.id_pelicula = p.id_pelicula
    ) AS generos,
    (
        SELECT GROUP_CONCAT(ac.nombre_actor SEPARATOR ', ') 
        FROM pelicula_actor pac 
        JOIN actores ac ON pac.id_actor = ac.id_actor 
        WHERE pac.id_pelicula = p.id_pelicula
    ) AS reparto
FROM peliculas p
INNER JOIN directores d ON p.id_director = d.id_director
INNER JOIN paises pa ON p.codigo_pais = pa.codigo_pais
ORDER BY p.titulo;


-- -----------------------------------------------------------------------------
-- CONSULTA 10: MANEJO Y OPERACIONES DE FECHAS (EDAD DEL DIRECTOR)
-- Objetivo: Calcular la edad exacta que tenía cada director de cine en la fecha
-- de estreno de su película específica usando funciones de diferencia de fechas.
-- DBeaver tip: Útil para ver la conversión al vuelo de tipos de datos DATE.
-- -----------------------------------------------------------------------------
SELECT 
    p.titulo AS pelicula,
    p.fecha_estreno AS fecha_estreno_pelicula,
    d.nombre_director AS director,
    d.fecha_nacimiento AS nacimiento_director,
    TIMESTAMPDIFF(YEAR, d.fecha_nacimiento, p.fecha_estreno) AS edad_director_en_estreno
FROM peliculas p
INNER JOIN directores d ON p.id_director = d.id_director
ORDER BY edad_director_en_estreno DESC;
