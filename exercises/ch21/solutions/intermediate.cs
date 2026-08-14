// Solution to Exercise 21.2 — The PostgreSQL Handbook, Appendix D.
// Run against: scripts/reset-to-chapter.ps1 -Chapter 21
// A method in the Lumina.Data idiom (src/Lumina.Data); not part of any csproj.
// SQL verified via psql in a rolled-back transaction (new id 81001 at State 21).

using Npgsql;

public static class CreateTicketWithEventDemo
{
    public static async Task<string> CreateAsync(NpgsqlDataSource source)
    {
        await using var connection = await source.OpenConnectionAsync();
        await using var tx = await connection.BeginTransactionAsync();
        try
        {
            long id;
            string reference;

            // RETURNING hands back the generated id in the same round trip —
            // no separate SELECT, no race to read your own write.
            await using (var insert = new NpgsqlCommand(
                """
                INSERT INTO ticket (reference, customer_id, team_id, subject,
                                    body, status, priority, channel, created_at)
                VALUES ($1, 2, 2, 'Renewal invoice missing PO number',
                        'Finance needs the PO on the January renewal invoice.',
                        'open', 'normal', 'email', '2026-01-15 09:00:00+00')
                RETURNING id, reference;
                """, connection, tx))
            {
                insert.Parameters.AddWithValue("LUM-90002");
                await using var reader = await insert.ExecuteReaderAsync();
                await reader.ReadAsync();
                id = reader.GetInt64(0);
                reference = reader.GetString(1);
            }

            // The id we just received writes the matching audit event.
            await using (var record = new NpgsqlCommand(
                """
                INSERT INTO ticket_event (ticket_id, event_kind, payload, occurred_at)
                VALUES ($1, 'created', '{"channel": "email"}',
                        '2026-01-15 09:00:00+00');
                """, connection, tx))
            {
                record.Parameters.AddWithValue(id);
                await record.ExecuteNonQueryAsync();
            }

            // Both rows or neither — Chapter 14's atomic pair, from code.
            await tx.CommitAsync();
            return reference;
        }
        catch
        {
            await tx.RollbackAsync();
            throw;
        }
    }
}
