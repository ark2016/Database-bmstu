-- �������� ����� ���� ������
CREATE DATABASE SportsDB;
GO

-- ������������� ����� ���� ������
USE SportsDB;
GO

-- � ������ ������ ��������������� ����� ��� ������������� �� ����� => ����� 1 � 1

-- �������� ������ �������
CREATE TABLE Player (
    player_id INT PRIMARY KEY IDENTITY(1,1),
    last_name NVARCHAR(100) NOT NULL,
    first_name NVARCHAR(100) NOT NULL,
    middle_name NVARCHAR(100) NOT NULL,
    birth_date DATE NOT NULL,
    rating SMALLINT,
    country VARCHAR(2) NOT NULL DEFAULT 'RU',
    region INT
);
GO

-- �������� ������ ������� � ���������� 1 � 1
CREATE TABLE Club (
    player_id INT PRIMARY KEY,
    club_name NVARCHAR(100) NOT NULL,
    FOREIGN KEY (player_id) REFERENCES Player(player_id)
);
GO

-- ���������� ������� Player ��������� ������
INSERT INTO Player (last_name, first_name, middle_name, birth_date, rating, country, region)
VALUES
    ('Smith', 'John', 'A.', '1990-01-01', 85, 'US', 1),
    ('Doe', 'Jane', 'B.', '1992-02-02', 90, 'CA', 2),
    ('Brown', 'Charlie', 'C.', '1985-03-03', 80, 'UK', 3);
GO

-- ���������� ������� Club ��������� ������
INSERT INTO Club (player_id, club_name)
VALUES
    (1, 'Club A'),
    (2, 'Club B'),
    (3, 'Club C'); -- ����� ����������� ����� ��� �������
GO

-- ������������ ������ � ������� Player
SELECT * FROM Player;
GO

-- ������������ ������ � ������� Club
SELECT * FROM Club;
GO

-- �������� ��������� ��� ������� Player
CREATE TRIGGER trg_Player_Insert
ON Player
AFTER INSERT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM inserted WHERE rating < 0)
    BEGIN
        RAISERROR ('������� �� ����� ���� �������������', 16, 1);
        ROLLBACK TRANSACTION;
    END
    IF EXISTS (SELECT 1 FROM inserted WHERE birth_date > DATEADD(YEAR, -3, GETDATE()))
    BEGIN
        RAISERROR ('����� ������ ���� ������ 3 ���', 16, 1);
        ROLLBACK TRANSACTION;
    END
    IF EXISTS (SELECT 1 FROM inserted WHERE region < 0)
    BEGIN
        RAISERROR ('����� ������� �� ����� ���� �������������', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO

CREATE TRIGGER trg_Player_Update
ON Player
AFTER UPDATE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM inserted WHERE rating < 0)
    BEGIN
        RAISERROR ('������� �� ����� ���� �������������', 16, 1);
        ROLLBACK TRANSACTION;
    END
    IF EXISTS (SELECT 1 FROM inserted WHERE birth_date > DATEADD(YEAR, -3, GETDATE()))
    BEGIN
        RAISERROR ('����� ������ ���� ������ 3 ���', 16, 1);
        ROLLBACK TRANSACTION;
    END
    IF EXISTS (SELECT 1 FROM inserted WHERE region < 0)
    BEGIN
        RAISERROR ('����� ������� �� ����� ���� �������������', 16, 1);
        ROLLBACK TRANSACTION;
    END
    IF UPDATE(player_id)
    BEGIN
        RAISERROR ('��������� ���������� ����� ���������', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO

CREATE TRIGGER trg_Player_Delete
ON Player
AFTER DELETE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM deleted WHERE player_id IN (SELECT player_id FROM Club))
    BEGIN
        RAISERROR ('������ ������� ������ � ��������� ������', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO

-- �������� ��������� ��� ������� Club
CREATE TRIGGER trg_Club_Insert
ON Club
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM inserted WHERE club_name IS NULL)
    BEGIN
        RAISERROR ('�������� ����� �� ����� ���� ������', 16, 1);
        ROLLBACK TRANSACTION;
    END
    ELSE
    BEGIN
        INSERT INTO Club (player_id, club_name)
        SELECT player_id, club_name
        FROM inserted;
    END
END;
GO

CREATE TRIGGER trg_Club_Update
ON Club
INSTEAD OF UPDATE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM inserted WHERE club_name IS NULL)
    BEGIN
        RAISERROR ('�������� ����� �� ����� ���� ������', 16, 1);
        ROLLBACK TRANSACTION;
    END
    IF UPDATE(player_id)
    BEGIN
        RAISERROR ('��������� ���������� ����� ���������', 16, 1);
        ROLLBACK TRANSACTION;
    END
    ELSE
    BEGIN
        UPDATE Club
        SET club_name = inserted.club_name
        FROM inserted
        WHERE Club.player_id = inserted.player_id;
    END
END;
GO

CREATE TRIGGER trg_Club_Delete
ON Club
INSTEAD OF DELETE
AS
BEGIN
    DELETE FROM Club
    WHERE player_id IN (SELECT player_id FROM deleted);
END;
GO

-- �������� ������������� ��� ������ Player � Club
CREATE VIEW PlayerClubView AS
SELECT
    p.player_id,
    p.last_name,
    p.first_name,
    p.middle_name,
    p.birth_date,
    p.rating,
    p.country,
    p.region,
    c.club_name
FROM
    Player p
JOIN
    Club c ON p.player_id = c.player_id;
GO

