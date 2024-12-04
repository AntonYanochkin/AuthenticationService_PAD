#See https://aka.ms/customizecontainer to learn how to customize your debug container and how Visual Studio uses this Dockerfile to build your images for faster debugging.
#
#FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
#USER app
#WORKDIR /app
#EXPOSE 8080
#EXPOSE 8081
#
#FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
#ARG BUILD_CONFIGURATION=Release
#WORKDIR /src
#COPY ["AutentificationService2.csproj", "."]
#RUN dotnet restore "./AutentificationService2.csproj"
#COPY . .
#WORKDIR "/src/."
#RUN dotnet build "./AutentificationService2.csproj" -c $BUILD_CONFIGURATION -o /app/build
#
#FROM build AS publish
#ARG BUILD_CONFIGURATION=Release
#RUN dotnet publish "./AutentificationService2.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false
#
#FROM base AS final
#WORKDIR /app
#COPY --from=publish /app/publish .
#ENTRYPOINT ["dotnet", "AutentificationService2.dll"]

# Используем базовый образ для выполнения приложения
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 50743
EXPOSE 44335

# Используем SDK образ для сборки приложения
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src

# Копируем только проектный файл и восстанавливаем зависимости (кэшируемый слой)
COPY ["AutentificationService2.csproj", "./"]
RUN dotnet restore "AutentificationService2.csproj"

# Копируем весь исходный код и собираем проект
COPY . .
RUN dotnet build "AutentificationService2.csproj" -c $BUILD_CONFIGURATION -o /app/build

# Публикация приложения
FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "AutentificationService2.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

# Финальный образ
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .

# Устанавливаем пользователя для запуска контейнера
USER app

ENTRYPOINT ["dotnet", "AutentificationService2.dll"]
