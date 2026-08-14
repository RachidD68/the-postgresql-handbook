// Solution to Exercise 22.1 — The PostgreSQL Handbook, Appendix D.
// Run against: scripts/reset-to-chapter.ps1 -Chapter 22
// Extends src/Lumina.EfCore (LuminaDbContext / Models.cs); not in any csproj.

using Microsoft.EntityFrameworkCore;

// Models.cs gains the entity and Ticket gains a navigation:
public class Tag
{
    public long Id { get; set; }
    public required string Name { get; set; }
    public required string Description { get; set; }
}
//   public List<Tag> Tags { get; } = [];        // on Ticket

// OnModelCreating — the snake_case loop fixes columns, but the join
// TABLE's name must be spelled out, composite key and all:
//
//   modelBuilder.Entity<Tag>(t => t.ToTable("tag"));
//   modelBuilder.Entity<Ticket>()
//       .HasMany(t => t.Tags).WithMany()
//       .UsingEntity("ticket_tag",
//           l => l.HasOne(typeof(Tag)).WithMany()
//                 .HasForeignKey("tag_id"),
//           r => r.HasOne(typeof(Ticket)).WithMany()
//                 .HasForeignKey("ticket_id"));

public static class TagQueryDemo
{
    public static void OneTicketsTags(LuminaDbContext db)
    {
        var tags = db.Tickets
            .Where(t => t.Reference == "LUM-1036")
            .SelectMany(t => t.Tags)
            .Select(tg => tg.Name);

        Console.WriteLine(tags.ToQueryString());
        // The SQL to expect — Chapter 7's two-join bridge walk (listing
        // 7.8's shape), verify with ToQueryString():
        //   SELECT t1.name AS "Name"
        //   FROM lumina.ticket AS t
        //   INNER JOIN lumina.ticket_tag AS t0 ON t.id = t0.ticket_id
        //   INNER JOIN lumina.tag AS t1 ON t0.tag_id = t1.id
        //   WHERE t.reference = 'LUM-1036'
        foreach (var name in tags) Console.WriteLine(name);
        // outage, performance — verified against State 22 in psql.
    }
}
