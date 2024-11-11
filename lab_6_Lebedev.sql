CREATE TABLE Сборная (
    регион INT PRIMARY KEY IDENTITY(1,1),  -- Автоинкрементный первичный ключ
    капитан NVARCHAR(100) NOT NULL
);

INSERT INTO Сборная (капитан) VALUES ('Иванов Иван');
INSERT INTO Сборная (капитан) VALUES ('Петров Петр');

SELECT * FROM Сборная;

DROP TABLE Сборная;
GO
---------------------------------------------------------------------------------------------
CREATE TABLE Игрок (
    фамилия NVARCHAR(100) NOT NULL,
    имя NVARCHAR(100) NOT NULL,
    отчество NVARCHAR(100) NOT NULL,
    дата_рождения DATE NOT NULL,
    player_id INT NOT NULL IDENTITY(1,1),  -- Автоинкрементный первиный ключ
    рейтинг SMALLINT,
    страна VARCHAR(2) NOT NULL DEFAULT 'RU',  -- Значение по умолчанию
    регион INT,
    название_го_клуба NVARCHAR(100),
    CONSTRAINT PK_Игрок PRIMARY KEY (фамилия, имя, отчество, дата_рождения), -- Первичный ключ, состоящий из нескольких столбцов.
    CONSTRAINT AK_Игрок UNIQUE (player_id), -- Уникальное ограничение для столбца
    CONSTRAINT CK_Рейтинг CHECK (рейтинг >= 0 AND рейтинг <= 5000) --  Ограничение проверки для столбца рейтинг
);

INSERT INTO Игрок (фамилия, имя, отчество, дата_рождения, рейтинг, регион, название_го_клуба)
VALUES ('Иванов', 'Иван', 'Иванович', '2000-01-01', 2216, 1, 'Го Клуб 1');


SELECT SCOPE_IDENTITY() AS player_id;

INSERT INTO Игрок (фамилия, имя, отчество, дата_рождения, рейтинг, регион, название_го_клуба)
VALUES ('Петров', 'Петр', 'Петрович', '1999-02-02', 2712, 1, 'Го Клуб 2');

SELECT * FROM Игрок;

SELECT @@IDENTITY AS player_id;

DROP TABLE Игрок;
GO
----------------------------------------------------------------------------------------------
CREATE TABLE Го_клуб (
    club_id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),  -- Глобальный уникальный идентификатор
	--Столбец club_id является первичным ключом и генерируется автоматически как уникальный идентификатор.
    название NVARCHAR(100) NOT NULL,
    адрес NVARCHAR(512) NOT NULL,
    регион TINYINT NOT NULL,
    рейтинг SMALLINT
);

INSERT INTO Го_клуб (название, адрес, регион, рейтинг) VALUES ('Го Клуб 1', 'Адрес 1', 1, 50);
INSERT INTO Го_клуб (название, адрес, регион, рейтинг) VALUES ('Го Клуб 2', 'Адрес 2', 1, 60);

SELECT * FROM Го_клуб;

DROP TABLE Го_клуб;
GO
--------------------------------------------------------------------------------------------
CREATE SEQUENCE Seq_TournamentID --Создает последовательность Seq_TournamentID, которая генерирует уникальные значения для столбца tournament_id.
    AS INT
    START WITH 1
    INCREMENT BY 1;

CREATE TABLE Турнир (
    tournament_id INT PRIMARY KEY DEFAULT NEXT VALUE FOR Seq_TournamentID,  -- Первичный ключ на основе последовательности
	-- Столбец tournament_id является первичным ключом и генерируется автоматически на основе последовательности Seq_TournamentID
    название_турнира NVARCHAR(100) NOT NULL,
    дата_начала DATE NOT NULL,
    дата_окончания DATE NOT NULL,
    место_проведения NVARCHAR(512) NOT NULL,
    организатор NVARCHAR(100) NOT NULL,
    уровень_соревнований TINYINT NOT NULL,
    ссылка_на_регламент NVARCHAR(256) NOT NULL
);

INSERT INTO Турнир (название_турнира, дата_начала, дата_окончания, место_проведения, организатор, уровень_соревнований, ссылка_на_регламент)
VALUES ('Турнир 1', '2024-01-01', '2024-01-05', 'Москва', 'Организатор 1', 1, 'ссылка 1');

INSERT INTO Турнир (название_турнира, дата_начала, дата_окончания, место_проведения, организатор, уровень_соревнований, ссылка_на_регламент)
VALUES ('Турнир 2', '2024-02-01', '2024-02-05', 'Санкт-Петербург', 'Организатор 2', 2, 'ссылка 2');

SELECT * FROM Турнир;

DROP TABLE Турнир;
GO
DROP SEQUENCE Seq_TournamentID;
GO
--------------------------------------------------------------------------------------
-- Создаем таблицу "Регион"
CREATE TABLE Регион (
    регион_id INT PRIMARY KEY IDENTITY(1,1),  -- Автоинкрементный первичный ключ
    название NVARCHAR(100) NOT NULL
);

-- Создаем таблицу "Игрок", которая ссылается на таблицу "Регион"
--Создаются таблицы Регион и Игрок, где таблица Игрок ссылается на таблицу Регион через внешний ключ регион_id.
CREATE TABLE Игрок (
    player_id INT PRIMARY KEY IDENTITY(1,1),  -- Автоинкрементный первичный ключ
    фамилия NVARCHAR(100) NOT NULL,
    имя NVARCHAR(100) NOT NULL,
    регион_id INT,
    CONSTRAINT FK_Игрок_Регион FOREIGN KEY (регион_id) REFERENCES Регион(регион_id)
    ON DELETE NO ACTION     -- Ограничение ссылочной целостности при удалении
    ON UPDATE NO ACTION     -- Ограничение ссылочной целостности при обновлении
);

