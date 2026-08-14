using Npgsql;

namespace Lumina.Data;

public static class QueryDemo
{
    public static async Task OpenTicketsAsync(NpgsqlDataSource source)
    {
        const string sql = """
            SELECT reference, subject, priority::text, first_response_at
            FROM ticket
            WHERE status = 'open'
            ORDER BY reference
            LIMIT 5;
            """;

        await using var command = source.CreateCommand(sql);
        await using var reader = await command.ExecuteReaderAsync();

        while (await reader.ReadAsync())
        {
            var reference = reader.GetString(0);
            var subject = reader.GetString(1);
            var priority = reader.GetString(2);

            // A nullable timestamptz becomes DateTimeOffset? — Chapter 4's NULL
            // rules crossing the wire. Ask before you read: GetFieldValue on a
            // NULL throws, exactly as reading a NULL as a non-null type should.
            var firstResponse = reader.IsDBNull(3)
                ? "(awaiting first response)"
                : reader.GetFieldValue<DateTimeOffset>(3).ToString("u");

            Console.WriteLine($"{reference}  {priority,-6}  {firstResponse}  {subject}");
        }
    }
}
