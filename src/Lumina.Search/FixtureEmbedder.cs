using Npgsql;
using Pgvector;

namespace Lumina.Search;

/// <summary>
/// The book's offline stand-in for a real embedding model. Instead of calling
/// an API, it borrows the stored fixture vector of the seeded article nearest
/// in topic to the query text, which keeps the companion demo deterministic
/// and free of API keys. It is honest about what it is: ModelName reports the
/// same 'book-fixture-det-v1' label the seed data carries, and a production
/// system replaces this one class with an HTTP-backed embedder without
/// touching anything else in Lumina.Search.
/// </summary>
public sealed class FixtureEmbedder(NpgsqlDataSource source) : IEmbedder
{
    public string ModelName => "book-fixture-det-v1";

    public async Task<Vector> EmbedAsync(string text, CancellationToken ct = default)
    {
        // Keyword routing onto the fixture corpus: enough to make the demo
        // meaningful, and obviously not an embedding model. The chapter's
        // running query ("scanner keeps grabbing two pages at a time") routes
        // to the document-feeder article, exactly as the SQL listings do.
        var anchor =
            text.Contains("page", StringComparison.OrdinalIgnoreCase) ||
            text.Contains("feed", StringComparison.OrdinalIgnoreCase) ||
            text.Contains("printer", StringComparison.OrdinalIgnoreCase)
                ? "Document feeder%"
                : "%";

        const string sql = """
            SELECT embedding
            FROM kb_article
            WHERE title LIKE $1
            ORDER BY id
            LIMIT 1;
            """;

        await using var command = source.CreateCommand(sql);
        command.Parameters.AddWithValue(anchor);
        var stored = await command.ExecuteScalarAsync(ct);
        return (Vector)stored!;
    }
}
