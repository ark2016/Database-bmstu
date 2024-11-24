CREATE FUNCTION dbo.GetRatingDescription(@рейтинг SMALLINT)
RETURNS NVARCHAR(50)
AS
BEGIN
    DECLARE @description NVARCHAR(50); --Объявляет переменную @description типа NVARCHAR с максимальной длиной 50 символов.
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

-- Удаление хранимой процедуры
IF OBJECT_ID('dbo.GetGoClubsWithDescription', 'P') IS NOT NULL
    DROP PROCEDURE dbo.GetGoClubsWithDescription;

-- Удаление пользовательской функции
IF OBJECT_ID('dbo.GetRatingDescription', 'FN') IS NOT NULL
    DROP FUNCTION dbo.GetRatingDescription;