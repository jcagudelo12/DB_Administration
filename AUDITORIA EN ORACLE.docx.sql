-- *********************************************************************** --
-- **                AUDITOR�A EN BASES DE DATOS ORACLE                 ** --
-- *********************************************************************** --

-- En Oracle existen tres tipos de auditor�a:
--    �	Auditor�a de Bases de Datos
--    �	Auditor�a de Objetos
--    �	Auditor�a de Granularidad Fina
-- Para que Oracle grabe los registros de auditor�a, debe tener el par�metro 
-- �audit_trail� activado. Por defecto, dicho par�metro, en el campo VALUE, 
-- tiene el valor NONE. Cuando est� en NONE, la auditor�a est� desactivada.
-- Para consultar si la auditor�a est� activada o no, se ejecuta el siguiente 
-- comando y se revisa el valor de la columna VALUE.

SELECT * 
FROM V$PARAMETER 
WHERE NAME = 'audit_trail';

-- Para activar la auditoria, se ejecuta el siguiente comando:

ALTER SYSTEM SET AUDIT_TRAIL = 'DB' 
SCOPE = SPFILE;

-- Y se debe reiniciar el servidor (shutdown / startup) para que tome efecto 
-- el cambio.

-- ***** AUDITORIA DE BASE DE DATOS

-- Vamos a consultar la tabla que tiene las pistas de auditoria.

SELECT *
FROM SYS.AUD$;

-- Para mirar la auditoria de sentencias, es decir, a cu�les usuarios se van a 
-- auditar y bajo que sentencias, se puede consultar la vista DBA_STMT_AUDIT_OPTS:

SELECT     SUBSTR( USER_NAME ,  1 , 10 ) , 
        SUBSTR( AUDIT_OPTION , 1 , 20 ) ,
        SUBSTR( SUCCESS , 1 , 10 ) ,
        SUBSTR( FAILURE, 1 , 10) 
FROM DBA_STMT_AUDIT_OPTS
          ORDER BY 1;
          
-- Para hacer el ejercicio, crear el usuario llamado USER200 y darle el rol de DBA.



CREATE USER USER200 IDENTIFIED BY 123;
GRANT DBA TO USER200;

-- Para auditar los SELECTs e INSERTs que haga el usuario USER200, ejecutemos lo 
-- siguiente:

AUDIT SELECT TABLE , INSERT TABLE 
BY USER200 BY ACCESS;

-- Para mirar cu�les sentencias se van a auditor del usuario USER200:

SELECT  SUBSTR( USER_NAME ,  1 , 10 ) , 
        SUBSTR( AUDIT_OPTION , 1 , 20 ) ,
        SUBSTR( SUCCESS , 1 , 10 ) ,
        SUBSTR( FAILURE, 1 , 10 )
FROM DBA_STMT_AUDIT_OPTS
ORDER BY 1;
        
-- Vamos a conectarnos con el usuario USER200 y vamos a realizar un SELECT sobre 
-- una tabla de su esquema. Es decir, primero creemos una tabla, llamada EMPLEADO, 
-- en el esquema de USER200 y luego le hacemos SELECT.

-- Vamos a comprobar que la sentencia SELECT, hecha por USER200, haya quedado 
-- registrada en la vista DBA_AUDIT_TRAIL:

SELECT SUBSTR(OS_USERNAME,1,20) USUARIO_SO, 
SUBSTR(USERNAME,1,12) USUARIO, 
TO_CHAR(TIMESTAMP,'DD-MM-YYY HH24:MI:SS') TIEMPO_CONEXION,
SUBSTR(ACTION_NAME,1,10)  ACCION,
SUBSTR( OBJ_NAME , 1, 15 ) OBJETO
FROM DBA_AUDIT_TRAIL 
WHERE USERNAME = 'USER200'  AND OBJ_NAME IN ('EMPLEADO')
ORDER BY USERNAME,TIMESTAMP,LOGOFF_TIME;

DELETE FROM DBA_AUDIT_TRAIL;

-- Se puede ver que queda grabada, en la vista de auditoria, el hecho de que el 
-- usuario USER200 hizo un SELECT sobre la table EMPLEADO. 

-- En este tipo de auditoria no queda registrada la instrucci�n SQL completa que 
-- dio pie para el registro de auditor�a, solamente dice que instrucci�n se 
-- ejecut� (INSERT, SELECT, etc.).

-- Con el usuario USER200, insertar dos tuplas en la table EMPLEADO. Luego, revisar
-- de nuevo el registro de auditoria (ejecutar la misma consulta anterior).

-- Si queremos desactivarle al usuario USER200 la auditoria sobre la instrucci�n 
-- SELECT, se ejecuta la siguiente instrucci�n:

NOAUDIT SELECT TABLE  BY USER200;

-- La auditor�a, para ese usuario, queda desactivada a partir de la proxima conexion
-- que haga.

-- Para comprobar que ya no se le va a auditar los SELECTs al usuario USER20:

SELECT     SUBSTR( USER_NAME ,  1 , 10 ) , 
SUBSTR( AUDIT_OPTION , 1 , 20 ) ,
SUBSTR( SUCCESS , 1 , 10 ) ,
SUBSTR( FAILURE, 1 , 10 )
FROM DBA_STMT_AUDIT_OPTS
ORDER BY 1;

