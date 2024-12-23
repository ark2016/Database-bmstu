-- Создание новой базы данных
CREATE DATABASE TransactionIsolationTest;
GO
USE TransactionIsolationTest;
GO

-- Создание таблицы для тестирования
CREATE TABLE Region (
    region_id INT PRIMARY KEY IDENTITY(1,1),
    name NVARCHAR(100) NOT NULL
);
GO

INSERT INTO Region (name) VALUES ('Москва');
GO

-- 1. Read Uncommitted - Грязное чтение (Возможно)
-- Сессия 1
BEGIN TRANSACTION;
UPDATE Region SET name = 'Санкт-Петербург' WHERE region_id = 1;
-- Не фиксируем транзакцию

-- Сессия 2
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
BEGIN TRANSACTION;
SELECT * FROM Region;
-- Возможно прочитать значение 'Санкт-Петербург' (грязное чтение)

-- Исследование блокировок в Сессии 2
SELECT 
    resource_type, 
    resource_subtype, 
    request_mode 
FROM sys.dm_tran_locks 
WHERE request_session_id = @@SPID;
-- Ожидаемые блокировки:
-- Возможно наличие Shared (S) блокировок на таблице или строке.

COMMIT;

-- Сессия 1
ROLLBACK;
GO

-- 2. Read Uncommitted - Невоспроизводимое чтение (Возможно)
-- Сессия 1
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
BEGIN TRANSACTION;
SELECT * FROM Region;
-- Читаем значение 'Москва'

-- Сессия 2
BEGIN TRANSACTION;
UPDATE Region SET name = 'Санкт-Петербург' WHERE region_id = 1;
COMMIT;

-- Сессия 1
SELECT * FROM Region;
-- Читаем значение 'Санкт-Петербург' (невоспроизводимое чтение)

-- Исследование блокировок в Сессии 1
SELECT 
    resource_type, 
    resource_subtype, 
    request_mode 
FROM sys.dm_tran_locks 
WHERE request_session_id = @@SPID;
-- Ожидаемые блокировки:
-- Возможно Shared (S) блокировки, но не гарантируется предотвращение изменения данных.

COMMIT;
GO

-- 3. Read Uncommitted - Фантомное чтение (Возможно)
-- Сессия 1
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
BEGIN TRANSACTION;
SELECT * FROM Region;
-- Читаем одну строку

-- Сессия 2
BEGIN TRANSACTION;
INSERT INTO Region (name) VALUES ('Магадан');
COMMIT;

-- Сессия 1
SELECT * FROM Region;
-- Читаем две строки (фантомное чтение)

-- Исследование блокировок в Сессии 1
SELECT 
    resource_type, 
    resource_subtype, 
    request_mode 
FROM sys.dm_tran_locks 
WHERE request_session_id = @@SPID;
-- Ожидаемые блокировки:
-- Shared (S) блокировки на диапазоне данных, позволяющие фантомные вставки.

COMMIT;
GO

-- 4. Read Committed - Грязное чтение (Невозможно)
-- Сессия 1
BEGIN TRANSACTION;
UPDATE Region SET name = 'Санкт-Петербург' WHERE region_id = 1;
-- Не фиксируем транзакцию

-- Сессия 2
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
BEGIN TRANSACTION;
SELECT * FROM Region;
-- Невозможно прочитать значение 'Санкт-Петербург' (грязное чтение невозможно)

-- Исследование блокировок в Сессии 2
SELECT 
    resource_type, 
    resource_subtype, 
    request_mode 
FROM sys.dm_tran_locks 
WHERE request_session_id = @@SPID;
-- Ожидаемые блокировки:
-- Shared (S) блокировки без возможности чтения незавершенных изменений.

COMMIT;

-- Сессия 1
ROLLBACK;
GO

-- 5. Read Committed - Невоспроизводимое чтение (Возможно)
-- Сессия 1
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
BEGIN TRANSACTION;
SELECT * FROM Region;
-- Читаем значение 'Москва'

-- Сессия 2
BEGIN TRANSACTION;
UPDATE Region SET name = 'Санкт-Петербург' WHERE region_id = 1;
COMMIT;

-- Сессия 1
SELECT * FROM Region;
-- Читаем значение 'Санкт-Петербург' (невоспроизводимое чтение)

