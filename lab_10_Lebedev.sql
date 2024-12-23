-- �������� ����� ���� ������
CREATE DATABASE TransactionIsolationTest;
GO
USE TransactionIsolationTest;
GO

-- �������� ������� ��� ������������
CREATE TABLE Region (
    region_id INT PRIMARY KEY IDENTITY(1,1),
    name NVARCHAR(100) NOT NULL
);
GO

INSERT INTO Region (name) VALUES ('������');
GO

-- 1. Read Uncommitted - ������� ������ (��������)
-- ������ 1
BEGIN TRANSACTION;
UPDATE Region SET name = '�����-���������' WHERE region_id = 1;
-- �� ��������� ����������

-- ������ 2
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
BEGIN TRANSACTION;
SELECT * FROM Region;
-- �������� ��������� �������� '�����-���������' (������� ������)

-- ������������ ���������� � ������ 2
SELECT 
    resource_type, 
    resource_subtype, 
    request_mode 
FROM sys.dm_tran_locks 
WHERE request_session_id = @@SPID;
-- ��������� ����������:
-- �������� ������� Shared (S) ���������� �� ������� ��� ������.

COMMIT;

-- ������ 1
ROLLBACK;
GO

-- 2. Read Uncommitted - ����������������� ������ (��������)
-- ������ 1
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
BEGIN TRANSACTION;
SELECT * FROM Region;
-- ������ �������� '������'

-- ������ 2
BEGIN TRANSACTION;
UPDATE Region SET name = '�����-���������' WHERE region_id = 1;
COMMIT;

-- ������ 1
SELECT * FROM Region;
-- ������ �������� '�����-���������' (����������������� ������)

-- ������������ ���������� � ������ 1
SELECT 
    resource_type, 
    resource_subtype, 
    request_mode 
FROM sys.dm_tran_locks 
WHERE request_session_id = @@SPID;
-- ��������� ����������:
-- �������� Shared (S) ����������, �� �� ������������� �������������� ��������� ������.

COMMIT;
GO

-- 3. Read Uncommitted - ��������� ������ (��������)
-- ������ 1
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
BEGIN TRANSACTION;
SELECT * FROM Region;
-- ������ ���� ������

-- ������ 2
BEGIN TRANSACTION;
INSERT INTO Region (name) VALUES ('�������');
COMMIT;

-- ������ 1
SELECT * FROM Region;
-- ������ ��� ������ (��������� ������)

-- ������������ ���������� � ������ 1
SELECT 
    resource_type, 
    resource_subtype, 
    request_mode 
FROM sys.dm_tran_locks 
WHERE request_session_id = @@SPID;
-- ��������� ����������:
-- Shared (S) ���������� �� ��������� ������, ����������� ��������� �������.

COMMIT;
GO

-- 4. Read Committed - ������� ������ (����������)
-- ������ 1
BEGIN TRANSACTION;
UPDATE Region SET name = '�����-���������' WHERE region_id = 1;
-- �� ��������� ����������

-- ������ 2
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
BEGIN TRANSACTION;
SELECT * FROM Region;
-- ���������� ��������� �������� '�����-���������' (������� ������ ����������)

-- ������������ ���������� � ������ 2
SELECT 
    resource_type, 
    resource_subtype, 
    request_mode 
FROM sys.dm_tran_locks 
WHERE request_session_id = @@SPID;
-- ��������� ����������:
-- Shared (S) ���������� ��� ����������� ������ ������������� ���������.

COMMIT;

-- ������ 1
ROLLBACK;
GO

-- 5. Read Committed - ����������������� ������ (��������)
-- ������ 1
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
BEGIN TRANSACTION;
SELECT * FROM Region;
-- ������ �������� '������'

-- ������ 2
BEGIN TRANSACTION;
UPDATE Region SET name = '�����-���������' WHERE region_id = 1;
COMMIT;

-- ������ 1
SELECT * FROM Region;
-- ������ �������� '�����-���������' (����������������� ������)

