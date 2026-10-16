-- Project: Event Management System SQL Database
-- File: event_management.sql

CREATE DATABASE event_management_db;
USE event_management_db;

-- Drop tables if they already exist to ensure a clean slate
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS tickets;
DROP TABLE IF EXISTS events;
DROP TABLE IF EXISTS organizers;
DROP TABLE IF EXISTS venues;
DROP TABLE IF EXISTS attendees;

-- Create Venues Table
CREATE TABLE venues (
    venue_id INT AUTO_INCREMENT PRIMARY KEY,
    venue_name VARCHAR(100) NOT NULL,
    city VARCHAR(50),
    capacity INT
);

-- Create Organizers Table
CREATE TABLE organizers (
    organizer_id INT AUTO_INCREMENT PRIMARY KEY,
    organizer_name VARCHAR(100) NOT NULL,
    email VARCHAR(100)
);

-- Create Events Table
CREATE TABLE events (
    event_id INT AUTO_INCREMENT PRIMARY KEY,
    event_name VARCHAR(100) NOT NULL,
    event_date DATETIME NOT NULL,
    venue_id INT,
    organizer_id INT,
    total_seats INT NOT NULL,
    available_seats INT NOT NULL,
    ticket_price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (venue_id) REFERENCES venues(venue_id) ON DELETE SET NULL,
    FOREIGN KEY (organizer_id) REFERENCES organizers(organizer_id) ON DELETE SET NULL
);

-- Create Attendees Table
CREATE TABLE attendees (
    attendee_id INT AUTO_INCREMENT PRIMARY KEY,
    attendee_name VARCHAR(100) NOT NULL,
    email VARCHAR(100)
);

-- Create Tickets Table (Enforces unique constraint to prevent double bookings)
CREATE TABLE tickets (
    ticket_id INT AUTO_INCREMENT PRIMARY KEY,
    event_id INT NOT NULL,
    attendee_id INT NOT NULL,
    booking_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (event_id) REFERENCES events(event_id) ON DELETE CASCADE,
    FOREIGN KEY (attendee_id) REFERENCES attendees(attendee_id) ON DELETE CASCADE,
    CONSTRAINT unique_attendee_event UNIQUE (event_id, attendee_id)
);

-- Create Payments Table
CREATE TABLE payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    ticket_id INT,
    amount DECIMAL(10, 2) NOT NULL,
    payment_status VARCHAR(20) NOT NULL,
    payment_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ticket_id) REFERENCES tickets(ticket_id) ON DELETE CASCADE
);

-- ------------------------------------------------------------
-- 2. SAMPLE DATA INSERTION
-- ------------------------------------------------------------

INSERT INTO venues (venue_name, city, capacity) VALUES
('Grand Hall', 'New York', 500),
('City Center', 'Chicago', 300),
('Tech Park Auditorium', 'San Francisco', 1000),
('Open Air Arena', 'Austin', 1500);
select * from venues;

INSERT INTO organizers (organizer_name, email) VALUES
('tech global inc', 'contact@techglobal.com'),
('music fest org', 'info@musicfest.com'),
('corp events co', NULL),
('community hub', 'hello@communityhub.org'),
('creative minds', 'support@creativeminds.com');
select*from organizers;

INSERT INTO events (event_name, event_date, venue_id, organizer_id, total_seats, available_seats, ticket_price) VALUES
('Tech Conference 2026', '2026-11-15 09:00:00', 1, 1, 500, 50, 150.00),
('Music Festival', '2026-12-01 18:00:00', 4, 2, 1000, 300, 80.00),
('Business Leadership Summit', '2026-10-25 10:00:00', 2, 1, 200, 150, 200.00),
('AI & Data Expo', '2026-11-01 09:30:00', 3, 1, 800, 50, 250.00),
('Local Art Workshop', '2026-10-20 14:00:00', NULL, 4, 50, 45, 30.00),
('Developer Summit', '2026-12-10 10:00:00', 1, 1, 400, 100, 120.00);
select*from events;

INSERT INTO attendees (attendee_name, email) VALUES
('  Alice Smith  ', 'alice@example.com'),
('Bob Johnson', NULL),
(' Charlie Brown ', 'charlie@example.com'),
('Diana Prince', 'diana@example.com'),
('  Evan Wright', NULL),
('Fiona Gallagher', 'fiona@example.com');
select*from attendees;

INSERT INTO tickets (event_id, attendee_id, booking_date) VALUES
(1, 1, '2026-10-01 10:00:00'),
(1, 2, '2026-10-02 11:30:00'),
(2, 1, '2026-10-03 14:15:00'),
(2, 3, '2026-10-04 09:00:00'),
(3, 4, '2026-10-05 16:45:00'),
(4, 1, '2026-10-06 12:00:00'),
(4, 5, '2026-10-07 15:30:00');
select*from tickets;

