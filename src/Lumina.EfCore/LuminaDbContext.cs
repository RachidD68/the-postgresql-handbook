// LuminaDbContext — maps the EXISTING Lumina schema. No migration runs here:
// the database Chapters 2-19 built is the source of truth, and this context
// adapts to it (schema lumina, snake_case names, the native enum, xmin).

using System.Text.RegularExpressions;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace Lumina.EfCore;

public class LuminaDbContext : DbContext
{
    private readonly bool _logSql;

    public LuminaDbContext(bool logSql = false) => _logSql = logSql;

    public DbSet<Ticket> Tickets => Set<Ticket>();
    public DbSet<Customer> Customers => Set<Customer>();
    public DbSet<TicketComment> Comments => Set<TicketComment>();
    public DbSet<TicketEvent> Events => Set<TicketEvent>();

    protected override void OnConfiguring(DbContextOptionsBuilder options)
    {
        // Never a password in code: PGPASSWORD / pgpass.conf supply it,
        // exactly as they did for psql in Chapter 1.
        var dsn = Environment.GetEnvironmentVariable("LUMINA_DSN")
                  ?? "Host=localhost;Username=postgres;Database=lumina";
        options.UseNpgsql(dsn,
            o => o.MapEnum<TicketPriority>("ticket_priority", "lumina"));
        if (_logSql)
            options.LogTo(Console.WriteLine, LogLevel.Information);
    }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.HasDefaultSchema("lumina");

        modelBuilder.Entity<Ticket>(t =>
        {
            t.ToTable("ticket");
            t.Property(x => x.CustomFields).HasColumnType("jsonb");
            t.Property(x => x.ResolutionMinutes).ValueGeneratedOnAddOrUpdate();
            t.HasOne(x => x.Customer).WithMany(c => c.Tickets)
                .HasForeignKey(x => x.CustomerId);
            t.HasMany(x => x.Comments).WithOne().HasForeignKey(c => c.TicketId);
            t.HasMany(x => x.Events).WithOne().HasForeignKey(e => e.TicketId);
            // Chapter 14's version-column pattern, for free: every row already
            // carries xmin, and PostgreSQL bumps it on every write.
            t.Property(x => x.Version)
                .HasColumnName("xmin").HasColumnType("xid")
                .ValueGeneratedOnAddOrUpdate().IsConcurrencyToken();
        });

        modelBuilder.Entity<Customer>(c => c.ToTable("customer"));
        modelBuilder.Entity<TicketComment>(c => c.ToTable("ticket_comment"));

        modelBuilder.Entity<TicketEvent>(e =>
        {
            e.ToTable("ticket_event");
            e.HasKey(x => new { x.Id, x.OccurredAt });   // partitioning tax, Ch19
            e.Property(x => x.Payload).HasColumnType("jsonb");
        });

        // The database's convention wins: every PascalCase property maps to
        // the snake_case column that already exists. A convention is just code.
        // (Explicitly named columns — xmin above — keep their names.)
        foreach (var entity in modelBuilder.Model.GetEntityTypes())
            foreach (var property in entity.GetProperties())
                if (property.GetColumnName() == property.Name)
                    property.SetColumnName(ToSnakeCase(property.Name));
    }

    private static string ToSnakeCase(string name) =>
        Regex.Replace(name, "(?<=[a-z0-9])[A-Z]", "_$0").ToLowerInvariant();
}
