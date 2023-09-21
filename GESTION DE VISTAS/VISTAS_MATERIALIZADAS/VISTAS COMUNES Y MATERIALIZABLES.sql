-- ****************************************************************** --
-- **                         VISTAS COMUNES                       ** --
-- ****************************************************************** --

-- CREAR LAS SIGUIENTES TABLAS:

CREATE TABLE EMPLEADO
(CEDULA NUMBER PRIMARY KEY,
NOMBRE VARCHAR2(40) NOT NULL,
EDAD NUMBER,
SUELDO NUMBER,
CODCARGO NUMBER);

CREATE TABLE CARGO
(CODIGO NUMBER PRIMARY KEY,
NOMBRE VARCHAR2(40) NOT NULL,
CATEGORIA NUMBER);

ALTER TABLE EMPLEADO
ADD FOREIGN KEY(CODCARGO)
REFERENCES CARGO(CODIGO);

-- INSERTAR LOS SIGUIENTES DATOS SOBRE LAS TABLAS CREADAS.

INSERT INTO CARGO VALUES (10,'Gerente General',1);
INSERT INTO CARGO VALUES (20,'Gerente de Produccion',2);
INSERT INTO CARGO VALUES (30,'Administrador de Planta',3);
INSERT INTO CARGO VALUES (40,'Gerente Financiero',2);
INSERT INTO CARGO VALUES (50,'Jefe de Sistemas',3);
INSERT INTO CARGO VALUES (60,'DBA' ,3);
INSERT INTO CARGO VALUES (70,'Analista de Sistemas',4);

SELECT * FROM CARGO;

INSERT INTO EMPLEADO VALUES (100,'Luis Franco',33,1500000,20);
INSERT INTO EMPLEADO VALUES (200,'Ana Velasco',58,3600000,40);
INSERT INTO EMPLEADO VALUES (300,'Paula Isaza',24,910000,60);
INSERT INTO EMPLEADO VALUES (400,'Jose Velez',77,2900000,20);
INSERT INTO EMPLEADO VALUES (500,'Ximena Torres',21,810000,70);
INSERT INTO EMPLEADO VALUES (600,'Cristina Galeano',31,990000,10);
INSERT INTO EMPLEADO VALUES (700,'Noe Rosales',66,2600000,20);

SELECT * FROM EMPLEADO;

-- CREAR LAS SIGUIENTES DOS VISTAS

CREATE VIEW vista1 AS
SELECT nombre, edad, sueldo
FROM empleado
WHERE edad >= 30
WITH READ ONLY;

CREATE VIEW vista2 AS
SELECT cedula, nombre, edad
FROM empleado
WHERE sueldo > 2000000;

-- MIREMOS QUE METADATOS ALMACENA REFERENTES A LAS VISTAS CREADAS
-- QUÉ SIGNIFICA EL RESULTADO?

SELECT text
FROM user_views
WHERE view_name = 'VISTA1';

SELECT text
FROM user_views
WHERE view_name = 'VISTA2';

-- MIREMOS EL CONTENIDO DE LA VISTA LLAMADA VISTA2. APARECE UN EMPLEADO LLAMADO
-- NOE ROSALES?

SELECT *
FROM vista2;

-- ACTUALICEMOSLE AL EMPLEADO CON CEDULA 700 SU SUELDO. HACER ESTO EN LA TABLA
-- BASE.

UPDATE empleado
SET sueldo = 580000
WHERE cedula = 700;

-- VOLVAMOS A CONSULTAR LA VISTA. APARECE NOE ROSALES? POR QUE SUCEDE ESTO?

SELECT *
FROM vista2;

-- MIREMOS LOS DATOS DEL EMPLEADO CON CEDULA 200.

SELECT * FROM vista2 WHERE CEDULA = 200;

-- A TRAVES DE LA VISTA, A ESE EMPLEADO CON CEDULA 200 SUMEMOSLE UNO A LA EDAD.

UPDATE vista2
SET edad = edad + 1
WHERE cedula = 200;

-- CONSULTEMOS DE NUEVO LA VISTA. LA EDAD DEL EMPLEADO 200 SUBIO EN UNO?

SELECT * FROM VISTA2;

-- Y LA EDAD DEL EMPLEADO 200 QUEDO SUMADO EN UNO EN LA TABLA BASE?

SELECT *
FROM empleado
WHERE cedula = 200;   -- SIGNIFICA QUE LA VISTA VISTA2 ES ACTUALIZABLE.

-- AHORA, A TRAVÉS DE LA VISTA, TRATEMOS DE SUMARLE UNO A LA EDAD DE LUIS FRANCO.
-- QUÉ SUCEDE? POR QUE SUCEDE ESTO?
UPDATE vista1
SET edad = edad + 1
WHERE nombre = 'Luis Franco'

-- CREEMOS LA SIGUIENTE VISTA. QUÉ SUCEDE?