-- Исследование блокировок в Сессия 1
SELECT 
    resource_type, 
    resource_subtype, 
    request_mode 
FROM sys.dm_tran_locks 
WHERE request_session_id = @@SPID;
-- Ожидаемые блокировки:
-- Shared (S) блокировки, которые могут быть переписаны после коммита в Сессии 2.

COMMIT;
GO

-- 6. Read Committed - Фантомное чтение (Возможно)
-- Сессия 1
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
BEGIN TRANSACTION;
SELECT * FROM Region;
-- Читаем одну строку

-- Сессия 2
BEGIN TRANSACTION;
INSERT INTO Region (name) VALUES ('Магадан');
COMMIT;

-- Сессия 1
SELECT * FROM Region;
-- Читаем две строки (фантомное чтение)

-- Исследование блокировок в Сессия 1
SELECT 
    resource_type, 
    resource_subtype, 
    request_mode 
FROM sys.dm_tran_locks 
WHERE request_session_id = @@SPID;
-- Ожидаемые блокировки:
-- Shared (S) блокировки на диапазоне, допускающие фантомные вставки.

COMMIT;
GO

-- 7. Repeatable Read - Грязное чтение (Невозможно)
-- Сессия 1
BEGIN TRANSACTION;
UPDATE Region SET name = 'Санкт-Петербург' WHERE region_id = 1;
-- Не фиксируем транзакцию

-- Сессия 2
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ; -- воспроизводимое чтение
BEGIN TRANSACTION;
SELECT * FROM Region;
-- Невозможно прочитать значение 'Санкт-Петербург' (грязное чтение невозможно)

-- Исследование блокировок в Сессия 2
SELECT 
    resource_type, 
    resource_subtype, 
    request_mode 
FROM sys.dm_tran_locks 
WHERE request_session_id = @@SPID;
-- Ожидаемые блокировки:
-- Shared (S) блокировки с удержанием на протяжении транзакции, предотвращающие изменения.

COMMIT;

-- Сессия 1
ROLLBACK;
GO

-- 8. Repeatable Read - Невоспроизводимое чтение (Невозможно)
-- Сессия 1
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
BEGIN TRANSACTION;
SELECT * FROM Region;
-- Читаем значение 'Москва'

-- Сессия 2
BEGIN TRANSACTION;
UPDATE Region SET name = 'Санкт-Петербург' WHERE region_id = 1;
COMMIT;

-- Сессия 1
SELECT * FROM Region;
-- Читаем значение 'Москва' (невоспроизводимое чтение невозможно)

-- Исследование блокировок в Сессия 1
SELECT 
    resource_type, 
    resource_subtype, 
    request_mode 
FROM sys.dm_tran_locks 
WHERE request_session_id = @@SPID;
-- Ожидаемые блокировки:
-- Повторяемые Shared (S) блокировки, предотвращающие изменение данных в Сессии 2.

COMMIT;
GO

-- 9. Repeatable Read - Фантомное чтение (Возможно)
-- Сессия 1
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
BEGIN TRANSACTION;
SELECT * FROM Region;
-- Читаем одну строку

-- Сессия 2
BEGIN TRANSACTION;
INSERT INTO Region (name) VALUES ('Магадан');
COMMIT;

-- Сессия 1
SELECT * FROM Region;
-- Читаем две строки (фантомное чтение)

-- Исследование блокировок в Сессия 1
SELECT 
    resource_type, 
    resource_subtype, 
    request_mode 
FROM sys.dm_tran_locks 
WHERE request_session_id = @@SPID;
-- Ожидаемые блокировки:
-- Хотя Repeatable Read предотвращает изменение существующих строк, фантомные вставки все еще возможны.

COMMIT;
GO

-- 10. Serializable - Грязное чтение (Невозможно)
-- Сессия 1
BEGIN TRANSACTION;
UPDATE Region SET name = 'Санкт-Петербург' WHERE region_id = 1;
-- Не фиксируем транзакцию

-- Сессия 2
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
BEGIN TRANSACTION;
SELECT * FROM Region;
-- Невозможно прочитать значение 'Санкт-Петербург' (грязное чтение невозможно)

-- Исследование блокировок в Сессия 2
SELECT 
    resource_type, 
    resource_subtype, 
    request_mode 
