# Event Registration and Management

The **Event Registration and Management** system is a comprehensive, full-stack Java web application designed to streamline the planning, registration, and administration of events. It provides a seamless experience for organizers to manage ticketing, capacities, and payments, while giving attendees an intuitive platform to discover events, register as individuals or teams, and access digital tickets.

## Technology Stack

| Component | Technology |
| :--- | :--- |
| **Language** | Java 17 |
| **Web Framework** | Jakarta Servlet 6.0 + JSP 3.1 |
| **Tag Library** | JSTL 3.0 |
| **Web Server** | Apache Tomcat 11 |
| **Database** | MySQL 8.0 |
| **JDBC Driver** | mysql-connector-j 8.0.33 |
| **Build Tool** | Apache Maven |
| **IDE** | Eclipse IDE for Enterprise Java |

## Project Structure (Eclipse)

```text
EventRegistrationAndManagement/
├── .classpath              # Eclipse classpath config
├── .project                # Eclipse project descriptor
├── .settings/              # Eclipse workspace settings
├── pom.xml                 # Maven build file
└── src/
    └── main/
        ├── java/com/event/
        │   ├── controller/ # 30 Servlets (LoginServlet, AddEventServlet, etc.)
        │   ├── service/    # Business logic (EventService, UserService)
        │   ├── dao/        # Data Access (EventDAO, UserDAO, TeamDAO, TicketDAO)
        │   ├── model/      # POJOs (User, Event, Team, Ticket, Notification)
        │   └── util/       # DBConnection, PasswordUtil
        └── webapp/
            ├── index.jsp   # Landing page
            ├── css/        # Stylesheets
            ├── jsp/        # 21 JSP pages
            ├── uploads/    # Payment screenshots (runtime)
            └── WEB-INF/
                ├── web.xml # Deployment descriptor
                └── lib/    # Libraries
```

## Features

### Attendee
- Browse and filter events (by title, date, location, eligibility)
- Register for individual or team events with custom forms
- Upload payment screenshots for paid events
- Receive digital tickets (TKT-XXXXXXXX)
- Join waitlist when event is full (auto-promoted on cancellations)
- Manage team members, cancel registration
- In-app notifications

### Organizer
- Create organization and host events
- Configure capacity, pricing, eligibility, custom form fields
- Verify payment screenshots (approve/reject)
- Check-in attendees on event day using ticket IDs
- Broadcast announcements to all registrants
- Export registration data as CSV
- View attendees, waitlist, and cancellations

## Setup Instructions

### Prerequisites
- Java 17 (JDK)
- Apache Tomcat 11
- MySQL 8.0
- Eclipse IDE for Enterprise Java Developers
- Maven

### Database Setup

```sql
CREATE DATABASE event_system;
CREATE USER 'event_user'@'localhost' IDENTIFIED BY 'Event@123';
GRANT ALL PRIVILEGES ON event_system.* TO 'event_user'@'localhost';
FLUSH PRIVILEGES;
```
*(Also, remember to import your SQL scripts `event_system.sql.txt` and `advance_migrations.sql` into the `event_system` database).*

### Import in Eclipse
1. Open Eclipse → File → Import → Maven → Existing Maven Projects
2. Browse to this project folder and click Finish
3. Right-click project → Maven → Update Project
4. Right-click project → Run As → Run on Server → Select Tomcat 11
5. Open browser → `http://localhost:8080/EventRegistrationAndManagement/`

## Architecture

The project follows **MVC** with DAO and Service layers:

```text
Browser (JSP) → Servlets (Controller) → Service → DAO → MySQL
```
