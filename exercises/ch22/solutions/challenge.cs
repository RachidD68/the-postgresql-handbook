// Solution to Exercise 22.3 — The PostgreSQL Handbook, Appendix D.
// Run against: scripts/reset-to-chapter.ps1 -Chapter 22
// Extends TicketReadService (src/Lumina.EfCore/RawLane.cs); not in any csproj.
// The xmin mechanics verified in psql at State 22: updating LUM-1001 bumped
// its xmin from 24089 to 24160 — the free concurrency token doing its job.

using Microsoft.EntityFrameworkCore;

public class TicketRepository(LuminaDbContext db)
{
    // EF lane 1: the paged, filterable open-tickets list — already shipped
    // as TicketReadService.OpenTickets(page, pageSize); a filter rides in
    // as one more Where before the OrderByDescending.

    // Raw lane: the leaderboard — already shipped as
    // TicketReadService.Leaderboard() over Sql.Leaderboard (Chapter 10's
    // window function, untranslatable from LINQ).

    // EF lane 2: the optimistic write that survives one concurrent edit.
    public void SetSatisfaction(string reference, short score)
    {
        var ticket = db.Tickets.Single(t => t.Reference == reference);
        for (var attempt = 1; ; attempt++)
        {
            ticket.Satisfaction = score;
            try
            {
                db.SaveChanges();
                // EF's UPDATE carries WHERE id = $1 AND xmin = $2 — if a
                // concurrent writer bumped xmin, zero rows match and EF
                // throws instead of silently overwriting.
                return;
            }
            catch (DbUpdateConcurrencyException) when (attempt == 1)
            {
                // Reload takes the winner's row (and its new xmin);
                // re-apply on top and try exactly once more.
                db.Entry(ticket).Reload();
            }
            // A second failure propagates: something is writing in a loop,
            // and Chapter 14's pessimistic patterns (via the raw lane) are
            // the honest next stop.
        }
    }
}

// The proof, two contexts, as listing 22.19's demo staged it:
//
//   using var a = new LuminaDbContext();
//   using var b = new LuminaDbContext();
//   var ticketA = a.Tickets.Single(t => t.Reference == "LUM-1001");
//   var ticketB = b.Tickets.Single(t => t.Reference == "LUM-1001");
//   ticketB.Satisfaction = 2; b.SaveChanges();    // B wins the race
//   ticketA.Satisfaction = 5; a.SaveChanges();    // throws: stale xmin
//
// SaveChanges on context A throws DbUpdateConcurrencyException; the retry
// arm reloads (picking up B's xmin), re-applies 5, and the second
// SaveChanges succeeds — one lost-update prevented, one retry, no locks
// held while any human was thinking.
