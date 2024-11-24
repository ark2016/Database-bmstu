CREATE TABLE √о_клуб (
    club_id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(), 
    название NVARCHAR(100) NOT NULL,
    адрес NVARCHAR(512) NOT NULL,
    регион TINYINT NOT NULL,
    рейтинг SMALLINT
);
GO

CREATE PROCEDURE dbo.GetGoClubs
    @club_cursor CURSOR VARYING OUTPUT
	--ќпредел€ет параметр @club_cursor типа CURSOR с атрибутами VARYING и OUTPUT. Ёто означает, что процедура будет возвращать курсор, который может быть использован в вызывающем коде.
AS
BEGIN
    SET @club_cursor = CURSOR FORWARD_ONLY STATIC FOR --»нициализирует курсор @club_cursor как однонаправленный статический курсор.
    SELECT club_id, название, адрес, регион, рейтинг
    FROM √о_клуб;

    OPEN @club_cursor;
END;
GO

-- ”даление хранимой процедуры
IF OBJECT_ID('dbo.GetGoClubs', 'P') IS NOT NULL
    DROP PROCEDURE dbo.GetGoClubs;

DROP TABLE √о_клуб;