-- ������������ ���������� � ������ 1
SELECT 
    resource_type, 
    resource_subtype, 
    request_mode 
FROM sys.dm_tran_locks 
WHERE request_session_id = @@SPID;
-- ��������� ����������:
-- Shared (S) ����������, ������� ����� ���� ���������� ����� ������� � ������ 2.

COMMIT;
GO

-- 6. Read Committed - ��������� ������ (��������)
-- ������ 1
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
BEGIN TRANSACTION;
SELECT * FROM Region;
-- ������ ���� ������

-- ������ 2
BEGIN TRANSACTION;
INSERT INTO Region (name) VALUES ('�������');
COMMIT;

-- ������ 1
SELECT * FROM Region;
-- ������ ��� ������ (��������� ������)

-- ������������ ���������� � ������ 1
SELECT 
    resource_type, 
    resource_subtype, 
    request_mode 
FROM sys.dm_tran_locks 
WHERE request_session_id = @@SPID;
-- ��������� ����������:
-- Shared (S) ���������� �� ���������, ����������� ��������� �������.

COMMIT;
GO

-- 7. Repeatable Read - ������� ������ (����������)
-- ������ 1
BEGIN TRANSACTION;
UPDATE Region SET name = '�����-���������' WHERE region_id = 1;
-- �� ��������� ����������

-- ������ 2
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ; -- ��������������� ������
BEGIN TRANSACTION;
SELECT * FROM Region;
-- ���������� ��������� �������� '�����-���������' (������� ������ ����������)

-- ������������ ���������� � ������ 2
SELECT 
    resource_type, 
    resource_subtype, 
    request_mode 
FROM sys.dm_tran_locks 
WHERE request_session_id = @@SPID;
-- ��������� ����������:
-- Shared (S) ���������� � ���������� �� ���������� ����������, ��������������� ���������.

COMMIT;

-- ������ 1
ROLLBACK;
GO

-- 8. Repeatable Read - ����������������� ������ (����������)
-- ������ 1
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
BEGIN TRANSACTION;
SELECT * FROM Region;
-- ������ �������� '������'

-- ������ 2
BEGIN TRANSACTION;
UPDATE Region SET name = '�����-���������' WHERE region_id = 1;
COMMIT;

-- ������ 1
SELECT * FROM Region;
-- ������ �������� '������' (����������������� ������ ����������)

-- ������������ ���������� � ������ 1
SELECT 
    resource_type, 
    resource_subtype, 
    request_mode 
FROM sys.dm_tran_locks 
WHERE request_session_id = @@SPID;
-- ��������� ����������:
-- ����������� Shared (S) ����������, ��������������� ��������� ������ � ������ 2.

COMMIT;
GO

-- 9. Repeatable Read - ��������� ������ (��������)
-- ������ 1
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
BEGIN TRANSACTION;
SELECT * FROM Region;
-- ������ ���� ������

-- ������ 2
BEGIN TRANSACTION;
INSERT INTO Region (name) VALUES ('�������');
COMMIT;

-- ������ 1
SELECT * FROM Region;
-- ������ ��� ������ (��������� ������)

-- ������������ ���������� � ������ 1
SELECT 
    resource_type, 
    resource_subtype, 
    request_mode 
FROM sys.dm_tran_locks 
WHERE request_session_id = @@SPID;
-- ��������� ����������:
-- ���� Repeatable Read ������������� ��������� ������������ �����, ��������� ������� ��� ��� ��������.

COMMIT;
GO

-- 10. Serializable - ������� ������ (����������)
-- ������ 1
BEGIN TRANSACTION;
UPDATE Region SET name = '�����-���������' WHERE region_id = 1;
-- �� ��������� ����������

-- ������ 2
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
BEGIN TRANSACTION;
SELECT * FROM Region;
-- ���������� ��������� �������� '�����-���������' (������� ������ ����������)

-- ������������ ���������� � ������ 2
SELECT 
    resource_type, 
    resource_subtype, 
    request_mode 
