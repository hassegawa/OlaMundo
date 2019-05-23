FROM mcr.microsoft.com/dotnet/core/sdk:2.1-alpine AS build-env
WORKDIR /app

# Copiar csproj e restaurar dependencias
COPY *.csproj ./
RUN dotnet restore

# Build da aplicacao
COPY . ./

# node https://pkgs.alpinelinux.org/package/edge/main/x86_64/nodejs
RUN apk add nodejs=8.9.3-r1
RUN dotnet publish -c Release -o out

# Build da imagem
FROM mcr.microsoft.com/dotnet/core/runtime:2.1-alpine
WORKDIR /app
COPY --from=build-env /app/out .
ENTRYPOINT ["dotnet", "OlaMundo.dll"]