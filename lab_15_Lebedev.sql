
-- Создание баз данных

IF DB_ID('GoPlayersDB1') IS NULL
    EXEC('CREATE DATABASE GoPlayersDB1');
IF DB_ID('GoPlayersDB2') IS NULL
    EXEC('CREATE DATABASE GoPlayersDB2');
GO


-- Создание таблиц


-- Создание таблицы PlayerInfo в GoPlayersDB1
USE GoPlayersDB1;
GO

IF OBJECT_ID('dbo.PlayerInfo', 'U') IS NOT NULL
    DROP TABLE dbo.PlayerInfo;
GO

CREATE TABLE dbo.PlayerInfo (
    player_id INT PRIMARY KEY,
    last_name NVARCHAR(100) NOT NULL,
    first_name NVARCHAR(100) NOT NULL,
    middle_name NVARCHAR(100) NOT NULL,
    date_of_birth DATE NOT NULL,
    rating SMALLINT,
    country VARCHAR(2) NOT NULL DEFAULT 'RU'
);
GO

-- Создание таблицы PlayerStats в GoPlayersDB2
USE GoPlayersDB2;
GO

IF OBJECT_ID('dbo.PlayerStats', 'U') IS NOT NULL
    DROP TABLE dbo.PlayerStats;
GO

CREATE TABLE dbo.PlayerStats (
    player_id INT PRIMARY KEY,
    region INT NOT NULL,
    club_name NVARCHAR(100)
);
GO


-- Вставка исходных данных


-- Вставка данных в PlayerInfo (GoPlayersDB1)
USE GoPlayersDB1;
GO
INSERT INTO dbo.PlayerInfo (player_id, last_name, first_name, middle_name, date_of_birth, rating, country) VALUES
(1, 'Иванов', 'Иван', 'Иванович', '1990-01-15', 1500, 'RU'),
(2, 'Петров', 'Петр', 'Петрович', '1992-05-20', 1800, 'CN'),
(3, 'Сидоров', 'Сидор', 'Сидорович', '1995-10-10', 2200, 'JP');
GO

-- Вставка данных в PlayerStats (GoPlayersDB2)
USE GoPlayersDB2;
GO
INSERT INTO dbo.PlayerStats (player_id, region, club_name) VALUES
(1, 77, 'Club A'),
(2, 50, 'Club B'),
(3, 78, 'Club C');
GO


-- Создание представлений для "сквозного" доступа


-- Представление PlayerStatsView в GoPlayersDB1 для доступа к PlayerStats из GoPlayersDB2
USE GoPlayersDB1;
GO

IF OBJECT_ID('dbo.PlayerStatsView', 'V') IS NOT NULL
    DROP VIEW dbo.PlayerStatsView;
GO

CREATE VIEW dbo.PlayerStatsView AS
SELECT
    ps.player_id,
    ps.region,
    ps.club_name
FROM
    GoPlayersDB2.dbo.PlayerStats ps;
GO

-- Представление PlayerInfoView в GoPlayersDB2 для доступа к PlayerInfo из GoPlayersDB1
USE GoPlayersDB2;
GO

IF OBJECT_ID('dbo.PlayerInfoView', 'V') IS NOT NULL
    DROP VIEW dbo.PlayerInfoView;
GO

CREATE VIEW dbo.PlayerInfoView AS
SELECT
    pi.player_id,
    pi.last_name,
    pi.first_name,
    pi.middle_name,
    pi.date_of_birth,
    pi.rating,
    pi.country
FROM
    GoPlayersDB1.dbo.PlayerInfo pi;
GO


-- Создание триггеров для PlayerInfo (GoPlayersDB1)


USE GoPlayersDB1;
GO

-- Триггер на вставку в PlayerInfo
-- Проверим, что рейтинг не отрицательный
IF OBJECT_ID('dbo.PlayerInfoInsert', 'TR') IS NOT NULL
    DROP TRIGGER dbo.PlayerInfoInsert;
GO

