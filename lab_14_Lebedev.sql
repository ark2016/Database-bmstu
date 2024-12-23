-- �������� ��� ������, ���� ��� ����������

USE master;
GO

IF DB_ID('GoClubDB1') IS NOT NULL
    DROP DATABASE GoClubDB1;
GO

IF DB_ID('GoClubDB2') IS NOT NULL
    DROP DATABASE GoClubDB2;
GO

-- �������� ��� ������

CREATE DATABASE GoClubDB1;
GO

CREATE DATABASE GoClubDB2;
GO

-- �������� ����������� ����������������� ������ � GoClubDB1

USE GoClubDB1;
GO

-- �������� ������� PlayerInfo, ���� ��� ��� ����������
IF OBJECT_ID('dbo.PlayerInfo', 'U') IS NOT NULL
    DROP TABLE dbo.PlayerInfo;
GO

-- �������� ������� PlayerInfo � GoClubDB1
CREATE TABLE dbo.PlayerInfo (
    player_id INT PRIMARY KEY,
    last_name NVARCHAR(100) NOT NULL,
    first_name NVARCHAR(100) NOT NULL,
    middle_name NVARCHAR(100) NOT NULL,
    date_of_birth DATE NOT NULL,
    country VARCHAR(2) NOT NULL DEFAULT 'RU'
);
GO

-- �������� ����������� ����������������� ������ � GoClubDB2

USE GoClubDB2;
GO

-- �������� ������� PlayerDetails, ���� ��� ��� ����������
IF OBJECT_ID('dbo.PlayerDetails', 'U') IS NOT NULL
    DROP TABLE dbo.PlayerDetails;
GO

-- �������� ������� PlayerDetails � GoClubDB2
CREATE TABLE dbo.PlayerDetails (
    player_id INT PRIMARY KEY,
    rating SMALLINT,
    region INT NOT NULL,
    club_name NVARCHAR(100)
);
GO

-- �������� ����������������� �������������

USE GoClubDB1;
GO

-- �������� ������������� PlayerView, ���� ��� ��� ����������
IF OBJECT_ID('dbo.PlayerView', 'V') IS NOT NULL
    DROP VIEW dbo.PlayerView;
GO

-- �������� ����������������� ������������� PlayerView
CREATE VIEW dbo.PlayerView
AS
SELECT 
    p1.player_id, 
    p1.last_name, 
    p1.first_name, 
    p1.middle_name, 
    p1.date_of_birth, 
    p1.country, 
    p2.rating, 
    p2.region, 
    p2.club_name
FROM dbo.PlayerInfo p1
JOIN GoClubDB2.dbo.PlayerDetails p2 ON p1.player_id = p2.player_id;
GO

-- �������� ��������� ��� �������, ���������� � ��������

-- ������� ��� �������
CREATE TRIGGER PlayerView_Insert
ON dbo.PlayerView
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON; -- �� ���������� ��������� � ���������� ���������� �����

    -- ������� � PlayerInfo
    INSERT INTO dbo.PlayerInfo (player_id, last_name, first_name, middle_name, date_of_birth, country)
    SELECT player_id, last_name, first_name, middle_name, date_of_birth, country
    FROM inserted;

    -- ������� � PlayerDetails
    INSERT INTO GoClubDB2.dbo.PlayerDetails (player_id, rating, region, club_name)
    SELECT player_id, rating, region, club_name
    FROM inserted;
END;
GO

-- ����������� ������� ��� ���������� � �������� ��������� player_id
CREATE TRIGGER PlayerView_Update
ON dbo.PlayerView
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON; -- �� ���������� ��������� � ���������� ���������� �����

    -- ��������, ���� �� ���������� ������� player_id
    IF UPDATE(player_id)
    BEGIN
        RAISERROR('���������� player_id ���������.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- ���������� ������ � PlayerInfo
    UPDATE p1
    SET 
        p1.last_name = i.last_name,
        p1.first_name = i.first_name,
        p1.middle_name = i.middle_name,
        p1.date_of_birth = i.date_of_birth,
        p1.country = i.country
    FROM dbo.PlayerInfo p1
    JOIN inserted i ON p1.player_id = i.player_id;

    -- ���������� ������ � PlayerDetails
    UPDATE p2
    SET 
        p2.rating = i.rating,
        p2.region = i.region,
        p2.club_name = i.club_name
    FROM GoClubDB2.dbo.PlayerDetails p2
    JOIN inserted i ON p2.player_id = i.player_id;
END;
GO

-- ������� ��� ��������
CREATE TRIGGER PlayerView_Delete
ON dbo.PlayerView
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON; -- �� ���������� ��������� � ���������� ���������� �����

    -- �������� �� PlayerInfo
    DELETE p1
    FROM dbo.PlayerInfo p1
    JOIN deleted d ON p1.player_id = d.player_id;

    -- �������� �� PlayerDetails
    DELETE p2
    FROM GoClubDB2.dbo.PlayerDetails p2
    JOIN deleted d ON p2.player_id = d.player_id;
END;
GO

-- ������� ������ ����� �������������

USE GoClubDB1;
GO

INSERT INTO dbo.PlayerView (player_id, last_name, first_name, middle_name, date_of_birth, country, rating, region, club_name) VALUES
(1, 'Ivanov', 'Ivan', 'Ivanovich', '1990-01-01', 'RU', 2000, 10, 'Club 1'), -- ��������� � GoClubDB1 � GoClubDB2
(20, 'Petrov', 'Petr', 'Petrovich', '1985-05-05', 'RU', 1800, 60, 'Club 2'); -- ����������
GO

-- ������� �� �������������

SELECT * FROM dbo.PlayerView;
GO

SELECT * FROM GoClubDB2.dbo.PlayerDetails;
GO

SELECT * FROM GoClubDB1.dbo.PlayerInfo;
GO

-- ���������� ����� �������������

UPDATE dbo.PlayerView
SET rating = 2200
WHERE last_name = 'Ivanov' AND player_id = 1;
GO

-- ������� �� ������������� ����� ����������

SELECT * FROM dbo.PlayerView;
GO

-- ������� ���������� player_id (������ ����������� �������)
BEGIN TRY
    UPDATE dbo.PlayerView
    SET player_id = 9999
    WHERE player_id = 1;
END TRY
BEGIN CATCH
    SELECT ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

-- �������� ����� �������������

DELETE FROM dbo.PlayerView
WHERE player_id = 1;
GO

-- �������� ������ � �������� ����� ��������

-- ������ � PlayerInfo ����� ��������
USE GoClubDB1;
GO
SELECT * FROM dbo.PlayerInfo;
GO

-- ������ � PlayerDetails ����� �������� ������
USE GoClubDB2;
GO
SELECT * FROM dbo.PlayerDetails;
GO

-- ������� (�����������)

USE GoClubDB1;
GO
IF OBJECT_ID('dbo.PlayerView', 'V') IS NOT NULL
    DROP VIEW dbo.PlayerView;
GO

USE GoClubDB1;
GO
DROP TABLE IF EXISTS dbo.PlayerInfo;
GO

USE GoClubDB2;
GO
DROP TABLE IF EXISTS dbo.PlayerDetails;
GO

-- �������� ��� ������
USE master;
GO
DROP DATABASE IF EXISTS GoClubDB1;
GO
DROP DATABASE IF EXISTS GoClubDB2;
GO
