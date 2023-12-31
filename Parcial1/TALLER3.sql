--6.Realizar SELECT a la vista EX2VISTA de TALLER2

SELECT * FROM TALLER2.EX2VISTA;

--7. CREACI�N DE VISTA MATERIALIZABLE

CREATE MATERIALIZED VIEW EX3VISTA
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND
AS
SELECT e.CEDULA, c.NOMBRE AS Carrera, e.NOMBRE AS Estudiante
FROM SYSTEM.ESTUDIANTE e
INNER JOIN SYSTEM.CARRERA c ON e.Codcarrera = c.Codigo
WHERE e.Edad > 30;

SELECT * FROM EX3VISTA;

EXEC DBMS_MVIEW.REFRESH('EX3VISTA');

