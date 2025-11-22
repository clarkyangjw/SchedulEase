# SchedulEase

A RESTful appointment management system built with Spring Boot and PostgreSQL.

## Tech Stack

-   **Java 17**
-   **Spring Boot 3.5.7**
-   **PostgreSQL** (Google Cloud SQL)
-   **Spring Data JPA**
-   **Maven**

## Features

-   Provider management
-   Client management
-   Service management
-   Appointment scheduling and status tracking

## Quick Start

### Prerequisites

-   Java 17+
-   Maven 3.8+
-   PostgreSQL database

### Configuration

Update `src/main/resources/application.yml` with your database credentials:

```yaml
spring:
    datasource:
        url: jdbc:postgresql://your-host:5432/schedulease
        username: your_username
        password: your_password
```

### Build & Run

```bash
mvn clean install
mvn spring-boot:run
```

The application will start on `http://localhost:8080`

## API Endpoints

-   **Providers**: `/api/providers`
-   **Clients**: `/api/clients`
-   **Services**: `/api/services`
-   **Appointments**: `/api/appointments`

All endpoints support standard CRUD operations (GET, POST, PUT, DELETE).

## Project Structure

```
src/main/java/com/cstar/schedulease/
├── service/
│   ├── provider/     # Provider management
│   ├── client/       # Client management
│   ├── services/     # Service management
│   └── appointment/  # Appointment management
├── common/           # Shared entities and enums
├── exception/        # Global exception handling
└── config/           # Configuration classes
```