CREATE TRIGGER dbo.PlayerInfoInsert
ON dbo.PlayerInfo
FOR INSERT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE rating < 0
    )
    BEGIN
        RAISERROR('ERROR: Рейтинг не может быть отрицательным.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO

-- Триггер на обновление в PlayerInfo
-- Запрещает изменение player_id
IF OBJECT_ID('dbo.PlayerInfoUpdate', 'TR') IS NOT NULL
    DROP TRIGGER dbo.PlayerInfoUpdate;
GO

CREATE TRIGGER dbo.PlayerInfoUpdate
ON dbo.PlayerInfo
FOR UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF UPDATE(player_id)
    BEGIN
        RAISERROR('ERROR: Изменение player_id запрещено.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO

-- Триггер на удаление в PlayerInfo
-- Каскадное удаление из PlayerStats
IF OBJECT_ID('dbo.PlayerInfoDelete', 'TR') IS NOT NULL
    DROP TRIGGER dbo.PlayerInfoDelete;
GO

CREATE TRIGGER dbo.PlayerInfoDelete
ON dbo.PlayerInfo
FOR DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM GoPlayersDB2.dbo.PlayerStats
    WHERE player_id IN (SELECT player_id FROM deleted);
END;
GO


-- Создание триггеров для PlayerStats (GoPlayersDB2)


USE GoPlayersDB2;
GO

-- Триггер на вставку в PlayerStats
-- Проверяем, что player_id существует в PlayerInfo
IF OBJECT_ID('dbo.PlayerStatsInsert', 'TR') IS NOT NULL
    DROP TRIGGER dbo.PlayerStatsInsert;
GO

CREATE TRIGGER dbo.PlayerStatsInsert
ON dbo.PlayerStats
FOR INSERT
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (
        SELECT 1
        FROM inserted i
        LEFT JOIN GoPlayersDB1.dbo.PlayerInfo pi ON i.player_id = pi.player_id
        WHERE pi.player_id IS NULL
    )
    BEGIN
        RAISERROR('ERROR: PlayerInfo with this player_id does not exist.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO

-- Триггер на обновление в PlayerStats
-- Запрещаем изменение player_id и проверяем существование player_id в PlayerInfo
IF OBJECT_ID('dbo.PlayerStatsUpdate', 'TR') IS NOT NULL
    DROP TRIGGER dbo.PlayerStatsUpdate;
GO

CREATE TRIGGER dbo.PlayerStatsUpdate
ON dbo.PlayerStats
FOR UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF UPDATE(player_id)
    BEGIN
        RAISERROR('ERROR: Изменение player_id запрещено.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

   
END;
GO




-- Проверка логики


-- Обновление рейтинга игрока в PlayerInfo (player_id не меняется, должно сработать)
USE GoPlayersDB1;
GO
UPDATE dbo.PlayerInfo SET rating = 2100 WHERE player_id = 1;
GO

-- Попытка вставить PlayerStats с несуществующим player_id = 9999 (должна быть ошибка)
USE GoPlayersDB2;
GO
BEGIN TRY
    INSERT INTO dbo.PlayerStats (player_id, region, club_name) VALUES (9999, 10, 'NonExistent');
END TRY
BEGIN CATCH
    SELECT ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

-- Попытка обновить player_id в PlayerStats (должна быть ошибка)
BEGIN TRY
    UPDATE dbo.PlayerStats SET player_id = 9999 WHERE player_id = 1;
END TRY
BEGIN CATCH
    SELECT ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

-- Удаление записи из PlayerInfo
-- Должно каскадно удалить запись из PlayerStats
USE GoPlayersDB1;
GO
DELETE FROM dbo.PlayerInfo WHERE player_id = 2;
GO

-- Проверка данных в PlayerInfo
SELECT * FROM dbo.PlayerInfo;
GO

-- Проверка данных в PlayerStats (запись для player_id=2 должна быть удалена)
USE GoPlayersDB2;
GO
SELECT * FROM dbo.PlayerStats;
GO

-- Проверка логирования удаления в PlayerStatsDeleteLog
SELECT * FROM dbo.PlayerStatsDeleteLog;
GO

-- Проверка данных через представления
-- В GoPlayersDB1: Просмотр данных PlayerStats
USE GoPlayersDB1;
GO
SELECT * FROM dbo.PlayerStatsView;
GO

-- В GoPlayersDB2: Просмотр данных PlayerInfo
USE GoPlayersDB2;
GO
SELECT * FROM dbo.PlayerInfoView;
GO



USE GoPlayersDB2;
GO
IF OBJECT_ID('dbo.PlayerStatsDelete', 'TR') IS NOT NULL
    DROP TRIGGER dbo.PlayerStatsDelete;
IF OBJECT_ID('dbo.PlayerStatsUpdate', 'TR') IS NOT NULL
    DROP TRIGGER dbo.PlayerStatsUpdate;
IF OBJECT_ID('dbo.PlayerStatsInsert', 'TR') IS NOT NULL
    DROP TRIGGER dbo.PlayerStatsInsert;
IF OBJECT_ID('dbo.PlayerInfoView', 'V') IS NOT NULL
    DROP VIEW dbo.PlayerInfoView;
IF OBJECT_ID('dbo.PlayerStats', 'U') IS NOT NULL
    DROP TABLE dbo.PlayerStats;
IF OBJECT_ID('dbo.PlayerStatsDeleteLog', 'U') IS NOT NULL
    DROP TABLE dbo.PlayerStatsDeleteLog;
GO

USE GoPlayersDB1;
GO
IF OBJECT_ID('dbo.PlayerInfoDelete', 'TR') IS NOT NULL
    DROP TRIGGER dbo.PlayerInfoDelete;
IF OBJECT_ID('dbo.PlayerInfoUpdate', 'TR') IS NOT NULL
    DROP TRIGGER dbo.PlayerInfoUpdate;
IF OBJECT_ID('dbo.PlayerInfoInsert', 'TR') IS NOT NULL
    DROP TRIGGER dbo.PlayerInfoInsert;
IF OBJECT_ID('dbo.PlayerStatsView', 'V') IS NOT NULL
    DROP VIEW dbo.PlayerStatsView;
IF OBJECT_ID('dbo.PlayerInfo', 'U') IS NOT NULL
    DROP TABLE dbo.PlayerInfo;
GO

USE master;
GO
IF DB_ID('GoPlayersDB1') IS NOT NULL
    DROP DATABASE GoPlayersDB1;
IF DB_ID('GoPlayersDB2') IS NOT NULL
    DROP DATABASE GoPlayersDB2;
GO
