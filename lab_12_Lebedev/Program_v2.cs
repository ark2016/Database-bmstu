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

                Console.WriteLine("Connected level");
                Console.WriteLine("Type 'help' for help");

                string com;
                while (true)
                {
                    Console.Write(">");
                    com = Console.ReadLine();
                    if (string.IsNullOrWhiteSpace(com))
                        continue;

                    switch (com.ToLower())
                    {
                        case "s":
                            Console.Write("->tables | * | column | t: ");
                            string subcom = Console.ReadLine();
                            if (string.IsNullOrWhiteSpace(subcom))
                                continue;

                            switch (subcom.ToLower())
                            {
                                case "tables":
                                    string qTables = "SELECT TABLE_SCHEMA, TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE'";
                                    using (SqlConnection connection = new SqlConnection(connectionString))
                                    {
                                        connection.Open();
                                        SqlCommand cmd = new SqlCommand(qTables, connection);
                                        Exec(cmd);
                                    }
                                    break;

                                case "*":
                                    Console.Write("->tablename: ");
                                    string tableAll = Console.ReadLine();
                                    if (!CheckTableExists(tableAll, connectionString))
                                    {
                                        Console.WriteLine("Table does not exist.");
                                        continue;
                                    }
                                    string qAll = $"SELECT * FROM [{tableAll}]";
                                    using (SqlConnection connection = new SqlConnection(connectionString))
                                    {
                                        connection.Open();
                                        SqlCommand cmdAll = new SqlCommand(qAll, connection);
                                        Exec(cmdAll);
                                    }
                                    break;

                                case "column":
                                    Console.Write("->tablename: ");
                                    string tableCol = Console.ReadLine();
                                    if (!CheckTableExists(tableCol, connectionString))
                                    {
                                        Console.WriteLine("Table does not exist.");
                                        continue;
                                    }
                                    Console.Write("-->column name: ");
                                    string columnName = Console.ReadLine();
                                    if (!CheckColumnExists(tableCol, columnName, connectionString))
                                    {
                                        Console.WriteLine("Column does not exist.");
                                        continue;
                                    }
                                    string qCol = $"SELECT [{columnName}] FROM [{tableCol}]";
                                    using (SqlConnection connection = new SqlConnection(connectionString))
                                    {
                                        connection.Open();
                                        SqlCommand cmdCol = new SqlCommand(qCol, connection);
                                        Exec(cmdCol);
                                    }
                                    break;

                                case "t":
                                    // Новая команда 't' для демонстрации функционала
                                    DemonstrateFunctionality(connectionString);
                                    break;

                                default:
                                    Console.WriteLine("Unknown subcommand.");
                                    break;
                            }
                            break;

                        case "i":
                            Console.Write("->tablename: ");
                            string tableInsert = Console.ReadLine();
                            if (!CheckTableExists(tableInsert, connectionString))
                            {
                                Console.WriteLine("Table does not exist.");
                                continue;
                            }

                            // Получение схемы таблицы
                            List<string> columns = new List<string>();
                            List<string> parameters = new List<string>();
                            Dictionary<string, string> columnTypes = new Dictionary<string, string>();

                            using (SqlConnection connection = new SqlConnection(connectionString))
                            {
                                connection.Open();
                                DataTable schema = connection.GetSchema("Columns", new string[] { null, null, tableInsert });
                                foreach (DataRow row in schema.Rows)
                                {
                                    string columnName = row["COLUMN_NAME"].ToString();
                                    string dataType = row["DATA_TYPE"].ToString();
                                    columns.Add($"[{columnName}]");
                                    parameters.Add($"@{columnName}");
                                    columnTypes.Add(columnName, dataType);
                                }

                                string columnsJoined = string.Join(", ", columns);
                                string parametersJoined = string.Join(", ", parameters);
                                string qInsert = $"INSERT INTO [{tableInsert}] ({columnsJoined}) VALUES ({parametersJoined})";
                                Console.WriteLine($"Q: {qInsert}");

                                SqlCommand cmdInsert = new SqlCommand(qInsert, connection);

                                foreach (var col in columns)
                                {
                                    string colName = col.Trim('[', ']');
                                    Console.Write($"-->{colName}: ");
                                    string input = Console.ReadLine();
                                    cmdInsert.Parameters.AddWithValue($"@{colName}", string.IsNullOrEmpty(input) ? DBNull.Value : input);
                                }

                                if (Run(cmdInsert) == 0)
                                    Console.WriteLine("Entry has been inserted.");
                            }
                            break;

                        case "d":
                            Console.Write("->tablename: ");
                            string tableDelete = Console.ReadLine();
                            if (!CheckTableExists(tableDelete, connectionString))
                            {
                                Console.WriteLine("Table does not exist.");
                                continue;
                            }

                            // Получение схемы таблицы
                            List<string> delColumns = new List<string>();
                            Dictionary<string, string> delColumnTypes = new Dictionary<string, string>();

                            using (SqlConnection connection = new SqlConnection(connectionString))
                            {
                                connection.Open();
                                DataTable schema = connection.GetSchema("Columns", new string[] { null, null, tableDelete });
                                foreach (DataRow row in schema.Rows)
                                {
                                    string columnName = row["COLUMN_NAME"].ToString();
                                    string dataType = row["DATA_TYPE"].ToString();
                                    delColumns.Add(columnName);
                                    delColumnTypes.Add(columnName, dataType);
                                }

                                string qDelete = $"DELETE FROM [{tableDelete}] WHERE ";
                                List<string> conditions = new List<string>();
                                SqlCommand cmdDelete = new SqlCommand();
                                cmdDelete.Connection = connection;

                                foreach (var col in delColumns)
                                {
                                    Console.Write($"-->Delete by {col}? Y/N: ");
                                    string t_com = Console.ReadLine();
                                    if (t_com.Equals("Y", StringComparison.OrdinalIgnoreCase))
                                    {
                                        Console.Write($"-->{col}[{delColumnTypes[col]}] value: ");
                                        string value = Console.ReadLine();
                                        conditions.Add($"[{col}] = @{col}");
                                        cmdDelete.Parameters.AddWithValue($"@{col}", string.IsNullOrEmpty(value) ? DBNull.Value : value);
                                    }
                                }

                                if (conditions.Count == 0)
                                {
                                    Console.WriteLine("Delete parameters are missing.");
                                    continue;
                                }

                                qDelete += string.Join(" AND ", conditions);
                                cmdDelete.CommandText = qDelete;
                                Console.WriteLine($"Q: {qDelete}");

                                if (Run(cmdDelete) == 0)
                                    Console.WriteLine("Entry(-ies) has been deleted.");
                            }
                            break;

                        case "u":
                            Console.Write("->tablename: ");
                            string tableUpdate = Console.ReadLine();
                            if (!CheckTableExists(tableUpdate, connectionString))
                            {
                                Console.WriteLine("Table does not exist.");
                                continue;
                            }

                            // Получение схемы таблицы
                            List<string> updateColumns = new List<string>();
                            Dictionary<string, string> updateColumnTypes = new Dictionary<string, string>();

                            using (SqlConnection connection = new SqlConnection(connectionString))
                            {
                                connection.Open();
                                DataTable schema = connection.GetSchema("Columns", new string[] { null, null, tableUpdate });
                                foreach (DataRow row in schema.Rows)
                                {
                                    string columnName = row["COLUMN_NAME"].ToString();
                                    string dataType = row["DATA_TYPE"].ToString();
                                    updateColumns.Add(columnName);
                                    updateColumnTypes.Add(columnName, dataType);
                                }

                                // Выбор столбцов для обновления
                                List<string> setConditions = new List<string>();
                                SqlCommand cmdUpdate = new SqlCommand();
                                cmdUpdate.Connection = connection;

                                foreach (var col in updateColumns)
                                {
                                    Console.Write($"-->Modify {col}? Y/N: ");
                                    string t_com = Console.ReadLine();
                                    if (t_com.Equals("Y", StringComparison.OrdinalIgnoreCase))
                                    {
                                        Console.Write($"-->{col}[{updateColumnTypes[col]}] new value: ");
                                        string newValue = Console.ReadLine();
                                        setConditions.Add($"[{col}] = @new_{col}");
                                        cmdUpdate.Parameters.AddWithValue($"@new_{col}", string.IsNullOrEmpty(newValue) ? DBNull.Value : newValue);
                                    }
                                }

                                if (setConditions.Count == 0)
                                {
                                    Console.WriteLine("No columns selected for update.");
                                    continue;
                                }

                                // Выбор условий для обновления
                                List<string> whereConditions = new List<string>();
                                foreach (var col in updateColumns)
                                {
                                    Console.Write($"-->Update by {col}? Y/N: ");
                                    string t_com = Console.ReadLine();
                                    if (t_com.Equals("Y", StringComparison.OrdinalIgnoreCase))
                                    {
                                        Console.Write($"-->{col}[{updateColumnTypes[col]}] value: ");
                                        string value = Console.ReadLine();
                                        whereConditions.Add($"[{col}] = @old_{col}");
                                        cmdUpdate.Parameters.AddWithValue($"@old_{col}", string.IsNullOrEmpty(value) ? DBNull.Value : value);
                                    }
                                }

                                if (whereConditions.Count == 0)
                                {
                                    Console.WriteLine("Update conditions are missing.");
                                    continue;
                                }

                                string qUpdate = $"UPDATE [{tableUpdate}] SET {string.Join(", ", setConditions)} WHERE {string.Join(" AND ", whereConditions)}";
                                cmdUpdate.CommandText = qUpdate;
                                Console.WriteLine($"Q: {qUpdate}");

                                if (Run(cmdUpdate) == 0)
                                    Console.WriteLine("Entry(-ies) has been updated.");
                            }
                            break;

                        case "t":
                            // Новая команда 't' для демонстрации функционала
                            Console.WriteLine("Демонстрация функционала:");
                            DemonstrateFunctionality(connectionString);
                            break;

                        // case "e":
                        //     Console.Write("-> Enter explicit query: ");
                        //     string explicitQuery = Console.ReadLine();
                        //     if (string.IsNullOrWhiteSpace(explicitQuery))
                        //     {
                        //         Console.WriteLine("Empty query.");
                        //         continue;
                        //     }
                        //     using (SqlConnection connection = new SqlConnection(connectionString))
                        //     {
                        //         connection.Open();
                        //         SqlCommand cmdExplicit = new SqlCommand(explicitQuery, connection);
                        //         Exec(cmdExplicit);
                        //     }
                        //     break;

                        case "h":
                            Console.WriteLine("Available commands:");
                            Console.WriteLine("\ts - Select operations");
                            Console.WriteLine("\ti - Insert a new entry");
                            Console.WriteLine("\td - Delete an entry");
                            Console.WriteLine("\tu - Update an entry");
                            Console.WriteLine("\tt - Demonstrate functionality");
                            // Console.WriteLine("\te - Execute an explicit SQL query");
                            Console.WriteLine("\th - Help");
                            Console.WriteLine("\tq - Quit / Switch to Disconnected level");
                            break;

                        case "q":
                            goto SwitchToDisconnected;

                        default:
                            Console.WriteLine("Unknown command. Type 'h' for help.");
                            break;
                    }
                }

            SwitchToDisconnected:
                Console.WriteLine("Exit = [q]");
                Console.WriteLine("Switch to Disconnected level. Press any key to continue...");
                string switchCom = Console.ReadLine();
                if (switchCom.Equals("q", StringComparison.OrdinalIgnoreCase))
                {
                    Console.WriteLine("Closing application.");
                    return;
                }

                Console.WriteLine("\nDisconnected level");
                Console.WriteLine("Type 'help' for help");

                // Настройка DataSet и SqlDataAdapter
                DataSet cds = new DataSet("cds");
                string mainTable = "Go_club";

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

                    while (true)
                    {
                        Console.Write(">");
                        com = Console.ReadLine();
                        if (string.IsNullOrWhiteSpace(com))
                            continue;

                        switch (com.ToLower())
                        {
                            case "s":
                                Console.WriteLine($"SELECT * FROM {mainTable}");
                                PrintTable(cds.Tables[mainTable]);
                                break;

                            case "i":
                                Console.Write("->club_id: ");
                                if (!Guid.TryParse(Console.ReadLine(), out Guid club_id))
                                {
                                    Console.WriteLine("Неверный формат GUID.");
                                    continue;
                                }

                                Console.Write("->название: ");
                                string name = Console.ReadLine();

                                Console.Write("->адрес: ");
                                string adress = Console.ReadLine();

                                Console.Write("->регион: ");
                                if (!byte.TryParse(Console.ReadLine(), out byte region))
                                {
                                    Console.WriteLine("Неверный формат региона.");
                                    continue;
                                }

                                Console.Write("->рейтинг: ");
                                if (!short.TryParse(Console.ReadLine(), out short rating))
                                {
                                    Console.WriteLine("Неверный формат рейтинга.");
                                    continue;
                                }

                                DataRow newRow = dt.NewRow();
                                newRow["club_id"] = club_id;
                                newRow["name"] = name;
                                newRow["adress"] = adress;
                                newRow["region"] = region;
                                newRow["rating"] = rating;

                                try
                                {
                                    dt.Rows.Add(newRow);
                                    Console.WriteLine("Row has been added.");
                                }
                                catch (Exception e)
                                {
                                    Console.WriteLine($"Ошибка при добавлении строки: {e.Message}");
                                }
                                break;

                            case "d":
                                Console.Write("->by PrimaryKey club_id: ");
                                if (!Guid.TryParse(Console.ReadLine(), out Guid del_club_id))
                                {
                                    Console.WriteLine("Неверный формат GUID.");
                                    continue;
                                }

                                DataRow delRow = dt.Rows.Find(del_club_id);
                                if (delRow != null)
                                {
                                    try
                                    {
                                        delRow.Delete();
                                        Console.WriteLine("Row has been deleted.");
                                    }
                                    catch (Exception e)
                                    {
                                        Console.WriteLine($"Ошибка при удалении строки: {e.Message}");
                                    }
                                }
                                else
                                {
                                    Console.WriteLine("Row not found.");
                                }
                                break;

                            case "u":
                                Console.Write("->by PrimaryKey club_id: ");
                                if (!Guid.TryParse(Console.ReadLine(), out Guid upd_club_id))
                                {
                                    Console.WriteLine("Неверный формат GUID.");
                                    continue;
                                }

                                DataRow updRow = dt.Rows.Find(upd_club_id);
                                if (updRow != null)
                                {
                                    Console.Write("->new рейтинг: ");
                                    if (!short.TryParse(Console.ReadLine(), out short newRating))
                                    {
                                        Console.WriteLine("Неверный формат рейтинга.");
                                        continue;
                                    }

                                    try
                                    {
                                        updRow["rating"] = newRating;
                                        Console.WriteLine("Row has been updated.");
                                    }
                                    catch (Exception e)
                                    {
                                        Console.WriteLine($"Ошибка при обновлении строки: {e.Message}");
                                    }
                                }
                                else
                                {
                                    Console.WriteLine("Row not found.");
                                }
                                break;

                            case "a":
                                try
                                {
                                    adapter.Update(cds, dt.TableName);
                                    Console.WriteLine("Changes have been accepted.");
                                }
                                catch (Exception e)
                                {
                                    Console.WriteLine($"Ошибка при применении изменений: {e.Message}");
                                }
                                break;

                            case "h":
                                Console.WriteLine("Available commands:");
                                Console.WriteLine("\ts - Select all entries");
                                Console.WriteLine("\ti - Insert a new entry");
                                Console.WriteLine("\td - Delete an entry by PrimaryKey");
                                Console.WriteLine("\tu - Update an entry's rating by PrimaryKey");
                                Console.WriteLine("\ta - Accept changes to the database");
                                Console.WriteLine("\th - Help");
                                Console.WriteLine("\tq - Quit");
                                break;

                            case "q":
                                Console.WriteLine("Closing application.");
                                return;

                            default:
                                Console.WriteLine("Unknown command. Type 'h' for help.");
                                break;
                        }
                    }
                }
            }
            catch (Exception e)
            {
                Console.WriteLine($"Необработанное исключение: {e.Message}");
                Console.ReadLine();
            }
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

    }
}
