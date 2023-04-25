using System.Diagnostics.Metrics;
using System.Net;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;

namespace LocalFunctionProj
{
    public class HttpExample
    {
        private readonly ILogger _logger;
        //internal static Meter MyMeter = new Meter("FunctionsOpenTelemetry.MyMeter");
        //internal static Counter<long> MyCounter = MyMeter.CreateCounter<long>("MyCounter");

        public HttpExample(ILoggerFactory loggerFactory)
        {
            _logger = loggerFactory.CreateLogger<HttpExample>();
        }

        [Function("HttpExample")]
        public HttpResponseData Run([HttpTrigger(AuthorizationLevel.Anonymous, "get", "post")] HttpRequestData req)
        {
            _logger.LogInformation("C# HTTP trigger function processed a request.");
            //MyCounter.Add(1, new("name", "apple"), new("color", "red"));
            var response = req.CreateResponse(HttpStatusCode.OK);
            response.Headers.Add("Content-Type", "text/plain; charset=utf-8");

            response.WriteString("Welcome to Azure Functions!");

            return response;
        }
    }
}
