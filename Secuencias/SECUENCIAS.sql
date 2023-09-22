-- *************************************************************** --
--                       SECUENCIAS                             ** --
-- *************************************************************** --

-- QU� ES UNA SECUENCIA EN ORACLE?

-- C�MO SE CREA UNA SECUENCIA EN ORACLE?

CREATE SEQUENCE SECUENCIA10
  START WITH 10
  INCREMENT BY 50
  MAXVALUE 300
  NOCACHE
  NOCYCLE

-- QU� PASA CUANDO SE PONE NOCYCLE?

SELECT SECUENCIA10.NEXTVAL FROM DUAL  -- EJECUTAR 6 VECES

-- QU� PASA CUANDO SE PONE CYCLE? SU RELACI�N CON MINVALUE?

CREATE SEQUENCE SECUENCIA11
  START WITH 10
  INCREMENT BY 50
  MAXVALUE 300
  NOCACHE
  CYCLE
  
SELECT SECUENCIA11.NEXTVAL FROM DUAL -- EJECUTAR 7 VECES

-- UNA SECUENCIA PARA VARIAS TABLAS.

CREATE TABLE EJEMPLO1
(CODIGO NUMBER DEFAULT SECUENCIA11.NEXTVAL,
NOMBRE VARCHAR2(60))

CREATE TABLE EJEMPLO2
(CODIGO NUMBER DEFAULT SECUENCIA11.NEXTVAL,
NOMBRE VARCHAR2(60))

INSERT INTO EJEMPLO1 (NOMBRE) VALUES ('AAAAAA');
INSERT INTO EJEMPLO1 (NOMBRE) VALUES ('BBBBBB');
INSERT INTO EJEMPLO1 (NOMBRE) VALUES ('CCCCCC');
INSERT INTO EJEMPLO2 (NOMBRE) VALUES ('AAAAAA');
INSERT INTO EJEMPLO2 (NOMBRE) VALUES ('BBBBBB');
INSERT INTO EJEMPLO1 (NOMBRE) VALUES ('DDDDDD');

SELECT * FROM EJEMPLO1;
SELECT * FROM EJEMPLO2;

-- UNA SECUENCIA CON INCREMENTO NEGATIVO.

CREATE SEQUENCE SECUENCIA12
  START WITH 100
  INCREMENT BY -20
  MAXVALUE 100
  MINVALUE 10
  NOCACHE
  CYCLE
  
CREATE TABLE EJEMPLO3
(CODIGO NUMBER DEFAULT SECUENCIA12.NEXTVAL,
NOMBRE VARCHAR2(60))

INSERT INTO EJEMPLO3 (NOMBRE) VALUES ('AAAAAA');
INSERT INTO EJEMPLO3 (NOMBRE) VALUES ('BBBBBB');

SELECT * FROM EJEMPLO3;

INSERT INTO EJEMPLO3 (NOMBRE) VALUES ('CCCCCC');
INSERT INTO EJEMPLO3 (NOMBRE) VALUES ('DDDDDD');
INSERT INTO EJEMPLO3 (NOMBRE) VALUES ('EEEEEE');

SELECT * FROM EJEMPLO3;

INSERT INTO EJEMPLO3 (NOMBRE) VALUES ('FFFFFF');

SELECT * FROM EJEMPLO3;

-- QU� PASA CON EL CONSECUTIVO DE LA SECUENCIA ANTE UN ROLLBACK?

CREATE SEQUENCE SECUENCIA13
  START WITH 20
  INCREMENT BY 30
  MAXVALUE 400
  MINVALUE 10
  NOCACHE
  CYCLE

CREATE TABLE EJEMPLO4
(CODIGO NUMBER DEFAULT SECUENCIA13.NEXTVAL,
NOMBRE VARCHAR2(60))

INSERT INTO EJEMPLO4 (NOMBRE) VALUES ('FFFFFF');
INSERT INTO EJEMPLO4 (NOMBRE) VALUES ('EEEEEE');

SELECT * FROM EJEMPLO4

ROLLBACK WORK;

SELECT * FROM EJEMPLO4

SELECT SECUENCIA13.CURRVAL FROM DUAL;
-- IMPACTO DEL PARAMETRO CACHE -- CONSULTA DE USER_SEQUENCES

CREATE SEQUENCE SECUENCIA14
  START WITH 10
  INCREMENT BY 50
  MAXVALUE 300
  CACHE 4
  CYCLE
  
SELECT * FROM USER_SEQUENCES;  -- EN CUANTO EST� LAST_NUMBER PARA SECUENCIA14?

SELECT SECUENCIA14.NEXTVAL FROM DUAL; -- Y AHORA EN CUANTO ESTA LAST_NUMBER?
  

  