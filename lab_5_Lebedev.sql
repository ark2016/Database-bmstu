CREATE DATABASE СборнаяDB
ON PRIMARY 
( NAME = SbornayaDB, FILENAME = 'D:\labDB\lab5\СборнаяDB.mdf' , SIZE = 8192KB , FILEGROWTH = 65536KB )
LOG ON 
( NAME = SbornayaDB_log, FILENAME = 'D:\labDB\lab5\СборнаяDB_log.ldf' , SIZE = 8192KB , FILEGROWTH = 65536KB );
GO

CREATE TABLE Сборная  (
    регион INT PRIMARY KEY NOT NULL,
    капитан NVARCHAR(100) NOT NULL
);

INSERT INTO Сборная(регион, капитан)
VALUES (1, 'Иванов Иван Иваныч')


INSERT INTO Сборная(регион, капитан)
VALUES (2, 'Вин Дизель')

SELECT * FROM [Сборная];

GO

ALTER DATABASE СборнаяDB
ADD FILEGROUP СборнаяFG;
GO

ALTER DATABASE СборнаяDB
ADD FILE 
( NAME = 'СборнаяData',
  FILENAME = 'D:\labDB\lab5\СборнаяData.ndf',
  SIZE = 5MB,
  MAXSIZE = 100MB,
  FILEGROWTH = 5MB )
TO FILEGROUP СборнаяFG;
GO

ALTER DATABASE СборнаяDB
MODIFY FILEGROUP СборнаяFG DEFAULT;
GO

CREATE TABLE ГоКлуб (
    Название NVARCHAR(100) PRIMARY KEY NOT NULL,
    Адрес NVARCHAR(512) NOT NULL,
	Регион TINYINT NOT NULL,
	Рейтинг SMALLINT NULL
);

INSERT INTO ГоКлуб(Название, Адрес, Регион, Рейтинг)
VALUES ('Иванов Иван Иваныч', 'лучшее место', 100, 1487)


INSERT INTO ГоКлуб(Название, Адрес, Регион, Рейтинг)
VALUES ('sente', 'Москва', 0, 1900)

SELECT * FROM ГоКлуб;
GO

DROP TABLE ГоКлуб;
GO

ALTER DATABASE СборнаяDB
MODIFY FILEGROUP [PRIMARY] DEFAULT;
GO
/*
Этот шаг изменяет группу файлов по умолчанию обратно на PRIMARY. Это означает, что все новые таблицы, 
создаваемые после этого изменения, будут создаваться в группе файлов PRIMARY, если не указано иное.
*/

ALTER DATABASE СборнаяDB
REMOVE FILE СборнаяData;
GO

ALTER DATABASE СборнаяDB
REMOVE FILEGROUP СборнаяFG;
GO

CREATE SCHEMA СборнаяСхема;
GO

ALTER SCHEMA СборнаяСхема TRANSFER dbo.Сборная;
GO

DROP TABLE СборнаяСхема.Сборная;
GO

DROP SCHEMA СборнаяСхема;
GO
