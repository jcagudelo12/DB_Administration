-- ************************************************************************** --
-- **                        TABLAS PARTICIONADAS                          ** --
-- ************************************************************************** --

-- ** CREACION DE TABLESPACES

CREATE TABLESPACE TBS_ASIA2
DATAFILE 'C:\TEMP\DF_COMPROBANTES_ASIA3.DBF'
SIZE 100M;

CREATE TABLESPACE TBS_EUROPA2
DATAFILE 'C:\TEMP\DF_COMPROBANTES_EUROPA3.DBF'
SIZE 100M;

CREATE TABLESPACE TBS_AL2
DATAFILE 'C:\TEMP\DF_COMPROBANTES_AL3.DBF'
SIZE 100M;

CREATE TABLESPACE TBS_OTROS2
DATAFILE 'C:\TEMP\DF_COMPROBANTES_OTROS3.DBF'
SIZE 100M;

-- PARTICION POR LISTA
-- CREAR TABLA PARTICIONADA

CREATE TABLE Ventas10
(ID NUMBER(10),
 ORIGEN VARCHAR2(20),
 FECHA DATE default sysdate )

PARTITION BY LIST(ORIGEN)

(PARTITION ventas_ASIA3  VALUES('ASIA')    tablespace TBS_ASIA2,
 PARTITION ventas_EUROPA3 VALUES ('EUROPA') tablespace TBS_EUROPA2,
 PARTITION ventas_AL3     VALUES ('AL')   tablespace TBS_AL2,
 PARTITION ventas_otros3  VALUES(DEFAULT)   tablespace TBS_OTROS2 );
 
 -- INSERTAR DATOS EN LA TABLA RECIEN CREADA
 
INSERT INTO VENTAS10
SELECT LEVEL, 'ASIA', SYSDATE
FROM DUAL CONNECT BY LEVEL < 1000000;

INSERT INTO VENTAS10
SELECT LEVEL, 'EUROPA', SYSDATE
FROM DUAL CONNECT BY LEVEL < 1000000;

INSERT INTO VENTAS10
SELECT LEVEL, 'AL', SYSDATE
FROM DUAL CONNECT BY LEVEL < 1000000;

INSERT INTO VENTAS10
SELECT LEVEL, 'AFRICA', SYSDATE
FROM DUAL CONNECT BY LEVEL < 100000;

SELECT COUNT(*) FROM VENTAS10;

-- CONSULTAR LOS DATOS DE LA TABLA

SELECT * FROM VENTAS10;

SELECT COUNT(*) FROM VENTAS10 PARTITION ( ventas_ASIA3 );

SELECT * FROM VENTAS10 PARTITION (ventas_EUROPA3);

-- EN EL DICCIONARIO DE DATOS, PODEMOS CONSULTAR.....

SELECT TABLE_NAME, PARTITION_NAME, HIGH_VALUE,    
               TABLESPACE_NAME
FROM USER_TAB_PARTITIONS
WHERE TABLE_NAME = 'VENTAS10';

-- CREACION DE OTROS TABLESPACES....

CREATE TABLESPACE TBS_COMPROBANTES_2016
DATAFILE 'C:\TEMP\DF_COMPROBANTES_2016.DBF'
SIZE 100M;

CREATE TABLESPACE TBS_COMPROBANTES_2017
DATAFILE 'C:\TEMP\DF_COMPROBANTES_2017.DBF'
SIZE 100M;

CREATE TABLESPACE TBS_COMPROBANTES_2018
DATAFILE 'C:\TEMP\DF_COMPROBANTES_2018.DBF'
SIZE 100M;

-- TABLA PARTICIONADA POR RANGO

CREATE TABLE COMPROBANTES10
( IDCOMPROBANTE NUMBER(15),
  FECHA                 DATE DEFAULT SYSDATE ,
  MONTO               NUMBER(15,4) DEFAULT 0,
  REGION               VARCHAR(20) NOT NULL,
  ESTADO              INTEGER DEFAULT 1 )

  PARTITION BY RANGE ( FECHA)

( PARTITION COMPROBANTES1_2016 VALUES 
LESS THAN ( TO_DATE( '2016-12-31 23:59:00', 'YYYY-MM-DD HH24:MI:SS' )) 
TABLESPACE TBS_COMPROBANTES_2016,

    PARTITION COMPROBANTES1_2017 VALUES 
LESS THAN ( TO_DATE( '2017-12-31 23:59:00', 'YYYY-MM-DD HH24:MI:SS' )) 
TABLESPACE TBS_COMPROBANTES_2017,

    PARTITION COMPROBANTES1_2018 VALUES 
LESS THAN ( TO_DATE( '2018-12-31 23:59:00', 'YYYY-MM-DD HH24:MI:SS' )) 
TABLESPACE TBS_COMPROBANTES_2018 );

-- INSERTAR DATOS EN LA TABLA RECIEN CREADA.

INSERT INTO COMPROBANTES10
SELECT LEVEL, SYSDATE-3000, 350, 'AMERICA' , 1 
FROM DUAL CONNECT BY LEVEL <= 1000000;

INSERT INTO COMPROBANTES10
SELECT LEVEL, TO_DATE( '2017-2-5 23:59:00', 'YYYY-MM-DD HH24:MI:SS'), 350, 'AMERICA' , 1 
FROM DUAL CONNECT BY LEVEL <= 1000000;

INSERT INTO COMPROBANTES10
SELECT LEVEL, TO_DATE( '2019-2-5 23:59:00', 'YYYY-MM-DD HH24:MI:SS'), 350, 'AMERICA' , 1 
FROM DUAL CONNECT BY LEVEL <= 10;

SELECT count(*) FROM COMPROBANTES10;

-- CONSULTA DE LA TABLA PARTICIONADA

SELECT * FROM COMPROBANTES10 PARTITION (COMPROBANTES1_2016 );

-- AGREGANDO NUEVA PARTICION

CREATE TABLESPACE TBS_COMPROBANTES1_2019
 DATAFILE 'C:\TEMP\DF_COMPROBANTES_2019.DBF'
 SIZE 100M;
 
 ALTER TABLE COMPROBANTES10
 ADD PARTITION COMPROBANTES1_2019
VALUES LESS THAN ( TO_DATE( '2019-12-31 23:59:00', 'YYYY-MM-DD HH24:MI:SS' )) TABLESPACE TBS_COMPROBANTES1_2019 ;

SELECT TABLE_NAME, PARTITION_NAME, HIGH_VALUE
FROM USER_TAB_PARTITIONS
WHERE TABLE_NAME = 'COMPROBANTES10';

-- TAREA: C�MO PARTICIONAR UNA TABLA YA CREADA SIN PARTICI�N?
-- Se debe de usar split


