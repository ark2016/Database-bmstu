CREATE TABLE ������� (
    ������ INT PRIMARY KEY IDENTITY(1,1),  -- ���������������� ��������� ����
    ������� NVARCHAR(100) NOT NULL
);

INSERT INTO ������� (�������) VALUES ('������ ����');
INSERT INTO ������� (�������) VALUES ('������ ����');

SELECT * FROM �������;

DROP TABLE �������;
GO
---------------------------------------------------------------------------------------------
CREATE TABLE ����� (
    ������� NVARCHAR(100) NOT NULL,
    ��� NVARCHAR(100) NOT NULL,
    �������� NVARCHAR(100) NOT NULL,
    ����_�������� DATE NOT NULL,
    player_id INT NOT NULL IDENTITY(1,1),  -- ���������������� �������� ����
    ������� SMALLINT,
    ������ VARCHAR(2) NOT NULL DEFAULT 'RU',  -- �������� �� ���������
    ������ INT,
    ��������_��_����� NVARCHAR(100),
    CONSTRAINT PK_����� PRIMARY KEY (�������, ���, ��������, ����_��������), -- ��������� ����, ��������� �� ���������� ��������.
    CONSTRAINT AK_����� UNIQUE (player_id), -- ���������� ����������� ��� �������
    CONSTRAINT CK_������� CHECK (������� >= 0 AND ������� <= 5000) --  ����������� �������� ��� ������� �������
);

INSERT INTO ����� (�������, ���, ��������, ����_��������, �������, ������, ��������_��_�����)
VALUES ('������', '����', '��������', '2000-01-01', 2216, 1, '�� ���� 1');


SELECT SCOPE_IDENTITY() AS player_id;

INSERT INTO ����� (�������, ���, ��������, ����_��������, �������, ������, ��������_��_�����)
VALUES ('������', '����', '��������', '1999-02-02', 2712, 1, '�� ���� 2');

SELECT * FROM �����;

SELECT @@IDENTITY AS player_id;

DROP TABLE �����;
GO
----------------------------------------------------------------------------------------------
CREATE TABLE ��_���� (
    club_id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),  -- ���������� ���������� �������������
	--������� club_id �������� ��������� ������ � ������������ ������������� ��� ���������� �������������.
    �������� NVARCHAR(100) NOT NULL,
    ����� NVARCHAR(512) NOT NULL,
    ������ TINYINT NOT NULL,
    ������� SMALLINT
);

INSERT INTO ��_���� (��������, �����, ������, �������) VALUES ('�� ���� 1', '����� 1', 1, 50);
INSERT INTO ��_���� (��������, �����, ������, �������) VALUES ('�� ���� 2', '����� 2', 1, 60);

SELECT * FROM ��_����;

DROP TABLE ��_����;
GO
--------------------------------------------------------------------------------------------
CREATE SEQUENCE Seq_TournamentID --������� ������������������ Seq_TournamentID, ������� ���������� ���������� �������� ��� ������� tournament_id.
    AS INT
    START WITH 1
    INCREMENT BY 1;

CREATE TABLE ������ (
    tournament_id INT PRIMARY KEY DEFAULT NEXT VALUE FOR Seq_TournamentID,  -- ��������� ���� �� ������ ������������������
	-- ������� tournament_id �������� ��������� ������ � ������������ ������������� �� ������ ������������������ Seq_TournamentID
    ��������_������� NVARCHAR(100) NOT NULL,
    ����_������ DATE NOT NULL,
    ����_��������� DATE NOT NULL,
    �����_���������� NVARCHAR(512) NOT NULL,
    ����������� NVARCHAR(100) NOT NULL,
    �������_������������ TINYINT NOT NULL,
    ������_��_��������� NVARCHAR(256) NOT NULL
);

INSERT INTO ������ (��������_�������, ����_������, ����_���������, �����_����������, �����������, �������_������������, ������_��_���������)
VALUES ('������ 1', '2024-01-01', '2024-01-05', '������', '����������� 1', 1, '������ 1');

INSERT INTO ������ (��������_�������, ����_������, ����_���������, �����_����������, �����������, �������_������������, ������_��_���������)
VALUES ('������ 2', '2024-02-01', '2024-02-05', '�����-���������', '����������� 2', 2, '������ 2');

SELECT * FROM ������;

DROP TABLE ������;
GO
DROP SEQUENCE Seq_TournamentID;
GO
--------------------------------------------------------------------------------------
-- ������� ������� "������"
CREATE TABLE ������ (
    ������_id INT PRIMARY KEY IDENTITY(1,1),  -- ���������������� ��������� ����
    �������� NVARCHAR(100) NOT NULL
);

-- ������� ������� "�����", ������� ��������� �� ������� "������"
--��������� ������� ������ � �����, ��� ������� ����� ��������� �� ������� ������ ����� ������� ���� ������_id.
CREATE TABLE ����� (
    player_id INT PRIMARY KEY IDENTITY(1,1),  -- ���������������� ��������� ����
    ������� NVARCHAR(100) NOT NULL,
    ��� NVARCHAR(100) NOT NULL,
    ������_id INT,
    CONSTRAINT FK_�����_������ FOREIGN KEY (������_id) REFERENCES ������(������_id)
    ON DELETE NO ACTION     -- ����������� ��������� ����������� ��� ��������
    ON UPDATE NO ACTION     -- ����������� ��������� ����������� ��� ����������
);

