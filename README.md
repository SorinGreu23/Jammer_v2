# Jammer v2

A collaborative project management application built for Advanced Programming and DBMS classes, featuring board-based task management with multi-user collaboration capabilities.

## 🚀 Project Overview

Jammer v2 is a full-stack web application that provides collaborative board management functionality, allowing users to create, manage, and collaborate on project boards. The application supports user invitations, role-based access control, and email-based collaboration features.

## 🛠️ Technology Stack

### Backend
- **Java 21** - Programming language
- **Spring Boot 3.4.5** - Application framework
- **Spring Data JDBC** - Database access
- **Spring Boot Mail** - Email functionality
- **Thymeleaf** - Template engine for email templates
- **Maven** - Dependency management and build tool
- **Lombok** - Code generation library
- **jBCrypt 0.4** - Password hashing
- **SpringDoc OpenAPI 2.3.0** - API documentation
- **SQL Server JDBC Driver** - Database connectivity

### Frontend
- **Angular 19.2** - Frontend framework
- **TypeScript 5.7** - Programming language
- **PrimeNG 19.1** - UI component library
- **PrimeIcons 7.0** - Icon library
- **Font Awesome 4.7** - Additional icon library
- **RxJS 7.8** - Reactive programming
- **Angular CDK 19.0** - Component development kit

### Database
- **Microsoft SQL Server** - Primary database (SQL Server Express with SQLEXPRESS instance)
- **Stored Procedures** - Complex database operations
- **JDBC Template** - Database operations

## 📋 Features

- **User Management**: Registration, authentication, and profile management
- **Board Management**: Create and manage project boards
- **Collaborative Workspaces**: Multi-user board collaboration
- **Invitation System**: Invite users via email or username
- **Email Notifications**: Automated invitation and notification emails
- **Responsive Design**: Modern UI with PrimeNG components

## 🏗️ Architecture

### Architectural Patterns

Jammer v2 implements a **Clean Architecture** pattern with clear separation of concerns, ensuring maintainability, testability, and independence from external frameworks.

**Domain Layer** (`domain/`)
- Contains pure business logic and entities
- Defines core business rules and domain services
- Independent of any external frameworks or technologies
- Entities: `User`, `Board`, `BoardMember`, `BoardInvitation`

**Application Layer** (`application/`)
- Orchestrates domain objects to fulfill use cases
- Contains application-specific business rules
- Defines interfaces for external services (ports)
- Use cases: `CreateBoard`, `InviteUser`, `ManageBoardMembers`
- Application services coordinate multiple domain operations

**Infrastructure Layer** (`api/`, `persistence/`, `infrastructure/`)
- **API Layer** (`api/`): REST controllers, DTOs, request/response mapping
- **Persistence Layer** (`persistence/`): Database repositories, entity mapping
- **Infrastructure Layer** (`infrastructure/`): External service implementations

### Frontend Architecture (Angular)

The Angular frontend follows **Component-Based Architecture** with:

```
client-app/src/
├── app/
│   ├── shared/            # Reusable components, pipes, directives
│   ├── views/             # Feature views and components
│   ├── app.routes.ts      # Application routing configuration
│   ├── app.config.ts      # Application configuration
│   └── app.component.*    # Root application component
```

#### Frontend Design Patterns

- **Module-based organization** for feature separation
- **Service-oriented architecture** for data management
- **Reactive programming** with RxJS for async operations
- **Component composition** with PrimeNG UI library
- **Route-based lazy loading** for performance optimization


### Project Structure

```
Jammer_v2/
├── src/main/java/com/example/jammer/
│   ├── domain/              # Business entities and domain logic
│   ├── application/         # Use cases and application services
│   ├── api/                 # REST controllers and DTOs
│   ├── persistence/         # Database repositories and data access
│   ├── infrastructure/      # External services (email, CORS, etc.)
│   └── JammerApplication.java
├── client-app/
│   ├── src/app/
│   │   ├── views/           # Feature components and pages
│   │   ├── shared/          # Reusable components and services
│   │   ├── app.routes.ts    # Routing configuration
│   │   └── app.config.ts    # App configuration
│   ├── package.json
│   └── angular.json
├── database_migration_board_members.sql
├── pom.xml
└── README.md
```

### Key Architectural Benefits

1. **Separation of Concerns**: Each layer has distinct responsibilities
2. **Maintainability**: Changes in one layer don't affect others
3. **Scalability**: Easy to add new features without impacting existing code
4. **Technology Independence**: Core logic is not tied to specific frameworks
5. **Database Abstraction**: Repository pattern abstracts data access logic

### Data Flow Pattern

1. **Request Flow**: Angular → REST Controller → Application Service → Domain Service → Repository → Database
2. **Response Flow**: Database → Repository → Domain Entity → Application Service → DTO → REST Controller → Angular
3. **Business Logic**: Concentrated in Domain and Application layers
4. **Cross-cutting Concerns**: Handled by Infrastructure layer (logging, security, email)

## 🚦 Prerequisites

- **Java 21** or higher
- **Node.js 18+** and npm
- **SQL Server Express** with SQLEXPRESS instance (or full SQL Server)
- **Maven 3.6+** (included wrapper available with `mvnw`)

## 📊 Database Schema

The application uses a comprehensive database schema supporting:

- **Users**: User accounts and authentication
- **Boards**: Project boards and workspace management  
- **BoardMembers**: User-board relationships with roles (admin/member)
- **BoardInvitations**: Email-based invitation system with expiration
- **Tasks**: Task management within boards
- **Workspaces**: Workspace organization

Key tables:
- `Workspace.Users`
- `Workspace.Boards`
- `Workspace.BoardMembers`
- `Workspace.BoardInvitations`
- `Workspace.Tasks`
- `Workspace.Workspaces`

### Database Features
- **Stored Procedures**: Complex operations like `GetBoardMembers`, `InviteUserToBoard`, `AcceptBoardInvitation`
- **Constraints**: Foreign keys, unique constraints, and check constraints for data integrity
- **Indexes**: Performance optimization for frequent queries
- **Status Management**: Invitation status tracking (PENDING, ACCEPTED, REJECTED, EXPIRED)

## 🔧 Troubleshooting

### Common Issues

**Database Connection Issues:**
- Ensure SQL Server Express is running
- Check if the instance name is correct (SQLEXPRESS is default)
- Verify the database `JammerDB` exists
- Check username/password in `application.properties`

**Email Issues:**
- For Gmail, ensure app passwords are used instead of regular passwords

**Build Issues:**
- Ensure Java 21 is installed
- Clear Maven cache
- For frontend: delete `node_modules` and run `npm install` again

## 🔗 Related Documentation

- [Spring Boot Documentation](https://spring.io/projects/spring-boot)
- [Angular Documentation](https://angular.io/docs)
- [PrimeNG Documentation](https://primeng.org/)
- [SQL Server Documentation](https://docs.microsoft.com/en-us/sql/sql-server/)

---

**Note**: This project is developed for educational purposes as part of Advanced Programming and Database Management Systems coursework.
