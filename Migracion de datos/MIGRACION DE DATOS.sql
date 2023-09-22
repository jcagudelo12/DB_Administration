-- ************************************************************************* --
-- **                     MIGRACIÓN DE DATOS                              ** --
-- ************************************************************************* --

-- En ORACLE existe algo que se llama MULTITABLE INSERT, el cual permite migrar
-- datos de una tabla hacia otras tablas, según unos criterios definidos.
-- Existen cuatro (4) tipos de MULTITABLE INSERT:
-- ? INSERT ALL incondicional
-- ? INSERT ALL condicional
-- ? INSERT FIRST condicional
-- ? INSERT de pivote
-- Vamos a mirar cada uno de ellos con un ejemplo concreto.

-- Crear la siguiente tabla:
CREATE TABLE empleados
(cedula NUMBER PRIMARY KEY,
nombre VARCHAR2(50) NOT NULL,
edad NUMBER,
sexo VARCHAR2(1) NOT NULL,
sueldo NUMBER NOT NULL);

-- A dicha tabla insertarle los siguientes datos:

INSERT INTO empleados VALUES
(98541,'Lina Botero',52,'F',6200000);
INSERT INTO empleados VALUES
(43834,'Paula Betancur',NULL,'F',8100000);
INSERT INTO empleados VALUES
(12354,'Pedro Jaramillo',33,'M',4200000);
INSERT INTO empleados VALUES
(12345,'Sergio Arboleda',NULL,'M',8500000);
INSERT INTO empleados VALUES
(98765,'Patricia Restrepo',66,'F',3900000);
INSERT INTO empleados VALUES
(56012,'Carlos Pinto',30,'M',1500000);

SELECT * FROM EMPLEADOS;

-- Crear las siguientes tablas:

CREATE TABLE empleados_hombres
(cedula NUMBER PRIMARY KEY,
nombre VARCHAR2(50) NOT NULL,
edad NUMBER);

CREATE TABLE empleados_mujeres
(cedula NUMBER PRIMARY KEY,
nombre VARCHAR2(50) NOT NULL,
sueldo NUMBER NOT NULL);

CREATE TABLE empleados_para_gerencia
(cedula NUMBER PRIMARY KEY,
nombre VARCHAR2(50) NOT NULL,
sueldo NUMBER NOT NULL);

CREATE TABLE empleados_para_produccion
(cedula NUMBER PRIMARY KEY,
nombre VARCHAR2(50) NOT NULL,
edad NUMBER);

CREATE TABLE sueldos_bajos
(cedula NUMBER PRIMARY KEY,
nombre VARCHAR2(50) NOT NULL,
sueldo NUMBER NOT NULL);

CREATE TABLE sueldos_medios
(cedula NUMBER PRIMARY KEY,
nombre VARCHAR2(50) NOT NULL,
sueldo NUMBER NOT NULL);

CREATE TABLE sueldos_altos
(cedula NUMBER PRIMARY KEY,
nombre VARCHAR2(50) NOT NULL,
sueldo NUMBER NOT NULL);

-- Vamos a implementar un INSERT ALL incondicional.

INSERT ALL
INTO empleados_para_gerencia VALUES (CED,NOM,SAL)
INTO empleados_para_produccion VALUES (CED,NOM,ED)
SELECT cedula CED, nombre NOM, edad ED, sueldo SAL
FROM empleados;

-- El INSERT ALL incondicional ejecuta el query (SELECT) e inserta TODAS
-- las tuplas devueltas en las tablas que se encuentran en la sección INTO.

SELECT * FROM EMPLEADOS_PARA_GERENCIA;
SELECT * FROM EMPLEADOS_PARA_PRODUCCION;

-- Vamos a implementar un INSERT ALL condicional.

INSERT ALL
WHEN SX='M' THEN
INTO empleados_hombres VALUES (CED,NOM,ED)
WHEN SX='F' THEN
INTO empleados_mujeres VALUES (CED,NOM,SAL)
SELECT cedula CED, nombre NOM, edad ED, sueldo SAL, sexo SX
FROM empleados;

-- El INSERT ALL condicional ejecuta el query (SELECT) y dependiendo de
-- unas condiciones especificadas en la sección WHEN, inserta los datos en
-- tablas específicas.
-- Este INSERT ALL también puede manejar la cláusula ELSE.
-- INSERT ALL
-- WHEN ……… THEN
-- INTO …….. VALUES …….
-- WHEN ……… THEN
-- INTO ………. VALUES ………
-- ELSE
-- INTO ……….. VALUES ………
-- SELECT ………………..
-- FROM …………..

SELECT * FROM empleados_hombres;
SELECT * FROM empleados_mujeres;

-- Vamos a implementar un INSERT FIRST condicional.

INSERT FIRST
WHEN SAL < 3000000 THEN
INTO sueldos_bajos VALUES (CED,NOM,SAL)
WHEN SAL BETWEEN 3000000 AND 5000000 THEN
INTO sueldos_medios VALUES (CED,NOM,SAL)
ELSE
INTO sueldos_altos VALUES (CED,NOM,SAL)
SELECT cedula CED, nombre NOM, sueldo SAL
FROM empleados;

-- El INSERT FIRST ejecuta el query (SELECT) y empieza a evaluar las
-- condiciones de la sección WHEN, de arriba para abajo. Y cuando se cumpla
-- una condición, inserta en esa tabla y no sigue evaluando las otras
-- condiciones. Por eso se llama FIRST, solo ejecuta la primera condición que
-- se cumpla.

