package com.event.util;

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.Statement;

public class DbApply {
    public static void main(String[] args) throws Exception {
        if (args.length < 2) {
            System.err.println("Usage: DbApply <dbAdminUser> <dbAdminPass>");
            System.exit(2);
        }
        String adminUser = args[0];
        String adminPass = args[1];

        String url = "jdbc:mysql://localhost:3306/?allowPublicKeyRetrieval=true&useSSL=false&serverTimezone=UTC";

        try (Connection conn = DriverManager.getConnection(url, adminUser, adminPass)) {
            System.out.println("Connected to MySQL as " + adminUser);

            // Apply main schema (creates database, user, tables)
            Path schema = Paths.get("event_system.sql.txt");
            if (Files.exists(schema)) {
                System.out.println("Applying schema: " + schema);
                runSqlFile(conn, schema);
            } else {
                System.out.println("Schema file not found: " + schema.toAbsolutePath());
            }

            // Ensure we use the application database
            try (Statement s = conn.createStatement()) {
                s.execute("USE event_system");
            }

            // Apply test accounts
            Path tests = Paths.get("scripts", "test_accounts.sql");
            if (Files.exists(tests)) {
                System.out.println("Applying test accounts: " + tests);
                runSqlFile(conn, tests);
            } else {
                System.out.println("Test accounts file not found: " + tests.toAbsolutePath());
            }

            // Apply extended test data (events, registrations, payments, reports, waitlist)
            Path testData = Paths.get("scripts", "test_data.sql");
            if (Files.exists(testData)) {
                System.out.println("Applying test data: " + testData);
                runSqlFile(conn, testData);
            } else {
                System.out.println("Test data file not found: " + testData.toAbsolutePath());
            }

            System.out.println("DB script application completed.");
        }
    }

    private static void runSqlFile(Connection conn, Path path) throws Exception {
        String content = new String(Files.readAllBytes(path));

        // Naive split on semicolon followed by line break; good enough for schema and simple inserts
        String[] statements = content.split("(?m);\\s*\\r?\\n");
        for (String stmt : statements) {
            String sql = stmt.trim();
            if (sql.isEmpty()) continue;
            try (Statement s = conn.createStatement()) {
                s.execute(sql);
            }
        }
    }
}