-- ***** AUDITORIA DE OBJETOS

-- La Auditor�a de objetos, registra los cambios por operaciones efectuadas por los 
-- usuarios en determinadas tablas.

-- Vamos a consultar las auditor�as activas que existen sobre objetos de la base 
-- de datos:

SELECT * FROM DBA_OBJ_AUDIT_OPTS WHERE OWNER='USER20'

-- Para hacer el ejercicio, vamos a activar la auditoria relacionada con las 
-- acciones SELECT, INSERT y UPDATE, sobre el objeto USER200.EMPLEADO.

AUDIT SELECT, INSERT, DELETE, UPDATE ON USER200.EMPLEADO;

-- Consultemos los objetos auditados:

SELECT *
FROM DBA_OBJ_AUDIT_OPTS WHERE OWNER = 'USER200'

-- Creemos un nuevo usuario, llamado MATEO1, con permisos de hacer consultas e 
-- inserciones sobre la table EMPLEADO de USER200. Luego de esto, con el usuario 
-- MATEO1, inserter datos en EMPLEADO y consultarlos.

CREATE USER MATEO1 IDENTIFIED BY 123
GRANT CREATE SESSION TO MATEO1;
GRANT SELECT, INSERT ON USER200.EMPLEADO TO MATEO1;

-- Miremos como qued� grabado el registro de auditor�a sobre el objeto 
-- USER200.EMPLEADO, por parte del usuario MATEO1:

SELECT SUBSTR(OS_USERNAME,1,10) USUARIO_SO, 
SUBSTR(USERNAME,1,12) USUARIO,
TO_CHAR(TIMESTAMP,'DD-MM-YYYHH24:MI:SS') TIEMPO_CONEXION, SUBSTR(OWNER,1,10) PROPIE, 
SUBSTR(OBJ_NAME,1,15) OBJETO, 
SUBSTR(ACTION_NAME,1,35) ACCION
FROM DBA_AUDIT_OBJECT
WHERE USERNAME='MATEO1' AND OBJ_NAME LIKE '%EMPLEADO%'
ORDER BY TIMESTAMP DESC;

-- Para desactivar todas las opciones de auditor�a que tenemos configuradas, 
-- ejecutamos:

NOAUDIT ALL ON DEFAULT;

-- ***** AUDITORIA DE GRANULARIDAD FINA

-- Si queremos que la auditoria hecha por Oracle grabe la instrucci�n SQL completa 
-- ejecutada por un usuario, utilizamos este tipo de auditor�a.

-- En el ejemplo que vamos a desarrollar se auditan las sentencias INSERT, UPDATE, 
-- DELETE, y SELECT en la tabla �USER200.EMPLEADO�, controlando cualquier acceso a 
-- la columna �APELLIDO� pertenecientes a los empleados con apellido �GOMEZ�:

ALTER TABLE USER200.EMPLEADO ADD APELLIDO VARCHAR2(30)

SELECT * FROM USER200.EMPLEADO;

UPDATE USER200.EMPLEADO SET APELLIDO = 'GOMEZ'

INSERT INTO USER200.EMPLEADO VALUES (2501,'LUIS',33,'LOPEZ');
INSERT INTO USER200.EMPLEADO VALUES (7800,'JORGE',41,'GOMEZ');
INSERT INTO USER200.EMPLEADO VALUES (7801,'VERONICA',41,'TAMAYO');

BEGIN
DBMS_FGA.ADD_POLICY(
OBJECT_SCHEMA => 'USER200',
OBJECT_NAME => 'EMPLEADO',
POLICY_NAME => 'CHK_HR_EMP',
AUDIT_CONDITION => 'APELLIDO= ''GOMEZ'' ',
AUDIT_COLUMN => 'APELLIDO',
STATEMENT_TYPES => 'INSERT,UPDATE,DELETE,SELECT');
END;

-- Ahora, desde otro usuario que tenga permisos, vamos a insertar dos nuevas tuplas 
-- en la tabla EMPLEADO, una tupla de un 
-- empleado cuyo apellido es GOMEZ, y otra tupla con un empleado de apellido LOPEZ.

INSERT INTO USER200.EMPLEADO VALUES (2509,'CRISTINA',33,'GOMEZ');
INSERT INTO USER200.EMPLEADO VALUES (2508,'CARLOS',33,'LOPEZ');

-- Ahora consultemos los datos de la auditor�a de granularidad fina:

SELECT TO_CHAR( TIMESTAMP , 'DD/MM/YY HH24:MI') TIEMPO ,
              DB_USER , USERHOST, SUBSTR( OBJECT_NAME , 1 , 15 ) , 
              SUBSTR( OBJECT_SCHEMA , 1 , 15 ) , POLICY_NAME, 
              SQL_TEXT
FROM DBA_FGA_AUDIT_TRAIL;

-- Como podemos apreciar, la instrucci�n INSERT del empleado GOMEZ qued� registrada 
-- en la auditoria, mas el del empleado de apellido LOPEZ no qued� registrado. 
-- Y se puede observar que la instrucci�n INSERT complete queda registrada.

-- Si queremos eliminar la auditoria anterior, ejecutamos:

BEGIN
DBMS_FGA.DROP_POLICY( object_schema =>'USER200' , 
                object_name  => 'EMPLEADO', 
                 policy_name =>'CHK_HR_EMP');
END;





