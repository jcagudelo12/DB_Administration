-- ************************************************************** --
-- **                 GESTI�N DE �NDICES                       ** --
-- ************************************************************** --

-- CREAR LA TABLA CARGO1
CREATE TABLE CARGO1
(CODIGO NUMBER PRIMARY KEY, NOMBRE VARCHAR2(50) NOT NULL);

-- INSERTEMOS LOS SIGUIENTES CARGOS:

INSERT INTO CARGO1 VALUES (10,'GERENTE');
INSERT INTO CARGO1 VALUES (20,'OPERARIO'); 
INSERT INTO CARGO1 VALUES (30,'SUPERVISOR'); 
INSERT INTO CARGO1 VALUES (40,'ANALISTA'); 
INSERT INTO CARGO1 VALUES (50,'ADMINISTRADOR');

SELECT * FROM CARGO1;
-- CREAR LA TABLA EMPLEADO1
CREATE TABLE EMPLEADO1
(CEDULA NUMBER PRIMARY KEY, 
NOMBRE VARCHAR2(30),
EDAD NUMBER, 
CODCARGO NUMBER);

ALTER TABLE EMPLEADO1 ADD FOREIGN KEY(CODCARGO) REFERENCES CARGO1(CODIGO);

 -- INSERTEMOS EMPLEADOS.
 
INSERT INTO EMPLEADO1 VALUES (1000,'Luis Ojeda', 25,20); 
INSERT INTO EMPLEADO1 VALUES (2000,'Paula Betancur', 55,10); 
INSERT INTO EMPLEADO1 VALUES (3000,'Andres Ortiz', 60,20); 
INSERT INTO EMPLEADO1 VALUES (4000,'Esmeralda Porras', 30,40);

-- VAMOS A CONSULTAR LOS METADATOS DE LOS INDICES DE LAS DOS TABLAS CREADAS.

SELECT index_name, index_type, table_name, tablespace_name  
FROM all_indexes
WHERE table_name = 'CARGO1';

SELECT index_name, index_type, table_name, tablespace_name 
FROM all_indexes
WHERE table_name = 'EMPLEADO1';

-- Cada tabla aparece ya con un �ndice creado. Por que?

-- C�mo sabemos, los �ndices que tiene una tabla, por cual columna(s) son? 
-- Consultar la vista ALL_IND_COLUMNS.

SELECT *
FROM ALL_IND_COLUMNS
WHERE table_name = 'CARGO1';

SELECT *
FROM ALL_IND_COLUMNS
WHERE table_name = 'EMPLEADO1';


-- Crearle a la tabla CARGO1 un �ndice �nico por el campo Nombre.

CREATE UNIQUE INDEX in_nombre ON CARGO1(nombre);

-- Volver a consultar los �ndices que tiene la tabla CARGO1. 
-- Ya debe aparecer el indice �in_nombre�.

-- Tratemos de insertar un nuevo cargo, pero que tenga el mismo nombre de 
-- uno que ya exista.

INSERT INTO CARGO1 VALUES (60,'ANALISTA');   -- Qu� sucede?
--No se permite el insert debido a que nombre ahora es un �ndice, por lo cual debe de ser �nico

-- Vamos a monitorear el uso de un �ndice. Creemos el siguiente �ndice:

CREATE INDEX em_edad ON EMPLEADO1(edad);

-- Para activar el monitoreo del �ndice, ejecutamos...

ALTER INDEX em_edad MONITORING USAGE;

-- Ahora hagamos una consulta sobre la tabla EMPLEADO1.

SELECT * FROM EMPLEADO1 WHERE cedula = 1000;

-- Como se sabe si el indice fue utilizado al ejecutar la anterior consulta?

SELECT *
FROM v$object_usage
WHERE table_name = 'EMPLEADO1';   -- QU� VALOR TIENE EL CAMPO USED?

-- Ahora ejecutemos la siguiente consulta:
SELECT * 
FROM EMPLEADO1
WHERE edad = 55;

-- Y volvamos a mirar si con la consulta anterior el �ndice se us�.

-- La vista v$object_usage, del diccionario de datos, permite saber el uso 
-- de los �ndices. Si un �ndice ha sido usado por lo menos una vez, 
-- aparece en esta vista.

-- Para desactivar el monitoreo de un �ndice se ejecuta:

ALTER INDEX em_edad NOMONITORING USAGE;

-- Que sucede en v$object_usage para esta tabla luego de deshabilitar el monitoreo?

-- Otra manera de saber si un �ndice fue usado o no en una consulta es mirar 
-- el plan de ejecuci�n de la misma. Para ello hacemos lo siguiente:

EXPLAIN PLAN FOR
SELECT * FROM EMPLEADO1 WHERE cedula = 1000;

-- Esto �explica� la ejecuci�n de la consulta y dicha explicaci�n la graba en la 
-- tabla PLAN_TABLE. Por lo tanto, debemos consultar dicha tabla, usando un 
-- procedimiento almacenado disponible en Oracle:

SELECT PLAN_TABLE_OUTPUT
FROM TABLE(DBMS_XPLAN.DISPLAY());

-- Como se puede ver en el resultado, hay un escaneo al �ndice creado por la 
-- clave primaria.

