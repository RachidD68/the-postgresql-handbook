using System.Data;
using Npgsql;

namespace Lumina.Data;

public static class TransactionDemo
{
    public static async Task ResolveWithRefundAsync(NpgsqlDataSource source)
    {
        const int maxAttempts = 3;

        for (var attempt = 1; attempt <= maxAttempts; attempt++)
        {
            await using var connection = await source.OpenConnectionAsync();
            await using var tx =
                await connection.BeginTransactionAsync(IsolationLevel.Serializable);
            try
            {
                // Both writes commit together or not at all — Chapter 14's
                // resolve-and-refund pair, now as application code.
                await using (var resolve = new NpgsqlCommand(
                    """
                    UPDATE ticket
                    SET status = 'resolved', resolved_at = '2026-01-15 09:20:00+00'
                    WHERE reference = $1 AND status <> 'resolved';
                    """, connection, tx))
                {
                    resolve.Parameters.AddWithValue("LUM-1031");
                    await resolve.ExecuteNonQueryAsync();
                }

                await using (var record = new NpgsqlCommand(
                    """
                    INSERT INTO ticket_event (ticket_id, event_kind, payload, occurred_at)
                    SELECT id, 'refund_issued', '{"amount_cents": 4900}',
                           '2026-01-15 09:20:00+00'
                    FROM ticket WHERE reference = $1;
                    """, connection, tx))
                {
                    record.Parameters.AddWithValue("LUM-1031");
                    await record.ExecuteNonQueryAsync();
                }

                await tx.CommitAsync();
                Console.WriteLine($"Refund committed on attempt {attempt}.");
                return;
            }
            catch (PostgresException ex)
                when (ex.SqlState == PostgresErrorCodes.SerializationFailure)
            {
                // 40001 is not an error to log — it is a transaction to retry.
                await tx.RollbackAsync();
                if (attempt == maxAttempts) throw;
                await Task.Delay(50 * attempt);
            }
        }
    }
}
