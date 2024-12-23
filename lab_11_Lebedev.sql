---------------------------------------------------------------------
-- 1. Переход на базу master и удаление существующей базы GoGameDB
---------------------------------------------------------------------
USE master;
GO

IF EXISTS (SELECT name FROM sys.databases WHERE name = N'GoGameDB')
BEGIN
    ALTER DATABASE GoGameDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE GoGameDB;
END
GO

---------------------------------------------------------------------
-- 2. Создание базы данных GoGameDB
---------------------------------------------------------------------
CREATE DATABASE GoGameDB
ON 
PRIMARY (
    NAME = GoGameDB_Data,
    FILENAME = 'D:\programming\labDB\lab11\GoGameDB_Data.mdf', 
    SIZE = 10MB,
    MAXSIZE = 100MB,
    FILEGROWTH = 5MB
),
FILEGROUP FG_GoGames (
    NAME = GoGameDB_GoGamesData,
    FILENAME = 'D:\programming\labDB\lab11\GoGameDB_GoGamesData.ndf', 
    SIZE = 5MB,
    MAXSIZE = 50MB,
    FILEGROWTH = 5MB
)
LOG ON (
    NAME = GoGameDB_Log,
    FILENAME = 'D:\programming\labDB\lab11\GoGameDB_Log.ldf', 
    SIZE = 5MB,
    MAXSIZE = 25MB,
    FILEGROWTH = 5MB
);
GO

USE GoGameDB;
GO

---------------------------------------------------------------------
-- 3. Создание последовательности для TournamentID 
---------------------------------------------------------------------
IF EXISTS (SELECT * FROM sys.sequences WHERE name = N'Seq_TournamentID')
BEGIN
    DROP SEQUENCE Seq_TournamentID;
END
GO

CREATE SEQUENCE Seq_TournamentID
    START WITH 1
    INCREMENT BY 1;
GO

---------------------------------------------------------------------
-- 4. Создание таблиц с ограничениями целостности
---------------------------------------------------------------------

---------------------------
-- 4.1 Таблица Region (Регион)
---------------------------
IF OBJECT_ID('dbo.Region', 'U') IS NOT NULL
    DROP TABLE dbo.Region;
GO

CREATE TABLE Region (
    region_id INT PRIMARY KEY IDENTITY(1,1),
    name       NVARCHAR(100) NOT NULL,
    [Description] NVARCHAR(1000) NULL
);
GO

---------------------------
-- 4.3 Таблица GoClub (Го клуб)
---------------------------
IF OBJECT_ID('dbo.GoClub', 'U') IS NOT NULL
    DROP TABLE dbo.GoClub;
GO

CREATE TABLE GoClub (
    name    NVARCHAR(100) NOT NULL PRIMARY KEY, -- название 
    address NVARCHAR(512) NOT NULL,             -- адрес
    region  TINYINT       NOT NULL,             -- регион (код)
    rating  SMALLINT      NULL                  -- рейтинг
);
GO

---------------------------
-- 4.2 Таблица Player (Игрок)
---------------------------
IF OBJECT_ID('dbo.Player', 'U') IS NOT NULL
    DROP TABLE dbo.Player;
GO

CREATE TABLE Player (
    player_id       INT          NOT NULL PRIMARY KEY IDENTITY(1,1),   -- PK
    last_name       NVARCHAR(100) NOT NULL,                            -- фамилия
    first_name      NVARCHAR(100) NOT NULL,                            -- имя
    middle_name     NVARCHAR(100) NOT NULL,                            -- отчество
    birth_date      DATE          NOT NULL,                            -- дата рождения
    rating          SMALLINT      NULL,                                -- рейтинг
    country         VARCHAR(2)    NOT NULL DEFAULT('KR'),              -- страна (код)
    region          INT           NULL,                                -- FK -> Region
    club_name       NVARCHAR(100) NULL,                                -- FK -> GoClub
    CONSTRAINT UQ_Player_FIOB UNIQUE (last_name, first_name, middle_name, birth_date), -- Альтернативный ключ
    CONSTRAINT FK_Player_Region FOREIGN KEY (region) REFERENCES Region(region_id),
    CONSTRAINT FK_Player_Club   FOREIGN KEY (club_name) REFERENCES GoClub(name)
);
GO


