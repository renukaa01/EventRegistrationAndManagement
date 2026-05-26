USE event_system;

-- 1) Insert a normal user (idempotent)
INSERT INTO users (name, email, password_hash, user_type, role)
SELECT 'Test User', 'test.user@example.com', 'a109e36947ad56de1dca1cc49f0ef8ac9ad9a7b1aa0df41fb3c4cb73c1ff01ea', 'PUBLIC', 'USER'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email='test.user@example.com');

-- 2) Insert an organizer user (idempotent)
INSERT INTO users (name, email, password_hash, user_type, role)
SELECT 'Test Organizer', 'organizer@example.com', 'f8dbe23466ff7375d8173c4fe272b5c4d3f2f5dad748f5bbbe5f8ca07ce63ca5', 'COMPANY', 'USER'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email='organizer@example.com');

SET @org_admin_id = (SELECT id FROM users WHERE email='organizer@example.com' LIMIT 1);

-- Create organization if not exists
INSERT INTO organizations (name, type, admin_user_id)
SELECT 'Test Organization','COMPANY', @org_admin_id
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name='Test Organization');

-- Make the organizer an ADMIN (idempotent)
UPDATE users SET role='ADMIN' WHERE email='organizer@example.com' AND role <> 'ADMIN';

-- Verification selects (harmless)
SELECT id, name, email, role FROM users WHERE email IN ('test.user@example.com','organizer@example.com');
SELECT id, name, admin_user_id FROM organizations WHERE name='Test Organization';
