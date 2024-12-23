
-- �������� ��� ������

IF DB_ID('GoPlayersDB1') IS NULL
    EXEC('CREATE DATABASE GoPlayersDB1');
IF DB_ID('GoPlayersDB2') IS NULL
    EXEC('CREATE DATABASE GoPlayersDB2');
GO


-- �������� ������


-- �������� ������� PlayerInfo � GoPlayersDB1
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

-- �������� ������� PlayerStats � GoPlayersDB2
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


-- ������� �������� ������


-- ������� ������ � PlayerInfo (GoPlayersDB1)
USE GoPlayersDB1;
GO
INSERT INTO dbo.PlayerInfo (player_id, last_name, first_name, middle_name, date_of_birth, rating, country) VALUES
(1, '������', '����', '��������', '1990-01-15', 1500, 'RU'),
(2, '������', '����', '��������', '1992-05-20', 1800, 'CN'),
(3, '�������', '�����', '���������', '1995-10-10', 2200, 'JP');
GO

-- ������� ������ � PlayerStats (GoPlayersDB2)
USE GoPlayersDB2;
GO
INSERT INTO dbo.PlayerStats (player_id, region, club_name) VALUES
(1, 77, 'Club A'),
(2, 50, 'Club B'),
(3, 78, 'Club C');
GO


-- �������� ������������� ��� "���������" �������


-- ������������� PlayerStatsView � GoPlayersDB1 ��� ������� � PlayerStats �� GoPlayersDB2
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

-- ������������� PlayerInfoView � GoPlayersDB2 ��� ������� � PlayerInfo �� GoPlayersDB1
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


-- �������� ��������� ��� PlayerInfo (GoPlayersDB1)


USE GoPlayersDB1;
GO

-- ������� �� ������� � PlayerInfo
-- ��������, ��� ������� �� �������������
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
        RAISERROR('ERROR: ������� �� ����� ���� �������������.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO

-- ������� �� ���������� � PlayerInfo
-- ��������� ��������� player_id
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
        RAISERROR('ERROR: ��������� player_id ���������.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO

-- ������� �� �������� � PlayerInfo
-- ��������� �������� �� PlayerStats
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


-- �������� ��������� ��� PlayerStats (GoPlayersDB2)


USE GoPlayersDB2;
GO

-- ������� �� ������� � PlayerStats
-- ���������, ��� player_id ���������� � PlayerInfo
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

-- ������� �� ���������� � PlayerStats
-- ��������� ��������� player_id � ��������� ������������� player_id � PlayerInfo
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
        RAISERROR('ERROR: ��������� player_id ���������.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

   
END;
GO




-- �������� ������


-- ���������� �������� ������ � PlayerInfo (player_id �� ��������, ������ ���������)
USE GoPlayersDB1;
GO
UPDATE dbo.PlayerInfo SET rating = 2100 WHERE player_id = 1;
GO

-- ������� �������� PlayerStats � �������������� player_id = 9999 (������ ���� ������)
USE GoPlayersDB2;
GO
BEGIN TRY
    INSERT INTO dbo.PlayerStats (player_id, region, club_name) VALUES (9999, 10, 'NonExistent');
END TRY
BEGIN CATCH
    SELECT ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

-- ������� �������� player_id � PlayerStats (������ ���� ������)
BEGIN TRY
    UPDATE dbo.PlayerStats SET player_id = 9999 WHERE player_id = 1;
END TRY
BEGIN CATCH
    SELECT ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

-- �������� ������ �� PlayerInfo
-- ������ �������� ������� ������ �� PlayerStats
USE GoPlayersDB1;
GO
DELETE FROM dbo.PlayerInfo WHERE player_id = 2;
GO

-- �������� ������ � PlayerInfo
SELECT * FROM dbo.PlayerInfo;
GO

-- �������� ������ � PlayerStats (������ ��� player_id=2 ������ ���� �������)
USE GoPlayersDB2;
GO
SELECT * FROM dbo.PlayerStats;
GO

-- �������� ����������� �������� � PlayerStatsDeleteLog
SELECT * FROM dbo.PlayerStatsDeleteLog;
GO

-- �������� ������ ����� �������������
-- � GoPlayersDB1: �������� ������ PlayerStats
USE GoPlayersDB1;
GO
SELECT * FROM dbo.PlayerStatsView;
GO

-- � GoPlayersDB2: �������� ������ PlayerInfo
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