FROM sys.dm_tran_locks 
WHERE request_session_id = @@SPID;
-- ��������� ����������:
-- Shared (S) � RangeS-S ����������, �������������� ������ ��������.

COMMIT;

-- ������ 1
ROLLBACK;
GO

-- 11. Serializable - ����������������� ������ (����������)
-- ������ 1
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
BEGIN TRANSACTION;
SELECT * FROM Region;
-- ������ �������� '������'

-- ������ 2
BEGIN TRANSACTION;
UPDATE Region SET name = '�����-���������' WHERE region_id = 1;
COMMIT;

-- ������ 1
SELECT * FROM Region;
-- ������ �������� '������' (����������������� ������ ����������)

-- ������������ ���������� � ������ 1
SELECT 
    resource_type, 
    resource_subtype, 
    request_mode 
FROM sys.dm_tran_locks 
WHERE request_session_id = @@SPID;
-- ��������� ����������:
-- RangeS-S ���������� ������������� ����� ���������, ����������� ������������� ������.

COMMIT;
GO

-- 12. Serializable - ��������� ������ (����������)
-- ������ 1
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
BEGIN TRANSACTION;
SELECT * FROM Region;
-- ������ ���� ������

-- ������ 2
BEGIN TRANSACTION;
INSERT INTO Region (name) VALUES ('�������');
COMMIT;

-- ������ 1
SELECT * FROM Region;
-- ������ ���� ������ (��������� ������ ����������)

-- ������������ ���������� � ������ 1
SELECT 
    resource_type, 
    resource_subtype, 
    request_mode 
FROM sys.dm_tran_locks 
WHERE request_session_id = @@SPID;
-- ��������� ����������:
-- RangeS-S ���������� ������������� ��������� �������, ���������� ���������� ����� �����.

COMMIT;
GO

-- ������������ ���������� � �������������� sys.dm_tran_locks
-- ������ 1
BEGIN TRANSACTION;
UPDATE Region SET name = '�����-���������' WHERE region_id = 1;
-- �� ��������� ����������

-- ������ 2
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
BEGIN TRANSACTION;
SELECT * FROM Region;
-- ��������� ����������
SELECT 
    resource_type, 
    resource_subtype, 
    request_mode 
FROM sys.dm_tran_locks 
WHERE request_session_id = @@SPID;
-- ��������� ����������:
-- DATABASE S � ���������� ������ ���� ������ � ������ Shared (S).
-- OBJECT IX � Intent Exclusive ���������� �� ������ �������.
-- PAGE IX � Intent Exclusive ���������� �� ������ ��������.
-- KEY RangeS-S � ������ ��������� �� ������� ����� �����.
-- KEY RangeX-X � ������������ ���������� �� ��������� � �����.

COMMIT;

/*
DATABASE S � ���������� ������ ���� ������ � ������ Shared (S).
��� ����������� ���������� �� ������ ���� ���� ������, �����������, ��� ���������� ������ ������.
OBJECT IX � ���������� ������ ������� (�������) � ����� Intent Exclusive (IX).
Intent-���������� ������ ��� ���������������� ��������� ��������� ����� ���������� (����� �������������) ������������ ��� ����������� ���������� �� ����������� ������� (��������, ������).
PAGE IX � ���������� OBJECT IX, �� �� ������ ���������� ��������
KEY RangeS-S � ��� ����������� ����������, ����������� ��� ������ �������� SERIALIZABLE.
    RangeS-S ��������, ��� ���������� ���������� �shared� ���������� � �� ����������� �����, � �� ���������, ������������ ������ ���������� �� ������� ����� ����� � ���� �������� (�� ���� ������ �� ����������� �������).
KEY RangeX-X � ��� ���� ��� ����������� ����������.
    RangeX-X ���������, ��� ���������� ���������� ������������ ���������� (X) �� ��������� � �� �����.    
*/

-- ������ 1
ROLLBACK;
GO

-- �������� ��������� ������ � ���� ������
DROP TABLE Region;
GO
USE master;
GO
DROP DATABASE TransactionIsolationTest;
GO
