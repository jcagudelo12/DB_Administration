-- VISTAS COMUNES EN ORACLE

CREATE TABLE PRODUCTOS(
CODIGO NUMBER PRIMARY KEY,
NOMBRE VARCHAR(30) NOT NULL,
PRECIO NUMBER,
EXISTENCIAS NUMBER
);

INSERT INTO PRODUCTOS VALUES(1, 'ARROZ CARIBE', 5000, 300);
INSERT INTO PRODUCTOS VALUES(2, 'JABON ARIEL', 15000, 200);
INSERT INTO PRODUCTOS VALUES(3, 'LECHE COLANTA', 4000, 100);
INSERT INTO PRODUCTOS VALUES(4, 'JABON PALMOLIVE', 6000, 150);
INSERT INTO PRODUCTOS VALUES(5, 'QUESO ALPINA', 12000, 180);


SELECT * FROM PRODUCTOS;

-- CREACI�N DE LA PRIMERA VISTA
CREATE VIEW VISTA1 AS 
SELECT CODIGO, NOMBRE, PRECIO 
FROM PRODUCTOS
WHERE PRECIO > 4000
WITH READ ONLY;

-- CREACI�N DE LA SEGUNDA VISTA
CREATE VIEW VISTA2 AS 
SELECT NOMBRE, EXISTENCIAS
FROM PRODUCTOS
WHERE EXISTENCIAS < 200;

-- REVISI�N DE LA VISTA EN EL DICCIONARIO DE DATOS
-- SE CORROBORA QUE SE ALMACENA COMO UN STRING
SELECT * FROM 
USER_VIEWS
WHERE VIEW_NAME = 'VISTA1';

-- MOSTRAR LOS REGISTRPOS DE LA VISTA
SELECT * FROM VISTA1; -- READ ONLY
SELECT * FROM VISTA2; -- NOT READ ONLY

-- ACTUALIZAR VISTAS
UPDATE VISTA2 SET NOMBRE = 'LECHE PROLECHE'; -- SE PERMITE EL UPDATE

UPDATE VISTA1 SET NOMBRE = 'LECHE PROLECHE'; -- NO SE PERMITE EL UPDATE POR SER READ ONLY

-- INSERTAR NUEVO PRODUCTO A TRAVES DE VISTA2
INSERT INTO VISTA2 VALUES('LECHE', 200); -- NO ES POSIBLE PORQUE NO SE PUEDE ENVIAR EL CODIGO QUE ES LA PK

-- ELIMINAR REGISTROS DE UNA VISTA
DELETE FROM VISTA2;

-- ACTUALIZAR EXISTENCIAS DE UN PRODUCTO
UPDATE VISTA2 SET EXISTENCIAS = 250 WHERE NOMBRE = 'QUESO ALPINA';

SELECT * FROM VISTA2;

CREATE TABLE CATEGORIA(
ID_CATEGORIA NUMBER PRIMARY KEY,
NOMBRE VARCHAR(30)
);

SELECT * FROM PRODUCTOS;
INSERT INTO CATEGORIA VALUES (1, 'LACTEOS');
INSERT INTO CATEGORIA VALUES (2, 'ASEO');

UPDATE PRODUCTOS
SET ID_CATEGORIA = 1;

ALTER TABLE PRODUCTOS
ADD ID_CATEGORIA NUMBER;

ALTER TABLE PRODUCTOS
ADD FOREIGN KEY (ID_CATEGORIA)
REFERENCES CATEGORIA(ID_CATEGORIA);

CREATE VIEW VISTA3 AS
SELECT P.CODIGO, P.NOMBRE, P.PRECIO, C.NOMBRE AS NOMBRECAT
FROM PRODUCTOS P 
INNER JOIN CATEGORIA C
ON C.ID_CATEGORIA = P. ID_CATEGORIA;

SELECT * FROM VISTA3;


UPDATE VISTA3
SET NOMBRE = 'QUESO COLANTA'
WHERE CODIGO = 1;

-- CAMBIAR EL NOMBRE DE UNA CATEGORIA
UPDATE VISTA3
SET NOMBRECAT = 'VARIOS'
WHERE ID_CATEGORIA = 1;

-- TAREA CREAR VISTA CON:
-- WITH CHECK OPTION (INTENTAR ENTENDER PARA QUE SIRVE)