CREATE DATABASE �������DB
ON PRIMARY 
( NAME = SbornayaDB, FILENAME = 'D:\labDB\lab5\�������DB.mdf' , SIZE = 8192KB , FILEGROWTH = 65536KB )
LOG ON 
( NAME = SbornayaDB_log, FILENAME = 'D:\labDB\lab5\�������DB_log.ldf' , SIZE = 8192KB , FILEGROWTH = 65536KB );
GO

CREATE TABLE �������  (
    ������ INT PRIMARY KEY NOT NULL,
    ������� NVARCHAR(100) NOT NULL
);

INSERT INTO �������(������, �������)
VALUES (1, '������ ���� ������')


INSERT INTO �������(������, �������)
VALUES (2, '��� ������')

SELECT * FROM [�������];

GO

ALTER DATABASE �������DB
ADD FILEGROUP �������FG;
GO

ALTER DATABASE �������DB
ADD FILE 
( NAME = '�������Data',
  FILENAME = 'D:\labDB\lab5\�������Data.ndf',
  SIZE = 5MB,
  MAXSIZE = 100MB,
  FILEGROWTH = 5MB )
TO FILEGROUP �������FG;
GO

ALTER DATABASE �������DB
MODIFY FILEGROUP �������FG DEFAULT;
GO

CREATE TABLE ������ (
    �������� NVARCHAR(100) PRIMARY KEY NOT NULL,
    ����� NVARCHAR(512) NOT NULL,
	������ TINYINT NOT NULL,
	������� SMALLINT NULL
);

INSERT INTO ������(��������, �����, ������, �������)
VALUES ('������ ���� ������', '������ �����', 100, 1487)


INSERT INTO ������(��������, �����, ������, �������)
VALUES ('sente', '������', 0, 1900)

SELECT * FROM ������;
GO

DROP TABLE ������;
GO

ALTER DATABASE �������DB
MODIFY FILEGROUP [PRIMARY] DEFAULT;
GO
/*
���� ��� �������� ������ ������ �� ��������� ������� �� PRIMARY. ��� ��������, ��� ��� ����� �������, 
����������� ����� ����� ���������, ����� ����������� � ������ ������ PRIMARY, ���� �� ������� ����.
*/

ALTER DATABASE �������DB
REMOVE FILE �������Data;
GO

ALTER DATABASE �������DB
REMOVE FILEGROUP �������FG;
GO

CREATE SCHEMA ������������;
GO

ALTER SCHEMA ������������ TRANSFER dbo.�������;
GO

DROP TABLE ������������.�������;
GO

DROP SCHEMA ������������;
GO