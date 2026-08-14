using Lumina.Data;

// Every Chapter 21 demo is a method you can run on its own:
//   dotnet run -- first-query
//   dotnet run -- injection
//   dotnet run -- insert
//   dotnet run -- transaction
//   dotnet run -- nplusone   (the default)
var command = args.Length > 0 ? args[0] : "nplusone";

await using var source = DataSourceFactory.Create();

switch (command)
{
    case "first-query": await QueryDemo.OpenTicketsAsync(source); break;
    case "injection": await InjectionDemo.RunAsync(source); break;
    case "insert": await InsertDemo.CreateTicketAsync(source); break;
    case "transaction": await TransactionDemo.ResolveWithRefundAsync(source); break;
    case "nplusone": await NPlusOneDemo.CompareAsync(source); break;
    default:
        Console.WriteLine($"Unknown command '{command}'. Try: first-query, injection, insert, transaction, nplusone.");
        break;
}
