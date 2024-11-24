CREATE TABLE ��_���� (
    club_id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(), 
    �������� NVARCHAR(100) NOT NULL,
    ����� NVARCHAR(512) NOT NULL,
    ������ TINYINT NOT NULL,
    ������� SMALLINT
);
GO

CREATE PROCEDURE dbo.GetGoClubs
    @club_cursor CURSOR VARYING OUTPUT
	--���������� �������� @club_cursor ���� CURSOR � ���������� VARYING � OUTPUT. ��� ��������, ��� ��������� ����� ���������� ������, ������� ����� ���� ����������� � ���������� ����.
AS
BEGIN
    SET @club_cursor = CURSOR FORWARD_ONLY STATIC FOR --�������������� ������ @club_cursor ��� ���������������� ����������� ������.
    SELECT club_id, ��������, �����, ������, �������
    FROM ��_����;

    OPEN @club_cursor;
END;
GO

-- �������� �������� ���������
IF OBJECT_ID('dbo.GetGoClubs', 'P') IS NOT NULL
    DROP PROCEDURE dbo.GetGoClubs;

DROP TABLE ��_����;