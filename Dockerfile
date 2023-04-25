FROM mcr.microsoft.com/dotnet/sdk:7.0 AS installer-env

# Build requires 3.1 SDK
COPY --from=mcr.microsoft.com/dotnet/core/sdk:3.1 /usr/share/dotnet /usr/share/dotnet

#ENV OTEL_DOTNET_AUTO_HOME=/home/site/wwwroot/otel-ai

#RUN apt-get update && \
#    apt-get install unzip -y

COPY . /src/dotnet-function-app
RUN cd /src/dotnet-function-app && \
    mkdir -p /home/site/wwwroot && \
    dotnet publish *.csproj --output /home/site/wwwroot 

#RUN curl -sSfL https://raw.githubusercontent.com/open-telemetry/opentelemetry-dotnet-instrumentation/v0.5.0/otel-dotnet-auto-install.sh -O
#RUN sh otel-dotnet-auto-install.sh

# To enable ssh & remote debugging on app service change the base image to the one below
# FROM mcr.microsoft.com/azure-functions/dotnet-isolated:3.0-dotnet-isolated5.0-appservice
FROM mcr.microsoft.com/azure-functions/dotnet-isolated:4-dotnet-isolated7.0
ENV AzureWebJobsScriptRoot=/home/site/wwwroot \
    AzureFunctionsJobHost__Logging__Console__IsEnabled=true \
    OTEL_DOTNET_AUTO_HOME=/otel-dotnet-auto \
    CORECLR_ENABLE_PROFILING="1" \
    CORECLR_PROFILER='{918728DD-259F-4A6A-AC2B-B85E1B658318}' \
    CORECLR_PROFILER_PATH=/home/site/wwwroot/otel-ai/OpenTelemetry.AutoInstrumentation.Native.so \
    CORECLR_PROFILER_PATH="/otel-dotnet-auto/linux-x64/OpenTelemetry.AutoInstrumentation.Native.so" \
    DOTNET_ADDITIONAL_DEPS="/otel-dotnet-auto/AdditionalDeps" \
    DOTNET_SHARED_STORE="/otel-dotnet-auto/store" \
    DOTNET_STARTUP_HOOKS="/otel-dotnet-auto/net/OpenTelemetry.AutoInstrumentation.StartupHook.dll" \
    OTEL_DOTNET_AUTO_HOME="/otel-dotnet-auto" \
    OTEL_SERVICE_NAME=aca-func \    
    OTEL_EXPORTER_OTLP_ENDPOINT=https://southcentralus-3.in.applicationinsights.azure.com/38838d71-4573-46dd-a1e2-c133ab7a9fff \
    OTEL_EXPORTER_OTLP_TRACES_ENDPOINT=https://southcentralus-3.in.applicationinsights.azure.com/38838d71-4573-46dd-a1e2-c133ab7a9fff/v1/traces 
#    OTEL_RESOURCE_ATTRIBUTES=deployment.environment=production,service.version=1.0.0.0

RUN apt-get update && \
    apt-get install unzip curl -y

ARG OTEL_VERSION=0.6.0
ADD https://github.com/open-telemetry/opentelemetry-dotnet-instrumentation/releases/download/v${OTEL_VERSION}/otel-dotnet-auto-install.sh otel-dotnet-auto-install.sh

RUN sh otel-dotnet-auto-install.sh

COPY --from=installer-env ["/home/site/wwwroot", "/home/site/wwwroot"]