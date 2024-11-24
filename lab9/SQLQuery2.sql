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
    Р.название AS название_региона,
    И.регион_id
FROM Игрок И
JOIN Регион Р ON И.регион_id = Р.регион_id;
GO
-- Создает представление Игрок_Регион_View, которое выбирает столбцы из таблиц Игрок и Регион и объединяет их по столбцу регион_id.

-- Выбираем данные из представления
SELECT * FROM Игрок_Регион_View;
GO

-- Триггер на вставку
CREATE TRIGGER trg_Insert_Игрок_Регион_View
ON Игрок_Регион_View
INSTEAD OF INSERT
AS
BEGIN
    INSERT INTO Игрок (фамилия, имя, регион_id)
    SELECT фамилия, имя, регион_id
    FROM inserted;
END;
GO

-- Триггер на удаление
CREATE TRIGGER trg_Delete_Игрок_Регион_View
ON Игрок_Регион_View
INSTEAD OF DELETE
AS
BEGIN
    DELETE FROM Игрок
    WHERE player_id IN (SELECT player_id FROM deleted);
END;
GO

-- Триггер на обновление
CREATE TRIGGER trg_Update_Игрок_Регион_View
ON Игрок_Регион_View
INSTEAD OF UPDATE
AS
BEGIN
    UPDATE Игрок
    SET фамилия = inserted.фамилия,
        имя = inserted.имя,
        регион_id = inserted.регион_id
    FROM inserted
    WHERE Игрок.player_id = inserted.player_id;
END;
GO
--===========================================================================================
-- Попытка вставки игрока с фамилией "Иванов"
INSERT INTO Игрок (фамилия, имя, регион_id) VALUES ('Иванов', 'Алексей', 1);
-- Должна возникнуть ошибка

-- Вставка данных через представление
INSERT INTO Игрок_Регион_View (фамилия, имя, регион_id) VALUES ('Сидоров', 'Сидор', 1);
-- Данные должны быть успешно вставлены


-- Попытка удаления игрока с ID 1
DELETE FROM Игрок WHERE player_id = 1;
-- Должна возникнуть ошибка

-- Удаление данных через представление
DELETE FROM Игрок_Регион_View WHERE player_id = 2;
-- Данные должны быть успешно удалены

-- Попытка обновления игрока с фамилией "Петров" и именем "Петр"
UPDATE Игрок SET фамилия = 'Петров', имя = 'Петр' WHERE player_id = 3;
-- Должна возникнуть ошибка

-- Обновление данных через представление
UPDATE Игрок_Регион_View SET фамилия = 'Кузнецов', имя = 'Кузьма' WHERE player_id = 3;
-- Данные должны быть успешно обновлены


--===========================================================================================

-- Удаление триггера на вставку
DROP TRIGGER trg_Insert_Игрок_Регион_View;
GO

-- Удаление триггера на удаление
DROP TRIGGER trg_Delete_Игрок_Регион_View;
GO

-- Удаление триггера на обновление
DROP TRIGGER trg_Update_Игрок_Регион_View;
GO

-- Удаляем таблицы и представление
DROP VIEW Игрок_Регион_View;
DROP TABLE Игрок;
DROP TABLE Регион;
GO