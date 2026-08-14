// The migrations demo (Chapter 22, section 5): a throwaway context holding ONE
// new table, so GenerateCreateScript() shows exactly the DDL EF's migration
// pipeline would emit for it. Nothing here is ever applied to the database.

using System.Text.RegularExpressions;
using Microsoft.EntityFrameworkCore;

namespace Lumina.EfCore;

public class SavedReply
{
    public long Id { get; set; }
    public long TeamId { get; set; }
    public required string Title { get; set; }
    public required string Body { get; set; }
    public DateTimeOffset CreatedAt { get; set; }
}

public class SavedReplyContext : DbContext
{
    public DbSet<SavedReply> SavedReplies => Set<SavedReply>();

    protected override void OnConfiguring(DbContextOptionsBuilder options)
        => options.UseNpgsql("Host=localhost;Database=lumina");

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.HasDefaultSchema("lumina");
        modelBuilder.Entity<SavedReply>(r =>
        {
            r.ToTable("saved_reply");
            foreach (var property in r.Metadata.GetProperties())
                property.SetColumnName(ToSnakeCase(property.Name));
        });
    }

    private static string ToSnakeCase(string name) =>
        Regex.Replace(name, "(?<=[a-z0-9])[A-Z]", "_$0").ToLowerInvariant();
}
