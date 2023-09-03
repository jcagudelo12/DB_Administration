-- USE pepitas;
-- DROP DATABASE pepitas;

-- Create data base
CREATE DATABASE IF NOT EXISTS pepitas;

USE pepitas;

-- Create tables
CREATE TABLE IF NOT EXISTS turno_laboral (
	id_turno INT NOT NULL AUTO_INCREMENT,
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL,
    PRIMARY KEY (id_turno)      
);

CREATE TABLE IF NOT EXISTS supervisor (
	cedula_supervisor INT NOT NULL,
    nombre_supervisor VARCHAR(120),
    PRIMARY KEY (cedula_supervisor)
);

CREATE TABLE IF NOT EXISTS trabaja ( 
	id_turno INT NOT NULL,
    cedula_supervisor INT NOT NULL,
    fecha_inicio DATE,
    fecha_fin DATE,
    PRIMARY KEY (id_turno, cedula_supervisor),
    FOREIGN KEY (id_turno) REFERENCES turno_laboral(id_turno),
    FOREIGN KEY (cedula_supervisor) REFERENCES supervisor(cedula_supervisor)
);

CREATE TABLE IF NOT EXISTS proceso_produccion (
	id_proceso SMALLINT NOT NULL AUTO_INCREMENT,
    nombre_proceso varchar(50) NOT NULL,
    PRIMARY KEY(id_proceso)
);

CREATE TABLE IF NOT EXISTS supervisa (
	cedula_supervisor INT NOT NULL,
    id_proceso SMALLINT NOT NULL,
    PRIMARY KEY (id_proceso, cedula_supervisor),
    FOREIGN KEY (id_proceso) REFERENCES proceso_produccion(id_proceso),
    FOREIGN KEY (cedula_supervisor) REFERENCES supervisor(cedula_supervisor)
);

CREATE TABLE IF NOT EXISTS operario (
	cedula_operario int NOT NULL,
    nombre_operario varchar(120) NOT NULL,
    id_proceso SMALLINT,
    PRIMARY KEY (cedula_operario),
    FOREIGN KEY (id_proceso) REFERENCES proceso_produccion(id_proceso)
);

CREATE TABLE IF NOT EXISTS referencia (
	id_referencia INT NOT NULL AUTO_INCREMENT,
    nombre_referencia VARCHAR(70),
    PRIMARY KEY(id_referencia)
);

CREATE TABLE IF NOT EXISTS lote_produccion (
	id_lote int NOT NULL AUTO_INCREMENT,
    cant_unidades int,
    id_referencia int,
    PRIMARY KEY(id_lote),
    FOREIGN KEY(id_referencia) REFERENCES referencia(id_referencia)
);

CREATE TABLE IF NOT EXISTS interviene (
    id_lote INT NOT NULL,
    cedula_operario INT NOT NULL,
    fecha_hora_inicio_trabajo DATETIME NOT NULL,
    PRIMARY KEY (id_lote, cedula_operario),
    FOREIGN KEY (id_lote) REFERENCES lote_produccion(id_lote),
    FOREIGN KEY (cedula_operario) REFERENCES operario(cedula_operario)
);

CREATE TABLE IF NOT EXISTS tiene_asignado (
    id_lote INT NOT NULL,
    id_proceso SMALLINT NOT NULL,
    fecha_hora_ingreso DATETIME NOT NULL,
    PRIMARY KEY (id_lote, id_proceso),
    FOREIGN KEY (id_lote) REFERENCES lote_produccion(id_lote),
    FOREIGN KEY (id_proceso) REFERENCES proceso_produccion(id_proceso)
);

CREATE TABLE IF NOT EXISTS ordinaria ( 
	id_referencia INT NOT NULL,
    costo_prod double,
    PRIMARY KEY(id_referencia),
    FOREIGN KEY(id_referencia) REFERENCES referencia(id_referencia)
);

CREATE TABLE IF NOT EXISTS lujo ( 
	id_referencia INT NOT NULL,
    estrato SMALLINT,
    PRIMARY KEY(id_referencia),
    FOREIGN KEY(id_referencia) REFERENCES referencia(id_referencia)
);

CREATE TABLE IF NOT EXISTS materia_prima (
	id_materia_prima INT NOT NULL AUTO_INCREMENT,
    nombre_materia_prima VARCHAR(200) NOT NULL,
    cantidad double,
    stock_minimo double,
    PRIMARY KEY (id_materia_prima)
);