INSERT INTO payments (ticket_id, amount, payment_status, payment_date) VALUES
(1, 150.00, 'Success', '2026-10-01 10:05:00'),
(2, 150.00, 'Failed', '2026-10-02 11:35:00'),
(3, 80.00, 'Success', '2026-10-03 14:20:00'),
(4, 80.00, 'Success', '2026-10-04 09:05:00'),
(5, 200.00, 'Pending', '2026-10-05 16:50:00'),
(6, 250.00, 'Success', '2026-10-06 12:10:00');
select*from payments;

-- ------------------------------------------------------------
-- 4. BASIC QUERIES (Sorting, Counting, Total Revenue)
-- ------------------------------------------------------------

-- Sort events by date in ascending order
SELECT event_id, event_name, event_date, ticket_price
FROM events
ORDER BY event_date ASC;

-- Count the number of attendees per event
SELECT e.event_id, e.event_name, COUNT(t.attendee_id) AS attendee_count
FROM events e
LEFT JOIN tickets t ON e.event_id = t.event_id
GROUP BY e.event_id, e.event_name;

-- Show the total revenue generated per event
SELECT e.event_id, e.event_name, COALESCE(SUM(p.amount), 0) AS total_revenue
FROM events e
JOIN tickets t ON e.event_id = t.event_id
JOIN payments p ON t.ticket_id = p.ticket_id
WHERE p.payment_status = 'Success'
GROUP BY e.event_id, e.event_name;

-- ------------------------------------------------------------
-- 5. AGGREGATE FUNCTIONS (SUM, AVG, MAX, MIN, COUNT)
-- ------------------------------------------------------------

-- Calculate the total revenue generated from all events
SELECT SUM(amount) AS total_revenue_all_events
FROM payments
WHERE payment_status = 'Success';

-- Find the event with the highest number of attendees
SELECT e.event_id, e.event_name, COUNT(t.attendee_id) AS max_attendees
FROM events e
JOIN tickets t ON e.event_id = t.event_id
GROUP BY e.event_id, e.event_name
ORDER BY max_attendees DESC
LIMIT 1;

-- Compute the average ticket price across all events
SELECT AVG(ticket_price) AS average_ticket_price
FROM events;

-- ------------------------------------------------------------
-- 6. PRIMARY & FOREIGN KEY RELATIONSHIPS
-- ------------------------------------------------------------
-- Constraint 1: UNIQUE(event_id, attendee_id) in 'tickets' table prevents double bookings.
-- Constraint 2: FOREIGN KEY (ticket_id) REFERENCES tickets(ticket_id) in 'payments' links payments to tickets.

-- ------------------------------------------------------------
-- 7. JOINS (INNER, LEFT, RIGHT, FULL OUTER JOIN)
-- ------------------------------------------------------------

-- INNER JOIN: Retrieve event details along with venue information
SELECT e.event_id, e.event_name, e.event_date, v.venue_name, v.city
FROM events e
INNER JOIN venues v ON e.venue_id = v.venue_id;

-- LEFT JOIN: Get a list of attendees who booked a ticket but did not complete payment
SELECT a.attendee_id, a.attendee_name, t.ticket_id, p.payment_status
FROM attendees a
JOIN tickets t ON a.attendee_id = t.attendee_id
LEFT JOIN payments p ON t.ticket_id = p.ticket_id
WHERE p.payment_status IS NULL OR p.payment_status != 'Success';

-- RIGHT JOIN: Identify events without any attendees
SELECT e.event_id, e.event_name
FROM tickets t
RIGHT JOIN events e ON t.event_id = e.event_id
WHERE t.ticket_id IS NULL;

-- FULL OUTER JOIN (Emulated via UNION for MySQL compatibility): Show attendees who have not booked any ticket
SELECT a.attendee_id, a.attendee_name, t.ticket_id
FROM attendees a
LEFT JOIN tickets t ON a.attendee_id = t.attendee_id
WHERE t.ticket_id IS NULL
UNION
SELECT a.attendee_id, a.attendee_name, t.ticket_id
FROM attendees a
RIGHT JOIN tickets t ON a.attendee_id = t.attendee_id
WHERE a.attendee_id IS NULL;

-- ------------------------------------------------------------
-- 8. SUBQUERIES
-- ------------------------------------------------------------