INSERT INTO ������ (��������) VALUES ('������');
INSERT INTO ������ (��������) VALUES ('�����-���������');

-- ��������� �������, ������� ��������� �� �������
INSERT INTO ����� (�������, ���, ������_id) VALUES ('������', '����', 1);
INSERT INTO ����� (�������, ���, ������_id) VALUES ('������', '����', 2);

SELECT * FROM �����;
SELECT * FROM ������;

-----------------------------NO ACTION

-- �������� �������, �� ������� ��������� ����� (NO ACTION)
-- � ���� ������ ��� ������� ������� ������, �� ������� ��������� ������ � ������� "�����", ��������� ������.
--DELETE FROM ������ WHERE ������_id = 1;

-- ��������� ���������: SQL Server �� �������� ������� ������, ��� ��� �� ���� ��������� ������ � ������� "�����".

-----------------------------CASCADE

DROP TABLE �����;
DROP TABLE ������;

-- ������� ������� ������ � �������� CASCADE
CREATE TABLE ������ (
    ������_id INT PRIMARY KEY IDENTITY(1,1),
    �������� NVARCHAR(100) NOT NULL
);

CREATE TABLE ����� (
    player_id INT PRIMARY KEY IDENTITY(1,1),
    ������� NVARCHAR(100) NOT NULL,
    ��� NVARCHAR(100) NOT NULL,
    ������_id INT,
    CONSTRAINT FK_�����_������ FOREIGN KEY (������_id) REFERENCES ������(������_id)
    ON DELETE CASCADE      -- ��� �������� ������� ��������� ��� ��������� ������
    ON UPDATE CASCADE      -- ��� ���������� ������� ����������� ��� ������
);

INSERT INTO ������ (��������) VALUES ('������');
INSERT INTO ������ (��������) VALUES ('�����-���������');

INSERT INTO ����� (�������, ���, ������_id) VALUES ('������', '����', 1);
INSERT INTO ����� (�������, ���, ������_id) VALUES ('������', '����', 2);

-- �������� ������� � CASCADE
DELETE FROM ������ WHERE ������_id = 1;

SELECT * FROM �����;
SELECT * FROM ������;


-----------------------------SET NULL

DROP TABLE �����;
DROP TABLE ������;

-- ������� ������� ������ � �������� SET NULL
CREATE TABLE ������ (
    ������_id INT PRIMARY KEY IDENTITY(1,1),
    �������� NVARCHAR(100) NOT NULL
);

CREATE TABLE ����� (
    player_id INT PRIMARY KEY IDENTITY(1,1),
    ������� NVARCHAR(100) NOT NULL,
    ��� NVARCHAR(100) NOT NULL,
    ������_id INT NULL,
    CONSTRAINT FK_�����_������ FOREIGN KEY (������_id) REFERENCES ������(������_id)
    ON DELETE SET NULL      -- ��� �������� ������� ������_id ����� ���������� � NULL
    ON UPDATE CASCADE       -- ��� ���������� ������� ����������� ��� ������
);

INSERT INTO ������ (��������) VALUES ('������');
INSERT INTO ������ (��������) VALUES ('�����-���������');

INSERT INTO ����� (�������, ���, ������_id) VALUES ('������', '����', 1);
INSERT INTO ����� (�������, ���, ������_id) VALUES ('������', '����', 2);

-- �������� ������� � SET NULL
DELETE FROM ������ WHERE ������_id = 1;

SELECT * FROM �����;
SELECT * FROM ������;

-----------------------------SET DEFAULT
DROP TABLE �����;
DROP TABLE ������;

-- ������� ������� ������ � �������� SET DEFAULT
CREATE TABLE ������ (
    ������_id INT PRIMARY KEY IDENTITY(1,1),
    �������� NVARCHAR(100) NOT NULL
);

CREATE TABLE ����� (
    player_id INT PRIMARY KEY IDENTITY(1,1),
    ������� NVARCHAR(100) NOT NULL,
    ��� NVARCHAR(100) NOT NULL,
    ������_id INT DEFAULT 2,  -- �������� �� ���������
    CONSTRAINT FK_�����_������ FOREIGN KEY (������_id) REFERENCES ������(������_id)
    ON DELETE SET DEFAULT      -- ��� �������� ������� ������_id ����� ���������� � �������� �� ���������
    ON UPDATE CASCADE          -- ��� ���������� ������� ����������� ��� ������
);

INSERT INTO ������ (��������) VALUES ('������');
INSERT INTO ������ (��������) VALUES ('�����-���������');

INSERT INTO ����� (�������, ���, ������_id) VALUES ('������', '����', 1);
INSERT INTO ����� (�������, ���, ������_id) VALUES ('������', '����', 2);

-- �������� ������� � SET DEFAULT
DELETE FROM ������ WHERE ������_id = 1;

SELECT * FROM �����;
SELECT * FROM ������;

DROP TABLE �����;
DROP TABLE ������;
GO





/*
    CONSTRAINT FK_�����_������ FOREIGN KEY (������_id) REFERENCES ������(������_id)
��� ������ ���������� ������� ���� (foreign key) � ������� �����, ������� ��������� �� ������� ������. 
������� ���� ������������ ��� ����������� ��������� ����������� ����� ���������, �� ���� ��� ��������, 
��� �������� � ������� ������_id ������� ����� ������ ����� ��������������� ��������� � ������� ������_id ������� ������.
*/