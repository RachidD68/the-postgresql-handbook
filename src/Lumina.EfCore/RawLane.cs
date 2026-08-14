// The raw-SQL lane (Chapter 22, section 6): result shapes and the hand-off
// pattern. SqlQueryRaw maps result columns to properties by name — it knows
// nothing about the context's snake_case convention, so [Column] says so.

using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace Lumina.EfCore;

public class LeaderboardRow
{
    [Column("full_name")]        public string FullName { get; set; } = "";
    [Column("resolved_tickets")] public long ResolvedTickets { get; set; }
    [Column("leaderboard_rank")] public long LeaderboardRank { get; set; }
}

public class ClaimedJob
{
    [Column("id")]       public long Id { get; set; }
    [Column("job_kind")] public string JobKind { get; set; } = "";
}

// One service, two lanes over the same DbContext: LINQ where EF's plumbing
// earns its keep, raw SQL where the SQL itself is the feature.
public class TicketReadService(LuminaDbContext db)
{
    // The EF lane: shaping, paging, parameterization — the plumbing.
    public List<TicketSummary> OpenTickets(int page, int pageSize = 20) =>
        db.Tickets
            .Where(t => t.Status == "open")
            .OrderByDescending(t => t.CreatedAt)
            .Skip(page * pageSize).Take(pageSize)
            .Select(t => new TicketSummary(t.Reference, t.Subject, t.CreatedAt))
            .ToList();

    // The raw lane: Chapter 10's window function, untranslatable from LINQ.
    public List<LeaderboardRow> Leaderboard() =>
        db.Database.SqlQueryRaw<LeaderboardRow>(Sql.Leaderboard).ToList();
}

public record TicketSummary(string Reference, string Subject, DateTimeOffset CreatedAt);

// The raw lane's SQL, in one place. Verbatim from the book's listings —
// the harness runs the same text against State(22).
public static class Sql
{
    public const string Leaderboard = """
        SELECT a.full_name,
               count(*) AS resolved_tickets,
               rank() OVER (ORDER BY count(*) DESC) AS leaderboard_rank
        FROM ticket AS t
        JOIN agent AS a ON a.id = t.assigned_agent_id
        WHERE t.resolved_at IS NOT NULL
        GROUP BY a.full_name
        ORDER BY leaderboard_rank, a.full_name
        LIMIT 5;
        """;

    public const string ClaimNextJob = """
        WITH claimed AS (
            UPDATE ticket_job
            SET job_state = 'running',
                locked_at = '2026-01-15 09:00:00+00',
                locked_by = 'worker-ef'
            WHERE id IN (SELECT id
                         FROM ticket_job
                         WHERE job_state = 'queued'
                           AND run_after <= '2026-01-15 09:00:00+00'
                         ORDER BY id
                         FOR UPDATE SKIP LOCKED
                         LIMIT 1)
            RETURNING id, job_kind
        )
        SELECT id, job_kind FROM claimed;
        """;
}