-- Find events that generated revenue above the average ticket sales
SELECT event_id, event_name, total_revenue
FROM (
    SELECT e.event_id, e.event_name, SUM(p.amount) AS total_revenue
    FROM events e
    JOIN tickets t ON e.event_id = t.event_id
    JOIN payments p ON t.ticket_id = p.ticket_id
    WHERE p.payment_status = 'Success'
    GROUP BY e.event_id, e.event_name
) AS event_revenues
WHERE total_revenue > (
    SELECT AVG(event_revenue)
    FROM (
        SELECT SUM(p.amount) AS event_revenue
        FROM tickets t
        JOIN payments p ON t.ticket_id = p.ticket_id
        WHERE p.payment_status = 'Success'
        GROUP BY t.event_id
    ) AS avg_table
);

-- Identify attendees who have booked tickets for multiple events
SELECT attendee_id, attendee_name
FROM attendees
WHERE attendee_id IN (
    SELECT attendee_id
    FROM tickets
    GROUP BY attendee_id
    HAVING COUNT(DISTINCT event_id) > 1
);

-- Retrieve organizers who have managed more than 3 events
SELECT organizer_id, organizer_name
FROM organizers
WHERE organizer_id IN (
    SELECT organizer_id
    FROM events
    GROUP BY organizer_id
    HAVING COUNT(event_id) > 3
);

-- ------------------------------------------------------------
-- 9. DATE & TIME FUNCTIONS
-- ------------------------------------------------------------

-- Extract the month from event_date to analyze event trends
SELECT event_id, event_name, event_date,
       MONTHNAME(event_date) AS event_month,
       MONTH(event_date) AS month_number
FROM events;

-- Calculate the number of days remaining for an upcoming event
SELECT event_id, event_name, event_date,
       DATEDIFF(event_date, NOW()) AS days_remaining
FROM events
WHERE event_date > NOW();

-- Format payment_date as YYYY-MM-DD HH:MM:SS
SELECT payment_id, amount,
       DATE_FORMAT(payment_date, '%Y-%m-%d %H:%i:%s') AS formatted_payment_date
FROM payments;

-- ------------------------------------------------------------
-- 10. STRING MANIPULATION FUNCTIONS
-- ------------------------------------------------------------

-- Convert all organizer names to uppercase
SELECT organizer_id, UPPER(organizer_name) AS uppercase_organizer_name
FROM organizers;

-- Remove extra spaces from attendee names using TRIM()
SELECT attendee_id, TRIM(attendee_name) AS cleaned_attendee_name
FROM attendees;

-- Replace NULL email fields with "Not Provided"
SELECT attendee_id, attendee_name,
       COALESCE(email, 'Not Provided') AS email_status
FROM attendees;

-- ------------------------------------------------------------
-- 11. WINDOW FUNCTIONS
-- ------------------------------------------------------------

-- Rank events based on total revenue earned
SELECT e.event_id, e.event_name, SUM(p.amount) AS total_revenue,
       RANK() OVER (ORDER BY SUM(p.amount) DESC) AS revenue_rank
FROM events e
JOIN tickets t ON e.event_id = t.event_id
JOIN payments p ON t.ticket_id = p.ticket_id
WHERE p.payment_status = 'Success'
GROUP BY e.event_id, e.event_name;

-- Display the cumulative sum of ticket sales
SELECT ticket_id, booking_date, amount,
       SUM(amount) OVER (ORDER BY booking_date) AS cumulative_ticket_sales
FROM (
    SELECT t.ticket_id, t.booking_date, p.amount
    FROM tickets t
    JOIN payments p ON t.ticket_id = p.ticket_id
    WHERE p.payment_status = 'Success'
) AS successful_sales;

-- Show the running total of attendees registered per event
SELECT event_id, ticket_id, booking_date,
       COUNT(ticket_id) OVER (PARTITION BY event_id ORDER BY booking_date) AS running_attendee_count
FROM tickets;

-- ------------------------------------------------------------
-- 12. SQL CASE EXPRESSIONS
-- ------------------------------------------------------------

-- Categorize events based on ticket sales / availability
SELECT event_id, event_name, available_seats, total_seats,
       CASE 
           WHEN available_seats < (0.20 * total_seats) THEN 'High Demand'
           WHEN available_seats BETWEEN (0.20 * total_seats) AND (0.50 * total_seats) THEN 'Moderate Demand'
           ELSE 'Low Demand'
       END AS demand_category
FROM events;

-- Assign payment statuses using CASE
SELECT payment_id, ticket_id, amount, payment_status,
       CASE 
           WHEN payment_status = 'Success' THEN 'Successful'
           WHEN payment_status = 'Failed' THEN 'Failed'
           ELSE 'Pending'
       END AS categorized_payment_status
FROM payments;