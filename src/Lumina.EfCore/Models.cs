// Lumina Helpdesk — EF Core entity classes (Chapter 22).
// Database-first: these classes describe the schema Chapters 2-19 built.
// The database is the source of truth; the C# adapts to it, never the reverse.

using System.Text.Json;

namespace Lumina.EfCore;

public enum TicketPriority { Low, Normal, High, Urgent }

public class Ticket
{
    public long Id { get; set; }
    public required string Reference { get; set; }
    public long CustomerId { get; set; }
    public long? AssignedAgentId { get; set; }
    public long TeamId { get; set; }
    public required string Subject { get; set; }
    public required string Body { get; set; }
    public required string Status { get; set; }
    public TicketPriority Priority { get; set; }
    public required string Channel { get; set; }
    public DateTimeOffset CreatedAt { get; set; }
    public DateTimeOffset? FirstResponseAt { get; set; }
    public DateTimeOffset? ResolvedAt { get; set; }
    public DateTimeOffset? ClosedAt { get; set; }
    public short? Satisfaction { get; set; }
    public JsonDocument CustomFields { get; set; } = null!;
    public int? ResolutionMinutes { get; set; }        // GENERATED — read-only
    public uint Version { get; set; }                  // xmin: the free token

    public Customer Customer { get; set; } = null!;
    public List<TicketComment> Comments { get; } = [];
    public List<TicketEvent> Events { get; } = [];
}

public class Customer
{
    public long Id { get; set; }
    public required string CompanyName { get; set; }
    public required string FullName { get; set; }
    public required string Email { get; set; }         // citext in the database
    public required string Plan { get; set; }
    public DateTimeOffset SignedUpAt { get; set; }

    public List<Ticket> Tickets { get; } = [];
}

public class TicketComment
{
    public long Id { get; set; }
    public long TicketId { get; set; }
    public long? ParentCommentId { get; set; }
    public required string AuthorKind { get; set; }
    public long AuthorId { get; set; }
    public required string Body { get; set; }
    public DateTimeOffset CreatedAt { get; set; }
}

public class TicketEvent
{
    public long Id { get; set; }
    public long TicketId { get; set; }
    public required string EventKind { get; set; }
    public JsonDocument Payload { get; set; } = null!;
    public DateTimeOffset OccurredAt { get; set; }
}
