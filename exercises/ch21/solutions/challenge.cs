// Solution to Exercise 21.3 — The PostgreSQL Handbook, Appendix D.
// Run against: scripts/reset-to-chapter.ps1 -Chapter 21
// Extends NPlusOneDemo (src/Lumina.Data) with the second cure; not in any csproj.
// Measured on the authoring machine at State 21 (warmed pool, dotnet run):
//   N+1 loop (1 + 40 queries):  20.0 ms   (120 comments)
//   Single join (1 query):       0.6 ms   (120 comments)  -> 33x
//   jsonb_agg  (1 query):   one round trip like the join; the widened query
//   itself measures ~4.9 ms in psql \timing, the document assembly being
//   the extra work the database now does for you.

using System.Diagnostics;
using Npgsql;

public static class NPlusOneCures
{
    // Cure 2: one query returning each ticket WITH its comments nested —
    // listing 21.14's shape, widened from one reference to all forty rows.
    public static async Task<int> JsonDocumentsAsync(NpgsqlDataSource source)
    {
        const string sql = """
            SELECT jsonb_build_object(
                       'reference', t.reference,
                       'subject',   t.subject,
                       'comments',  coalesce(
                           jsonb_agg(
                               jsonb_build_object('author', c.author_kind,
                                                  'body', c.body)
                               ORDER BY c.created_at
                           ) FILTER (WHERE c.id IS NOT NULL),
                           '[]'::jsonb)
                   ) AS document
            FROM ticket AS t
            LEFT JOIN ticket_comment AS c ON c.ticket_id = t.id
            WHERE t.id <= 40
            GROUP BY t.reference, t.subject
            ORDER BY t.reference;
            """;

        var documents = 0;
        await using var command = source.CreateCommand(sql);
        await using var reader = await command.ExecuteReaderAsync();
        while (await reader.ReadAsync())
            documents++;                      // each row is a complete JSON doc
        return documents;                     // 40
    }

    public static async Task CompareAllThreeAsync(NpgsqlDataSource source)
    {
        // Warm the pool first, exactly as CompareAsync does — otherwise the
        // first version measured pays connection setup for everyone.
        await NPlusOneDemo.NPlusOneAsync(source);
        await NPlusOneDemo.SingleJoinAsync(source);
        await JsonDocumentsAsync(source);

        var sw = Stopwatch.StartNew();
        await NPlusOneDemo.NPlusOneAsync(source);
        var loopMs = sw.Elapsed.TotalMilliseconds;

        sw.Restart();
        await NPlusOneDemo.SingleJoinAsync(source);
        var joinMs = sw.Elapsed.TotalMilliseconds;

        sw.Restart();
        await JsonDocumentsAsync(source);
        var jsonMs = sw.Elapsed.TotalMilliseconds;

        Console.WriteLine($"loop {loopMs:F1} ms | join {joinMs:F1} ms | jsonb {jsonMs:F1} ms");
    }
}

// Why the gap WIDENS off localhost: the loop pays the network 41 times,
// the single-query versions once. At ~0 ms localhost latency the demo shows
// a ~33x gap that is all per-query overhead; add 5 ms of real network and
// the loop gains 41 x 5 = 205 ms while the others gain 5 ms — the ratio
// grows with every millisecond of distance.
