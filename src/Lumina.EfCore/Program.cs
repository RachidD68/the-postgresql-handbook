// Chapter 22 — Gateway: PostgreSQL with EF Core.
// Every demo prints the SQL EF generates (ToQueryString — the chapter's
// microscope) so the book can show real captured output, never invented SQL.
//
// Run order matters only for the last two demos (they write). Reset first:
//     scripts\reset-to-chapter.ps1 -Chapter 22

using Lumina.EfCore;
using Microsoft.EntityFrameworkCore;

using var db = new LuminaDbContext();

Demo("22-first-query: Where / OrderBy / Take", FirstQuery);
Demo("22-projection: Select shapes the SELECT", Projection);
Demo("22-include: Include is a join", IncludeJoin);
Demo("22-groupby: GroupBy is GROUP BY", GroupByStatus);
Demo("22-fanout: two collection Includes, single query", FanOutSingle);
Demo("22-splitquery: the same query, split", FanOutSplit);
Demo("22-jsonb: containment from LINQ", JsonbContainment);
Demo("22-enum: the native enum orders itself", EnumOrdering);
Demo("22-migrate: the DDL EF would emit", MigrationDdl);
Demo("22-leaderboard: the raw lane", RawLeaderboard);
Demo("22-skiplocked: the queue stays raw", SkipLockedClaim);
Demo("22-xmin: conflict and retry", ConcurrencyConflict);

void Demo(string title, Action body)
{
    Console.WriteLine($"\n===== {title} =====");
    body();
}

void FirstQuery()
{
    var openTickets = db.Tickets
        .Where(t => t.Status == "open")
        .OrderByDescending(t => t.CreatedAt)
        .Take(10);

    Console.WriteLine(openTickets.ToQueryString());
}

void Projection()
{
    var slim = db.Tickets
        .Where(t => t.Status == "open")
        .OrderByDescending(t => t.CreatedAt)
        .Select(t => new { t.Reference, t.Subject, t.CreatedAt })
        .Take(10);

    Console.WriteLine(slim.ToQueryString());
}

void IncludeJoin()
{
    var unhappy = db.Tickets
        .Include(t => t.Customer)
        .Where(t => t.Satisfaction <= 2)
        .OrderBy(t => t.Id);

    Console.WriteLine(unhappy.ToQueryString());
}

void GroupByStatus()
{
    var byStatus = db.Tickets
        .GroupBy(t => t.Status)
        .Select(g => new { Status = g.Key, Tickets = g.Count() })
        .OrderByDescending(x => x.Tickets);

    Console.WriteLine(byStatus.ToQueryString());
}

void FanOutSingle()
{
    var fanOut = db.Tickets
        .Include(t => t.Comments)
        .Include(t => t.Events)
        .Where(t => t.Reference == "LUM-1001");

    Console.WriteLine(fanOut.ToQueryString());
}

void FanOutSplit()
{
    var split = db.Tickets
        .Include(t => t.Comments)
        .Include(t => t.Events)
        .Where(t => t.Reference == "LUM-1001")
        .AsSplitQuery();

    Console.WriteLine(split.ToQueryString());

    // ToQueryString can only show the first statement of a split query, so
    // execute it on a logging context and let the command log show all three.
    using var logDb = new LuminaDbContext(logSql: true);
    _ = logDb.Tickets
        .Include(t => t.Comments)
        .Include(t => t.Events)
        .Where(t => t.Reference == "LUM-1001")
        .AsSplitQuery()
        .ToList();
}

void JsonbContainment()
{
    // Chapter 11's containment question, asked from LINQ.
    var phoneUrgent = db.Events
        .Where(e => e.EventKind == "created")
        .Where(e => EF.Functions.JsonContains(e.Payload,
            """{"channel": "phone", "priority": "urgent"}"""))
        .Select(e => new { e.TicketId, e.OccurredAt });

    Console.WriteLine(phoneUrgent.ToQueryString());
}

void EnumOrdering()
{
    var urgentOpen = db.Tickets
        .Where(t => t.Status == "open" && t.Priority == TicketPriority.Urgent)
        .Select(t => new { t.Reference, t.Priority });

    Console.WriteLine(urgentOpen.ToQueryString());

    // ORDER BY priority DESC — declaration order, exactly as Chapter 5 built it.
    var worstFirst = db.Tickets
        .Where(t => t.Status == "open")
        .OrderByDescending(t => t.Priority)
        .ThenBy(t => t.CreatedAt)
        .Select(t => new { t.Reference, t.Priority, t.Subject });

    Console.WriteLine(worstFirst.ToQueryString());
}

void MigrationDdl()
{
    using var replies = new SavedReplyContext();
    Console.WriteLine(replies.Database.GenerateCreateScript());
}

void RawLeaderboard()
{
    var service = new TicketReadService(db);
    foreach (var row in service.Leaderboard())
        Console.WriteLine(
            $"{row.LeaderboardRank}. {row.FullName} — {row.ResolvedTickets}");
}

void SkipLockedClaim()
{
    var claimed = db.Database.SqlQueryRaw<ClaimedJob>(Sql.ClaimNextJob).ToList();
    foreach (var job in claimed)
        Console.WriteLine($"claimed job {job.Id}: {job.JobKind}");
}

void ConcurrencyConflict()
{
    using var first = new LuminaDbContext(logSql: true);
    using var second = new LuminaDbContext();

    var mine = first.Tickets.Single(t => t.Reference == "LUM-1001");
    var theirs = second.Tickets.Single(t => t.Reference == "LUM-1001");

    theirs.Satisfaction = 5;
    second.SaveChanges();          // wins quietly: the row's xmin advances

    mine.Satisfaction = 1;
    try
    {
        first.SaveChanges();       // stale xmin: zero rows matched
    }
    catch (DbUpdateConcurrencyException)
    {
        Console.WriteLine("conflict detected — reloading and retrying");
        first.Entry(mine).Reload();
        mine.Satisfaction = 1;     // re-apply the change to the fresh row
        first.SaveChanges();       // retry succeeds against the new xmin
    }
}