INSERT INTO Регион (название) VALUES ('Москва');
INSERT INTO Регион (название) VALUES ('Санкт-Петербург');

-- Вставляем игроков, которые ссылаются на регионы
INSERT INTO Игрок (фамилия, имя, регион_id) VALUES ('Иванов', 'Иван', 1);
INSERT INTO Игрок (фамилия, имя, регион_id) VALUES ('Петров', 'Петр', 2);

SELECT * FROM Игрок;
SELECT * FROM Регион;

-----------------------------NO ACTION

-- Удаление региона, на который ссылается игрок (NO ACTION)
-- В этом случае при попытке удалить регион, на который ссылаются записи в таблице "Игрок", возникнет ошибка.
--DELETE FROM Регион WHERE регион_id = 1;

-- Ожидаемый результат: SQL Server не позволит удалить регион, так как на него ссылаются записи в таблице "Игрок".

-----------------------------CASCADE

DROP TABLE Игрок;
DROP TABLE Регион;

-- Создаем таблицы заново с правилом CASCADE
CREATE TABLE Регион (
    регион_id INT PRIMARY KEY IDENTITY(1,1),
    название NVARCHAR(100) NOT NULL
);

CREATE TABLE Игрок (
    player_id INT PRIMARY KEY IDENTITY(1,1),
    фамилия NVARCHAR(100) NOT NULL,
    имя NVARCHAR(100) NOT NULL,
    регион_id INT,
    CONSTRAINT FK_Игрок_Регион FOREIGN KEY (регион_id) REFERENCES Регион(регион_id)
    ON DELETE CASCADE      -- При удалении региона удаляются все связанные игроки
    ON UPDATE CASCADE      -- При обновлении региона обновляются все ссылки
);

INSERT INTO Регион (название) VALUES ('Москва');
INSERT INTO Регион (название) VALUES ('Санкт-Петербург');

INSERT INTO Игрок (фамилия, имя, регион_id) VALUES ('Иванов', 'Иван', 1);
INSERT INTO Игрок (фамилия, имя, регион_id) VALUES ('Петров', 'Петр', 2);

-- Удаление региона с CASCADE
DELETE FROM Регион WHERE регион_id = 1;

SELECT * FROM Игрок;
SELECT * FROM Регион;


-----------------------------SET NULL

DROP TABLE Игрок;
DROP TABLE Регион;

-- Создаем таблицы заново с правилом SET NULL
CREATE TABLE Регион (
    регион_id INT PRIMARY KEY IDENTITY(1,1),
    название NVARCHAR(100) NOT NULL
);

CREATE TABLE Игрок (
    player_id INT PRIMARY KEY IDENTITY(1,1),
    фамилия NVARCHAR(100) NOT NULL,
    имя NVARCHAR(100) NOT NULL,
    регион_id INT NULL,
    CONSTRAINT FK_Игрок_Регион FOREIGN KEY (регион_id) REFERENCES Регион(регион_id)
    ON DELETE SET NULL      -- При удалении региона регион_id будет установлен в NULL
    ON UPDATE CASCADE       -- При обновлении региона обновляются все ссылки
);

INSERT INTO Регион (название) VALUES ('Москва');
INSERT INTO Регион (название) VALUES ('Санкт-Петербург');

INSERT INTO Игрок (фамилия, имя, регион_id) VALUES ('Иванов', 'Иван', 1);
INSERT INTO Игрок (фамилия, имя, регион_id) VALUES ('Петров', 'Петр', 2);

-- Удаление региона с SET NULL
DELETE FROM Регион WHERE регион_id = 1;

SELECT * FROM Игрок;
SELECT * FROM Регион;

-----------------------------SET DEFAULT
DROP TABLE Игрок;
DROP TABLE Регион;

-- Создаем таблицы заново с правилом SET DEFAULT
CREATE TABLE Регион (
    регион_id INT PRIMARY KEY IDENTITY(1,1),
    название NVARCHAR(100) NOT NULL
);

CREATE TABLE Игрок (
    player_id INT PRIMARY KEY IDENTITY(1,1),
    фамилия NVARCHAR(100) NOT NULL,
    имя NVARCHAR(100) NOT NULL,
    регион_id INT DEFAULT 2,  -- Значение по умолчанию
    CONSTRAINT FK_Игрок_Регион FOREIGN KEY (регион_id) REFERENCES Регион(регион_id)
    ON DELETE SET DEFAULT      -- При удалении региона регион_id будет установлен в значение по умолчанию
    ON UPDATE CASCADE          -- При обновлении региона обновляются все ссылки
);

INSERT INTO Регион (название) VALUES ('Москва');
INSERT INTO Регион (название) VALUES ('Санкт-Петербург');

INSERT INTO Игрок (фамилия, имя, регион_id) VALUES ('Иванов', 'Иван', 1);
INSERT INTO Игрок (фамилия, имя, регион_id) VALUES ('Петров', 'Петр', 2);

-- Удаление региона с SET DEFAULT
DELETE FROM Регион WHERE регион_id = 1;

SELECT * FROM Игрок;
SELECT * FROM Регион;

DROP TABLE Игрок;
DROP TABLE Регион;
GO





/*
    CONSTRAINT FK_Игрок_Регион FOREIGN KEY (регион_id) REFERENCES Регион(регион_id)
Эта строка определяет внешний ключ (foreign key) в таблице Игрок, который ссылается на таблицу Регион. 
Внешний ключ используется для обеспечения ссылочной целостности между таблицами, то есть для гарантии, 
что значения в столбце регион_id таблицы Игрок всегда будут соответствовать значениям в столбце регион_id таблицы Регион.
*/