FROM sys.dm_tran_locks 
WHERE request_session_id = @@SPID;
-- Ожидаемые блокировки:
-- Shared (S) и RangeS-S блокировки, обеспечивающие полную изоляцию.

COMMIT;

-- Сессия 1
ROLLBACK;
GO

-- 11. Serializable - Невоспроизводимое чтение (Невозможно)
-- Сессия 1
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
BEGIN TRANSACTION;
SELECT * FROM Region;
-- Читаем значение 'Москва'

-- Сессия 2
BEGIN TRANSACTION;
UPDATE Region SET name = 'Санкт-Петербург' WHERE region_id = 1;
COMMIT;

-- Сессия 1
SELECT * FROM Region;
-- Читаем значение 'Москва' (невоспроизводимое чтение невозможно)

-- Исследование блокировок в Сессия 1
SELECT 
    resource_type, 
    resource_subtype, 
    request_mode 
FROM sys.dm_tran_locks 
WHERE request_session_id = @@SPID;
-- Ожидаемые блокировки:
-- RangeS-S блокировки предотвращают любые изменения, обеспечивая повторяемость чтений.

COMMIT;
GO

-- 12. Serializable - Фантомное чтение (Невозможно)
-- Сессия 1
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
BEGIN TRANSACTION;
SELECT * FROM Region;
-- Читаем одну строку

-- Сессия 2
BEGIN TRANSACTION;
INSERT INTO Region (name) VALUES ('Магадан');
COMMIT;

-- Сессия 1
SELECT * FROM Region;
-- Читаем одну строку (фантомное чтение невозможно)

-- Исследование блокировок в Сессия 1
SELECT 
    resource_type, 
    resource_subtype, 
    request_mode 
FROM sys.dm_tran_locks 
WHERE request_session_id = @@SPID;
-- Ожидаемые блокировки:
-- RangeS-S блокировки предотвращают фантомные вставки, гарантируя отсутствие новых строк.

COMMIT;
GO

-- Исследование блокировок с использованием sys.dm_tran_locks
-- Сессия 1
BEGIN TRANSACTION;
UPDATE Region SET name = 'Санкт-Петербург' WHERE region_id = 1;
-- Не фиксируем транзакцию

-- Сессия 2
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
BEGIN TRANSACTION;
SELECT * FROM Region;
-- Проверяем блокировки
SELECT 
    resource_type, 
    resource_subtype, 
    request_mode 
FROM sys.dm_tran_locks 
WHERE request_session_id = @@SPID;
-- Ожидаемые блокировки:
-- DATABASE S – Блокировка уровня базы данных в режиме Shared (S).
-- OBJECT IX – Intent Exclusive блокировки на уровне объекта.
-- PAGE IX – Intent Exclusive блокировки на уровне страницы.
-- KEY RangeS-S – Защита диапазона от вставки новых строк.
-- KEY RangeX-X – Эксклюзивные блокировки на диапазоне и ключе.

COMMIT;

/*
DATABASE S – Блокировка уровня базы данных в режиме Shared (S).
Это совместимая блокировка на уровне всей базы данных, указывающая, что транзакция читает данные.
OBJECT IX – Блокировка уровня объекта (таблицы) с типом Intent Exclusive (IX).
Intent-блокировки служат для протоколирования намерения поставить более конкретную (более «гранулярную») эксклюзивную или обновляющую блокировку на нижележащем ресурсе (странице, строке).
PAGE IX – Аналогично OBJECT IX, но на уровне конкретной страницы
KEY RangeS-S – Это диапазонные блокировки, специфичные для уровня изоляции SERIALIZABLE.
    RangeS-S означает, что транзакция удерживает «shared» блокировку и на фактическом ключе, и на диапазоне, предотвращая другие транзакции от вставки новых строк в этот диапазон (то есть защита от «фантомных» вставок).
KEY RangeX-X – Еще один тип диапазонной блокировки.
    RangeX-X указывает, что транзакция удерживает эксклюзивную блокировку (X) на диапазоне и на ключе.    
*/

-- Сессия 1
ROLLBACK;
GO

-- Удаление созданных таблиц и базы данных
DROP TABLE Region;
GO
USE master;
GO
DROP DATABASE TransactionIsolationTest;
GO
