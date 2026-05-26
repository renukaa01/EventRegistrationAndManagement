USE event_system;

-- Resolve ids
SET @user_id = (SELECT id FROM users WHERE email='test.user@example.com' LIMIT 1);
SET @organizer_id = (SELECT id FROM users WHERE email='organizer@example.com' LIMIT 1);
SET @org_id = (SELECT id FROM organizations WHERE name='Test Organization' LIMIT 1);

-- 1) Create two events (one free, one paid) if not exists
INSERT INTO events (title, description, event_date, location, organization_id, created_by, status, eligibility, capacity, available_seats, price, event_type)
SELECT 'Community Meetup', 'A meetup for community members to network and learn.', DATE_ADD(CURDATE(), INTERVAL 7 DAY), 'Main Hall', @org_id, @organizer_id, 'ACTIVE', 'OPEN', 100, 100, 0.00, 'FREE'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM events WHERE title='Community Meetup' AND event_date = DATE_ADD(CURDATE(), INTERVAL 7 DAY));

INSERT INTO events (title, description, event_date, location, organization_id, created_by, status, eligibility, capacity, available_seats, price, event_type)
SELECT 'Pro Workshop', 'A paid hands-on workshop for professionals.', DATE_ADD(CURDATE(), INTERVAL 14 DAY), 'Conference Room', @org_id, @organizer_id, 'ACTIVE', 'OPEN', 50, 50, 25.00, 'PAID'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM events WHERE title='Pro Workshop' AND event_date = DATE_ADD(CURDATE(), INTERVAL 14 DAY));

-- Resolve inserted event ids
SET @event_meetup = (SELECT id FROM events WHERE title='Community Meetup' AND event_date = DATE_ADD(CURDATE(), INTERVAL 7 DAY) LIMIT 1);
SET @event_workshop = (SELECT id FROM events WHERE title='Pro Workshop' AND event_date = DATE_ADD(CURDATE(), INTERVAL 14 DAY) LIMIT 1);

-- 2) Register test user for meetup (idempotent)
INSERT INTO registrations (user_id, event_id)
SELECT @user_id, @event_meetup
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM registrations WHERE user_id=@user_id AND event_id=@event_meetup);

-- 3) Register test user and organizer for paid workshop and insert payments
INSERT INTO registrations (user_id, event_id)
SELECT @user_id, @event_workshop
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM registrations WHERE user_id=@user_id AND event_id=@event_workshop);

INSERT INTO registrations (user_id, event_id)
SELECT @organizer_id, @event_workshop
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM registrations WHERE user_id=@organizer_id AND event_id=@event_workshop);

-- Payments for workshop (idempotent)
INSERT INTO payments (user_id, event_id, amount, status)
SELECT @user_id, @event_workshop, 25.00, 'SUCCESS'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM payments WHERE user_id=@user_id AND event_id=@event_workshop AND amount=25.00 LIMIT 1);

INSERT INTO payments (user_id, event_id, amount, status)
SELECT @organizer_id, @event_workshop, 25.00, 'SUCCESS'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM payments WHERE user_id=@organizer_id AND event_id=@event_workshop AND amount=25.00 LIMIT 1);

-- 4) Add a sample report by the user for the meetup (idempotent)
INSERT INTO reports (event_id, user_id, reason)
SELECT @event_meetup, @user_id, 'Test report: sample feedback'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM reports WHERE event_id=@event_meetup AND user_id=@user_id);

-- 5) Update available_seats for events (synchronize with registrations)
UPDATE events e
SET e.available_seats = e.capacity - (
    SELECT COUNT(*) FROM registrations r WHERE r.event_id = e.id
)
WHERE e.id IN (@event_meetup, @event_workshop);

-- 6) Insert a waitlist entry example (idempotent)
-- create a fake waitlist user if needed
INSERT INTO users (name, email, password_hash, user_type, role)
SELECT 'Waitlist User', 'waitlist.user@example.com', 'd41d8cd98f00b204e9800998ecf8427e', 'PUBLIC', 'USER'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email='waitlist.user@example.com');

SET @wait_user = (SELECT id FROM users WHERE email='waitlist.user@example.com' LIMIT 1);

INSERT INTO waitlist (user_id, event_id)
SELECT @wait_user, @event_workshop
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM waitlist WHERE user_id=@wait_user AND event_id=@event_workshop);

-- Final verification selects (harmless)
SELECT id, title, event_date, capacity, available_seats FROM events WHERE id IN (@event_meetup, @event_workshop);
SELECT id, user_id, event_id FROM registrations WHERE event_id IN (@event_meetup, @event_workshop);
SELECT id, user_id, event_id, amount, status FROM payments WHERE event_id=@event_workshop;
