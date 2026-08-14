// Solution to Exercise 22.2 — The PostgreSQL Handbook, Appendix D.
// Run against: scripts/reset-to-chapter.ps1 -Chapter 22
// Uses src/Lumina.EfCore; not in any csproj. Each original ran in psql at
// State 22 and the LINQ translation's row counts matched.

using Microsoft.EntityFrameworkCore;

public static class TranslationDrill
{
    // 1. Chapter 4's NULL-aware filter: tickets never answered.
    //    == null is the safe spelling — EF translates it to IS NULL,
    //    sidestepping the = NULL trap Chapter 4 set.
    public static void NeverAnswered(LuminaDbContext db)
    {
        var silent = db.Tickets
            .Where(t => t.FirstResponseAt == null)
            .Select(t => new { t.Reference, t.CreatedAt });
        Console.WriteLine(silent.ToQueryString());
        // Expect (verify with ToQueryString()):
        //   SELECT t.reference AS "Reference", t.created_at AS "CreatedAt"
        //   FROM lumina.ticket AS t
        //   WHERE t.first_response_at IS NULL
        Console.WriteLine(silent.Count());   // 862 — matches psql.
    }

    // 2. Chapter 7's ticket-with-customer join.
    public static void TicketWithCustomer(LuminaDbContext db)
    {
        var joined = db.Tickets
            .Select(t => new { t.Reference, t.Customer.CompanyName });
        Console.WriteLine(joined.ToQueryString());
        // Expect the INNER JOIN of listing 22.6 — INNER because
        // customer_id is NOT NULL (Chapter 6 steering the generator):
        //   SELECT t.reference AS "Reference", c.company_name AS "CompanyName"
        //   FROM lumina.ticket AS t
        //   INNER JOIN lumina.customer AS c ON t.customer_id = c.id
        Console.WriteLine(joined.Count());   // 80,040 — matches psql.
    }

    // 3. Chapter 8's per-team resolution average.
    public static void TeamAverages(LuminaDbContext db)
    {
        var averages = db.Tickets
            .Where(t => t.ResolutionMinutes != null)
            .GroupBy(t => t.TeamId)
            .Select(g => new
            {
                TeamId = g.Key,
                AvgMinutes = g.Average(t => t.ResolutionMinutes!.Value),
            });
        Console.WriteLine(averages.ToQueryString());
        // Expect GROUP BY with avg and a float8 cast (Average promises
        // double; listing 22.7 showed the same type-minding with count):
        //   SELECT t.team_id AS "TeamId",
        //          avg(t.resolution_minutes::float8) AS "AvgMinutes"
        //   FROM lumina.ticket AS t
        //   WHERE t.resolution_minutes IS NOT NULL
        //   GROUP BY t.team_id
        // psql agrees on the numbers: teams 1/2/3 average
        // 2947.5 / 2706.2 / 2797.2 minutes. Where the generated text
        // differs cosmetically (parentheses, alias names), EXPLAIN both —
        // the plans, not the spelling, decide equivalence.
    }
}
