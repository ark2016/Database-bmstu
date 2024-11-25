-- ��� 1: �������� ���� ������ � �������

-- �������� ���� ������
CREATE DATABASE GoClubDB;
GO

-- ������������ ��������� �� ����� ���� ������
USE GoClubDB;
GO

-- �������� ������� ��_����
CREATE TABLE ��_���� (
    club_id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    �������� NVARCHAR(100) NOT NULL,
    ����� NVARCHAR(512) NOT NULL,
    ������ TINYINT NOT NULL,
    ������� SMALLINT
);
GO

-- ���������� ������� �������
INSERT INTO ��_���� (��������, �����, ������, �������)
VALUES
    ('���� �', '����� �', 1, 2200),
    ('���� �', '����� �', 2, 1800),
    ('���� �', '����� �', 3, 1200),
    ('���� �', '����� �', 4, 2350);
GO

-- �������� ������ � �������
-- SELECT * FROM ��_����;
-- GO

-- �������� �������� ���������, ������������ ������

CREATE PROCEDURE dbo.GetClubsCursor
    @ClubCursor CURSOR VARYING OUTPUT --���������� �������� @club_cursor ���� CURSOR � ���������� VARYING � OUTPUT. ��� ��������, ��� ��������� ����� ���������� ������, ������� ����� ���� ����������� � ���������� ����.
AS
BEGIN
    SET @ClubCursor = CURSOR FORWARD_ONLY STATIC FOR --�������������� ������ @club_cursor ��� ���������������� ����������� ������.
    SELECT ��������, �����, ������, ������� FROM ��_����;
    OPEN @ClubCursor;
END;
GO

-- ����������� �������� ��������� � �������������� ���������������� �������

-- �������� ���������������� ������� ��� ������������ �������
CREATE FUNCTION dbo.GetRatingCategory (@������� SMALLINT)
RETURNS NVARCHAR(50)
AS
BEGIN
    DECLARE @Category NVARCHAR(50);
    IF @������� >= 2000
        SET @Category = '�������';
    ELSE IF @������� >= 1500
        SET @Category = '�������';
    ELSE
        SET @Category = '������';
    RETURN @Category;
END; 
GO

-- ����������� �������� ��������� � �������������� ���������������� �������
CREATE PROCEDURE dbo.GetClubsCursorWithCategory
    @ClubCursor CURSOR VARYING OUTPUT
AS
BEGIN
    SET @ClubCursor = CURSOR FORWARD_ONLY STATIC FOR
    SELECT ��������, �����, ������, �������, dbo.GetRatingCategory(�������) AS RatingCategory FROM ��_����;
	OPEN @ClubCursor;
	--fetch next
END;
GO

-- �������� �������� ��������� ��� ��������� ������� � ������ ���������

-- �������� ���������������� ������� ��� �������� �������
CREATE FUNCTION dbo.CheckRating (@������� SMALLINT)
RETURNS BIT
AS
BEGIN
    RETURN CASE WHEN @������� >= 1500 THEN 1 ELSE 0 END;
END;
GO

-- �������� �������� ��������� ��� ��������� ������� � ������ ���������
CREATE PROCEDURE dbo.ProcessClubsCursor
AS
BEGIN
    DECLARE @ClubCursor CURSOR;
    DECLARE @�������� NVARCHAR(100), @����� NVARCHAR(512), @������ TINYINT, @������� SMALLINT, @RatingCategory NVARCHAR(50);

    -- ����� ��������� ��� ��������� �������
    EXEC dbo.GetClubsCursorWithCategory @ClubCursor = @ClubCursor OUTPUT;

    -- �������� �������
    --OPEN @ClubCursor;

    -- ��������� ������� � ����� ���������
    FETCH NEXT FROM @ClubCursor INTO @��������, @�����, @������, @�������, @RatingCategory;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF dbo.CheckRating(@�������) = 1
            PRINT '����: ' + @�������� + ', �����: ' + @����� + ', ���������: ' + @RatingCategory;
        FETCH NEXT FROM @ClubCursor INTO @��������, @�����, @������, @�������, @RatingCategory;
    END;

    -- �������� � �������� �������
    CLOSE @ClubCursor;
    DEALLOCATE @ClubCursor;
END;
GO

-- ����������� �������� ��������� � �������������� ��������� �������

-- �������� ��������� �������
CREATE FUNCTION dbo.GetClubsTableFunction ()
RETURNS TABLE
AS
RETURN
(
    SELECT ��������, �����, ������, �������, dbo.GetRatingCategory(�������) AS RatingCategory FROM ��_����
);
GO

-- ����������� �������� ��������� � �������������� ��������� �������
CREATE PROCEDURE dbo.GetClubsCursorWithTableFunction
    @ClubCursor CURSOR VARYING OUTPUT
AS
BEGIN
    SET @ClubCursor = CURSOR FORWARD_ONLY STATIC FOR
    SELECT * FROM dbo.GetClubsTableFunction();
    OPEN @ClubCursor;
END;
GO

-- �������� ����� ��������� �������, ������������ �������
CREATE FUNCTION dbo.GetClubsWithRatingCategory ()
RETURNS @ResultTable TABLE
(
    club_id UNIQUEIDENTIFIER,
    �������� NVARCHAR(100),
    ����� NVARCHAR(512),
    ������ TINYINT,
    ������� SMALLINT,
    RatingCategory NVARCHAR(50)
)
AS
BEGIN
    INSERT INTO @ResultTable
    SELECT
        club_id,
        ��������,
        �����,
        ������,
        �������,
        dbo.GetRatingCategory(�������) AS RatingCategory
    FROM ��_����;
    RETURN;
END;
GO
 --SELECT * from ��_����;
-- ���������� �������� ��������

-- ���������� �������� ��������� ��� ��������� ������� � ������ ���������
EXEC dbo.ProcessClubsCursor;
GO

--	�������� ���� ��������� ���������

-- �������� �������� ��������, ���� ��� ����������
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'GetClubsCursor')
    DROP PROCEDURE dbo.GetClubsCursor;
GO

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'GetClubsCursorWithCategory')
    DROP PROCEDURE dbo.GetClubsCursorWithCategory;
GO

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'ProcessClubsCursor')
    DROP PROCEDURE dbo.ProcessClubsCursor;
GO

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'GetClubsCursorWithTableFunction')
    DROP PROCEDURE dbo.GetClubsCursorWithTableFunction;
GO

-- �������� ���������������� �������, ���� ��� ����������
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.GetRatingCategory') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
    DROP FUNCTION dbo.GetRatingCategory;
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.CheckRating') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
    DROP FUNCTION dbo.CheckRating;
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.GetClubsTableFunction') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
    DROP FUNCTION dbo.GetClubsTableFunction;
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.GetClubsWithRatingCategory') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
    DROP FUNCTION dbo.GetClubsWithRatingCategory;
GO

-- �������� �������
DROP TABLE ��_����;
GO

-- �������� ���� ������
USE master;
GO
DROP DATABASE GoClubDB;
GO
