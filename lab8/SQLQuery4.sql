CREATE TABLE Го_клуб (
    club_id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(), 
    название NVARCHAR(100) NOT NULL,
    адрес NVARCHAR(512) NOT NULL,
    регион TINYINT NOT NULL,
    рейтинг SMALLINT
);
GO

CREATE FUNCTION dbo.GetRatingDescription(@рейтинг SMALLINT)
RETURNS NVARCHAR(50)
AS
BEGIN
    DECLARE @description NVARCHAR(50);
    IF @рейтинг >= 2000
        SET @description = 'Отличный';
    ELSE IF @рейтинг >= 1500
        SET @description = 'Хороший';
    ELSE IF @рейтинг >= 1000
        SET @description = 'Средний';
    ELSE
        SET @description = 'Низкий';

    RETURN @description;
END;
GO

CREATE PROCEDURE dbo.GetGoClubsWithDescription
    @club_cursor CURSOR VARYING OUTPUT --Определяет параметр @club_cursor типа CURSOR с атрибутами VARYING и OUTPUT. Это означает, что процедура будет возвращать курсор, который может быть использован в вызывающем коде.
AS
BEGIN
    SET @club_cursor = CURSOR FORWARD_ONLY STATIC FOR --Инициализирует курсор @club_cursor как однонаправленный статический курсор.
    SELECT club_id, название, адрес, регион, рейтинг, dbo.GetRatingDescription(рейтинг) AS RatingDescription
    FROM Го_клуб;

    OPEN @club_cursor;
END;
GO


CREATE PROCEDURE dbo.GetGoClubsFromTableFunction
    @club_cursor CURSOR VARYING OUTPUT --Определяет параметр @club_cursor типа CURSOR с атрибутами VARYING и OUTPUT. Это означает, что процедура будет возвращать курсор, который может быть использован в вызывающем коде.
AS
BEGIN
    SET @club_cursor = CURSOR FORWARD_ONLY STATIC FOR --Инициализирует курсор @club_cursor как однонаправленный статический курсор.
    SELECT club_id, название, адрес, регион, рейтинг, RatingDescription
    FROM dbo.GetGoClubsWithDescription();

    OPEN @club_cursor;
END;
GO

-- Удаление хранимой процедуры
IF OBJECT_ID('dbo.GetGoClubsFromTableFunction', 'P') IS NOT NULL
    DROP PROCEDURE dbo.GetGoClubsFromTableFunction;


-- Удаление табличной функции
IF OBJECT_ID('dbo.GetGoClubsWithDescription', 'FN') IS NOT NULL
    DROP FUNCTION dbo.GetGoClubsWithDescription;


-- Удаление пользовательской функции
IF OBJECT_ID('dbo.GetRatingDescription', 'FN') IS NOT NULL
    DROP FUNCTION dbo.GetRatingDescription;

DROP TABLE Го_клуб;