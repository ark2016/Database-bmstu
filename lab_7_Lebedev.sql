-- Создаем таблицу Игрок
CREATE TABLE Игрок (
    player_id INT PRIMARY KEY IDENTITY(1,1), 
	--Столбец player_id является первичным ключом и автоинкрементным (значение автоматически увеличивается на 1 при каждой вставке).
    фамилия NVARCHAR(100) NOT NULL,
    имя NVARCHAR(100) NOT NULL,
    отчество NVARCHAR(100) NOT NULL,
    дата_рождения DATE NOT NULL,
    рейтинг SMALLINT,
    страна VARCHAR(2) NOT NULL DEFAULT 'RU',
    регион INT,
    название_го_клуба NVARCHAR(100)
);
GO

-- Вставляем данные в таблицу Игрок
INSERT INTO Игрок (фамилия, имя, отчество, дата_рождения, рейтинг, регион, название_го_клуба)
VALUES ('Иванов', 'Иван', 'Иванович', '2000-01-01', 2216, 1, 'Го Клуб 1');

INSERT INTO Игрок (фамилия, имя, отчество, дата_рождения, рейтинг, регион, название_го_клуба)
VALUES ('Петров', 'Петр', 'Петрович', '1999-02-02', 2712, 1, 'Го Клуб 2');
GO

-- Создаем представление на основе таблицы Игрок
CREATE VIEW Игрок_View AS
SELECT
    player_id,
    фамилия,
    имя,
    отчество,
    дата_рождения,
    рейтинг,
    страна,
    регион,
    название_го_клуба
FROM Игрок;
GO
--Создает представление Игрок_View, которое выбирает все столбцы из таблицы Игрок.

-- Выбираем данные из представления
SELECT * FROM Игрок_View;
GO

-- Удаляем таблицу и представление
DROP VIEW Игрок_View;
DROP TABLE Игрок;
GO
------------------------------------------------------------------------------------------------
-- Создаем таблицу Регион
CREATE TABLE Регион (
    регион_id INT PRIMARY KEY IDENTITY(1,1),-- Столбец регион_id является первичным ключом и автоинкрементным.
    название NVARCHAR(100) NOT NULL
);
GO

-- Создаем таблицу Игрок
CREATE TABLE Игрок (
    player_id INT PRIMARY KEY IDENTITY(1,1),--Столбец player_id является первичным ключом и автоинкрементным.
    фамилия NVARCHAR(100) NOT NULL,
    имя NVARCHAR(100) NOT NULL,
    регион_id INT,
    CONSTRAINT FK_Игрок_Регион FOREIGN KEY (регион_id) REFERENCES Регион(регион_id) 
	--Внешний ключ, который ссылается на таблицу Регион. Ограничение ссылочной целостности при удалении и обновлении.
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
);
GO

-- Вставляем данные в таблицу Регион
INSERT INTO Регион (название) VALUES ('Москва');
INSERT INTO Регион (название) VALUES ('Санкт-Петербург');
GO

-- Вставляем данные в таблицу Игрок
INSERT INTO Игрок (фамилия, имя, регион_id) VALUES ('Иванов', 'Иван', 1);
INSERT INTO Игрок (фамилия, имя, регион_id) VALUES ('Петров', 'Петр', 2);
GO

-- Создаем представление на основе полей обеих таблиц
CREATE VIEW Игрок_Регион_View AS
SELECT
    И.player_id,
    И.фамилия,
    И.имя,
    Р.название AS название_региона
FROM Игрок И
JOIN Регион Р ON И.регион_id = Р.регион_id;
GO
-- Создает представление Игрок_Регион_View, которое выбирает столбцы из таблиц Игрок и Регион и объединяет их по столбцу регион_id.



-- Выбираем данные из представления
SELECT * FROM Игрок_Регион_View;
GO

