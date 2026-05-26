# EventRegistrationAndManagement

A full-stack Event Registration and Management System designed to handle various aspects of organizing and attending events. The system offers an interactive and user-friendly interface for both event organizers and attendees.

## Features
- **User Roles:** Distinct dashboards for Attendees and Administrators/Organizers.
- **Event Management:** Create, edit, publish, delete, and manage events effortlessly.
- **Registrations:** Support for individual and team-based registrations.
- **Ticketing System:** Digital ticket generation for verified attendees.
- **Payment Verification:** Manage payment statuses for attendees.
- **Waitlist Handling:** Automatic waitlist management for fully booked events.
- **Attendee Check-in:** System for checking in attendees on the day of the event.
- **Reporting:** Export registrations and generate event reports.

## Technology Stack
- **Frontend:** HTML, CSS, JavaScript, JSP (JavaServer Pages)
- **Backend:** Java (Servlets)
- **Database:** MySQL (JDBC for connectivity)
- **Build Tool:** Maven
- **IDE Support:** Eclipse / VS Code

## Prerequisites
Before you begin, ensure you have met the following requirements:
- **Java Development Kit (JDK):** Version 8 or higher.
- **Database:** MySQL Server installed and running.
- **Server:** Apache Tomcat or an embedded server like Jetty.
- **Maven:** Installed (or use the embedded Maven wrapper).

## Database Setup
1. Open your MySQL client (e.g., MySQL Workbench or CLI).
2. Create the database and import the required schema:
   - Execute the SQL script `event_system.sql.txt` to initialize the base tables.
   - Execute `advance_migrations.sql` to apply the latest schema updates.
3. Update the database connection credentials:
   - Navigate to `src/main/java/com/event/util/DBConnection.java` or `DbApply.java` (depending on the active configuration) and update the `DB_URL`, `USER`, and `PASSWORD` to match your local MySQL setup.

## Installation and Running locally

### Using Eclipse IDE
1. Open Eclipse and select **File > Import**.
2. Choose **Existing Maven Projects** and browse to the cloned repository directory.
3. Click Finish to import the project.
4. Right-click the project, select **Run As > Run on Server**, and choose your configured Apache Tomcat server.

### Using Maven (Command Line)
1. Open a terminal and navigate to the project directory.
2. Build the project:
   ```bash
   mvn clean install
   ```
3. Run the project (if using an embedded Jetty plugin in `pom.xml`):
   ```bash
   mvn jetty:run
   ```
4. Access the application in your browser at `http://localhost:8080/EventRegistrationAndManagement` (or simply `http://localhost:8080` depending on the configuration).

## Contributing
Contributions are always welcome! Feel free to open a pull request or an issue if you have any suggestions or find a bug.
