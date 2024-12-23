using System;
using System.Data;
using Microsoft.Data.SqlClient;
using System.Configuration;
using System.Collections.Generic;

namespace ADOnet
{
    class Program
    {
        /// Проверяет существование таблицы в базе данных.
        static bool CheckTableExists(string table, string connectionString)
        {
            try
            {
                using (SqlConnection connection = new SqlConnection(connectionString))
                {
                    connection.Open();
                    DataTable schema = connection.GetSchema("Tables", new string[] { null, null, table, "BASE TABLE" });
                    return schema.Rows.Count > 0;
                }
            }
            catch (Exception e)
            {
                Console.WriteLine($"Ошибка при проверке таблицы: {e.Message}");
                return false;
            }
        }
        /// Проверяет существование столбца в таблице.
        static bool CheckColumnExists(string table, string column, string connectionString)
        {
            try
            {
                using (SqlConnection connection = new SqlConnection(connectionString))
                {
                    connection.Open();
                    DataTable schema = connection.GetSchema("Columns", new string[] { null, null, table, column });
                    return schema.Rows.Count > 0;
                }
            }
            catch (Exception e)
            {
                Console.WriteLine($"Ошибка при проверке столбца: {e.Message}");
                return false;
            }
        }
        /// Выполняет команду SQL, не возвращающую результаты.
        static int Run(SqlCommand command)
        {
            try
            {
                command.ExecuteNonQuery();
                return 0;
            }
            catch (SqlException e)
            {
                Console.WriteLine($"SQL ошибка: {e.Message}");
                return -1;
            }
        }
        /// Выполняет команду SQL, возвращающую результаты, и выводит их.
        static void Exec(SqlCommand command)
        {
            try
            {
                using (SqlDataReader reader = command.ExecuteReader())
                {
                    do
                    {
                        while (reader.Read())
                        {
                            for (int i = 0; i < reader.FieldCount; i++)
                            {
                                Console.Write($"\t{reader.GetValue(i)}");
                            }
                            Console.WriteLine();
                        }
                    } while (reader.NextResult());
                }
            }
            catch (Exception e)
            {
                Console.WriteLine($"Ошибка при выполнении команды: {e.Message}");
            }
            Console.WriteLine();
        }
        /// Выводит содержимое DataTable на консоль.
        static void PrintTable(DataTable dt)
        {
            foreach (DataRow row in dt.Rows)
            {
                foreach (var item in row.ItemArray)
                {
                    Console.Write($"\t{item}");
                }
                Console.WriteLine();
            }
            Console.WriteLine();
        }      
        /// Демонстрирует дополнительный функционал приложения.
        /// Например, выводит статистику по таблице Go_club.
        static void DemonstrateFunctionality(string connectionString)
        {
            try
            {
                using (SqlConnection connection = new SqlConnection(connectionString))
                {
                    connection.Open();

                    // Пример 1: Общее количество клубов
                    string qCount = "SELECT COUNT(*) FROM Go_club";
                    Console.WriteLine($"Выполняется запрос: {qCount}");
                    SqlCommand cmdCount = new SqlCommand(qCount, connection);
                    int count = (int)cmdCount.ExecuteScalar();
                    Console.WriteLine($"Общее количество клубов: {count}");

                    // Пример 2: Средний рейтинг
                    string qAvg = "SELECT AVG(CAST(rating AS FLOAT)) FROM Go_club";
                    Console.WriteLine($"\nВыполняется запрос: {qAvg}");
                    SqlCommand cmdAvg = new SqlCommand(qAvg, connection);
                    double avg = (double)cmdAvg.ExecuteScalar();
                    Console.WriteLine($"Средний рейтинг: {avg:F2}");

                    // Пример 3: Клуб с самым высоким рейтингом
                    string qMax = "SELECT TOP 1 name, rating FROM Go_club ORDER BY rating DESC";
                    Console.WriteLine($"\nВыполняется запрос: {qMax}");
                    SqlCommand cmdMax = new SqlCommand(qMax, connection);
                    using (SqlDataReader reader = cmdMax.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            string name = reader["name"].ToString();
                            short rating = (short)reader["rating"];
                            Console.WriteLine($"Клуб с самым высоким рейтингом: {name} ({rating})");
                        }
                    }

                    // Пример 4: Клубы по регионам
                    string qRegions = "SELECT region, COUNT(*) AS quantity FROM Go_club GROUP BY region ORDER BY region";
                    Console.WriteLine($"\nВыполняется запрос: {qRegions}");
                    SqlCommand cmdRegions = new SqlCommand(qRegions, connection);
                    using (SqlDataReader reader = cmdRegions.ExecuteReader())
                    {
                        Console.WriteLine("\nКлубы по регионам:");
                        Console.WriteLine("Регион\tКоличество");
                        while (reader.Read())
                        {
                            byte region = (byte)reader["region"];
                            int number = (int)reader["quantity"];
                            Console.WriteLine($"{region}\t{number}");
                        }
                    }
                }
            }
            catch (Exception e)
            {
                Console.WriteLine($"Ошибка при демонстрации функционала: {e.Message}");
            }
            Console.WriteLine();
        }       
        /// Тестовая функция для подключенного режима.
        /// Выполняет ряд операций для демонстрации функциональности.        
        static void TestConnectedMode(string connectionString)
        {
            Console.WriteLine("=== Тестирование Подключенного Режима ===\n");

            try
            {
                using (SqlConnection connection = new SqlConnection(connectionString))
                {
                    connection.Open();

                    // Тест 1: Вставка новой записи
                    Console.WriteLine("Тест 1: Вставка новой записи в Go_club");
                    string insertQuery = "INSERT INTO [Go_club] (club_id, name, adress, region, rating) VALUES (@club_id, @name, @adress, @region, @rating)";
                    SqlCommand insertCmd = new SqlCommand(insertQuery, connection);
                    Guid testClubId = Guid.NewGuid();
                    insertCmd.Parameters.AddWithValue("@club_id", testClubId);
                    insertCmd.Parameters.AddWithValue("@name", "Test Club Connected");
                    insertCmd.Parameters.AddWithValue("@adress", "Test Address Connected");
                    insertCmd.Parameters.AddWithValue("@region", 1);
                    insertCmd.Parameters.AddWithValue("@rating", 100);
                    Console.WriteLine($"Выполняется запрос: {insertQuery}");
                    if (Run(insertCmd) == 0)
                        Console.WriteLine("Вставлена тестовая запись.\n");

                    // Тест 2: Выборка вставленной записи
                    Console.WriteLine("Тест 2: Выборка вставленной записи");
                    string selectQuery = "SELECT * FROM [Go_club] WHERE club_id = @club_id";
                    SqlCommand selectCmd = new SqlCommand(selectQuery, connection);
                    selectCmd.Parameters.AddWithValue("@club_id", testClubId);
                    Console.WriteLine($"Выполняется запрос: {selectQuery}");
                    Exec(selectCmd);

                    // Тест 3: Обновление вставленной записи
                    Console.WriteLine("Тест 3: Обновление рейтинга вставленной записи до 200");
                    string updateQuery = "UPDATE [Go_club] SET rating = @rating WHERE club_id = @club_id";
                    SqlCommand updateCmd = new SqlCommand(updateQuery, connection);
                    updateCmd.Parameters.AddWithValue("@rating", 200);
                    updateCmd.Parameters.AddWithValue("@club_id", testClubId);
                    Console.WriteLine($"Выполняется запрос: {updateQuery}");
                    if (Run(updateCmd) == 0)
                        Console.WriteLine("Обновлена тестовая запись.\n");

                    // Тест 4: Удаление вставленной записи
                    Console.WriteLine("Тест 4: Удаление вставленной записи");
                    string deleteQuery = "DELETE FROM [Go_club] WHERE club_id = @club_id";
                    SqlCommand deleteCmd = new SqlCommand(deleteQuery, connection);
                    deleteCmd.Parameters.AddWithValue("@club_id", testClubId);
                    Console.WriteLine($"Выполняется запрос: {deleteQuery}");
                    if (Run(deleteCmd) == 0)
                        Console.WriteLine("Удалена тестовая запись.\n");
                }
            }
            catch (Exception e)
            {
                Console.WriteLine($"Ошибка в подключенном режиме: {e.Message}\n");
            }
        }        
        /// Тестовая функция для отключенного режима.
        /// Выполняет ряд операций с использованием DataSet и DataAdapter.
        static void TestDisconnectedMode(string connectionString)
        {
            Console.WriteLine("=== Тестирование Отключенного Режима ===\n");

            DataSet cds = new DataSet("cds");
            string mainTable = "Go_club";

            try
            {
                using (SqlConnection connection = new SqlConnection(connectionString))
                {
                    connection.Open();
                    SqlDataAdapter adapter = new SqlDataAdapter($"SELECT * FROM [{mainTable}]", connection);
                    SqlCommandBuilder builder = new SqlCommandBuilder(adapter);
                    adapter.Fill(cds, mainTable);
                    DataTable dt = cds.Tables[mainTable];

                    // Установка первичного ключа
                    try
                    {
                        DataColumn[] primary_key = new DataColumn[1];
                        primary_key[0] = dt.Columns["club_id"];
                        dt.PrimaryKey = primary_key;
                    }
                    catch (Exception e)
                    {
                        Console.WriteLine($"Ошибка при установке первичного ключа: {e.Message}");
                    }

                    // Тест 5: Добавление новой строки в DataSet
                    Console.WriteLine("Тест 5: Добавление новой строки в DataSet");
                    DataRow newRow = dt.NewRow();
                    Guid testClubId = Guid.NewGuid();
                    newRow["club_id"] = testClubId;
                    newRow["name"] = "Test Club Disconnected";
                    newRow["adress"] = "Test Address Disconnected";
                    newRow["region"] = 2;
                    newRow["rating"] = 150;
                    dt.Rows.Add(newRow);
                    Console.WriteLine("Добавлена новая строка в DataSet.\n");

                    // Тест 6: Модификация новой строки
                    Console.WriteLine("Тест 6: Изменение рейтинга новой строки на 250");
                    DataRow existingRow = dt.Rows.Find(testClubId);
                    if (existingRow != null)
                    {
                        existingRow["rating"] = 250;
                        Console.WriteLine("Изменена строка в DataSet.\n");
                    }
                    else
                    {
                        Console.WriteLine("Строка не найдена в DataSet.\n");
                    }

                    // Тест 7: Принятие изменений к базе данных
                    Console.WriteLine("Тест 7: Принятие изменений в базе данных");
                    adapter.Update(cds, dt.TableName);
                    Console.WriteLine("Изменения были приняты.\n");

                    // Проверка изменений
                    Console.WriteLine("Проверка изменений...");
                    cds.Clear();
                    adapter.Fill(cds, mainTable); // Перезаполняем DataSet
                    DataRow verifiedRow = dt.Rows.Find(testClubId);
                    if (verifiedRow != null)
                    {
                        Console.WriteLine("Проверена строка:");
                        Console.WriteLine($"\tclub_id: {verifiedRow["club_id"]}");
                        Console.WriteLine($"\tname: {verifiedRow["name"]}");
                        Console.WriteLine($"\tadress: {verifiedRow["adress"]}");
                        Console.WriteLine($"\tregion: {verifiedRow["region"]}");
                        Console.WriteLine($"\trating: {verifiedRow["rating"]}\n");
                    }
                    else
                    {
                        Console.WriteLine("Строка не найдена после обновления.\n");
                    }

                    // Очистка: Удаление тестовой строки
                    Console.WriteLine("Очистка: Удаление тестовой строки из базы данных");
                    verifiedRow = dt.Rows.Find(testClubId);
                    if (verifiedRow != null)
                    {
                        verifiedRow.Delete();
                        adapter.Update(cds, dt.TableName);
                        Console.WriteLine("Тестовая строка удалена.\n");
                    }
                    else
                    {
                        Console.WriteLine("Тестовая строка уже отсутствует.\n");
                    }
                }
            }
            catch (Exception e)
            {
                Console.WriteLine($"Ошибка в отключенном режиме: {e.Message}\n");
            }
        }

        static void Main(string[] args)
        {
            try
            {
                // Получение строки подключения из конфигурационного файла
                var connectionStringSettings = ConfigurationManager.ConnectionStrings["AdoConnString"];
                if (connectionStringSettings == null)
                {
                    Console.WriteLine("Строка подключения 'AdoConnString' не найдена в конфигурации.");
                    return;
                }
                string connectionString = connectionStringSettings.ConnectionString;

                Console.WriteLine("=== ADOnetApp - Тестирование ===\n");

                // Демонстрация функционала
                Console.WriteLine("=== Демонстрация дополнительного функционала ===");
                DemonstrateFunctionality(connectionString);

                // Тестирование подключенного режима
                TestConnectedMode(connectionString);

                // Тестирование отключенного режима
                TestDisconnectedMode(connectionString);

                Console.WriteLine("=== Тестирование завершено ===");
            }
            catch (Exception e)
            {
                Console.WriteLine($"Необработанное исключение: {e.Message}");
                Console.ReadLine();
            }
        }
    }
}
