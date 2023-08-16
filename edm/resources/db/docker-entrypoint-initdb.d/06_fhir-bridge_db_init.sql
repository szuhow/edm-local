CREATE DATABASE fhirbridge;
--CREATE USER edm-db-admin PASSWORD 'password';
ALTER USER "edm-db-admin" WITH PASSWORD 'password';
GRANT ALL PRIVILEGES ON DATABASE fhirbridge TO "edm-db-admin";
 \connect fhirbridge;
CREATE SCHEMA fhirbridge;