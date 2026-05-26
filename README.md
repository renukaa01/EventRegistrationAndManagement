# Event Registration and Management

## 📂 Project Structure (Eclipse)
```text
EventRegistrationAndManagement/
├── src/main/java/          # Java source code (Controllers, Models, DAOs, Services)
│   └── com/event/          # Main application package
├── src/main/webapp/        # Frontend resources (JSP, CSS, HTML)
│   ├── WEB-INF/            # Web application configuration (web.xml)
│   └── jsp/                # View templates for the application
├── pom.xml                 # Maven configuration and dependencies
├── .classpath              # Eclipse classpath configuration
├── .project                # Eclipse project configuration
├── .settings/              # Eclipse workspace settings for the project
├── event_system.sql.txt    # Base database schema
└── advance_migrations.sql  # Database schema updates
```

## ✨ Features

### 🧑‍💼 Organizer
- **Dashboard:** Get an overview of all created events and attendee statistics.
- **Event Management:** Create, publish, edit, and delete events easily.
- **Ticketing & Payments:** Manage digital tickets and verify offline payments from attendees.
- **Waitlist Management:** Handle overflow registrations automatically when events reach maximum capacity.
- **Check-In System:** Mark attendees as checked in on the day of the event.
- **Reporting:** Export registrations and attendee lists for logistics planning.

### 👤 Attendee
- **User Dashboard:** Browse upcoming events and see your registration history.
- **Event Registration:** Register for events as an individual or join/create a team.
- **My Tickets:** View and manage digital tickets for verified registrations.
- **Payment Status:** Check whether your offline payment has been verified by the organizer.

## ⚙️ Setup Instructions

### 1. Database Setup
1. Ensure MySQL Server is installed and running on your local machine.
2. Open your preferred MySQL client (e.g., MySQL Workbench).
3. Execute the `event_system.sql.txt` script to create the database and base tables.
4. Next, execute the `advance_migrations.sql` script to apply the latest database updates.
5. Update your database credentials (URL, username, and password) in `src/main/java/com/event/util/DBConnection.java` and `src/main/java/com/event/util/DbApply.java`.

### 2. Eclipse IDE Setup
1. Clone the repository to your local machine.
2. Open Eclipse and navigate to **File > Import**.
3. Select **Maven > Existing Maven Projects** and browse to the cloned repository directory.
4. Click **Finish** to import the project. Let Eclipse download the necessary Maven dependencies.
5. Right-click the imported project in the Project Explorer, select **Run As > Run on Server**.
6. Select your configured server (e.g., Apache Tomcat) and click **Finish**.
7. The application will launch in your browser (usually at `http://localhost:8080/EventRegistrationAndManagement`).

## 🏗️ Architecture

This project is built using a classic **Model-View-Controller (MVC)** architecture utilizing Java web technologies:

- **View (JSP):** The presentation layer. It handles displaying data to the user and collecting input via HTML forms (`src/main/webapp/jsp`).
- **Controller (Servlets):** The business logic coordinator. It receives HTTP requests from the View, processes the logic, interacts with the Service and DAO layers, and forwards the appropriate response back to the View (`com.event.controller`).
- **Model (Java Beans & DAO):** The data layer. It includes Data Objects representing entities like Events, Users, and Tickets (`com.event.model`), and Data Access Objects (DAO) that manage raw interactions with the MySQL Database using JDBC (`com.event.dao`).

The application is built and managed using **Maven** and is designed to run in any standard Java Servlet Container (such as **Apache Tomcat**).
