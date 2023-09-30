-- 1.Creación de roles
-- Creación del rol con permisos de DBA
CREATE ROLE ExamenRol1;
GRANT DBA to ExamenRol1;

-- Creación del rol con permisos Conexión, crear tablas, crear vistas comunes
CREATE ROLE ExamenRol2;
GRANT CREATE SESSION, CREATE TABLE, CREATE VIEW TO ExamenRol2;

-- Creación del rol con permisos Conexión, crear tablas, crear vistas materializables, crear secuencias
CREATE ROLE ExamenRol3;
GRANT CREATE SESSION, CREATE TABLE, CREATE MATERIALIZED VIEW, CREATE SEQUENCE TO ExamenRol3;

--2. Cración de perfiles
--Creación Perfil 1 con limite de 4 intentos de fallidos de password y 3 de minutos de inactividad
CREATE PROFILE Per1 LIMIT
FAILED_LOGIN_ATTEMPTS 4
IDLE_TIME 3;

--Creación Perfil 2 con tiempo de vida de password de 120 dias y 4 sesiones por usuario
CREATE PROFILE Per2 LIMIT
PASSWORD_LIFE_TIME 120
SESSIONS_PER_USER 4;


--3. Creación de usuarios
--Creación de usuarios y asignación de roles y perfiles
CREATE USER TALLER1 IDENTIFIED BY 1357 QUOTA 5M ON USERS PROFILE Per1;
GRANT ExamenRol1 TO TALLER1;

CREATE USER TALLER2 IDENTIFIED BY 3456 QUOTA 10M ON USERS PROFILE Per2;
GRANT ExamenRol2 TO TALLER2;

CREATE USER TALLER3 IDENTIFIED BY 0011 QUOTA 8M ON USERS PROFILE Per2;
GRANT ExamenRol3 TO TALLER3;

--4. Creación de tablas

CREATE TABLE ACUDIENTE(
Codigo NUMBER PRIMARY KEY,
Nombre varchar(20),
Sexo varchar(1),
Telefono varchar(20)
);
select * from acudiente;
CREATE TABLE CARRERA(
Codigo NUMBER PRIMARY KEY,
Nombre varchar(20)
);


--Creación de secuencia para código carrera
CREATE SEQUENCE SEQ1
START WITH 10
INCREMENT BY 15
MAXVALUE 200
CACHE 2
CYCLE;

--Teniendo la secuencia creada, creamos la tabla estudiante y asignamos las FK
CREATE TABLE ESTUDIANTE(
Cedula NUMBER DEFAULT SEQ1.NEXTVAL,
Nombre varchar(20),
Edad NUMBER,
Codcarrera NUMBER,
CodAcudiente NUMBER
);

ALTER TABLE ESTUDIANTE
ADD FOREIGN KEY (Codcarrera)
REFERENCES CARRERA(Codigo);

ALTER TABLE ESTUDIANTE
ADD FOREIGN KEY (CodAcudiente)
REFERENCES ACUDIENTE(Codigo);

ALTER TABLE ESTUDIANTE
ADD PRIMARY KEY (Cedula);

-- Poblar tablas

INSERT INTO CARRERA VALUES(1, 'Sistemas');
INSERT INTO CARRERA VALUES(2, 'Ambiental');
INSERT INTO CARRERA VALUES(3, 'Administración');
INSERT INTO CARRERA VALUES(4, 'Química');

SELECT * FROM CARRERA;

INSERT INTO ACUDIENTE VALUES(1, 'Pepita', 'F', '111111');
INSERT INTO ACUDIENTE VALUES(2, 'Pepito', 'M', '222222');
INSERT INTO ACUDIENTE VALUES(3, 'Andrea', 'F', '333333');
INSERT INTO ACUDIENTE VALUES(4, 'Camilo', 'M', '444444');

SELECT * FROM ACUDIENTE;

INSERT INTO ESTUDIANTE (Nombre, Edad, Codcarrera, Codacudiente) VALUES('Marta', 20, 1, 1);
INSERT INTO ESTUDIANTE (Nombre, Edad, Codcarrera, Codacudiente) VALUES('Andres', 30, 2, 2);
INSERT INTO ESTUDIANTE (Nombre, Edad, Codcarrera, Codacudiente) VALUES('Felipe', 25, 3, 3);
INSERT INTO ESTUDIANTE (Nombre, Edad, Codcarrera, Codacudiente) VALUES('Camila', 40, 4, 4);

SELECT * FROM ESTUDIANTE;
SELECT * FROM DBA_SYS_PRIVS WHERE GRANTEE = 'TALLER3';

--Dar permisos de SELECT a Usuarioa TALLER2 en las tablas necesarias
GRANT SELECT ON ESTUDIANTE TO TALLER2 WITH GRANT OPTION;
GRANT SELECT ON ACUDIENTE TO TALLER2 WITH GRANT OPTION;
GRANT SELECT ON CARRERA TO TALLER2 WITH GRANT OPTION;

COMMIT;

--Permiso para que el usuario TaLLER2 pueda actualizar la edad del estudiante
GRANT UPDATE (EDAD) ON ESTUDIANTE TO TALLER2;
COMMIT;

--Permisos necesarios para que TALLER2 pueda otorgar el permiso de SELECT a TALLER3
GRANT SELECT ON TALLER2.EX2VISTA TO TALLER2 WITH GRANT OPTION;

GRANT SELECT ON ESTUDIANTE TO TALLER3;
GRANT SELECT ON CARRERA TO TALLER3;

--UPDATE para probar la vista materializable de TALLER3
UPDATE ESTUDIANTE SET EDAD = 31 WHERE CEDULA = 10;
COMMIT;

--8. Dar permiso de SELECT a TALLER2 sobre la vista EX3VISTA de TALLER3
GRANT SELECT ON TALLER3.EX3VISTA TO TALLER2;

