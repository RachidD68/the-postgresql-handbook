using Npgsql;
using Pgvector.Npgsql;

namespace Lumina.Search;

/// <summary>
/// Chapter 23's data source: the same LUMINA_DSN contract as Chapter 21, with
/// two deliberate differences. The fallback targets the book's pgvector
/// container on port 5433 (the native install has no vector extension), and
/// UseVector() teaches Npgsql's type mapper that a vector(n) column travels as
/// Pgvector.Vector. No password lives in the repository: Npgsql honors
/// PGPASSWORD, libpq's own mechanism, and production uses LUMINA_DSN.
/// </summary>
public static class SearchDataSource
{
    public static NpgsqlDataSource Create()
    {
        var dsn = Environment.GetEnvironmentVariable("LUMINA_DSN")
            ?? "Host=localhost;Port=5433;Username=postgres;Database=lumina";

        var builder = new NpgsqlDataSourceBuilder(dsn);
        builder.UseVector();   // vector(n) <-> Pgvector.Vector, both directions
        return builder.Build();
    }
}
