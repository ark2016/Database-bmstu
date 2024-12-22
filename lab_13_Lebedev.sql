
--Удаление баз данных, если они существуют

USE master;
GO

IF DB_ID('GoClubDB1') IS NOT NULL
    DROP DATABASE GoClubDB1;
GO

IF DB_ID('GoClubDB2') IS NOT NULL
    DROP DATABASE GoClubDB2;
GO


-- Создание баз данных

CREATE DATABASE GoClubDB1;
GO

CREATE DATABASE GoClubDB2;
GO


-- Создание таблиц с горизонтальным фрагментированием в GoClubDB1

USE GoClubDB1;
GO

-- Удаляем таблицу, если существует
IF OBJECT_ID('dbo.Player', 'U') IS NOT NULL
    DROP TABLE dbo.Player;
GO

-- Создание таблицы Player в GoClubDB1 (region <= 50)
CREATE TABLE dbo.Player (
    region INT NOT NULL,
    player_id INT NOT NULL,
    last_name NVARCHAR(100) NOT NULL,
    first_name NVARCHAR(100) NOT NULL,
    middle_name NVARCHAR(100) NOT NULL,
    date_of_birth DATE NOT NULL,
    rating SMALLINT,
    country VARCHAR(2) NOT NULL DEFAULT 'RU',
    club_name NVARCHAR(100),
    CONSTRAINT PK_Player1 PRIMARY KEY(region, player_id),
    CONSTRAINT CK_Player_Region1 CHECK (region <= 50)
);
GO


-- Создание таблиц с горизонтальным фрагментированием в GoClubDB2

USE GoClubDB2;
GO

-- Удаляем таблицу, если существует
IF OBJECT_ID('dbo.Player', 'U') IS NOT NULL
    DROP TABLE dbo.Player;
GO

-- Создание таблицы Player в GoClubDB2 (region > 50)
CREATE TABLE dbo.Player (
    region INT NOT NULL,
    player_id INT NOT NULL,
    last_name NVARCHAR(100) NOT NULL,
    first_name NVARCHAR(100) NOT NULL,
    middle_name NVARCHAR(100) NOT NULL,
    date_of_birth DATE NOT NULL,
    rating SMALLINT,
    country VARCHAR(2) NOT NULL DEFAULT 'RU',
    club_name NVARCHAR(100),
    CONSTRAINT PK_Player2 PRIMARY KEY(region, player_id),
    CONSTRAINT CK_Player_Region2 CHECK (region > 50)
);
GO


-- Создание распределённого секционированного представления в GoClubDB1

USE GoClubDB1;
GO

-- Удаление представления, если оно уже существует
IF OBJECT_ID('dbo.PlayerView', 'V') IS NOT NULL
    DROP VIEW dbo.PlayerView;
GO

-- Создание секционированного представления без SCHEMABINDING (т.к. разные БД)
-- Важно: Структура, имена столбцов и порядок их перечисления должны совпадать
-- для обеих частей UNION ALL.
CREATE VIEW dbo.PlayerView
AS
SELECT 
    region,
    player_id,
    last_name,
    first_name,
    middle_name,
    date_of_birth,
    rating,
    country,
    club_name
FROM GoClubDB1.dbo.Player
UNION ALL
SELECT 
    region,
    player_id,
    last_name,
    first_name,
    middle_name,
    date_of_birth,
    rating,
    country,
    club_name
FROM GoClubDB2.dbo.Player;
GO


-- Вставка данных через представление

-- Вставляем запись с region <= 50, должна попасть в GoClubDB1
INSERT INTO dbo.PlayerView (region, player_id, last_name, first_name, middle_name, date_of_birth, rating, country, club_name)
VALUES (10, 1, 'Ivanov', 'Ivan', 'Ivanovich', '1990-01-01', 2000, 'RU', 'Club 1');

-- Вставляем запись с region > 50, должна попасть в GoClubDB2
INSERT INTO dbo.PlayerView (region, player_id, last_name, first_name, middle_name, date_of_birth, rating, country, club_name)
VALUES (60, 1, 'Petrov', 'Petr', 'Petrovich', '1985-05-05', 1800, 'RU', 'Club 2');
GO


-- Выборка данных из представления

SELECT * FROM dbo.PlayerView;
GO

-- Обновление данных через представление
-- Обновим рейтинг для Ivanov (region=10, player_id=1, данные в GoClubDB1)
UPDATE dbo.PlayerView
SET rating = 2200
WHERE last_name = 'Ivanov' AND region = 10 AND player_id = 1;
GO

-- Проверим результат обновления
SELECT * FROM dbo.PlayerView;
GO

--  Удаление данных через представление
-- Удалим запись Ivanov (region <= 50, значит она в GoClubDB1)
DELETE FROM dbo.PlayerView
WHERE region = 10 AND player_id = 1;
GO

-- Проверим таблицы по отдельности
-- Должна остаться только запись Petrov в GoClubDB2
USE GoClubDB1;
GO
SELECT * FROM dbo.Player;
GO

USE GoClubDB2;
GO
SELECT * FROM dbo.Player;
GO

USE GoClubDB1;
GO
IF OBJECT_ID('dbo.PlayerView', 'V') IS NOT NULL
    DROP VIEW dbo.PlayerView;
GO

USE GoClubDB1;
GO
DROP TABLE IF EXISTS dbo.Player;
GO

USE GoClubDB2;
GO
DROP TABLE IF EXISTS dbo.Player;
GO

USE master;
GO
IF DB_ID('GoClubDB1') IS NOT NULL
    DROP DATABASE GoClubDB1;
GO

IF DB_ID('GoClubDB2') IS NOT NULL
    DROP DATABASE GoClubDB2;
GO