CREATE VIEW vista3 AS
SELECT e.nombre, e.edad, c.nombre
FROM empleado e INNER JOIN cargo c
ON e.codcargo = c.codigo
WHERE e.edad < 50;

-- SE CORRIGE ASI...

CREATE VIEW vista3 AS
SELECT e.nombre, e.edad, c.nombre AS NOMBRECARGO
FROM empleado e INNER JOIN cargo c
ON e.codcargo = c.codigo
WHERE e.edad < 50;

-- MIREMOS EL CONTENIDO DE LA VISTA VISTA3

SELECT * FROM VISTA3;

-- HAGAMOS ESTA MODIFICACION A TRAVÉS DE LA VISTA

UPDATE vista3
SET nombre = 'Cristina Galeano Hernandez'
WHERE nombre = 'Cristina Galeano';

-- AHORA MIREMOS SI LA MODIFICACION ANTERIOR QUEDO HECHA.

SELECT * FROM VISTA3;

-- POR QUE LA MODIFICACIÓN SIGUIENTE NO FUNCIONA?

UPDATE vista3
SET sueldo = 5900000
WHERE nombre = 'Cristina Galeano Hernandez';

-- POR QUE LA MODIFICACIÓN SIGUIENTE SACA ERROR?

UPDATE vista3
SET nombrecargo = 'DBA'
WHERE nombre = 'Cristina Galeano Hernandez';

-- CREEMOS LA SIGUIENTE VISTA PARA MIRAR QUE HACE LA CLAUSULA WITH CHECK OPTION.

CREATE VIEW vista4 AS
SELECT cedula, nombre, edad, sueldo
FROM empleado
WHERE sueldo < 2000000
WITH CHECK OPTION;

-- INSERTEMOS ESTE DATO A TRAVÉS DE LA VISTA? FUNCIONO?

INSERT INTO vista4 VALUES
(900, 'Ricardo Marin', 56, 1900000);

-- INSERTEMOS ESTE OTRO DATO A TRAVES DE LA VISTA? QUE SUCEDIO?

INSERT INTO vista4 VALUES
(1000, 'Melissa Arboleda', 31, 3400000);

-- ****************************************************************** --
-- **                         VISTAS MATERIALIZABLES               ** --
-- ****************************************************************** --
-- Una vista materializable se comporta igual que una vista común. La
-- diferencia es que las vistas materializables almacenan el resultado de
-- la consulta, además de la instrucción.
-- El resultado de las vistas materializables se actualizan periódicamente
-- y puede ser ante las siguientes situaciones:
--     1. Automáticamente cuando se le hace commit a alguna de las
--       tablas bases.
--     2. Automáticamente en un horario predefinido.
--     3. En forma manual.
-- Hay que tener cuidado con los casos 2 y 3 ya que pueden generar un
-- cuello de botella. Lo ideal es hacerlo en un horario donde no haya
-- mucho movimiento en la base de datos (de madrugada, por ejemplo).
-- Para el primer caso, es recomendable cuando el commit implica
-- gestionar pocos datos. Cuando el commit es “masivo”, es decir, de
-- muchos datos, esta opción podría influir en el rendimiento del sistema.

-- Tipos de actualizaciones en una vista materializable.
-- La actualización de una vista materializable puede ser:
--    1. Completa: Implica, por cada actualización, borrar todos los datos
--       de la vista y volverla a cargar de datos.
--    2. Fast: A través de un log de movimientos de la vista, la
--       actualización de la misma va a ser incremental, es decir, va a
--       actualizar los últimos cambios hechos sobre ella.
--    3. Force: El sistema define si lo hace Fast o Completa.

-- Vamos a crear una vista materializable:
-- Se puede notar que la ejecución demora un poco ya que está
-- construyendo el resultado y lo está almacenando.
-- ON DEMAND significa actualización manual.

CREATE MATERIALIZED VIEW vista8
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND
AS
SELECT cedula, nombre, edad
FROM empleado
WHERE edad < 40;

-- Verifiquemos que la vista haya quedado cargada de datos. 

SELECT * FROM vista8;

-- Creemos otra vista materializable:
-- BUILD DEFERRRED CREA LA VISTA SIN LOS DATOS, SOLO CON LA ESTRUCTURA
CREATE MATERIALIZED VIEW vista9
BUILD DEFERRED
REFRESH COMPLETE ON DEMAND
AS
SELECT cedula, nombre, edad
FROM empleado
WHERE edad < 40;

-- Ahora miremos los datos de esta nueva vista:

SELECT * FROM vista9;

-- Qué sucede? Por qué no salen datos en el resultado? Cual es el efecto
-- de la cláusula BUILD DEFERRED?

-- Consultemos en el diccionario de datos donde quedó la información de
-- las vistas materializables.

SELECT object_type FROM user_objects
WHERE object_name = 'VISTA8';

-- También en la vista llamada user_mviews está la información de las
-- vistas materializables del usuario.

SELECT query, query_len, refresh_mode, refresh_method,
build_mode
FROM user_mviews
WHERE mview_name = 'VISTA8';

