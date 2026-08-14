// Solution to Exercise 21.1 — The PostgreSQL Handbook, Appendix D.
// Run against: scripts/reset-to-chapter.ps1 -Chapter 21
// A method in the Lumina.Data idiom (src/Lumina.Data); not part of any csproj.
// SQL verified via psql: customer 2 has 5 open tickets at State 21.

using Npgsql;

public static class CustomerTicketsDemo
{
    public static async Task PrintOpenTicketsAsync(
        NpgsqlDataSource source, long customerId)
    {
        // The id travels as $1 — there is no correct version of this method
        // that builds the WHERE clause with string concatenation.
        const string sql = """
            SELECT reference, subject, priority::text
            FROM ticket
            WHERE customer_id = $1 AND status = 'open'
            ORDER BY reference;
            """;

        await using var command = source.CreateCommand(sql);
        command.Parameters.AddWithValue(customerId);
        await using var reader = await command.ExecuteReaderAsync();

        while (await reader.ReadAsync())
        {
            var reference = reader.GetString(0);
            var subject = reader.GetString(1);
            var priority = reader.GetString(2);
            Console.WriteLine($"{reference}  {priority,-6}  {subject}");
        }
    }
}

// PrintOpenTicketsAsync(source, 2) prints five rows, LUM-1036 first —
// priority::text in the SQL keeps the enum readable to the reader exactly
// as QueryDemo does.
