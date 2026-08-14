using Npgsql;
using Pgvector;

namespace Lumina.Search;

/// <summary>One knowledge-base search result: id, title, and the lane score
/// (cosine distance for semantic search, RRF score for hybrid).</summary>
public sealed record SearchHit(long Id, string Title, double Score);

/// <summary>
/// The Chapter 23 retriever. Three operations, in the order the chapter
/// builds them: ingest (embed at write time), semantic search (embed the
/// query, ORDER BY distance), and hybrid search (full-text and vector lanes
/// fused with reciprocal rank fusion). Every query vector travels as a bound
/// parameter — a 768-dimension literal never belongs in a SQL string.
/// </summary>
public sealed class KbSearch(NpgsqlDataSource source, IEmbedder embedder)
{
    // Embedding at ingestion: the vector is written WITH the row, and the
    // model's identity is written WITH the vector. Re-embedding under a new
    // model later means rewriting both columns together (Chapter 23 §2).
    public async Task<long> IngestAsync(
        string title, string body, long? ticketId = null,
        CancellationToken ct = default)
    {
        var embedding = await embedder.EmbedAsync($"{title}\n{body}", ct);

        const string sql = """
            INSERT INTO kb_article (ticket_id, title, body, embedding,
                                    embedding_model, created_at)
            VALUES ($1, $2, $3, $4, $5, '2026-01-15 09:00:00+00')
            RETURNING id;
            """;

        await using var command = source.CreateCommand(sql);
        command.Parameters.AddWithValue((object?)ticketId ?? DBNull.Value);
        command.Parameters.AddWithValue(title);
        command.Parameters.AddWithValue(body);
        command.Parameters.AddWithValue(embedding);        // Pgvector.Vector
        command.Parameters.AddWithValue(embedder.ModelName);

        return (long)(await command.ExecuteScalarAsync(ct))!;
    }

    // Embedding at query time: the user's words become a vector through the
    // SAME model that embedded the corpus, then the canonical kNN shape from
    // Chapter 23 §3 runs with the vector as a parameter.
    public async Task<IReadOnlyList<SearchHit>> SemanticAsync(
        string query, int k = 5, CancellationToken ct = default)
    {
        var queryEmbedding = await embedder.EmbedAsync(query, ct);

        const string sql = """
            SELECT id, title, (embedding <=> $1)::float8 AS distance
            FROM kb_article
            ORDER BY embedding <=> $1, id
            LIMIT $2;
            """;

        await using var command = source.CreateCommand(sql);
        command.Parameters.AddWithValue(queryEmbedding);
        command.Parameters.AddWithValue(k);

        var hits = new List<SearchHit>(k);
        await using var reader = await command.ExecuteReaderAsync(ct);
        while (await reader.ReadAsync(ct))
        {
            hits.Add(new SearchHit(
                reader.GetInt64(0), reader.GetString(1), reader.GetDouble(2)));
        }
        return hits;
    }

    // Chapter 23 §7's fusion query, verbatim, with the two lane inputs bound
    // as parameters: the user's embedding feeds the vector lane, the user's
    // WORDS feed the lexical lane. One user query, two representations.
    public async Task<IReadOnlyList<SearchHit>> HybridAsync(
        string query, int k = 8, CancellationToken ct = default)
    {
        var queryEmbedding = await embedder.EmbedAsync(query, ct);

        const string sql = """
            WITH vector_hits AS (
                SELECT id, title,
                       row_number() OVER (ORDER BY embedding <=> $1, id) AS rank
                FROM kb_article
                ORDER BY embedding <=> $1
                LIMIT 20
            ), lexical_hits AS (
                SELECT id, title,
                       row_number() OVER (
                           ORDER BY ts_rank(search_tsv,
                                            websearch_to_tsquery('english', $2))
                                    DESC, id
                       ) AS rank
                FROM kb_article
                WHERE search_tsv @@ websearch_to_tsquery('english', $2)
                LIMIT 20
            )
            SELECT id,
                   coalesce(v.title, l.title) AS title,
                   (coalesce(1.0 / (60 + v.rank), 0)
                  + coalesce(1.0 / (60 + l.rank), 0))::float8 AS rrf_score
            FROM vector_hits AS v
            FULL OUTER JOIN lexical_hits AS l USING (id)
            ORDER BY rrf_score DESC, id
            LIMIT $3;
            """;

        await using var command = source.CreateCommand(sql);
        command.Parameters.AddWithValue(queryEmbedding);
        command.Parameters.AddWithValue(query);
        command.Parameters.AddWithValue(k);

        var hits = new List<SearchHit>(k);
        await using var reader = await command.ExecuteReaderAsync(ct);
        while (await reader.ReadAsync(ct))
        {
            hits.Add(new SearchHit(
                reader.GetInt64(0), reader.GetString(1), reader.GetDouble(2)));
        }
        return hits;
    }
}
