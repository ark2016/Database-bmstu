CREATE TABLE ��_���� (
    club_id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(), 
    �������� NVARCHAR(100) NOT NULL,
    ����� NVARCHAR(512) NOT NULL,
    ������ TINYINT NOT NULL,
    ������� SMALLINT
);
GO

CREATE FUNCTION dbo.GetRatingDescription(@������� SMALLINT)
RETURNS NVARCHAR(50)
AS
BEGIN
    DECLARE @description NVARCHAR(50);
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
    @club_cursor CURSOR VARYING OUTPUT --���������� �������� @club_cursor ���� CURSOR � ���������� VARYING � OUTPUT. ��� ��������, ��� ��������� ����� ���������� ������, ������� ����� ���� ����������� � ���������� ����.
AS
BEGIN
    SET @club_cursor = CURSOR FORWARD_ONLY STATIC FOR --�������������� ������ @club_cursor ��� ���������������� ����������� ������.
    SELECT club_id, ��������, �����, ������, �������, dbo.GetRatingDescription(�������) AS RatingDescription
    FROM ��_����;

    OPEN @club_cursor;
END;
GO


CREATE PROCEDURE dbo.GetGoClubsFromTableFunction
    @club_cursor CURSOR VARYING OUTPUT --���������� �������� @club_cursor ���� CURSOR � ���������� VARYING � OUTPUT. ��� ��������, ��� ��������� ����� ���������� ������, ������� ����� ���� ����������� � ���������� ����.
AS
BEGIN
    SET @club_cursor = CURSOR FORWARD_ONLY STATIC FOR --�������������� ������ @club_cursor ��� ���������������� ����������� ������.
    SELECT club_id, ��������, �����, ������, �������, RatingDescription
    FROM dbo.GetGoClubsWithDescription();

    OPEN @club_cursor;
END;
GO

-- �������� �������� ���������
IF OBJECT_ID('dbo.GetGoClubsFromTableFunction', 'P') IS NOT NULL
    DROP PROCEDURE dbo.GetGoClubsFromTableFunction;


-- �������� ��������� �������
IF OBJECT_ID('dbo.GetGoClubsWithDescription', 'FN') IS NOT NULL
    DROP FUNCTION dbo.GetGoClubsWithDescription;


-- �������� ���������������� �������
IF OBJECT_ID('dbo.GetRatingDescription', 'FN') IS NOT NULL
    DROP FUNCTION dbo.GetRatingDescription;

DROP TABLE ��_����;