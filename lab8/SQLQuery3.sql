CREATE FUNCTION dbo.GetRatingDescription(@������� SMALLINT)
RETURNS NVARCHAR(50)
AS
BEGIN
    DECLARE @description NVARCHAR(50); --��������� ���������� @description ���� NVARCHAR � ������������ ������ 50 ��������.
    IF @������� >= 2000
        SET @description = '��������';
    ELSE IF @������� >= 1500
        SET @description = '�������';
    ELSE IF @������� >= 1000
        SET @description = '�������';
    ELSE
        SET @description = '������';

    RETURN @description;
END;
GO

CREATE PROCEDURE dbo.GetGoClubsWithDescription
    @club_cursor CURSOR VARYING OUTPUT -- ���������� �������� @club_cursor ���� CURSOR � ���������� VARYING � OUTPUT. ��� ��������, ��� ��������� ����� ���������� ������, ������� ����� ���� ����������� � ���������� ����.
AS
BEGIN
    SET @club_cursor = CURSOR FORWARD_ONLY STATIC FOR --�������������� ������ @club_cursor ��� ���������������� ����������� ������.
    SELECT club_id, ��������, �����, ������, �������, dbo.GetRatingDescription(�������) AS RatingDescription
    FROM ��_����;

    OPEN @club_cursor;
END;
GO

CREATE FUNCTION dbo.IsHighRating(@������� SMALLINT)
RETURNS BIT
AS
BEGIN
    IF @������� >= 2150
        RETURN 1;
    RETURN 0;
END;
GO

CREATE PROCEDURE dbo.ProcessGoClubs
AS
BEGIN
	--��������� ���������� ��� �������� ������ �� �������.
    DECLARE @club_cursor CURSOR; 
    DECLARE @club_id UNIQUEIDENTIFIER;
    DECLARE @�������� NVARCHAR(100);
    DECLARE @����� NVARCHAR(512);
    DECLARE @������ TINYINT;
    DECLARE @������� SMALLINT;
    DECLARE @RatingDescription NVARCHAR(50);

    EXEC dbo.GetGoClubsWithDescription @club_cursor = @club_cursor OUTPUT; --�������� �������� ��������� dbo.GetGoClubsWithDescription � �������� ������ � ���������� @club_cursor.

    FETCH NEXT FROM @club_cursor INTO @club_id, @��������, @�����, @������, @�������, @RatingDescription; --��������� ��������� ������ �� ������� � ����������.

    WHILE @@FETCH_STATUS = 0 --����, ������� �����������, ���� ���� ������ � �������.
    BEGIN
        IF dbo.IsHighRating(@�������) = 1 --���������, �������� �� ������� ������� � ������� ������� dbo.IsHighRating
        BEGIN --������� ���������� � �����, ���� ������� �������.
            PRINT '����: ' + @�������� + ', �����: ' + @����� + ', �������: ' + CAST(@������� AS NVARCHAR(10)) + ', ��������: ' + @RatingDescription;
        END
        FETCH NEXT FROM @club_cursor INTO @club_id, @��������, @�����, @������, @�������, @RatingDescription; --��������� ��������� ������ �� �������.
    END;
	--��������� � ����������� ������.
    CLOSE @club_cursor;
    DEALLOCATE @club_cursor;
END;
GO

-- �������� �������� ���������
IF OBJECT_ID('dbo.ProcessGoClubs', 'P') IS NOT NULL
    DROP PROCEDURE dbo.ProcessGoClubs;

-- �������� ���������������� �������
IF OBJECT_ID('dbo.IsHighRating', 'FN') IS NOT NULL
    DROP FUNCTION dbo.IsHighRating;

-- �������� �������� ���������
IF OBJECT_ID('dbo.GetGoClubsWithDescription', 'P') IS NOT NULL
    DROP PROCEDURE dbo.GetGoClubsWithDescription;

-- �������� ���������������� �������
IF OBJECT_ID('dbo.GetRatingDescription', 'FN') IS NOT NULL
    DROP FUNCTION dbo.GetRatingDescription;