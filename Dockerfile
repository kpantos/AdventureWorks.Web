# Stage 1: Build
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /source

# Copy the project files and restore dependencies
COPY *.sln .
COPY AdventureWorks.Web.csproj .
RUN dotnet restore AdventureWorks.Web.csproj

# Copy the rest of the source code and build the application
COPY . .
RUN dotnet publish AdventureWorks.Web.csproj -c Release -o /app

# Stage 2: Runtime
FROM mcr.microsoft.com/dotnet/aspnet:9.0-alpine AS runtime
WORKDIR /app

# Install required packages
RUN apk add --no-cache \
    icu-libs \
    tiff \
    libgdiplus \
    libc-dev \
    tzdata

# Set the globalization invariant mode to false
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false

# Set the ASPNETCORE_URLS environment variable
ENV ASPNETCORE_URLS=http://+:8080

# Copy the built application from the build stage
COPY --from=build /app .

# Expose port 8080
EXPOSE 8080

# Run the application
ENTRYPOINT ["dotnet", "AdventureWorks.Web.dll"]