-- ������������ ������ � ������������� PlayerClubView
SELECT * FROM PlayerClubView;
GO

-- �������� ��������� ��� �������������
--CREATE TRIGGER trg_PlayerClubView_Insert
--ON PlayerClubView
--INSTEAD OF INSERT
--AS
--BEGIN
--    -- ������� � Player
--    INSERT INTO Player (last_name, first_name, middle_name, birth_date, rating, country, region)
--    SELECT last_name, first_name, middle_name, birth_date, rating, country, region
--    FROM inserted;
--	--player_id �������� �� ���� IDENTITY

--    -- ��������� player_id
--    DECLARE @player_id INT;
--    SET @player_id = SCOPE_IDENTITY();

--    -- ������� � Club
--    INSERT INTO Club (player_id, club_name)
--    SELECT @player_id, club_name
--    FROM inserted;
--END;
--GO

CREATE TRIGGER trg_PlayerClubView_Insert
ON PlayerClubView
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @last_name NVARCHAR(100),
            @first_name NVARCHAR(100),
            @middle_name NVARCHAR(100),
            @birth_date DATE,
            @rating SMALLINT,
            @country VARCHAR(2),
            @region INT,
            @club_name NVARCHAR(100);

    DECLARE @cursor CURSOR;
    SET @cursor = CURSOR FOR SELECT last_name, first_name, middle_name, birth_date, rating, country, region, club_name FROM inserted;
    OPEN @cursor;

    FETCH NEXT FROM @cursor INTO @last_name, @first_name, @middle_name, @birth_date, @rating, @country, @region, @club_name;
    WHILE (@@FETCH_STATUS = 0)
    BEGIN
        -- ������� � Player
        INSERT INTO Player (last_name, first_name, middle_name, birth_date, rating, country, region)
        VALUES (@last_name, @first_name, @middle_name, @birth_date, @rating, @country, @region);

        -- ��������� player_id
        DECLARE @player_id INT;
        SET @player_id = SCOPE_IDENTITY();

        -- ������� � Club
        INSERT INTO Club (player_id, club_name)
        VALUES (@player_id, @club_name);

        FETCH NEXT FROM @cursor INTO @last_name, @first_name, @middle_name, @birth_date, @rating, @country, @region, @club_name;
    END

    CLOSE @cursor;
    DEALLOCATE @cursor;
END;
GO


CREATE TRIGGER trg_PlayerClubView_Update
ON PlayerClubView
INSTEAD OF UPDATE
AS
BEGIN
    IF UPDATE(player_id)
    BEGIN
        RAISERROR ('��������� ���������� ����� ���������', 16, 1);
        ROLLBACK TRANSACTION;
    END
	ELSE
    WITH UpdatedPlayer AS (
        SELECT
            i.player_id,
            i.last_name,
            i.first_name,
            i.middle_name,
            i.birth_date,
            i.rating,
            i.country,
            i.region
        FROM
            inserted i --��������� �������, ���������� ����� �������� ������� ����� ����������.
        JOIN --
            deleted d ON i.player_id = d.player_id  --��������� �������, ���������� ������ �������� ������� �� ����������.
    ) -- ������� ��������� �������
    MERGE INTO Player AS target --������� ������� (Player)
    USING UpdatedPlayer AS source --��������� ������� (UpdatedPlayer)
    ON target.player_id = source.player_id --������� ����������, ������� ����������, ����� ������ ����� ���������.
    WHEN MATCHED THEN
        UPDATE SET
            target.last_name = source.last_name,
            target.first_name = source.first_name,
            target.middle_name = source.middle_name,
            target.birth_date = source.birth_date,
            target.rating = source.rating,
            target.country = source.country,
            target.region = source.region;

    WITH UpdatedClub AS (
        SELECT
            i.player_id,
            i.club_name
        FROM
            inserted i
        JOIN
            deleted d ON i.player_id = d.player_id
    )
    MERGE INTO Club AS target
    USING UpdatedClub AS source
    ON target.player_id = source.player_id
    WHEN MATCHED THEN
        UPDATE SET
            target.club_name = source.club_name;
END;
GO

CREATE TRIGGER trg_PlayerClubView_Delete
ON PlayerClubView
INSTEAD OF DELETE
AS
BEGIN
    DELETE FROM Club
    WHERE player_id IN (SELECT player_id FROM deleted);

    DELETE FROM Player
    WHERE player_id IN (SELECT player_id FROM deleted);
END;
GO

UPDATE PlayerClubView
SET last_name = 'Oleg'
WHERE player_id = 1;
GO

--UPDATE PlayerClubView
--SET player_id = 10
--WHERE player_id = 1;
--GO

INSERT INTO PlayerClubView (last_name, first_name, middle_name, birth_date, rating, country, region, club_name)
VALUES
    ('Smith', 'John', 'A.', '1990-01-01', 85, 'US', 1,'Club A'),
    ('Doe', 'Jane', 'B.', '1992-02-02', 90, 'CA', 2, 'Club B');
GO

---- ���������� ������� Club ��������� ������
--INSERT INTO Club (player_id, club_name)
--VALUES
--    (1, 'Club A'),
--    (2, 'Club B'),
--    (3, 'Club C'); -- ����� ����������� ����� ��� �������
--GO


SELECT * FROM PlayerClubView;
GO

-- �������� ���� ��������� ��������� (��, ������ � �.�.)
USE master;
GO

-- ��������, ��� ���� ������ �� ������������
ALTER DATABASE SportsDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO

DROP DATABASE SportsDB;
GO
