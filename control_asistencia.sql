-- ============================================================================
-- SISTEMA DE CONTROL DE ASISTENCIA - ISFT N° 182 (COMPLETO)
-- ============================================================================
DROP DATABASE IF EXISTS control_asistencia;
CREATE DATABASE IF NOT EXISTS control_asistencia
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
USE control_asistencia;

-- ----------------------------------------------------------------------------
-- 1. TABLA: USUARIOS
-- ----------------------------------------------------------------------------
CREATE TABLE usuarios (
    id_usuario   INT AUTO_INCREMENT PRIMARY KEY,
    nombre       VARCHAR(80)  NOT NULL,
    apellido     VARCHAR(80)  NOT NULL,
    email        VARCHAR(120) NOT NULL UNIQUE,
    password     VARCHAR(255) NOT NULL,
    rol          ENUM('admin', 'docente', 'alumno') NOT NULL,
    legajo       VARCHAR(20) NULL,
    creado_en    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ----------------------------------------------------------------------------
-- 2. TABLA: CARRERAS
-- ----------------------------------------------------------------------------
CREATE TABLE carrera (
    id_carrera   INT AUTO_INCREMENT PRIMARY KEY,
    nombre       VARCHAR(120) NOT NULL,
    id_docente   INT NULL,
    CONSTRAINT fk_carrera_docente
        FOREIGN KEY (id_docente) REFERENCES usuarios(id_usuario)
        ON DELETE SET NULL
);

-- ----------------------------------------------------------------------------
-- 3. TABLA: MATERIAS
-- ----------------------------------------------------------------------------
CREATE TABLE materias (
    id_materia   INT AUTO_INCREMENT PRIMARY KEY,
    nombre       VARCHAR(120) NOT NULL,
    id_carrera   INT NOT NULL,
    año_materia  TINYINT NOT NULL DEFAULT 1, -- 1 = 1er año, 2 = 2do año, 3 = 3er año
    CONSTRAINT fk_materia_carrera
        FOREIGN KEY (id_carrera) REFERENCES carrera(id_carrera)
        ON DELETE CASCADE
);

-- ----------------------------------------------------------------------------
-- 4. TABLA: COMISIONES
-- ----------------------------------------------------------------------------
CREATE TABLE comisiones (
    id_comision          INT AUTO_INCREMENT PRIMARY KEY,
    id_materia           INT NOT NULL,
    nombre               VARCHAR(80) NOT NULL,
    año_lectivo          INT NOT NULL DEFAULT 2026,
    id_docente           INT NULL,
    id_docente_suplente  INT NULL,
    CONSTRAINT fk_comision_materia
        FOREIGN KEY (id_materia) REFERENCES materias(id_materia)
        ON DELETE CASCADE,
    CONSTRAINT fk_comision_docente
        FOREIGN KEY (id_docente) REFERENCES usuarios(id_usuario)
        ON DELETE SET NULL,
    CONSTRAINT fk_comision_suplente
        FOREIGN KEY (id_docente_suplente) REFERENCES usuarios(id_usuario)
        ON DELETE SET NULL
);

-- ----------------------------------------------------------------------------
-- 5. TABLA: INSCRIPCIONES A CARRERA
-- ----------------------------------------------------------------------------
CREATE TABLE inscripciones (
    id_inscripcion INT AUTO_INCREMENT PRIMARY KEY,
    id_alumno      INT NOT NULL,
    id_carrera     INT NOT NULL,
    fecha_alta     DATE NOT NULL DEFAULT (CURDATE()),
    UNIQUE KEY uq_alumno_carrera (id_alumno, id_carrera),
    CONSTRAINT fk_inscripcion_alumno
        FOREIGN KEY (id_alumno) REFERENCES usuarios(id_usuario)
        ON DELETE CASCADE,
    CONSTRAINT fk_inscripcion_carrera
        FOREIGN KEY (id_carrera) REFERENCES carrera(id_carrera)
        ON DELETE CASCADE
);

-- ----------------------------------------------------------------------------
-- 6. TABLA: ALUMNOS POR COMISION
-- ----------------------------------------------------------------------------
CREATE TABLE alumnos_comisiones (
    id_alumno    INT NOT NULL,
    id_comision  INT NOT NULL,
    fecha_alta   DATE NOT NULL DEFAULT (CURDATE()),
    PRIMARY KEY (id_alumno, id_comision),
    CONSTRAINT fk_ac_alumno
        FOREIGN KEY (id_alumno) REFERENCES usuarios(id_usuario)
        ON DELETE CASCADE,
    CONSTRAINT fk_ac_comision
        FOREIGN KEY (id_comision) REFERENCES comisiones(id_comision)
        ON DELETE CASCADE
);

-- ----------------------------------------------------------------------------
-- 7. TABLA: TOMAS DE LISTA
-- ----------------------------------------------------------------------------
CREATE TABLE tomas_lista (
    id_toma        INT AUTO_INCREMENT PRIMARY KEY,
    id_comision    INT NOT NULL,
    fecha          DATE NOT NULL,
    hora_apertura  TIME NOT NULL DEFAULT '18:00:00',
    hora_cierre    TIME NOT NULL DEFAULT '22:30:00',
    UNIQUE KEY uq_comision_fecha (id_comision, fecha),
    CONSTRAINT fk_toma_comision
        FOREIGN KEY (id_comision) REFERENCES comisiones(id_comision)
        ON DELETE CASCADE,
    CONSTRAINT chk_horario_institucional
        CHECK (hora_apertura >= '18:00:00' AND hora_cierre <= '22:30:00' AND hora_apertura < hora_cierre)
);

-- ----------------------------------------------------------------------------
-- 8. TABLA: ASISTENCIAS
-- ----------------------------------------------------------------------------
CREATE TABLE asistencias (
    id_asistencia  INT AUTO_INCREMENT PRIMARY KEY,
    id_toma        INT NOT NULL,
    id_alumno      INT NOT NULL,
    estado         ENUM('presente', 'ausente', 'justificacion') NOT NULL DEFAULT 'ausente',
    hora_marcado   TIME NULL,
    UNIQUE KEY uq_toma_alumno (id_toma, id_alumno),
    CONSTRAINT fk_asistencia_toma
        FOREIGN KEY (id_toma) REFERENCES tomas_lista(id_toma)
        ON DELETE CASCADE,
    CONSTRAINT fk_asistencia_alumno
        FOREIGN KEY (id_alumno) REFERENCES usuarios(id_usuario)
        ON DELETE CASCADE
);

-- ----------------------------------------------------------------------------
-- TRIGGERS DE SEGURIDAD (Validación de Rol)
-- ----------------------------------------------------------------------------
DELIMITER //

CREATE TRIGGER trg_check_alumno_inscripcion
BEFORE INSERT ON inscripciones
FOR EACH ROW
BEGIN
    DECLARE v_rol VARCHAR(20);
    SELECT rol INTO v_rol FROM usuarios WHERE id_usuario = NEW.id_alumno;
    IF v_rol != 'alumno' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El usuario indicado en la inscripción debe tener rol "alumno".';
    END IF;
END//

CREATE TRIGGER trg_check_alumno_comision
BEFORE INSERT ON alumnos_comisiones
FOR EACH ROW
BEGIN
    DECLARE v_rol VARCHAR(20);
    SELECT rol INTO v_rol FROM usuarios WHERE id_usuario = NEW.id_alumno;
    IF v_rol != 'alumno' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El usuario asignado a la comisión debe tener rol "alumno".';
    END IF;
END//

CREATE TRIGGER trg_check_alumno_asistencia
BEFORE INSERT ON asistencias
FOR EACH ROW
BEGIN
    DECLARE v_rol VARCHAR(20);
    SELECT rol INTO v_rol FROM usuarios WHERE id_usuario = NEW.id_alumno;
    IF v_rol != 'alumno' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El usuario al que se asigna asistencia debe tener rol "alumno".';
    END IF;
END//

DELIMITER ;

-- ============================================================================
-- DATOS INICIALES
-- ============================================================================

-- Usuarios base
INSERT INTO usuarios (nombre, apellido, email, password, rol, legajo) VALUES
('Araceli', 'Martinez', 'araamartinez_1998@mail.com', '$2b$12$DyrV.FhB/9bj/ZDG9fmw8.uARzlCzxAYOHjRc0NDcBaTyTgX4js0y', 'admin', NULL),
('Franco', 'Racca', 'franracca36@mail.com', '$2b$12$Ab6qgYz3lNRkyUilw5RKLel7DdLPiyIFrYJHl8xtYMMHjb34KPIMO', 'docente', NULL),
('Rosana', 'Hernandez', 'hernandez.rosana@mail.com', '$2b$12$Ab6qgYz3lNRkyUilw5RKLel7DdLPiyIFrYJHl8xtYMMHjb34KPIMO', 'docente', NULL),
('Adriana', 'Duarte', 'duarte.adriana@mail.com', '$2b$12$Ab6qgYz3lNRkyUilw5RKLel7DdLPiyIFrYJHl8xtYMMHjb34KPIMO', 'docente', NULL),
('Alan', 'Caceta', 'acaceta@mail.com', '$2b$12$eO/z.daCY7/NsxjleMOhPeM8E75SODGDxiyrRpjnhg5GybrB40lee', 'alumno', 'A-1001'),
('Ezequiel', 'Vargas', 'aevargas_1999@mail.com', '$2b$12$eO/z.daCY7/NsxjleMOhPeM8E75SODGDxiyrRpjnhg5GybrB40lee', 'alumno', 'A-1002');

-- Carreras
INSERT INTO carrera (nombre, id_docente) VALUES
('Análisis de Sistemas', 2),
('Administración de Recursos Humanos', NULL),
('Higiene y Seguridad en el Trabajo', NULL),
('Enfermería', NULL),
('Instrumentación Quirúrgica', NULL),
('Bibliotecología', NULL),
('Bibliotecario de Instituciones Educativas', NULL);

-- ----------------------------------------------------------------------------
-- CARGA DE MATERIAS POR CARRERA Y AÑO
-- ----------------------------------------------------------------------------

-- 1. Análisis de Sistemas (id_carrera = 1)
INSERT INTO materias (nombre, id_carrera, año_materia) VALUES
('Inglés I', 1, 1),
('Ciencia Tecnología y Sociedad', 1, 1),
('Análisis Matemático I', 1, 1),
('Álgebra', 1, 1),
('Algoritmos y Estructuras de Datos I', 1, 1),
('Sistemas y Organizaciones', 1, 1),
('Arquitectura de Computadores', 1, 1),
('Prácticas Profesionalizantes I', 1, 1),
('Inglés II', 1, 2),
('Análisis Matemático II', 1, 2),
('Estadística', 1, 2),
('Ingeniería de Software I', 1, 2),
('Algoritmos y Estructuras de Datos II', 1, 2),
('Sistemas Operativos', 1, 2),
('Base de Datos', 1, 2),
('Prácticas Profesionalizantes II', 1, 2),
('Inglés III', 1, 3),
('Aspectos Legales de la Profesión', 1, 3),
('Seminario de Actualización', 1, 3),
('Redes y Comunicaciones', 1, 3),
('Ingeniería de Software II', 1, 3),
('Algoritmos y Estructuras de Datos III', 1, 3),
('Prácticas Profesionalizantes III', 1, 3);

-- 2. Administración de Recursos Humanos (id_carrera = 2)
INSERT INTO materias (nombre, id_carrera, año_materia) VALUES
('Matemática I', 2, 1),
('Computación I', 2, 1),
('Derecho', 2, 1),
('Economía', 2, 1),
('Contabilidad', 2, 1),
('Sociología de la Organización', 2, 1),
('Principios de Administración', 2, 1),
('Metodología de la Investigación', 2, 1),
('Administración de Personal', 2, 1),
('Matemática II', 2, 2),
('Estadística', 2, 2),
('Inglés I', 2, 2),
('Computación II', 2, 2),
('Seguridad Social', 2, 2),
('Psicología Laboral', 2, 2),
('Seguridad e Higiene del Trabajo', 2, 2),
('Relaciones Laborales', 2, 2),
('Derecho Laboral', 2, 2),
('Práctica Profesional', 2, 2),
('Inglés II', 2, 3),
('Liquidación de Sueldos y Jornales', 2, 3),
('Selección de Personal, Evaluación y Capacitación', 2, 3),
('Dinámica Grupal', 2, 3),
('Administración Estratégica de los Recursos Humanos', 2, 3),
('Comunicación Organizacional', 2, 3),
('Práctica Profesional II', 2, 3);

-- 3. Higiene y Seguridad en el Trabajo (id_carrera = 3)
INSERT INTO materias (nombre, id_carrera, año_materia) VALUES
('Administración de las Organizaciones', 3, 1),
('Psicología Laboral', 3, 1),
('Física 1', 3, 1),
('Química 1', 3, 1),
('Medios de Representación', 3, 1),
('Medicina del Trabajo 1', 3, 1),
('Seguridad 1', 3, 1),
('Derecho del Trabajo', 3, 1),
('Práctica Profesionalizante 1', 3, 1),
('Estadística', 3, 2),
('Física 2', 3, 2),
('Química 2', 3, 2),
('Inglés Técnico', 3, 2),
('Ergonomía', 3, 2),
('Seguridad 2', 3, 2),
('Higiene Laboral y Medio Ambiente 1', 3, 2),
('Medicina del Trabajo 2', 3, 2),
('Práctica Profesionalizante 2', 3, 2),
('Comunicación y Administración de Medios', 3, 3),
('Capacitación de Personal', 3, 3),
('Seguridad 3', 3, 3),
('Higiene Laboral y Medio Ambiente 2', 3, 3),
('Control de la Contaminación', 3, 3),
('Práctica Profesionalizante 3', 3, 3);

-- 4. Enfermería (id_carrera = 4)
INSERT INTO materias (nombre, id_carrera, año_materia) VALUES
('Psicología', 4, 1),
('Teorías Socioculturales de la Salud', 4, 1),
('Condiciones y Medio Ambiente de Trabajo', 4, 1),
('Salud Pública I', 4, 1),
('Biología Humana', 4, 1),
('Fundamentos del Cuidado', 4, 1),
('Cuidados de la Salud Centrados en la Comunidad y la Familia', 4, 1),
('Práctica Profesionalizante I', 4, 1),
('Comunicación en Ciencias de la Salud', 4, 2),
('Inglés', 4, 2),
('Introducción a la Metodología de Investigación en Salud', 4, 2),
('Nutrición y Dietoterapia', 4, 2),
('Salud Pública II', 4, 2),
('Farmacología en Enfermería', 4, 2),
('Enfermería Materno Infantil', 4, 2),
('Enfermería del Adulto y del Adulto Mayor', 4, 2),
('Práctica Profesionalizante II', 4, 2),
('Organización y Gestión de Servicios de Enfermería', 4, 3),
('Aspectos Bioéticos y Legales de la Profesión', 4, 3),
('Enfermería en Salud Mental', 4, 3),
('Enfermería del Adulto y del Adulto Mayor II', 4, 3),
('Enfermería Comunitaria y Práctica Educativa en Salud', 4, 3),
('Enfermería en Emergencias y Catástrofes', 4, 3),
('Práctica Profesionalizante III', 4, 3);

-- 5. Instrumentación Quirúrgica (id_carrera = 5)
INSERT INTO materias (nombre, id_carrera, año_materia) VALUES
('Salud Pública', 5, 1),
('Fundamentos de las Ciencias Exactas', 5, 1),
('Procesos Tecnológicos en Salud', 5, 1),
('Biología', 5, 1),
('Prácticas Profesionalizantes I "Aproximación al Campo de la Salud"', 5, 1),
('Organización y Gestión de los Servicios de Salud', 5, 2),
('Seguridad e Higiene', 5, 2),
('Metodología de la Investigación en Servicios de Salud', 5, 2),
('Anatomía y Técnica Quirúrgica I', 5, 2),
('Fundamentos de la Instrumentación Quirúrgica', 5, 2),
('Prácticas Profesionalizantes II "Instrumentación Quirúrgica de Menor y Mediana Complejidad"', 5, 2),
('Taller de Emergencias y Urgencias', 5, 3),
('Organización y Administración del Quirófano', 5, 3),
('Bioética', 5, 3),
('Inglés', 5, 3),
('Anatomía y Técnicas Quirúrgicas II', 5, 3),
('Prácticas Profesionalizantes III "Instrumentación Quirúrgica de Mayor Complejidad y de Cirugía Infantil"', 5, 3);

-- 6. Bibliotecología (id_carrera = 6)
INSERT INTO materias (nombre, id_carrera, año_materia) VALUES
('Historia de los Procesos Socioculturales 1', 6, 1),
('Literatura Universal', 6, 1),
('Inglés 1', 6, 1),
('Historia de las Bibliotecas y Soportes de Información', 6, 1),
('Fundamentos de Bibliotecología y Ciencias de la Información', 6, 1),
('Administración y Gestión de Bibliotecas 1', 6, 1),
('Tecnologías Aplicadas a las Bibliotecas', 6, 1),
('Fuentes y Servicios de Información 1', 6, 1),
('Descripción Documental 1', 6, 1),
('Análisis Documental 1', 6, 1),
('Práctica Profesionalizante 1', 6, 1),
('Historia de los Procesos Socioculturales 2', 6, 2),
('Literatura Argentina y Latinoamericana', 6, 2),
('Inglés 2', 6, 2),
('Comunicación en Bibliotecas', 6, 2),
('Administración y Gestión de Bibliotecas 2', 6, 2),
('Tecnologías de Procesos y Servicios en Bibliotecas 1', 6, 2),
('Fuentes y Servicios de Información 2', 6, 2),
('Descripción Documental 2', 6, 2),
('Análisis Documental 2', 6, 2),
('Práctica Profesionalizante 2', 6, 2),
('Políticas de Información y Comunicación', 6, 3),
('Metodologías de Investigación en Unidades de Información', 6, 3),
('Inglés 3', 6, 3),
('Formación de Usuarios', 6, 3),
('Administración y Gestión de Bibliotecas 3', 6, 3),
('Gestión de Colecciones', 6, 3),
('Análisis y Descripción Documental', 6, 3),
('Tecnologías de Procesos y Servicios en Bibliotecas 2', 6, 3),
('Práctica Profesionalizante 3', 6, 3);

-- 7. Bibliotecario de Instituciones Educativas (id_carrera = 7)
INSERT INTO materias (nombre, id_carrera, año_materia) VALUES
('Historia de los Procesos Socioculturales I', 7, 1),
('Literatura Universal', 7, 1),
('Inglés I', 7, 1),
('Historia de las Bibliotecas y Soportes de Información', 7, 1),
('Fundamentos de Bibliotecología y Ciencias de la Información', 7, 1),
('Administración y Gestión de Bibliotecas I', 7, 1),
('Tecnologías Aplicadas a las Bibliotecas', 7, 1),
('Fuentes y Servicios de Información I', 7, 1),
('Descripción Documental I', 7, 1),
('Análisis Documental I', 7, 1),
('Práctica Profesionalizante I', 7, 1),
('Realidad Sociopolítica Cultural Contemporánea', 7, 2),
('Comunicación y Cibercultura', 7, 2),
('Literatura para las Infancias y Juventudes', 7, 2),
('Biblioteca Escuela y Diversidades', 7, 2),
('Formación de Usuarias/os en Bibliotecas Educativas', 7, 2),
('Desarrollo y Gestión de Colecciones', 7, 2),
('Administración y Gestión de Bibliotecas II', 7, 2),
('Tecnologías Aplicadas a las Bibliotecas II', 7, 2),
('Análisis Documental Especializado en Educación', 7, 2),
('Descripción Documental Especializado en Educación', 7, 2),
('Práctica Profesionalizante II', 7, 2);

-- Inscripciones iniciales
INSERT INTO inscripciones (id_alumno, id_carrera, fecha_alta) VALUES
(5, 1, CURDATE()),
(6, 1, CURDATE());