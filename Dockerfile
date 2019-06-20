FROM mcr.microsoft.com/dotnet/core/sdk:2.2-alpine AS build-env
WORKDIR /app

# Copiar csproj e restaurar dependencias
COPY crm.sln ./
COPY ./Regra.Negocio/*.csproj ./Regra.Negocio/
COPY ./New.CRM/*.csproj ./New.CRM/
RUN dotnet restore

# Build da aplicacao
COPY . .
WORKDIR /app/Regra.Negocio/
RUN dotnet build -c Release -o out

# node https://pkgs.alpinelinux.org/package/edge/main/x86_64/nodejs
WORKDIR /app/New.CRM/
RUN apk add nodejs=8.14.0-r0
RUN dotnet publish -c Release -o out

# Build da imagem
FROM mcr.microsoft.com/dotnet/core/aspnet:2.2-alpine
WORKDIR /app
COPY --from=build-env /app/out .
ENTRYPOINT ["dotnet", "New.CRM.dll"]