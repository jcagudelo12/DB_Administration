--5. Creación de vista con información del estudiante
CREATE VIEW EX2VISTA AS 
SELECT e.CEDULA, e.NOMBRE AS Estudiante, a.NOMBRE AS Acudiente, c.NOMBRE AS Carrera
FROM SYSTEM.ESTUDIANTE e
INNER JOIN SYSTEM.ACUDIENTE a ON e.CodAcudiente = a.Codigo
INNER JOIN SYSTEM.CARRERA c ON e.Codcarrera = c.Codigo
WHERE e.Edad < 30
WITH READ ONLY;

-- SELECT de la vista creada
select * from EX2VISTA;

--UPDATE solo para la columna edad
UPDATE SYSTEM.ESTUDIANTE SET EDAD = 30 WHERE CEDULA = 10;

--Prueba de que no se puede actualizar otro campo
UPDATE SYSTEM.ESTUDIANTE SET NOMBRE = 'JUAN' WHERE CEDULA = 40;

GRANT SELECT ON EX2VISTA TO TALLER3;

COMMIT;

-- Comprobar acceso a la vista materializable de TALLER3
SELECT * FROM TALLER3.ex3vista;