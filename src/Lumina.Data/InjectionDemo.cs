using Npgsql;

namespace Lumina.Data;

public static class InjectionDemo
{
    // NEVER write this. The method exists only to prove the hole is real: the
    // user's text is spliced straight into the SQL text, so the user can end
    // the string and write their own SQL.
    public static async Task<long> LookupVulnerableAsync(
        NpgsqlDataSource source, string userInput)
    {
        var sql = "SELECT count(*) FROM ticket WHERE reference = '" + userInput + "'";
        await using var command = source.CreateCommand(sql);
        return (long)(await command.ExecuteScalarAsync())!;
    }

    // ALWAYS write this. $1 is a placeholder the driver fills over the wire;
    // the value never becomes SQL text, so it can never change the query's shape.
    public static async Task<long> LookupSafeAsync(
        NpgsqlDataSource source, string userInput)
    {
        const string sql = "SELECT count(*) FROM ticket WHERE reference = $1";
        await using var command = source.CreateCommand(sql);
        command.Parameters.AddWithValue(userInput);
        return (long)(await command.ExecuteScalarAsync())!;
    }

    public static async Task RunAsync(NpgsqlDataSource source)
    {
        const string attack = "' OR 1=1 --";

        var vulnerable = await LookupVulnerableAsync(source, attack);
        var safe = await LookupSafeAsync(source, attack);

        Console.WriteLine($"Concatenated query matched  {vulnerable,6} rows");
        Console.WriteLine($"Parameterized query matched {safe,6} rows");
    }
}
