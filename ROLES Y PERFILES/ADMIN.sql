create user ADMINISTRADOR IDENTIFIED BY 1234;

--Asignar rol DBA al usuario Administrador
GRANT DBA TO ADMINISTRADOR;

--Asignar quota al usuario Administrador en el TABLESPACE de users
ALTER USER ADMINISTRADOR QUOTA 50M ON USERS;

