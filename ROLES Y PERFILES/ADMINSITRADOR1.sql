CREATE TABLE TEST1(
ID NUMBER);

INSERT INTO TEST1 VALUES (4);

SELECT * FROM TEST1;

SELECT * FROM VENTAS.PRODUCTOS;

INSERT INTO VENTAS.PRODUCTOS VALUES(4,'QUESO', 8000);
COMMIT;

UPDATE VENTAS.PRODUCTOS SET NOMBRE='QUESO' WHERE codigo=1;
COMMIT;
