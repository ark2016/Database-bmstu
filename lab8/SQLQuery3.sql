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
    @club_cursor CURSOR VARYING OUTPUT -- Определяет параметр @club_cursor типа CURSOR с атрибутами VARYING и OUTPUT. Это означает, что процедура будет возвращать курсор, который может быть использован в вызывающем коде.
AS
BEGIN
    SET @club_cursor = CURSOR FORWARD_ONLY STATIC FOR --Инициализирует курсор @club_cursor как однонаправленный статический курсор.
    SELECT club_id, название, адрес, регион, рейтинг, dbo.GetRatingDescription(рейтинг) AS RatingDescription
    FROM Го_клуб;

    OPEN @club_cursor;
END;
GO

CREATE FUNCTION dbo.IsHighRating(@рейтинг SMALLINT)
RETURNS BIT
AS
BEGIN
    IF @рейтинг >= 2150
        RETURN 1;
    RETURN 0;
END;
GO

CREATE PROCEDURE dbo.ProcessGoClubs
AS
BEGIN
	--Объявляет переменные для хранения данных из курсора.
    DECLARE @club_cursor CURSOR; 
    DECLARE @club_id UNIQUEIDENTIFIER;
    DECLARE @название NVARCHAR(100);
    DECLARE @адрес NVARCHAR(512);
    DECLARE @регион TINYINT;
    DECLARE @рейтинг SMALLINT;
    DECLARE @RatingDescription NVARCHAR(50);

    EXEC dbo.GetGoClubsWithDescription @club_cursor = @club_cursor OUTPUT; --Вызывает хранимую процедуру dbo.GetGoClubsWithDescription и получает курсор в переменную @club_cursor.

    FETCH NEXT FROM @club_cursor INTO @club_id, @название, @адрес, @регион, @рейтинг, @RatingDescription; --Извлекает следующую строку из курсора в переменные.

    WHILE @@FETCH_STATUS = 0 --Цикл, который выполняется, пока есть строки в курсоре.
    BEGIN
        IF dbo.IsHighRating(@рейтинг) = 1 --Проверяет, является ли рейтинг высоким с помощью функции dbo.IsHighRating
        BEGIN --Выводит информацию о клубе, если рейтинг высокий.
            PRINT 'Клуб: ' + @название + ', Адрес: ' + @адрес + ', Рейтинг: ' + CAST(@рейтинг AS NVARCHAR(10)) + ', Описание: ' + @RatingDescription;
        END
        FETCH NEXT FROM @club_cursor INTO @club_id, @название, @адрес, @регион, @рейтинг, @RatingDescription; --Извлекает следующую строку из курсора.
    END;
	--Закрывает и освобождает курсор.
    CLOSE @club_cursor;
    DEALLOCATE @club_cursor;
END;
GO

-- Удаление хранимой процедуры
IF OBJECT_ID('dbo.ProcessGoClubs', 'P') IS NOT NULL
    DROP PROCEDURE dbo.ProcessGoClubs;

-- Удаление пользовательской функции
IF OBJECT_ID('dbo.IsHighRating', 'FN') IS NOT NULL
    DROP FUNCTION dbo.IsHighRating;

-- Удаление хранимой процедуры
IF OBJECT_ID('dbo.GetGoClubsWithDescription', 'P') IS NOT NULL
    DROP PROCEDURE dbo.GetGoClubsWithDescription;

-- Удаление пользовательской функции
IF OBJECT_ID('dbo.GetRatingDescription', 'FN') IS NOT NULL
    DROP FUNCTION dbo.GetRatingDescription;