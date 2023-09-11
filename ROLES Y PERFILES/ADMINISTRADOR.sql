--ROLES

CREATE ROLE ROL1;

GRANT CREATE SESSION, CREATE TABLE TO ROL1;

CREATE USER JOSE IDENTIFIED BY JOSE QUOTA 10M ON USERS;
GRANT ROL1 TO JOSE;

--PARA QUE SE APLIQUE EL CAMBIO DEL NUEVO ROL EN EL USUARIO SE DEBE REINICIAR SESI�N
CREATE ROLE ROL2;
GRANT CREATE VIEW TO ROL2;
GRANT ROL2 TO JOSE;

--QUITAR  PRIVILEGIOS AL ROLE
REVOKE CREATE VIEW FROM ROL2;

DROP ROLE ROL1;



CREATE USER VENTAS IDENTIFIED BY VENTAS QUOTA 10M ON USERS;
GRANT CREATE SESSION, CREATE TABLE TO VENTAS;

CREATE ROLE OPERARIO;
GRANT CREATE SESSION TO OPERARIO;--PRIVILEGIO DEL SISTEMA
GRANT SELECT ON VENTAS.PRODUCTOS TO OPERARIO; --PRIVILEGIO DE OBJETO

CREATE ROLE SUPERVISOR;
GRANT CREATE SESSION, CREATE TABLE TO SUPERVISOR;

CREATE ROLE ADMINISTRADORES;
GRANT CREATE SESSION, CREATE TABLE, CREATE VIEW TO ADMINISTRADORES;
GRANT UPDATE, INSERT, DELETE ON VENTAS.PRODUCTOS TO ADMINISTRADORES;

CREATE USER OPERARIO1 IDENTIFIED BY OPERARIO1 QUOTA 5M ON USERS;
CREATE USER SUPERVISOR1 IDENTIFIED BY SUPERVISOR1 QUOTA 5M ON USERS;
CREATE USER ADMINISTRADOR1 IDENTIFIED BY ADMINISTRADOR1 QUOTA 5M ON USERS;

GRANT OPERARIO TO OPERARIO1;
GRANT SUPERVISOR TO SUPERVISOR1;
GRANT ADMINISTRADORES TO ADMINISTRADOR1;

GRANT SELECT ON VENTAS.PRODUCTOS TO ADMINISTRADOR1;


--PERFILES
CREATE PROFILE PERFIL1 LIMIT 
SESSIONS_PER_USER 2 -- SESSIONES ACTIVAS POR USUARIO
IDLE_TIME 2; --PERIODO DE INACTIVIDAD


SHOW PARAMETER RESOURCE_LIMIT; -- TRUE ES ACTIVO
-- en caso de que sea falso
ALTER SYSTEM SET RESOURCE_LIMIT = TRUE;


CREATE USER USUARIO1 IDENTIFIED BY USUARIO1 PROFILE PERFIL1;
GRANT CREATE SESSION TO USUARIO1;

CREATE PROFILE PERFIL2 LIMIT
FAILED_LOGIN_ATTEMPTS 2;

ALTER USER USUARIO1 PROFILE PERFIL2;

--DESBLOQUEAR CUENTA DE USUARIO BLOQUEADO
ALTER USER USUARIO1 ACCOUNT UNLOCK;