-- Insertemos, en la tabla EMPLEADO (Tabla base de vista8 y vista9), un
-- nuevo empleado cuya edad es menor a 40.

INSERT INTO empleado VALUES (250,'Lina Osorio',39,5600000,NULL);

-- Luego consultemos la información almacenada en la vista “vista8”.
-- Aparece el nuevo empleado?
SELECT * FROM vista8;

-- Para hacer el refresco manual de la vista ejecutamos lo siguiente:

exec dbms_mview.refresh('VISTA8');

-- Ahora revise si aparece el nuevo empleado insertado en el paso
-- anterior.

SELECT * FROM vista8;

-- Y en la vista9 que sucede?

SELECT * FROM VISTA9;

-- Refresque la vista “vista9”. Ahora sí le aparecen los datos cargados.

exec dbms_mview.refresh('VISTA9');

-- Ya vista9 aparece con datos?

SELECT * FROM VISTA9;

-- Ensayemos el refresco de la vista al hacerle commit a una de las tablas
-- base. Esto se debe hacer desde otro usuario diferente a SYS, ya que
-- en SYS no deja crear logs.

CREATE MATERIALIZED VIEW vista10
BUILD IMMEDIATE
REFRESH COMPLETE ON COMMIT
AS
SELECT cedula, nombre, edad
FROM empleado
WHERE edad < 40;

-- Insertemos un nuevo empleado:

INSERT INTO empleado VALUES
(251,'Pedro Suarez',25,630000,NULL);

-- Consultemos la vista……aun no aparece Pedro Suarez. 

SELECT * FROM VISTA10;

-- Hagamos commit a la transacción

COMMIT WORK;

-- Ahora, de nuevo, consultemos la vista. Aparece Pedro Suarez?

SELECT * FROM VISTA10;

-- Ensayemos una vista cuyo refresco se haga cada 2 minutos.

CREATE MATERIALIZED VIEW vista11
BUILD IMMEDIATE
REFRESH COMPLETE START WITH SYSDATE
NEXT (SYSDATE + 2/1440)
AS
SELECT e.cedula, e.nombre, e.edad, c.nombre AS nombrecargo
FROM empleado e INNER JOIN cargo c
ON e.codcargo = c.codigo
WHERE e.edad < 40;

SELECT * FROM VISTA11;

-- Actualicemos la edad de un empleado
UPDATE empleado SET edad = 39
WHERE cedula = 100;
COMMIT WORK;

-- No se empiezan a contar los 2 minutos hasta que se le haga commit a
-- la transacción.

SELECT * FROM empleado;
SELECT * FROM VISTA11;
-- En la vista aparece todavía la edad anterior.
-- Esperemos aproximadamente 2 minutos y volvamos a consultar la
-- vista.

-- De donde sale el 2 / 1440?

-- Para hacer un REFRESH de tipo FAST, primero se le debe crear un
-- log a la tabla base de la vista.

-- OJO: ORACLE no deja crear logs sobre tablas cuyo propietario es SYS.
-- Por lo tanto, debemos pasarnos para otro usuario.
-- Creemos otro usuario y le damos todos los privilegios.
-- Nos conectamos al esquema del usuario recién creado.

-- Creamos la tabla ASISTENTE:

CREATE TABLE ASISTENTE
(CEDULA NUMBER PRIMARY KEY,
NOMBRE VARCHAR2(40) NOT NULL);

-- CREEMOS EL LOG DE LA VISTA MATERIALIZABLE

CREATE MATERIALIZED VIEW LOG ON ASISTENTE;

-- Para revisar el contenido del LOG, hacer lo siguiente:

SELECT * FROM mlog$_asistente;  -- ESTA VACIO?

-- Y luego se crea la vista de la forma aprendida acá: 

CREATE MATERIALIZED VIEW vista12
BUILD IMMEDIATE
REFRESH FAST ON DEMAND
AS
SELECT cedula, nombre
FROM ASISTENTE
WHERE nombre LIKE 'P%';

-- De esta manera, cada vez que re refresque la vista, no la va a
-- reconstruir completamente (REFRESH COMPLETE) sino que la va a
-- reconstruir con base en los últimos cambios hechos a la tabla.

-- Insertemos tres asistentes en la tabla base:
INSERT INTO ASISTENTE VALUES (250, 'Carlos Giraldo');
INSERT INTO ASISTENTE VALUES (350,'Pablo Lopez');
INSERT INTO ASISTENTE VALUES (450,'Paula Sierra');

-- Al volver a consultar el log, vemos tres tuplas que nos dicen que
-- acabamos de insertar empleados con cedula 250, 350 y 450.
SELECT * FROM mlog$_asistente;

-- Ahora refresquemos la vista:

Exec dbms_mview.refresh('VISTA12');

-- Qué sucede con la vista? Y con el log?

SELECT * FROM VISTA12;
SELECT * FROM mlog$_asistente;