CREATE TABLE IF NOT EXISTS emplea (
	id_referencia INT NOT NULL, 
    id_materia_prima INT NOT NULL,
    PRIMARY KEY (id_referencia, id_materia_prima),
    FOREIGN KEY (id_referencia) REFERENCES referencia(id_referencia),
    FOREIGN KEY (id_materia_prima) REFERENCES materia_prima(id_materia_prima)
);

CREATE TABLE IF NOT EXISTS proveedor (
	id_proveedor INT NOT NULL AUTO_INCREMENT,
    nombre_proveedor VARCHAR(50) NOT NULL,
    tipo_proveedor VARCHAR(20),
    PRIMARY KEY (id_proveedor)
);

CREATE TABLE IF NOT EXISTS suministrado (
	id_materia_prima INT NOT NULL,
    id_proveedor INT NOT NULL,
    cantidad double,
    PRIMARY KEY (id_materia_prima, id_proveedor),
    FOREIGN KEY (id_materia_prima) REFERENCES materia_prima(id_materia_prima),
    FOREIGN KEY (id_proveedor) REFERENCES proveedor(id_proveedor)
);


-- Inserciones

-- Inserción en la tabla turno_laboral
INSERT INTO turno_laboral (hora_inicio, hora_fin) VALUES ('08:00:00', '16:00:00');
INSERT INTO turno_laboral (hora_inicio, hora_fin) VALUES ('16:00:00', '00:00:00');
INSERT INTO turno_laboral (hora_inicio, hora_fin) VALUES ('12:00:00', '21:00:00');

-- Inserción en la tabla supervisor
INSERT INTO supervisor (cedula_supervisor, nombre_supervisor) VALUES (123456789, 'Juan Pérez');
INSERT INTO supervisor (cedula_supervisor, nombre_supervisor) VALUES (987654321, 'María González');

-- Inserción en la tabla trabaja
INSERT INTO trabaja (id_turno, cedula_supervisor, fecha_inicio, fecha_fin) VALUES (1, 123456789, '2023-09-01', '2023-09-30');
INSERT INTO trabaja (id_turno, cedula_supervisor, fecha_inicio, fecha_fin) VALUES (2, 987654321, '2023-09-01', '2023-09-30');

-- Inserción en la tabla proceso_produccion
INSERT INTO proceso_produccion (nombre_proceso) VALUES ('Corte');
INSERT INTO proceso_produccion (nombre_proceso) VALUES ('Estampacion y bordado');
INSERT INTO proceso_produccion (nombre_proceso) VALUES ('Union de mangas');
INSERT INTO proceso_produccion (nombre_proceso) VALUES ('Coser cuellos');
INSERT INTO proceso_produccion (nombre_proceso) VALUES ('Coser cuellos');

-- Inserción en la tabla supervisa
INSERT INTO supervisa (cedula_supervisor, id_proceso) VALUES (123456789, 1);
INSERT INTO supervisa (cedula_supervisor, id_proceso) VALUES (987654321, 2);

-- Inserción en la tabla operario
INSERT INTO operario (cedula_operario, nombre_operario, id_proceso) VALUES (111111111, 'Pedro Gómez', 1);
INSERT INTO operario (cedula_operario, nombre_operario, id_proceso) VALUES (222222222, 'Luisa Torres', 2);

-- Inserción en la tabla referencia
INSERT INTO referencia (nombre_referencia) VALUES ('Referencia X');
INSERT INTO referencia (nombre_referencia) VALUES ('Referencia Y');

-- Inserción en la tabla lote_produccion
INSERT INTO lote_produccion (cant_unidades, id_referencia) VALUES (100, 1);
INSERT INTO lote_produccion (cant_unidades, id_referencia) VALUES (150, 2);

-- Inserción en la tabla interviene
INSERT INTO interviene (id_lote, cedula_operario, fecha_hora_inicio_trabajo) VALUES (1, 111111111, '2023-09-01 08:15:00');
INSERT INTO interviene (id_lote, cedula_operario, fecha_hora_inicio_trabajo) VALUES (2, 222222222, '2023-09-01 16:30:00');

-- Inserción en la tabla tiene_asignado
INSERT INTO tiene_asignado (id_lote, id_proceso, fecha_hora_ingreso) VALUES (1, 1, '2023-09-01 08:00:00');
INSERT INTO tiene_asignado (id_lote, id_proceso, fecha_hora_ingreso) VALUES (2, 2, '2023-09-01 16:00:00');