SELECT * FROM sueldos_bajos;
SELECT * FROM sueldos_medios;
SELECT * FROM sueldos_altos;

-- Ahora, implementemos un INSERT de pivote.
-- Supongamos las siguientes tablas, las cuales vamos a crear. La tabla
-- ventas_x_semana no está normalizada y refleja las ventas hechas por un
-- vendedor, en una semana dada y en cada uno de los días de esa semana,
-- de lunes a viernes.

CREATE TABLE ventas_x_semana
(cedulaven NUMBER,
semana NUMBER,
ventas_lunes NUMBER NOT NULL,
ventas_martes NUMBER NOT NULL,
ventas_miercoles NUMBER NOT NULL,
ventas_jueves NUMBER NOT NULL,
ventas_viernes NUMBER NOT NULL,
PRIMARY KEY(cedulaven,semana));

-- Insertemos el siguiente dato:

INSERT INTO ventas_x_semana VALUES
(100, 6, 520, 850, 41, 0, 56);

-- Crear la siguiente tabla, la cual ya está normalizada.

CREATE TABLE ventas_normalizada
(cedula_vendedor NUMBER NOT NULL,
semana NUMBER NOT NULL,
ventas NUMBER not null);

-- Ahora hagamos el INSERT de pivote:

INSERT ALL
INTO ventas_normalizada VALUES (cedulaven,semana,ventas_lunes)
INTO ventas_normalizada VALUES (cedulaven,semana,ventas_martes)
INTO ventas_normalizada VALUES (cedulaven,semana,ventas_miercoles)
INTO ventas_normalizada VALUES (cedulaven,semana,ventas_jueves)
INTO ventas_normalizada VALUES (cedulaven,semana,ventas_viernes)
SELECT cedulaven, semana, ventas_lunes, ventas_martes,
ventas_miercoles, ventas_jueves, ventas_viernes
FROM ventas_x_semana;

SELECT * FROM ventas_normalizada;

-- Como se puede observar, lo que se hizo fue pivotear (es decir, pasar de
-- filas a columnas) las ventas de la tabla ventas_x_semana hacia la tabla
-- ventas_normalizada.

-- ************************************************************************** --
-- **                           MERGE                                      ** --
-- ************************************************************************** --

-- Hacer un merge significa “cruzar” los datos de dos tablas. En este cruce hay
-- una tabla origen y una tabla destino. El merge recorre la tabla origen, tupla
-- por tupla, y verifica si existe en la tabla destino. Si en la tabla destino, la tupla
-- no existe, se inserta; si en la tabla destino la tupla existe, se actualiza. Y hay
-- una cláusula para borrar registros de la tabla destino.

-- Crear la tabla copia_empleados:

CREATE TABLE copia_empleados
(cedula NUMBER PRIMARY KEY,
nombre VARCHAR2(50) NOT NULL,
edad NUMBER,
sueldo NUMBER NOT NULL);

-- Vamos a hacer un MERGE donde la tabla origen es EMPLEADO y la tabla
-- destino es COPIA_EMPLEADOS.

MERGE INTO copia_empleados c
USING (SELECT * FROM empleados)
e ON (c.cedula = e.cedula)
WHEN MATCHED THEN
UPDATE SET
c.nombre = e.nombre,
c.edad = e.edad,
c.sueldo = e.sueldo
WHEN NOT MATCHED THEN
INSERT VALUES (e.cedula, e.nombre, e.edad, e.sueldo);

SELECT * FROM copia_empleados;

-- Los 6 empleados que hay grabados en EMPLEADOS quedaron grabados en
-- COPIA_EMPLEADOS. Como la tabla destino estaba vacía, lo que se hizo
-- fueron 6 INSERTS.

-- Miremos cómo funciona el MERGE cuando ejecuta, al mismo tiempo, el
-- UPDATE y el INSERT.

-- Insertemos un nuevo empleado en la tabla EMPLEADOS:

INSERT INTO empleados VALUES
(14000,'Roberto Castro',36,'M',4500000);

-- Luego actualicemos algunos datos de empleados:

UPDATE empleados
SET edad = 19
WHERE cedula = 43834;

UPDATE empleados
SET sueldo = 9000000
WHERE cedula = 12345;

-- Volvamos a ejecutar el MERGE anterior y miremos como quedó la tabla
-- COPIA_EMPLEADOS.

-- Nótese que en COPIA_EMPLEADOS ya aparece el empleado recién
-- insertado (Roberto Castro) y aparecen actualizados la edad y el sueldo de
-- los empleados 43834 y 12345 respectivamente.
-- En esta segunda ejecución del MERGE se puede comprobar la ejecución del
-- UPDATE y del INSERT al mismo tiempo.

-- La instrucción MERGE también tiene la opción de borrar tuplas.

-- Miremos el MERGE anterior con la cláusula DELETE.

MERGE INTO copia_empleados c
USING (SELECT * FROM empleados)
e ON (c.cedula = e.cedula)
WHEN MATCHED THEN
UPDATE SET
c.nombre = e.nombre,
c.edad = e.edad,
c.sueldo = e.sueldo
DELETE WHERE (e.sueldo > 8800000)
WHEN NOT MATCHED THEN
INSERT VALUES (e.cedula, e.nombre, e.edad, e.sueldo);

SELECT * FROM copia_empleados;

-- Nótese que en COPIA_EMPLEADOS se borró al empleado con cedula
-- 12345, el cual tenía un sueldo mayor a 8800000.

-- IMPORTANTE: Este DELETE funciona solamente para los registros
-- actualizados con el UPDATE, no para todos los registros existentes.
-- Verificarlo.