---------------------------
-- 4.4 Таблица NationalTeam (Сборная)
---------------------------
IF OBJECT_ID('dbo.NationalTeam', 'U') IS NOT NULL
    DROP TABLE dbo.NationalTeam;
GO

CREATE TABLE NationalTeam (
    region           INT          NOT NULL PRIMARY KEY,  -- PK (регион)
    captain_player_id INT NOT NULL              -- капитан (FK -> Player)
);
GO

-- Добавляем внешние ключи
ALTER TABLE NationalTeam
ADD CONSTRAINT FK_NationalTeam_Region FOREIGN KEY (region)
    REFERENCES Region(region_id),
    CONSTRAINT FK_NationalTeam_Captain FOREIGN KEY (captain_player_id)
    REFERENCES Player(player_id);
GO

---------------------------
-- 4.5 Таблица Tournament (Турнир)
---------------------------
IF OBJECT_ID('dbo.Tournament', 'U') IS NOT NULL
    DROP TABLE dbo.Tournament;
GO

CREATE TABLE Tournament (
    tournament_id        INT NOT NULL PRIMARY KEY,           -- PK
    tournament_name      NVARCHAR(100) NOT NULL,             -- название турнира 
    start_date           DATE          NOT NULL,             -- дата начала 
    end_date             DATE          NOT NULL,             -- дата окончания
    location             NVARCHAR(512) NOT NULL,             -- место проведения
    organizer            NVARCHAR(100) NOT NULL,             -- организатор
    competition_level    TINYINT       NOT NULL,             -- уровень соревнований
    regulation_link      NVARCHAR(256) NOT NULL,             -- ссылка на регламент
    CONSTRAINT UQ_Tournament_NameDate UNIQUE (tournament_name, start_date) -- Альтернативный ключ
);
GO

-- Добавляем default значение для tournament_id, используя sequence
ALTER TABLE Tournament
ADD CONSTRAINT DF_TournamentID_Default
    DEFAULT NEXT VALUE FOR Seq_TournamentID FOR tournament_id;
GO

---------------------------
-- 4.6 Таблица Game (Партия)
---------------------------
IF OBJECT_ID('dbo.Game', 'U') IS NOT NULL
    DROP TABLE dbo.Game;
GO

CREATE TABLE Game (
    game_date      DATETIME      NOT NULL, -- дата проведения 
    player_id_1    INT           NOT NULL, -- FK + PK
    player_id_2    INT           NOT NULL, -- FK + PK
    winner         TINYINT       NOT NULL, -- победитель (0,1,2)
    game_status    TINYINT       NOT NULL, -- статус партии
    game_link      NVARCHAR(256) NOT NULL, -- ссылка на партию
    handicap       TINYINT       NOT NULL, -- фора
    tournament_id  INT           NOT NULL, -- FK
    CONSTRAINT PK_Game PRIMARY KEY (game_date, player_id_1, player_id_2),

    -- Внешние ключи
    CONSTRAINT FK_Game_Player1 FOREIGN KEY (player_id_1) REFERENCES Player(player_id),
    CONSTRAINT FK_Game_Player2 FOREIGN KEY (player_id_2) REFERENCES Player(player_id),
    CONSTRAINT FK_Game_Tournament FOREIGN KEY (tournament_id) REFERENCES Tournament(tournament_id)
);
GO

---------------------------------------------------------------------
-- 4.7 Таблица "Игрок_Турнир_INT" (Player_Tournament_INT) 
---------------------------------------------------------------------
IF OBJECT_ID('dbo.Player_Tournament_INT', 'U') IS NOT NULL
    DROP TABLE dbo.Player_Tournament_INT;
GO

CREATE TABLE Player_Tournament_INT (
    tournament_id INT NOT NULL,
    player_id     INT NOT NULL,
    CONSTRAINT PK_Player_Tournament_INT PRIMARY KEY (tournament_id, player_id),
    CONSTRAINT FK_Player_Tournament_INT_Tournament FOREIGN KEY (tournament_id)
        REFERENCES Tournament(tournament_id),
    CONSTRAINT FK_Player_Tournament_INT_Player FOREIGN KEY (player_id)
        REFERENCES Player(player_id)
);
GO


---------------------------------------------------------------------
-- 5. Создание индексов 
---------------------------------------------------------------------

