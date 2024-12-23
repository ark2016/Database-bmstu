
# ADOnetApp

## Содержание

<!-- 1. [Введение](#введение)
2. [Требования](#требования)
3. [Настройка](#настройка)
4. [Запуск приложения](#запуск-приложения)
5. [Тестирование подключенного уровня](#тестирование-подключенного-уровня)
    - [1. Просмотр всех таблиц](#1-просмотр-всех-таблиц)
    - [2. Просмотр всех записей в таблице](#2-просмотр-всех-записей-в-таблице)
    - [3. Просмотр данных из определенного столбца](#3-просмотр-данных-из-определенного-столбца)
    - [4. Добавление новой записи](#4-добавление-новой-записи)
    - [5. Удаление записи](#5-удаление-записи)
    - [6. Обновление записи](#6-обновление-записи)
    - [7. Выполнение произвольного SQL-запроса](#7-выполнение-произвольного-sql-запроса)
    - [8. Команда помощи](#8-команда-помощи)
6. [Тестирование отключенного уровня](#тестирование-отключенного-уровня)
    - [1. Просмотр всех записей](#1-просмотр-всех-записей)
    - [2. Добавление новой записи](#2-добавление-новой-записи-1)
    - [3. Удаление записи по первичному ключу](#3-удаление-записи-по-первичному-ключу)
    - [4. Обновление рейтинга записи по первичному ключу](#4-обновление-рейтинга-записи-по-первичному-ключу)
    - [5. Принятие изменений в базе данных](#5-принятие-изменений-в-базе-данных)
    - [6. Команда помощи](#6-команда-помощи-1)
7. [Распространенные проблемы и их устранение](#распространенные-проблемы-и-их-устранение)
8. [Соображения безопасности](#соображения-безопасности)
9. [Заключение](#заключение) -->

1. [Запуск приложения](#запуск-приложения)
2. [Тестирование подключенного уровня](#тестирование-подключенного-уровня)
    - [1. Просмотр всех таблиц](#1-просмотр-всех-таблиц)
    - [2. Просмотр всех записей в таблице](#2-просмотр-всех-записей-в-таблице)
    - [3. Просмотр данных из определенного столбца](#3-просмотр-данных-из-определенного-столбца)
    - [4. Добавление новой записи](#4-добавление-новой-записи)
    - [5. Удаление записи](#5-удаление-записи)
    - [6. Обновление записи](#6-обновление-записи)
    <!-- - [7. Выполнение произвольного SQL-запроса](#7-выполнение-произвольного-sql-запроса) -->
    - [7. Команда помощи](#7-команда-помощи)
3. [Тестирование отключенного уровня](#тестирование-отключенного-уровня)
    - [1. Просмотр всех записей](#1-просмотр-всех-записей)
    - [2. Добавление новой записи](#2-добавление-новой-записи-1)
    - [3. Удаление записи по первичному ключу](#3-удаление-записи-по-первичному-ключу)
    - [4. Обновление рейтинга записи по первичному ключу](#4-обновление-рейтинга-записи-по-первичному-ключу)
    - [5. Принятие изменений в базе данных](#5-принятие-изменений-в-базе-данных)
    - [6. Команда помощи](#6-команда-помощи)

---

<!-- ## Введение

Этот план тестирования описывает шаги для проверки функциональности, надежности и безопасности приложения **ADOnetApp**. Приложение взаимодействует с базой данных SQL Server с использованием технологии ADO.NET как в подключенном, так и в отключенном режимах. Документ предоставляет подробные инструкции по тестированию каждой функции приложения, чтобы убедиться, что оно работает правильно.

## Требования

Перед началом тестирования убедитесь, что выполнены следующие требования:

- **Среда разработки:**
  - **Операционная система:** Windows 10 или выше
  - **.NET Framework:** версии 4.5 или выше
  - **SQL Server:** установлен и запущен (например, SQL Server Express)
  - **SQL Server Management Studio (SSMS) 20:** установлен
  - **Visual Studio:** установлен с инструментами для разработки на .NET
  - **NuGet-пакеты:** установлен `Microsoft.Data.SqlClient` в проекте

- **Настройка базы данных:**
  - **Имя базы данных:** `Lab12ado`
  - **Таблица:** `Go_club` со следующей схемой:
  
    | Название столбца | Тип данных        | Ограничения           |
    |------------------|-------------------|-----------------------|
    | club_id          | UNIQUEIDENTIFIER | PRIMARY KEY           |
    | название         | NVARCHAR(100)    | NOT NULL              |
    | адрес            | NVARCHAR(200)    | NOT NULL              |
    | регион           | TINYINT          | NOT NULL              |
    | рейтинг          | SMALLINT         | NOT NULL              |

- **Конфигурация:**
  - **`app.config`:** правильно настроен с указанием строки подключения.

## Настройка

1. **Клонирование репозитория:**
   ```bash
   git clone <ссылка на репозиторий>
   cd ADOnetApp
   ```

2. **Настройка `app.config`:**
   
   Убедитесь, что файл `app.config` настроен корректно с учетом данных вашего SQL Server. Пример:
   
   ```xml
   <?xml version="1.0" encoding="utf-8" ?>
   <configuration>
       <startup>
           <supportedRuntime version="v4.0" sku=".NETFramework,Version=v4.5" />
       </startup>
       <connectionStrings>
           <add name="AdoConnString"
                providerName="Microsoft.Data.SqlClient"
                connectionString="Server=LAPTOP-96TT95U4;Initial Catalog=Lab12ado;Integrated Security=True;Encrypt=True;TrustServerCertificate=True"/>
       </connectionStrings>
   </configuration>
   ```
   
   **Примечание:**
   - Замените `LAPTOP-96TT95U4` на имя вашего сервера.
   - Убедитесь, что `Encrypt=True;TrustServerCertificate=True;` установлены для обработки проблем с SSL-сертификатами во время разработки.

3. **Восстановление пакетов NuGet:**
   ```bash
   dotnet restore
   ```

4. **Сборка проекта:**
   ```bash
   dotnet build
   ```
   
   Убедитесь, что ошибок сборки нет. Предупреждения, связанные с обработкой `null`, можно устранить позже. -->

## Запуск приложения

Запустите приложение с помощью следующей команды:

```bash
dotnet run
```

После успешного запуска вы должны увидеть:

```
Connected level
Type 'help' for help
>
```
# ниже тестирование для `Program_v2.sc`
## Тестирование подключенного уровня

### 1. Просмотр всех таблиц

**Цель:** Убедиться, что приложение может вывести список всех таблиц в базе данных `Lab12ado`.

**Шаги:**

1. Введите:
   ```
   s
   ```
2. Когда появится запрос `->tables | * | column:`, введите:
   ```
   tables
   ```

**Ожидаемый результат:**

- Приложение отображает список всех таблиц в базе данных, включая `Go_club`.

**Пример вывода:**
```
	dbo	Go_club
	dbo	AnotherTable
	...
```

### 2. Просмотр всех записей в таблице

**Цель:** Убедиться, что приложение может получить и отобразить все записи из указанной таблицы.

**Шаги:**

1. Введите:
   ```
   s
   ```
2. Когда появится запрос `->tables | * | column:`, введите:
   ```
   *
   ```
3. Когда появится запрос `->tablename:`, введите:
   ```
   Go_club
   ```

**Ожидаемый результат:**

- Приложение отображает все записи из таблицы `Go_club` в табличном формате.

**Пример вывода:**
```
	E0E2A65F-3F4A-4B9A-8F36-2E7D6A1B9C3D	Go Club A	ул. Примерная, д. 1	1	85
	A1B2C3D4-E5F6-7890-1234-56789ABCDEF0	Go Club B	пр. Тестовый, д. 10	2	90
	12345678-90AB-CDEF-1234-567890ABCDEF	Go Club C	ул. Демонстрационная, д. 5	3	75
	...
```

### 3. Просмотр данных из определенного столбца

**Цель:** Убедиться, что приложение может получить и отобразить данные из указанного столбца таблицы.

**Шаги:**

1. Введите:
   ```
   s
   ```
2. Когда появится запрос `->tables | * | column:`, введите:
   ```
   column
   ```
3. Когда появится запрос `->tablename:`, введите:
   ```
   Go_club
   ```
4. Когда появится запрос `-->column name:`, введите:
   ```
   name
   ```

**Ожидаемый результат:**

- Приложение отображает все значения из столбца `name` таблицы `Go_club`.

**Пример вывода:**
```
	Go Club A
	Go Club B
	Go Club C
	...
```

### 4. Добавление новой записи

**Цель:** Проверить возможность добавления новой записи в таблицу `Go_club`.

**Шаги:**

1. Введите:
   ```
   i
   ```
2. Когда появится запрос `->tablename:`, введите:
   ```
   Go_club
   ```
3. Введите значения для каждого поля:
   ```
   -->club_id: E1F2G3H4-I5J6-K7L8-M9N0-O1P2Q3R4S5T6
   -->название: Go Club D
   -->адрес: ул. Новая, д. 20
   -->регион: 4
   -->рейтинг: 1000
   ```

<!-- **Ожидаемый результат:**

- Приложение подтверждает, что запись добавлена.
- Проверьте в SSMS, что новая запись существует в таблице `Go_club`. -->

<!-- **Пример вывода:**
```
Q: INSERT INTO [Go_club] ([club_id], [название], [адрес], [регион], [рейтинг]) VALUES (@club_id, @название, @адрес, @регион, @рейтинг)
Entry has been inserted.
``` -->

### 5. Удаление записи

**Цель:** Убедиться, что приложение может удалить запись на основе указанных пользователем критериев.

**Шаги:**

1. Введите:
   ```
   d
   ```
2. Когда появится запрос `->tablename:`, введите:
   ```
   Go_club
   ```
3. Для каждого столбца решите, использовать ли его в качестве критерия удаления (`Y/N`). Например:
   ```
   -->Delete by club_id? Y/N: Y
   -->club_id[uniqueidentifier] value: E1F2G3H4-I5J6-K7L8-M9N0-O1P2Q3R4S5T6
   -->Delete by название? Y/N: N
   -->Delete by адрес? Y/N: N
   -->Delete by регион? Y/N: N
   -->Delete by рейтинг? Y/N: N
   ```

<!-- **Ожидаемый результат:**

- Приложение подтверждает, что запись была удалена.
- Проверьте в SSMS, что указанной записи больше нет в таблице `Go_club`.

**Пример вывода:**
```
Q: DELETE FROM [Go_club] WHERE [club_id] = @club_id
Entry(-ies) has been deleted.
``` -->

### 6. Обновление записи

**Цель:** Проверить возможность обновления существующих записей на основе указанных пользователем критериев.

**Шаги:**

1. Введите:
   ```
   u
   ```
2. Когда появится запрос `->tablename:`, введите:
   ```
   Go_club
   ```
3. Для каждого столбца решите, обновлять ли его (`Y/N`). Например:
   ```
   -->Modify club_id? Y/N: N
   -->Modify название? Y/N: Y
   -->название[new value]: Go Club Updated
   -->Modify адрес? Y/N: N
   -->Modify регион? Y/N: N
   -->Modify рейтинг? Y/N: N
   ```
4. Для каждого столбца решите, использовать ли его в качестве условия для обновления (`Y/N`). Например:
   ```
   -->Update by club_id? Y/N: Y
   -->club_id[uniqueidentifier] value: E0E2A65F-3F4A-4B9A-8F36-2E7D6A1B9C3D
   -->Update by название? Y/N: N
   -->Update by адрес? Y/N: N
   -->Update by регион? Y/N: N
   -->Update by рейтинг? Y/N: N
   ```

<!-- **Ожидаемый результат:**

- Приложение подтверждает, что запись была обновлена.
- Проверьте в SSMS, что поле `название` указанной записи обновлено.

**Пример вывода:**
```
Q: UPDATE [Go_club] SET [название] = @new_название WHERE [club_id] = @old_club_id
Entry(-ies) has been updated.
``` -->

<!-- ### 7. Выполнение произвольного SQL-запроса

**Цель:** Убедиться, что приложение может выполнять произвольные SQL-запросы и отображать их результаты.

**Шаги:**

1. Введите:
   ```
   e
   ```
2. Когда появится запрос `-> Enter explicit query:`, введите:
   ```
   SELECT COUNT(*) FROM Go_club
   ``` -->

<!-- **Ожидаемый результат:**

- Приложение отображает результат выполнения запроса.

**Пример вывода:**
```
Q: SELECT COUNT(*) FROM Go_club
	3
``` -->

### 7. Команда помощи

**Цель:** Убедиться, что команда помощи отображает все доступные команды и их описания.

**Шаги:**

1. Введите:
   ```
   h
   ```

**Ожидаемый результат:**

- Приложение отображает список доступных команд с кратким описанием.

**Пример вывода:**
```
Available commands:
	s - Select operations
	i - Insert a new entry
	d - Delete an entry
	u - Update an entry
	e - Execute an explicit SQL query
	h - Help
	q - Quit / Switch to Disconnected level
```

## Тестирование отключенного уровня

После перехода на отключенный уровень с помощью команды `q` выполните следующие шаги для проверки его функциональности.

### 1. Просмотр всех записей

**Цель:** Убедиться, что приложение может отображать все записи из таблицы `Go_club` с использованием `DataSet`.

**Шаги:**

1. После ввода команды `q` и перехода на отключенный уровень вы должны увидеть:
   ```
   Disconnected level
   Type 'help' for help
   >
   ```
2. Введите:
   ```
   s
   ```

**Ожидаемый результат:**

- Все записи из таблицы `Go_club` отображаются.

**Пример вывода:**
```
SELECT * FROM Go_club
	E0E2A65F-3F4A-4B9A-8F36-2E7D6A1B9C3D	Go Club A	ул. Примерная, д. 1	1	85
	A1B2C3D4-E5F6-7890-1234-56789ABCDEF0	Go Club B	пр. Тестовый, д. 10	2	90
	12345678-90AB-CDEF-1234-567890ABCDEF	Go Club C	ул. Демонстрационная, д. 5	3	75
	...
```

### 2. Добавление новой записи

**Цель:** Проверить добавление новой записи в `DataSet` без немедленного сохранения изменений в базе данных.

**Шаги:**

1. Введите:
   ```
   i
   ```
2. Введите значения для каждого поля:
   ```
   ->club_id: E1F2G3H4-I5J6-K7L8-M9N0-O1P2Q3R4S5T6
   ->название: Go Club D
   ->адрес: ул. Новая, д. 20
   ->регион: 4
   ->рейтинг: 80
   ```

**Ожидаемый результат:**

- Приложение подтверждает, что строка добавлена в `DataSet`.
- Новая запись видна в приложении, но еще не добавлена в базу данных.

**Пример вывода:**
```
Row has been added.
```

### 3. Удаление записи по первичному ключу

**Цель:** Убедиться, что приложение может пометить запись для удаления в `DataSet` без немедленного удаления из базы данных.

**Шаги:**

1. Введите:
   ```
   d
   ```
2. Когда появится запрос `->by PrimaryKey club_id:`, введите:
   ```
   E0E2A65F-3F4A-4B9A-8F36-2E7D6A1B9C3D
   ```

**Ожидаемый результат:**

- Приложение подтверждает, что строка помечена для удаления.
- Указанная запись больше не отображается в приложении, но все еще существует в базе данных до принятия изменений.

**Пример вывода:**
```
Row has been deleted.
```

### 4. Обновление рейтинга записи по первичному ключу

**Цель:** Проверить обновление определенного поля записи в `DataSet` без немедленного сохранения изменений в базе данных.

**Шаги:**

1. Введите:
   ```
   u
   ```
2. Когда появится запрос `->by PrimaryKey club_id:`, введите:
   ```
   A1B2C3D4-E5F6-7890-1234-56789ABCDEF0
   ```
3. Когда появится запрос `->new рейтинг:`, введите:
   ```
   95
   ```

**Ожидаемый результат:**

- Приложение подтверждает, что строка обновлена в `DataSet`.
- Обновленный рейтинг виден в приложении, но изменения еще не применены к базе данных.

**Пример вывода:**
```
Row has been updated.
```

### 5. Принятие изменений в базе данных

**Цель:** Убедиться, что все отложенные изменения в `DataSet` (вставки, удаления, обновления) правильно применяются к базе данных.

**Шаги:**

1. Введите:
   ```
   a
   ```

**Ожидаемый результат:**

- Приложение подтверждает, что изменения были приняты и применены к базе данных.
- Проверьте в SSMS:
  - Новая запись (`Go Club D`) существует.
  - Указанная запись была удалена.
  - Рейтинг записи `Go Club B` обновлен до `95`.

**Пример вывода:**
```
Changes have been accepted.
```

### 6. Команда помощи

**Цель:** Убедиться, что команда помощи отображает все доступные команды отключенного уровня с их описаниями.

**Шаги:**

1. Введите:
   ```
   h
   ```

**Ожидаемый результат:**

- Приложение отображает список доступных команд с кратким описанием.

**Пример вывода:**
```
Available commands:
	s - Select all entries
	i - Insert a new entry
	d - Delete an entry by PrimaryKey
	u - Update an entry's рейтинг by PrimaryKey
	a - Accept changes to the database
	h - Help
	q - Quit
```

---



