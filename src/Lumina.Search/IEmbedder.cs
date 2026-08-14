using Pgvector;

namespace Lumina.Search;

/// <summary>
/// The one seam between your database code and the embedding model. A
/// production implementation calls an embedding API over HTTP (a hosted model
/// or a local one — anything that turns text into floats) and must say which
/// model produced the vector, because vectors from different models are not
/// comparable and must never share a column. Nothing else in Lumina.Search
/// knows or cares which model sits behind this interface.
/// </summary>
public interface IEmbedder
{
    /// <summary>Identifier stored beside every vector this embedder produces.</summary>
    string ModelName { get; }

    Task<Vector> EmbedAsync(string text, CancellationToken ct = default);
}