-- Индекс по фамилии игрока
IF EXISTS (SELECT * FROM sys.indexes WHERE name = N'IDX_Player_LastName' AND object_id = OBJECT_ID('Player'))
BEGIN
    DROP INDEX IDX_Player_LastName ON Player;
END
GO
CREATE NONCLUSTERED INDEX IDX_Player_LastName ON Player(last_name);
GO

-- Индекс по названию GoClub
IF EXISTS (SELECT * FROM sys.indexes WHERE name = N'IDX_GoClub_Name' AND object_id = OBJECT_ID('GoClub'))
BEGIN
    DROP INDEX IDX_GoClub_Name ON GoClub;
END
GO
CREATE NONCLUSTERED INDEX IDX_GoClub_Name ON GoClub(name);
GO

-- Индекс по дате проведения Game
IF EXISTS (SELECT * FROM sys.indexes WHERE name = N'IDX_Game_GameDate' AND object_id = OBJECT_ID('Game'))
BEGIN
    DROP INDEX IDX_Game_GameDate ON Game;
END
GO
CREATE NONCLUSTERED INDEX IDX_Game_GameDate ON Game(game_date);
GO

-- Индекс по названию турнира
IF EXISTS (SELECT * FROM sys.indexes WHERE name = N'IDX_Tournament_Name' AND object_id = OBJECT_ID('Tournament'))
BEGIN
    DROP INDEX IDX_Tournament_Name ON Tournament;
END
GO
CREATE NONCLUSTERED INDEX IDX_Tournament_Name ON Tournament(tournament_name);
GO

---------------------------------------------------------------------
-- 6. Создание представлений
---------------------------------------------------------------------

-- 6.1 Представление V_PlayerClubInfo
IF EXISTS (SELECT * FROM sys.views WHERE name = N'V_PlayerClubInfo')
BEGIN
    DROP VIEW V_PlayerClubInfo;
END
GO

CREATE VIEW V_PlayerClubInfo AS
SELECT 
    p.player_id,
    p.last_name,
    p.first_name,
    p.middle_name,
    p.birth_date,
    p.rating,
    p.country,
    p.region,
    c.name AS club_name
FROM Player p
LEFT JOIN GoClub c ON p.club_name = c.name;  -- ИЗМЕНЕНО: связываем по club_name
GO

-- 6.2 Представление V_GameResults
IF EXISTS (SELECT * FROM sys.views WHERE name = N'V_GameResults')
BEGIN
    DROP VIEW V_GameResults;
END
GO

CREATE VIEW V_GameResults AS
SELECT 
    g.game_date,
    g.player_id_1,
    g.player_id_2,
    CASE WHEN g.winner = 0 THEN 'Player1 Wins'
         WHEN g.winner = 1 THEN 'Player2 Wins'
         ELSE 'Draw'
    END AS [Result],
    t.tournament_name,
    t.location,
    g.game_status,
    g.game_link,
    g.handicap
FROM Game g
INNER JOIN Tournament t ON g.tournament_id = t.tournament_id;
GO

---------------------------------------------------------------------
-- 7. Создание хранимых процедур 
---------------------------------------------------------------------

IF EXISTS (SELECT * FROM sys.objects WHERE type = N'P' AND name = N'AddNewPlayer')
BEGIN
    DROP PROCEDURE AddNewPlayer;
END
GO

CREATE PROCEDURE AddNewPlayer
    @LastName   NVARCHAR(100),
    @FirstName  NVARCHAR(100),
    @MiddleName NVARCHAR(100),
    @BirthDate  DATE,
    @Rating     SMALLINT = NULL,
    @Country    VARCHAR(2) = 'KR',
    @Region     INT        = NULL,
    @ClubName   NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Проверка существования региона
    IF @Region IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Region WHERE region_id = @Region)
    BEGIN
        RAISERROR('Region ID %d does not exist.', 16, 1, @Region);
        RETURN;
    END

    -- Проверка существования клуба
    IF @ClubName IS NOT NULL AND NOT EXISTS (SELECT 1 FROM GoClub WHERE name = @ClubName)
    BEGIN
        RAISERROR('GoClub with name %s does not exist.', 16, 1, @ClubName);
        RETURN;
    END

    -- Проверка уникальности (фамилия, имя, отчество, дата)
    IF EXISTS (
        SELECT 1 
        FROM Player
        WHERE last_name   = @LastName
          AND first_name  = @FirstName
          AND middle_name = @MiddleName
          AND birth_date  = @BirthDate
    )
    BEGIN
        RAISERROR('Such player already exists.', 16, 1);
        RETURN;
    END

    INSERT INTO Player (
        last_name, first_name, middle_name, birth_date,
        rating, country, region, club_name
    )
    VALUES (
        @LastName, @FirstName, @MiddleName, @BirthDate,
        @Rating, @Country, @Region, @ClubName
    );
