FROM mcr.microsoft.com/dotnet/core/aspnet:2.1-alpine AS base
WORKDIR /app
EXPOSE 80


# Copiar csproj e restaurar dependencias
FROM mcr.microsoft.com/dotnet/core/sdk:2.1-alpine AS build
WORKDIR /src
COPY crm.sln ./
COPY ./Regra.Negocio/*.csproj ./Regra.Negocio/
COPY ./New.CRM/*.csproj ./New.CRM/
RUN dotnet restore

COPY . .
# Build da regra de negócio
WORKDIR /src/Regra.Negocio/
RUN dotnet build -c Release -o /app

# Build da aplicação
WORKDIR /src/New.CRM/
RUN apk add nodejs=10.16.3-r0
RUN dotnet build -c Release -o /app

FROM build AS publish
RUN dotnet publish -c Release -o /app

FROM base AS final
WORKDIR /app
COPY --from=publish /app .
ENTRYPOINT ["dotnet", "New.CRM.dll"]
