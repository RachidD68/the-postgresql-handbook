using Npgsql;

namespace Lumina.Data;

/// <summary>
/// Builds the one <see cref="NpgsqlDataSource"/> the whole application shares.
/// The connection string comes from the LUMINA_DSN environment variable so no
/// password ever lives in the repository; a localhost fallback keeps first-run
/// friction low. Npgsql also honors PGPASSWORD, libpq's own mechanism.
/// </summary>
public static class DataSourceFactory
{
    public static NpgsqlDataSource Create()
    {
        // In production, Host points at the Chapter 20 pooler (port 6432) and
        // Username is Chapter 17's least-privilege lumina_app — never postgres.
        var dsn = Environment.GetEnvironmentVariable("LUMINA_DSN")
            ?? "Host=localhost;Username=postgres;Database=lumina";

        var builder = new NpgsqlDataSourceBuilder(dsn);
        return builder.Build();
    }
}