END;
GO

---------------------------------------------------------------------
-- 8. Создание функций 
---------------------------------------------------------------------
IF EXISTS (SELECT * FROM sys.objects WHERE type = N'FN' AND name = N'GetPlayerAge')
BEGIN
    DROP FUNCTION dbo.GetPlayerAge;
END
GO

CREATE FUNCTION dbo.GetPlayerAge (@PlayerID INT)
RETURNS INT
AS
BEGIN
    DECLARE @BirthDate DATE;
    SELECT @BirthDate = birth_date
    FROM Player
    WHERE player_id = @PlayerID;

    IF @BirthDate IS NULL
        RETURN NULL;

    RETURN DATEDIFF(YEAR, @BirthDate, GETDATE())
           - CASE 
               WHEN (MONTH(@BirthDate) > MONTH(GETDATE()))
                 OR (MONTH(@BirthDate) = MONTH(GETDATE()) AND DAY(@BirthDate) > DAY(GETDATE()))
               THEN 1 
               ELSE 0 
             END;
END;
GO

---------------------------------------------------------------------
-- 9. Создание триггеров 
---------------------------------------------------------------------

-- Пример: Триггер на Game для предотвращения изменения ключевых полей
IF EXISTS (SELECT * FROM sys.triggers WHERE name = N'trg_Game_PreventPKUpdate')
BEGIN
    DROP TRIGGER trg_Game_PreventPKUpdate;
END
GO

