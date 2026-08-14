using Npgsql;

namespace Lumina.Data;

public static class InsertDemo
{
    public static async Task<(long Id, string Reference)> CreateTicketAsync(
        NpgsqlDataSource source)
    {
        // RETURNING (Chapter 3) hands back the generated id in the same round
        // trip as the INSERT — no second SELECT, no race to read your own write.
        const string sql = """
            INSERT INTO ticket (reference, customer_id, team_id, subject, body,
                                status, priority, channel, created_at)
            VALUES ($1, $2, $3, $4, $5, 'open', 'normal', 'email',
                    '2026-01-15 09:00:00+00')
            RETURNING id, reference;
            """;

        await using var command = source.CreateCommand(sql);
        command.Parameters.AddWithValue("LUM-90001");
        command.Parameters.AddWithValue(2L);
        command.Parameters.AddWithValue(2L);
        command.Parameters.AddWithValue("Card declined on enterprise renewal");
        command.Parameters.AddWithValue("Our renewal payment was declined this morning.");

        await using var reader = await command.ExecuteReaderAsync();
        await reader.ReadAsync();
        var id = reader.GetInt64(0);
        var reference = reader.GetString(1);

        Console.WriteLine($"Created ticket {reference} with id {id} in one round trip.");
        return (id, reference);
    }
}
