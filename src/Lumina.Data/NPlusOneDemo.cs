using System.Diagnostics;
using Npgsql;

namespace Lumina.Data;

public static class NPlusOneDemo
{
    // The smell: one query for the list, then one more per row. 1 + N round
    // trips, each paying the network cost Chapter 20 measured.
    public static async Task<int> NPlusOneAsync(NpgsqlDataSource source)
    {
        var references = new List<string>();
        await using (var list = source.CreateCommand(
            "SELECT reference FROM ticket WHERE id <= 40 ORDER BY id;"))
        await using (var reader = await list.ExecuteReaderAsync())
        {
            while (await reader.ReadAsync())
                references.Add(reader.GetString(0));
        }

        var comments = 0;
        foreach (var reference in references)
        {
            await using var perTicket = source.CreateCommand(
                """
                SELECT count(*)
                FROM ticket_comment AS c
                JOIN ticket AS t ON t.id = c.ticket_id
                WHERE t.reference = $1;
                """);
            perTicket.Parameters.AddWithValue(reference);
            comments += (int)(long)(await perTicket.ExecuteScalarAsync())!;
        }
        return comments;
    }

    // The cure: one query that asks the database for the shape you actually
    // want. The join is SQL you already know — Chapter 7, unchanged.
    public static async Task<int> SingleJoinAsync(NpgsqlDataSource source)
    {
        const string sql = """
            SELECT t.reference, count(c.id) AS comment_count
            FROM ticket AS t
            LEFT JOIN ticket_comment AS c ON c.ticket_id = t.id
            WHERE t.id <= 40
            GROUP BY t.reference
            ORDER BY t.reference;
            """;

        var comments = 0;
        await using var command = source.CreateCommand(sql);
        await using var reader = await command.ExecuteReaderAsync();
        while (await reader.ReadAsync())
            comments += (int)reader.GetInt64(1);
        return comments;
    }

    public static async Task CompareAsync(NpgsqlDataSource source)
    {
        // Warm the pool and caches first so the comparison times queries, not startup.
        await NPlusOneAsync(source);
        await SingleJoinAsync(source);

        var sw = Stopwatch.StartNew();
        var a = await NPlusOneAsync(source);
        sw.Stop();
        var nPlusOne = sw.Elapsed.TotalMilliseconds;

        sw.Restart();
        var b = await SingleJoinAsync(source);
        sw.Stop();
        var single = sw.Elapsed.TotalMilliseconds;

        Console.WriteLine($"N+1 loop (1 + 40 queries): {nPlusOne,7:F1} ms  ({a} comments)");
        Console.WriteLine($"Single join (1 query):     {single,7:F1} ms  ({b} comments)");
        Console.WriteLine($"Speedup: {nPlusOne / single:F1}x fewer milliseconds, same answer.");
    }
}
