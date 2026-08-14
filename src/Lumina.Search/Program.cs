using Lumina.Search;

// Chapter 23's demos, one per section that ships C#:
//   dotnet run -- semantic   (§6: embed the query, ORDER BY distance)
//   dotnet run -- hybrid     (§7: FTS lane + vector lane, RRF-fused — default)
//   dotnet run -- ingest     (§6: embed at write time; inserts one article)
//
// Requires the book's pgvector container (Chapter 1's compose file) and
// State(23): scripts/reset-to-chapter.ps1 -Chapter 23 with PGPORT=5433.
var command = args.Length > 0 ? args[0] : "hybrid";

await using var source = SearchDataSource.Create();
var embedder = new FixtureEmbedder(source);   // production: an API-backed IEmbedder
var search = new KbSearch(source, embedder);

const string question = "scanner keeps grabbing two pages at a time";

switch (command)
{
    case "semantic":
        Console.WriteLine($"Semantic search: \"{question}\"\n");
        foreach (var hit in await search.SemanticAsync(question))
        {
            Console.WriteLine($"  {hit.Score:F3}  [{hit.Id,3}]  {hit.Title}");
        }
        break;

    case "hybrid":
        Console.WriteLine($"Hybrid search: \"printer\" + the question's embedding\n");
        foreach (var hit in await search.HybridAsync("printer"))
        {
            Console.WriteLine($"  {hit.Score:F5}  [{hit.Id,3}]  {hit.Title}");
        }
        break;

    case "ingest":
        var id = await search.IngestAsync(
            "Scanner grabs two pages at a time",
            "Clean the separation pad and fan the stack before loading.",
            ticketId: 42);
        Console.WriteLine($"Ingested kb_article {id} (embedded at write time).");
        break;

    default:
        Console.WriteLine($"Unknown command '{command}'. Try: semantic, hybrid, ingest.");
        break;
}
