USE event_system;

-- 1. Modify Events Table
ALTER TABLE events CHANGE event_type participation_mode ENUM('FREE', 'PAID') DEFAULT 'FREE';
ALTER TABLE events ADD COLUMN event_type ENUM('INDIVIDUAL', 'TEAM') DEFAULT 'INDIVIDUAL' AFTER participation_mode;
ALTER TABLE events ADD COLUMN max_team_size INT DEFAULT 1;
ALTER TABLE events ADD COLUMN min_team_size INT DEFAULT 1;
ALTER TABLE events ADD COLUMN custom_form_schema TEXT;

-- 2. Create Teams Tables
CREATE TABLE IF NOT EXISTS teams (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    event_id INT,
    leader_user_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE,
    FOREIGN KEY (leader_user_id) REFERENCES users(id),
    CONSTRAINT unique_team_event UNIQUE (name, event_id)
);

CREATE TABLE IF NOT EXISTS team_members (
    id INT AUTO_INCREMENT PRIMARY KEY,
    team_id INT,
    user_id INT,
    FOREIGN KEY (team_id) REFERENCES teams(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT unique_user_team UNIQUE (team_id, user_id)
);

-- 3. Modify Registrations Table
ALTER TABLE registrations ADD COLUMN team_id INT NULL;
ALTER TABLE registrations ADD CONSTRAINT fk_reg_team FOREIGN KEY (team_id) REFERENCES teams(id) ON DELETE CASCADE;
ALTER TABLE registrations ADD COLUMN custom_answers TEXT;
ALTER TABLE registrations ADD COLUMN payment_screenshot_path VARCHAR(255);

-- 4. Add 'report_count' to events instead of counting dynamically for performance
ALTER TABLE events ADD COLUMN report_count INT DEFAULT 0;

-- 5. Upgrade Payments Table for Verification Module
ALTER TABLE payments MODIFY COLUMN status ENUM('PENDING', 'SUCCESS', 'FAILED') DEFAULT 'PENDING';
ALTER TABLE payments ADD COLUMN payment_screenshot_path VARCHAR(255);

-- 6. Escrow tracking for Waitlist Automation bypassing Verification
ALTER TABLE waitlist ADD COLUMN payment_screenshot_path VARCHAR(255);

-- 7. Ticketing Engine
CREATE TABLE IF NOT EXISTS tickets (
    id VARCHAR(100) PRIMARY KEY,
    event_id INT NOT NULL,
    user_id INT NULL,
    team_id INT NULL,
    ticket_type ENUM('INDIVIDUAL', 'TEAM') NOT NULL,
    status ENUM('ACTIVE', 'CANCELLED', 'USED') DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (team_id) REFERENCES teams(id) ON DELETE CASCADE,
    CONSTRAINT unique_tkt UNIQUE (event_id, user_id, team_id)
);

-- Phase 3 Expansion: User Notifications
CREATE TABLE IF NOT EXISTS user_notifications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    message VARCHAR(500) NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
