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

-- Триггер на вставку
CREATE TRIGGER trg_Insert_Игрок
ON Игрок
AFTER INSERT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM inserted WHERE фамилия = 'Иванов')
    BEGIN
        RAISERROR ('Вставка игрока с фамилией "Иванов" запрещена.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO

-- Триггер на удаление
CREATE TRIGGER trg_Delete_Игрок
ON Игрок
AFTER DELETE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM deleted WHERE player_id = 1)
    BEGIN
        RAISERROR ('Удаление игрока с ID 1 запрещено.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO

-- Триггер на обновление
CREATE TRIGGER trg_Update_Игрок
ON Игрок
AFTER UPDATE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM inserted WHERE фамилия = 'Петров' AND имя = 'Петр')
    BEGIN
        RAISERROR ('Обновление игрока с фамилией "Петров" и именем "Петр" запрещено.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO

-- Удаление триггера на вставку
DROP TRIGGER trg_Insert_Игрок;
GO

-- Удаление триггера на удаление
DROP TRIGGER trg_Delete_Игрок;
GO

-- Удаление триггера на обновление
DROP TRIGGER trg_Update_Игрок;
GO

-- Удаляем таблицы и представление
DROP VIEW Игрок_Регион_View;
DROP TABLE Игрок;
DROP TABLE Регион;
GO
