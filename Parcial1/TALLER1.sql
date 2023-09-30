--9.Crear migración

CREATE TABLE estudiantesSistemas(
codi
);

CREATE TABLE ESTUDIANTES_SISTEMAS(
Cedula NUMBER,
Nombre varchar(20),
Edad NUMBER,
Codcarrera NUMBER,
CodAcudiente NUMBER
);

CREATE TABLE ESTUDIANTES_AMBIENTAL(
Cedula NUMBER,
Nombre varchar(20),
Edad NUMBER,
Codcarrera NUMBER,
CodAcudiente NUMBER
);


--Crear MERGE de los estudiantes según su carrera
INSERT ALL
WHEN Codcarrera=1 THEN
INTO ESTUDIANTES_SISTEMAS VALUES (Cedula, Nombre, Edad, Codcarrera, CodAcudiente)
WHEN Codcarrera=2 THEN
INTO ESTUDIANTES_AMBIENTAL VALUES (Cedula, Nombre, Edad, Codcarrera, CodAcudiente)
SELECT Cedula, Nombre, Edad, Codcarrera, CodAcudiente
FROM SYSTEM.ESTUDIANTE;

SELECT * from SYSTEM.ESTUDIANTE;
SELECT * from ESTUDIANTES_AMBIENTAL;


-- 10. Qué actividades tienen que ver con los siguientes componentes de la arquitectura de Oracle?
-- El Data Buffer Cache tiene que ver con la creación de tablas y roles, con las inserciones y consultas, y también con las operacaiones de MERGE.
-- EL Shared Pool lo usamos al momento de crear tablas, vistas, roles y usuarios.
-- Todas las operaciones realizadas estan interantuando con el Data Buffer Cache y con el Shared Pool, ya sea directamente con la lectura y/o escritura almacenando
-- las instrucciones SQL.