CREATE TRIGGER trg_Game_PreventPKUpdate
ON Game
FOR UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF UPDATE(game_date) OR UPDATE(player_id_1) OR UPDATE(player_id_2)
    BEGIN
        RAISERROR('Cannot update primary key fields in Game table!', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO


IF EXISTS (SELECT * FROM sys.triggers WHERE name = N'trg_Tournament_PreventDelete')
    DROP TRIGGER trg_Tournament_PreventDelete;
GO

CREATE TRIGGER trg_Tournament_PreventDelete
ON Tournament
INSTEAD OF DELETE
AS
BEGIN
    RAISERROR('Deleting from Tournament is not allowed!', 16, 1);
    ROLLBACK TRANSACTION;
END;
GO

IF EXISTS (SELECT * FROM sys.triggers WHERE name = N'trg_Game_PreventPKUpdate')
    DROP TRIGGER trg_Game_PreventPKUpdate;
GO

CREATE TRIGGER trg_Game_PreventPKUpdate
ON Game
FOR UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF UPDATE(game_date) OR UPDATE(player_id_1) OR UPDATE(player_id_2)
    BEGIN
        RAISERROR('Cannot update primary key fields in Game table!', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO


IF EXISTS (SELECT * FROM sys.triggers WHERE name = N'trg_Tournament_PreventPKUpdate')
    DROP TRIGGER trg_Tournament_PreventPKUpdate;
GO

CREATE TRIGGER trg_Tournament_PreventPKUpdate
ON Tournament
FOR UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF UPDATE(tournament_id)
    BEGIN
        RAISERROR('Cannot update tournament_id in Tournament table!', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO

IF EXISTS (SELECT * FROM sys.triggers WHERE name = N'trg_Player_PreventDelete')
    DROP TRIGGER trg_Player_PreventDelete;
GO

CREATE TRIGGER trg_Player_PreventDelete
ON Player
INSTEAD OF DELETE
AS
BEGIN
    RAISERROR('Deleting a player is not allowed!', 16, 1);
    ROLLBACK TRANSACTION;
END;
GO

IF EXISTS (SELECT * FROM sys.triggers WHERE name = N'trg_GoClub_CascadeSetNull')
    DROP TRIGGER trg_GoClub_CascadeSetNull;
GO

CREATE TRIGGER trg_GoClub_CascadeSetNull
ON GoClub
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Player
    SET club_name = NULL
    FROM Player p
    INNER JOIN deleted d ON p.club_name = d.name;
END;
GO

-- Триггер для предотвращения удаления записей из таблицы Game
IF EXISTS (SELECT * FROM sys.triggers WHERE name = N'trg_Game_PreventDelete')
    DROP TRIGGER trg_Game_PreventDelete;
GO

CREATE TRIGGER trg_Game_PreventDelete
ON Game
INSTEAD OF DELETE
AS
BEGIN
    RAISERROR('Deleting from Game is not allowed!', 16, 1);
    ROLLBACK TRANSACTION;
END;
GO


-- Триггер для предотвращения удаления записей из таблицы Player_Tournament_INT
IF EXISTS (SELECT * FROM sys.triggers WHERE name = N'trg_Player_Tournament_INT_PreventDelete')
    DROP TRIGGER trg_Player_Tournament_INT_PreventDelete;
GO

CREATE TRIGGER trg_Player_Tournament_INT_PreventDelete
ON Player_Tournament_INT
INSTEAD OF DELETE
AS
BEGIN
    RAISERROR('Deleting from Player_Tournament_INT is not allowed!', 16, 1);
    ROLLBACK TRANSACTION;
END;
GO


-- Триггер для предотвращения удаления записей из таблицы NationalTeam
IF EXISTS (SELECT * FROM sys.triggers WHERE name = N'trg_NationalTeam_PreventDelete')
    DROP TRIGGER trg_NationalTeam_PreventDelete;
GO

CREATE TRIGGER trg_NationalTeam_PreventDelete
ON NationalTeam
INSTEAD OF DELETE
AS
BEGIN
    RAISERROR('Deleting from NationalTeam is not allowed!', 16, 1);
    ROLLBACK TRANSACTION;
END;
GO






---------------------------------------------------------------------
-- 10. DML-запросы для тестирования функционала
---------------------------------------------------------------------

-- 10.1 INSERT

-- 10.1.1 Добавление регионов
INSERT INTO Region (name, [Description])
VALUES
('Seoul', 'Capital of South Korea'),
('Tokyo', 'Capital of Japan');
GO

-- 10.1.2 Добавление GoClub (с tinyint region)
INSERT INTO GoClub (name, address, region, rating)
VALUES
('Seoul Go Club', 'Seoul Address', 1, 95),
('Tokyo Go Club', 'Tokyo Address', 2, 90);
GO

-- 10.1.3 Добавление новых игроков
INSERT INTO Player (last_name, first_name, middle_name, birth_date, rating, country, region, club_name)
VALUES
('Inoue', 'Tomoko', 'Yuki', '1985-03-22', 85, 'JP', 2, 'Tokyo Go Club'),
('Doe',   'John',   'Michael', '1990-07-15', 70, 'KR', 1, 'Seoul Go Club');
GO

-- 10.1.4 Добавление турнира
INSERT INTO Tournament (
    tournament_id, 
    tournament_name, 
    start_date, 
    end_date, 
    location, 
    organizer, 
    competition_level, 
    regulation_link
)
VALUES
(1, 'International Go Tournament', '2023-06-01', '2023-06-15', 'Seoul', 'Go Federation', 1, 'http://regulations.example.com');
GO

-- 10.1.5 Добавление партии (Game)
INSERT INTO Game (
    game_date, player_id_1, player_id_2,
    winner, game_status, game_link, handicap, tournament_id
)
VALUES
(GETDATE(), 1, 2, 0, 1, 'http://example.com/game1', 0, 1);
GO

-- 10.1.6 Добавление участия игроков в турнире (Игрок_Турнир_INT)
INSERT INTO Player_Tournament_INT (tournament_id, player_id)
VALUES
(1, 1),
(1, 2);
GO

-------------------
-- 10.2 SELECT
-------------------

-- Примеры выборок:
SELECT DISTINCT country
FROM Player;
GO

SELECT
    p.last_name AS [Last Name],
    p.first_name AS [First Name],
    c.name AS [Club Name]
FROM Player p
INNER JOIN GoClub c ON p.club_name = c.name;
GO

-- Выборка партий
SELECT
    g.game_date,
    g.player_id_1,
    g.player_id_2,
    CASE WHEN g.winner = 0 THEN 'Player1 Wins'
         WHEN g.winner = 1 THEN 'Player2 Wins'
         ELSE 'Draw'
    END AS result,
    t.tournament_name,
    t.location
FROM Game g
INNER JOIN Tournament t ON g.tournament_id = t.tournament_id;
GO

-- RIGHT JOIN, FULL OUTER JOIN, LEFT JOIN
SELECT
    c.name AS club_name,
    p.last_name,
    p.first_name
FROM GoClub c
RIGHT JOIN Player p ON c.name = p.club_name;
GO

SELECT
    p.last_name,
    p.first_name,
    c.name AS club_name
FROM Player p
FULL OUTER JOIN GoClub c ON p.club_name = c.name;
GO

SELECT
    p.last_name,
    p.first_name,
    c.name AS club_name
FROM Player p
LEFT JOIN GoClub c ON p.club_name = c.name;
GO

-- Прочие примеры WHERE, LIKE, BETWEEN, IN, EXISTS
-- Подсчёт количества игроков по стране (пример GROUP BY)
SELECT country, COUNT(*) AS PlayerCount
FROM Player
GROUP BY country
HAVING COUNT(*) > 0;  -- Пример HAVING
GO

-- Средний рейтинг по регионам
SELECT region, AVG(rating) AS AvgRating
FROM Player
GROUP BY region;
GO


-- Пример UNION
SELECT last_name AS Name FROM Player
UNION
SELECT name AS Name FROM GoClub;
GO

-- Пример EXCEPT
SELECT last_name AS Name FROM Player
EXCEPT
SELECT name AS Name FROM GoClub;
GO


-- Пример подзапроса
SELECT last_name, first_name, rating
FROM Player
WHERE rating > (SELECT AVG(rating) FROM Player);
GO


-- Пример IN
SELECT * 
FROM Player
WHERE country IN ('JP', 'KR');
GO

-- Пример BETWEEN (даты)
SELECT game_date, player_id_1, player_id_2
FROM Game
WHERE game_date BETWEEN '20230101' AND '20231231';
GO

-- Пример EXISTS
SELECT p.last_name, p.first_name
FROM Player p
WHERE EXISTS (
    SELECT 1
    FROM Game g
    WHERE g.player_id_1 = p.player_id
);
GO


SELECT * FROM Player
WHERE region IS NULL;
GO


SELECT last_name, first_name
FROM Player
WHERE last_name LIKE 'D%';
GO


-------------------
-- 10.3 UPDATE
-------------------

-- Пример: Увеличение рейтинга
UPDATE Player
SET rating = rating + 5
WHERE region = 1;
GO

-- Пример: Обновление адреса клуба
UPDATE GoClub
SET address = 'Osaka'
WHERE name = 'Tokyo Go Club';
GO

-------------------
-- 10.4 DELETE
-------------------

-- Пример: Удаление игроков с низким рейтингом (ошибка в триггере)
--DELETE FROM Player
--WHERE rating < 50;
--GO

-- Пример: Удаление партий до 2000 года (ошибка в триггере)
--DELETE FROM Game
--WHERE YEAR(game_date) < 2000;
--GO

---------------------------------------------------------------------
-- 11. Дополнительные примеры использования хранимых процедур и функций
---------------------------------------------------------------------

EXEC AddNewPlayer
    @LastName = 'Suzuki',
    @FirstName = 'Akira',
    @MiddleName = 'Hiroshi',
    @BirthDate = '1990-07-12',
    @Rating = 90,
    @Country = 'JP',
    @Region = 2,
    @ClubName = 'Tokyo Go Club';
GO

SELECT
    last_name,
    first_name,
    dbo.GetPlayerAge(player_id) AS Age
FROM Player;
GO

---------------------------------------------------------------------
-- 12. Примеры использования представлений
---------------------------------------------------------------------
SELECT
    game_date,
    player_id_1,
    player_id_2,
    [Result],
    tournament_name,
    location,
    game_status,
    game_link,
    handicap
FROM V_GameResults
ORDER BY game_date DESC;
GO

---------------------------------------------------------------------
-- 13. Очистка базы данных (Удаление всех созданных объектов)
---------------------------------------------------------------------
IF EXISTS (SELECT name FROM sys.databases WHERE name = N'GoGameDB')
BEGIN
    USE master;
    ALTER DATABASE GoGameDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE GoGameDB;
END
GO