-- Удаляем таблицы и представление
DROP VIEW Игрок_Регион_View;
DROP TABLE Игрок;
DROP TABLE Регион;
GO
------------------------------------------------------------------------------------------------
-- Создаем таблицу Игрок
CREATE TABLE Игрок (
    player_id INT PRIMARY KEY IDENTITY(1,1),
    фамилия NVARCHAR(100) NOT NULL,
    имя NVARCHAR(100) NOT NULL,
    отчество NVARCHAR(100) NOT NULL,
    дата_рождения DATE NOT NULL,
    рейтинг SMALLINT,
    страна VARCHAR(2) NOT NULL DEFAULT 'RU',
    регион INT,
    название_го_клуба NVARCHAR(100)
);
GO

-- Вставляем данные в таблицу Игрок
INSERT INTO Игрок (фамилия, имя, отчество, дата_рождения, рейтинг, регион, название_го_клуба)
VALUES ('Иванов', 'Иван', 'Иванович', '2000-01-01', 2216, 1, 'Го Клуб 1');

INSERT INTO Игрок (фамилия, имя, отчество, дата_рождения, рейтинг, регион, название_го_клуба)
VALUES ('Петров', 'Петр', 'Петрович', '1999-02-02', 2712, 1, 'Го Клуб 2');
GO

-- Создаем индекс для таблицы Игрок
CREATE INDEX IDX_Игрок_Фамилия_Имя
ON Игрок (фамилия, имя);
GO

--Создает индекс IDX_Игрок_Фамилия_Имя для таблицы Игрок на столбцах фамилия и имя. 
--Индексы улучшают производительность запросов, особенно для операций поиска и сортировки

-- Выбираем данные из таблицы Игрок
SELECT * FROM Игрок;
GO

-- Удаляем таблицу и индекс
DROP INDEX IDX_Игрок_Фамилия_Имя ON Игрок;
DROP TABLE Игрок;
GO

------------------------------------------------------------------------------------------------
-- Создаем таблицу Игрок
CREATE TABLE Игрок (
    player_id INT PRIMARY KEY IDENTITY(1,1),
    фамилия NVARCHAR(100) NOT NULL,
    имя NVARCHAR(100) NOT NULL,
    отчество NVARCHAR(100) NOT NULL,
    дата_рождения DATE NOT NULL,
    рейтинг SMALLINT,
    страна VARCHAR(2) NOT NULL DEFAULT 'RU',
    регион INT,
    название_го_клуба NVARCHAR(100)
);
GO

-- Вставляем данные в таблицу Игрок
INSERT INTO Игрок (фамилия, имя, отчество, дата_рождения, рейтинг, регион, название_го_клуба)
VALUES ('Иванов', 'Иван', 'Иванович', '2000-01-01', 2216, 1, 'Го Клуб 1');

INSERT INTO Игрок (фамилия, имя, отчество, дата_рождения, рейтинг, регион, название_го_клуба)
VALUES ('Петров', 'Петр', 'Петрович', '1999-02-02', 2712, 1, 'Го Клуб 2');
GO

-- Создаем индексированное представление
CREATE VIEW Игрок_Индексированное_View
WITH SCHEMABINDING
AS
SELECT
    player_id,
    фамилия,
    имя,
    отчество,
    дата_рождения,
    рейтинг,
    страна,
    регион,
    название_го_клуба
FROM dbo.Игрок;
GO

-- Создает индексированное представление Игрок_Индексированное_View, 
-- которое выбирает все столбцы из таблицы Игрок. Опция WITH SCHEMABINDING указывает, 
-- что представление связано с базовыми таблицами, и изменения в базовых таблицах могут 
-- потребовать пересоздания представления.

-- Создаем уникальный кластеризованный индекс для представления
CREATE UNIQUE CLUSTERED INDEX IDX_Игрок_Индексированное_View
ON Игрок_Индексированное_View (player_id);
GO

-- Создает уникальный кластеризованный индекс IDX_Игрок_Индексированное_View 
-- для представления Игрок_Индексированное_View на столбце player_id. Кластеризованный 
-- индекс указывает, что данные в представлении будут физически упорядочены по столбцу player_id.

-- Выбираем данные из индексированного представления
SELECT * FROM Игрок_Индексированное_View;
GO

-- Удаляем индексированное представление и таблицу
DROP VIEW Игрок_Индексированное_View;
DROP TABLE Игрок;
GO
