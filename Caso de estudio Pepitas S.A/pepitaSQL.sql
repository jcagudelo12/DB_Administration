-- USE pepitas;
-- DROP DATABASE pepitas;

-- Create data base
CREATE DATABASE IF NOT EXISTS pepitas;

USE pepitas;

-- Create tables
CREATE TABLE IF NOT EXISTS turno_laboral (
	id_turno INT NOT NULL AUTO_INCREMENT,
    nombre_turno VARCHAR(50),
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
    nombre_referencia VARCHAR(70) UNIQUE,
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

CREATE TABLE IF NOT EXISTS prenda_ordinaria ( 
	id_referencia INT NOT NULL,
    costo_prod double,
    PRIMARY KEY(id_referencia),
    FOREIGN KEY(id_referencia) REFERENCES referencia(id_referencia)
);

CREATE TABLE IF NOT EXISTS prenda_lujo ( 
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
INSERT INTO turno_laboral (nombre_turno, hora_inicio, hora_fin) VALUES 
('Mañana', '08:00:00', '16:00:00'),
('Tarde', '16:00:00', '00:00:00'),
('Noche', '12:00:00', '08:00:00');

-- Inserción en la tabla supervisor
INSERT INTO supervisor (cedula_supervisor, nombre_supervisor) VALUES 
(123456789, 'Juan Pérez'),
(987654321, 'María González'),
(1212121212, 'Gabriel Agudelo'),
(1313131313, 'David Cadavid');

-- Inserción en la tabla trabaja
INSERT INTO trabaja (id_turno, cedula_supervisor, fecha_inicio, fecha_fin) VALUES 
(1, 123456789, '2023-09-01', '2023-09-30'),
(2, 987654321, '2023-09-01', '2023-09-30'),
(3, 1212121212, '2023-09-01', '2023-09-30');

-- Inserción en la tabla proceso_produccion
INSERT INTO proceso_produccion (nombre_proceso) VALUES ('Corte'),
('Corte de Telas'),
('Costura'),
('Estampado'),
('Teñido'),
('Bordado');

-- Inserción en la tabla supervisa
INSERT INTO supervisa (cedula_supervisor, id_proceso) VALUES 
(123456789, 1),
(987654321, 2),
(1212121212, 3);

-- Inserción en la tabla operario
INSERT INTO operario (cedula_operario, nombre_operario, id_proceso) VALUES 
(111111111, 'Pedro Gómez', 1),
(222222222, 'Luisa Torres', 2),
(333333333, 'Javier Zalazar', 3),
(444444444, 'Laura Fuentes', 4);

-- Inserción en la tabla referencia
INSERT INTO referencia (nombre_referencia) VALUES 
('CAMI001'),
('CAMI002'),
('CAMI003'),
('PANT001'),
('PANT002'),
('PANT003'),
('PANT004'),
('VEST001'),
('VEST002'),
('VEST003'),
('VEST004'),
('VEST005'),
('VEST006');

-- Inserción en la tabla lote_produccion
INSERT INTO lote_produccion (cant_unidades, id_referencia) VALUES 
(100, 1),
(150, 2),
(1000, 3),
(200, 4),
(600, 5),
(350, 6);

-- Inserción en la tabla interviene
INSERT INTO interviene (id_lote, cedula_operario, fecha_hora_inicio_trabajo) VALUES 
(1, 111111111, '2023-09-01 08:15:00'),
(2, 222222222, '2023-09-01 16:30:00'),
(1, 333333333, '2023-09-01 08:00:00'),
(2, 444444444, '2023-09-01 16:00:00');

-- Inserción en la tabla tiene_asignado
INSERT INTO tiene_asignado (id_lote, id_proceso, fecha_hora_ingreso) VALUES
(1, 1, '2023-09-01 08:00:00'),
(1, 2, '2023-09-01 10:30:00'),
(2, 2, '2023-09-02 09:15:00'),
(2, 3, '2023-09-02 12:45:00'),
(3, 3, '2023-09-03 07:30:00'),
(3, 4, '2023-09-03 11:00:00'),
(4, 4, '2023-09-04 08:45:00'),
(4, 5, '2023-09-04 13:15:00'),
(5, 5, '2023-09-05 07:00:00'),
(5, 1, '2023-09-05 10:30:00'),
(6, 1, '2023-09-06 09:15:00'),
(6, 2, '2023-09-06 12:45:00');


-- Inserción en la tabla materia_prima
INSERT INTO materia_prima (nombre_materia_prima, cantidad, stock_minimo) VALUES
('Tela de algodón', 500, 100),
('Hilo de poliéster', 800, 150),
('Cremalleras', 300, 50),
('Botones de plástico', 600, 100),
('Forro de satén', 400, 80),
('Encaje', 200, 40),
('Tela de lino', 350, 70),
('Hilo de seda', 750, 120),
('Cintas elásticas', 250, 60),
('Tela de denim', 600, 100),
('Cierres de metal', 350, 70),
('Tela de terciopelo', 400, 80),
('Lentejuelas', 150, 30),
('Tela de seda', 450, 90),
('Hilo de algodón', 700, 110),
('Bieses', 200, 40),
('Tela de poliéster', 550, 90),
('Botones de madera', 300, 60),
('Charreteras', 100, 20),
('Tela de tul', 250, 50);


-- Inserción en la tabla proveedor
INSERT INTO proveedor (nombre_proveedor, tipo_proveedor) VALUES
('Proveedor A', 'Nacional'),
('Proveedor B', 'Nacional'),
('Proveedor C', 'Nacional'),
('Proveedor D', 'Internacional'),
('Proveedor E', 'Internacional'),
('Proveedor F', 'Nacional'),
('Proveedor G', 'Nacional'),
('Proveedor H', 'Internacional'),
('Proveedor I', 'Nacional'),
('Proveedor J', 'Internacional');


-- Asociando proveedores con materias primas en la tabla suministrado
INSERT INTO suministrado (id_materia_prima, id_proveedor, cantidad) VALUES
(1, 1, 1000),
(2, 2, 800),
(3, 3, 500),
(4, 4, 700),
(5, 5, 400),
(6, 6, 200),
(7, 7, 350),
(8, 8, 750),
(9, 9, 250),
(10, 10, 600),
(1, 2, 900),
(2, 3, 750),
(3, 4, 450),
(4, 5, 600),
(5, 6, 300),
(6, 7, 250),
(7, 8, 500),
(8, 9, 800),
(9, 10, 350),
(10, 1, 700); 


-- Asociando referencias con materias primas en la tabla emplea
INSERT INTO emplea (id_referencia, id_materia_prima) VALUES
(1, 1),
(1, 2),
(2, 3),
(2, 4),
(3, 5),
(3, 6),
(4, 7),
(4, 8),
(5, 9),
(5, 10),
(6, 1),
(6, 2),
(7, 3),
(7, 4),
(8, 5),
(8, 6),
(9, 7),
(9, 8),
(10, 9),
(10, 10);  


-- Asociando todas las referencias con costos en la tabla prenda_ordinaria
INSERT INTO prenda_ordinaria (id_referencia, costo_prod) VALUES
(1, 25000.00),
(2, 18000.00),
(3, 12000.00),
(4, 15000.00),
(5, 22000.00),
(6, 8000.00);    


-- Asociando referencias con estratos en la tabla prenda_lujo
INSERT INTO prenda_lujo (id_referencia, estrato) VALUES
(7, 3),
(8, 4),
(9, 5),
(10, 6),
(11, 3),
(12, 4),
(13, 5);   
