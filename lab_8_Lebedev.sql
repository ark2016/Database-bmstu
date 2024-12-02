-- Шаг 1: Создание базы данных и таблицы

-- Создание базы данных
CREATE DATABASE GoClubDB;
GO

-- Переключение контекста на новую базу данных
USE GoClubDB;
GO

-- Создание таблицы Го_клуб
CREATE TABLE Го_клуб (
    club_id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    название NVARCHAR(100) NOT NULL,
    адрес NVARCHAR(512) NOT NULL,
    регион TINYINT NOT NULL,
    рейтинг SMALLINT
);
GO

-- Заполнение таблицы данными
INSERT INTO Го_клуб (название, адрес, регион, рейтинг)
VALUES
    ('Клуб А', 'Адрес А', 1, 2200),
    ('Клуб Б', 'Адрес Б', 2, 1800),
    ('Клуб В', 'Адрес В', 3, 1200),
    ('Клуб Г', 'Адрес Г', 4, 2350);
GO

-- Проверка данных в таблице
-- SELECT * FROM Го_клуб;
-- GO

-- Создание хранимой процедуры, возвращающей курсор

CREATE PROCEDURE dbo.GetClubsCursor
    @ClubCursor CURSOR VARYING OUTPUT --Определяет параметр @club_cursor типа CURSOR с атрибутами VARYING и OUTPUT. Это означает, что процедура будет возвращать курсор, который может быть использован в вызывающем коде.
AS
BEGIN
    SET @ClubCursor = CURSOR FORWARD_ONLY STATIC FOR --Инициализирует курсор @club_cursor как однонаправленный статический курсор.
    SELECT название, адрес, регион, рейтинг FROM Го_клуб;
    OPEN @ClubCursor;
END;
GO

-- Модификация хранимой процедуры с использованием пользовательской функции

-- Создание пользовательской функции для формирования столбца
CREATE FUNCTION dbo.GetRatingCategory (@рейтинг SMALLINT)
RETURNS NVARCHAR(50)
AS
BEGIN
    DECLARE @Category NVARCHAR(50);
    IF @рейтинг >= 2000
        SET @Category = 'Высокий';
    ELSE IF @рейтинг >= 1500
        SET @Category = 'Средний';
    ELSE
        SET @Category = 'Низкий';
    RETURN @Category;
END; 
GO

-- Модификация хранимой процедуры с использованием пользовательской функции
CREATE PROCEDURE dbo.GetClubsCursorWithCategory
    @ClubCursor CURSOR VARYING OUTPUT
AS
BEGIN
    SET @ClubCursor = CURSOR FORWARD_ONLY STATIC FOR
    SELECT название, адрес, регион, рейтинг, dbo.GetRatingCategory(рейтинг) AS RatingCategory FROM Го_клуб;
	OPEN @ClubCursor;
	--fetch next
END;
GO

-- Создание хранимой процедуры для прокрутки курсора и вывода сообщений

-- Создание пользовательской функции для проверки условия
CREATE FUNCTION dbo.CheckRating (@рейтинг SMALLINT)
RETURNS BIT
AS
BEGIN
    RETURN CASE WHEN @рейтинг >= 1500 THEN 1 ELSE 0 END;
END;
GO

-- Создание хранимой процедуры для прокрутки курсора и вывода сообщений
CREATE PROCEDURE dbo.ProcessClubsCursor
AS
BEGIN
    DECLARE @ClubCursor CURSOR;
    DECLARE @название NVARCHAR(100), @адрес NVARCHAR(512), @регион TINYINT, @рейтинг SMALLINT, @RatingCategory NVARCHAR(50);

    -- Вызов процедуры для получения курсора
    EXEC dbo.GetClubsCursorWithCategory @ClubCursor = @ClubCursor OUTPUT;

    -- Открытие курсора
    --OPEN @ClubCursor;

    -- Прокрутка курсора и вывод сообщений
    FETCH NEXT FROM @ClubCursor INTO @название, @адрес, @регион, @рейтинг, @RatingCategory;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF dbo.CheckRating(@рейтинг) = 1
            PRINT 'Клуб: ' + @название + ', Адрес: ' + @адрес + ', Категория: ' + @RatingCategory;
        FETCH NEXT FROM @ClubCursor INTO @название, @адрес, @регион, @рейтинг, @RatingCategory;
    END;

    -- Закрытие и удаление курсора
    CLOSE @ClubCursor;
    DEALLOCATE @ClubCursor;
END;
GO

-- Модификация хранимой процедуры с использованием табличной функции

-- Создание табличной функции
CREATE FUNCTION dbo.GetClubsTableFunction ()
RETURNS TABLE
AS
RETURN
(
    SELECT название, адрес, регион, рейтинг, dbo.GetRatingCategory(рейтинг) AS RatingCategory FROM Го_клуб
);
GO

-- Модификация хранимой процедуры с использованием табличной функции
CREATE PROCEDURE dbo.GetClubsCursorWithTableFunction
    @ClubCursor CURSOR VARYING OUTPUT
AS
BEGIN
    SET @ClubCursor = CURSOR FORWARD_ONLY STATIC FOR
    SELECT * FROM dbo.GetClubsTableFunction();
    OPEN @ClubCursor;
END;
GO

-- Создание новой табличной функции, возвращающей таблицу
CREATE FUNCTION dbo.GetClubsWithRatingCategory ()
RETURNS @ResultTable TABLE
(
    club_id UNIQUEIDENTIFIER,
    название NVARCHAR(100),
    адрес NVARCHAR(512),
    регион TINYINT,
    рейтинг SMALLINT,
    RatingCategory NVARCHAR(50)
)
AS
BEGIN
    INSERT INTO @ResultTable
    SELECT
        club_id,
        название,
        адрес,
        регион,
        рейтинг,
        dbo.GetRatingCategory(рейтинг) AS RatingCategory
    FROM Го_клуб;
    RETURN;
END;
GO
 --SELECT * from Го_клуб;
-- Выполнение хранимых процедур

-- Выполнение хранимой процедуры для прокрутки курсора и вывода сообщений
EXEC dbo.ProcessClubsCursor;
GO

--	Удаление всех созданных элементов

-- Удаление хранимых процедур, если они существуют
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

-- Удаление пользовательских функций, если они существуют
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

-- Удаление таблицы
DROP TABLE Го_клуб;
GO

-- Удаление базы данных
USE master;
GO
DROP DATABASE GoClubDB;
GO
