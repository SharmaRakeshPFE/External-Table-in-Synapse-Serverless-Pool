--## Author :- Rakesh Sharma ##
--## Accessing external tables via Synapse Serverless Pool without exposing ADLS ##--
--## Test this script in TEST\DEV enviornment ##--
--## Creating a Master Key in the Database ##--
CREATE MASTER KEY ENCRYPTION BY PASSWORD='xxxxxxxx'


--## Create Database Scoped Credential
CREATE DATABASE SCOPED CREDENTIAL [ADLS_Patients]
WITH IDENTITY='SHARED ACCESS SIGNATURE', SECRET = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
GO

--## Create External Data Source ##--
CREATE EXTERNAL DATA SOURCE Table2ADLS
WITH (LOCATION = 'https://azsynapseadlsact.blob.core.windows.net/samplecsv',CREDENTIAL=ADLS_Patients)

--## Create External File Format ##--
CREATE EXTERNAL FILE FORMAT csvFile
WITH 
(
    FORMAT_TYPE = DELIMITEDTEXT,
    FORMAT_OPTIONS 
(
      FIELD_TERMINATOR = ',',
      STRING_DELIMITER = '"',
      FIRST_ROW = 0,
      USE_TYPE_DEFAULT = FALSE,
      ENCODING = 'UTF8'
)
);


--## Create External Table --##
CREATE EXTERNAL TABLE [dbo].[PatientsInfo]
(
[name] [Nvarchar](100),
[age] [varchar](100),
[height] [varchar](100)
)
WITH (DATA_SOURCE = [Table2ADLS], LOCATION = '/Patient.csv', FILE_FORMAT = [csvFile])
GO


--## Try accessing external table ##--
select * from [dbo].[PatientsInfo]


--## Creating SQL Login for testing ##--
CREATE LOGIN RakeshReadAdls WITH PASSWORD = 'xxxxx@xxxx';
CREATE USER RakeshReadAdls from Login RakeshReadAdls

--## Granting access to scoped credential to the SQL Login to access the ADLS content ##--
GRANT CONTROL ON DATABASE SCOPED CREDENTIAL :: [ADLS_Patients] TO [RakeshReadAdls]

--## Granting access to the table to SQL Login ##--
GRANT SELECT ON DATABASE::[ReadFromADLS] TO [RakeshReadAdls] 

--## Gratning access to AAD on external tables ##--
CREATE USER [vaks@microsoft.com] from External Provider 
GRANT SELECT ON DATABASE::[ReadFromADLS] TO [xxxxx@microsoft.com] 
GRANT CONNECT ON DATABASE::[ReadFromADLS] TO [xxxxxx@microsoft.com] 
GRANT CONTROL ON DATABASE SCOPED CREDENTIAL :: [ADLS_Patients] TO [xxxxx@microsoft.com]