-- NOTA: El hecho de que un campo tenga un �ndice asociado, no significa que 
-- SIEMPRE se va a usar dicho �ndice para consultar por el campo. Eso lo decide 
-- el motor en su plan de ejecuci�n. Hacer el ensayo con el �ndice creado por edad.

-- Para reconstruir un �ndice, usamos el siguiente comando:

ALTER INDEX em_edad REBUILD;

-- Por que raz�n hay que reconstruir un �ndice? Con el movimiento de los datos, 
-- los �ndices van actualiz�ndose, sufriendo fragmentaci�n con el paso del tiempo. 
-- El reconstruir un �ndice eliminamos esta fragmentaci�n y hacemos que su 
-- informaci�n quede f�sicamente contigua.

-- Hay un tip para saber si un �ndice hay que reconstruirlo. Primero, 
-- ejecutemos la siguiente instrucci�n:

ANALYZE INDEX em_edad VALIDATE STRUCTURE;

-- Este comando analiza la estructura actual del �ndice y graba los resultados 
-- en la tabla INDEX_STATS. Por eso, despu�s de ejecutar la anterior instrucci�n, 
-- se procede a consultar dicha tabla:

SELECT name, height, lf_rows, del_lf_rows, (del_lf_rows/lf_rows)*100 as ratio
FROM INDEX_STATS;

-- El tip dice que es recomendable reconstruir el �ndice si:
--    � El HEIGHT es mayor a 4, o
--    � El ratio es mayor a 20.
-- El cumplimiento de cualquiera de las dos condiciones anteriores significa 
-- que el �ndice tiene un grado alto de fragmentaci�n.

-- Para consultar el tama�o de un �ndice, en megas, ejecutar la siguiente consulta:

SELECT segment_name, SUM(bytes)/1024/1024 MB 
FROM USER_extents
WHERE segment_name = 'EM_EDAD' GROUP BY segment_name;

-- Existe otro tipo de indice en Oracle llamado Bitmap. Se recomienda crear este 
-- tipo de indice cuando los valores de la columna a indexar no varian mucho, es 
-- decir, cuando la columna no tiene muchos valores diferentes.
-- Se usa cuando son datos discretos(con pocas posibilidades)

-- A la tabla EMPLEADO adicionarle un nuevo campo llamado categor�a, de tipo 
-- num�rico. Vamos a suponer que existen empleados de 5 categorias posibles: 
-- 1, 2, 3, 4, 5. Por lo tanto, el campo categor�a es candidato a crearle un 
-- indice bitmap.

ALTER TABLE EMPLEADO1 ADD CATEGORIA NUMBER;

-- Para crear un indice de este tipo se ejecuta:

CREATE BITMAP INDEX em_categoria ON EMPLEADO1(categoria);

-- Chequear que si haya quedado como un indice tipo BITMAP, consultando la 
-- vista ALL_INDEXES.

SELECT index_name, index_type, table_name, tablespace_name 
FROM all_indexes
WHERE table_name = 'EMPLEADO1';

-- Ser� posible crear un �ndice en m�s de una columna de la tabla?
-- No es posible, ya se solo se permite un indice por campo (El error dice que la lista ya esta indexada)
-- En Oracle, existe la posibilidad de crear �ndices basados en funciones, 
-- esto es, en funciones agregadas o expresiones aritm�ticas.

-- Para hacer el ejemplo, vamos inicialmente a poblar a la tabla EMPLEADO1 de 
-- muchos registros. Para ello, ejecutar lo siguiente:
/*
BEGIN
FOR CUR_REC IN 20000..40000 LOOP INSERT INTO EMPLEADO1
VALUES (CUR_REC, 'HHHH', NULL, NULL, NULL); 
COMMIT;
END LOOP; 
END;
*/
-- Con esto nos aseguraremos que la tabla tendr�, m�nimo, 20000 registros.
-- Verificarlo.

SELECT * FROM EMPLEADO1;

-- Ahora, creemos un �ndice para el campo �nombre� de la tabla EMPLEADO1:

CREATE INDEX em_nombre ON empleado1(nombre);

-- Ahora, vamos a hacer la siguiente consulta:

EXPLAIN PLAN FOR 
SELECT * FROM EMPLEADO1
WHERE nombre = 'PAULA BETANCUR';

-- Se puede observar que dicha consulta usa el �ndice reci�n creado. Verificarlo.
SELECT PLAN_TABLE_OUTPUT
FROM TABLE(DBMS_XPLAN.DISPLAY());

-- Ahora ejecutemos la consulta, modific�ndola en un aspecto:

EXPLAIN PLAN FOR
SELECT * FROM EMPLEADO1
WHERE UPPER(nombre) = 'PAULA BETANCUR';

-- Como se puede apreciar, para esta �ltima consulta NO se us� el �ndice, 
-- (verificarlo) se le hizo un escaneo completo a la tabla. Para obligar a que para la 
-- anterior consulta use un indice, podemos crear el siguiente:

CREATE INDEX em_nombre_mayuscula ON empleado1(UPPER(nombre));

-- Vuelva a ejecutar la �ltima consulta y verifique el uso del nuevo �ndice. 
-- En este caso, estamos implementando un �ndice basado en funciones, 
-- en este caso, la funci�n UPPER.

-- Cuales son las ventajas de este tipo de �ndices? Cuando se usan?