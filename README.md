# event_management_system
Event Management System Database Project

Welcome to the Event Management System relational database project! This project is a comprehensive SQL database solution designed to manage events, venues, organizers, attendees, ticket sales, and payment tracking efficiently.

This repository contains the complete database setup, data relationships, and analytical SQL queries built following industry-standard database practices.

📌 Table of Contents

Project Overview

Database Architecture & Schema

Entity Relationship Summary

Key Features & Business Rules

Detailed Breakdown of SQL Queries

1. Data Definition & Insertion
2. Basic Data Aggregation
3. Aggregate Function
4. Table Joins (INNER, LEFT, RIGHT, FULL OUTER)
5. Advanced Subqueries
6. Date & Time Manipulation
7. String Functions & Cleaning
8. Window Functions
9. Conditional Logic (CASE Expressions)
   
How to Run This Project

File Structure

📌 Project Overview

Managing events requires handling interrelated information—such as ticket availability, registered attendees, organizer assignments, and transaction records.
This project solves those requirements by building a structured MySQL relational database. The system automates:
Tracking event ticket sales and calculating total revenue generated.
Enforcing business constraints (preventing duplicate ticket purchases for the same event by an attendee).
Categorizing event seat demand dynamically (High Demand, Moderate Demand, Low Demand).
Analyzing customer purchasing trends using Advanced Window Functions and Date/Time operations.

🏗️ Database Architecture & Schema

The system relies on 6 core relational tables:

                  +------------------+
                  |     VENUES       |
                  +------------------+
                           | 1
                           |
                           | N
                  +------------------+         +------------------+
                  |      EVENTS      |<--------|    ORGANIZERS    |
                  +------------------+ N     1 +------------------+
                           | 1
                           |
                           | N
                  +------------------+
                  |     TICKETS      |
                  +------------------+
                   /               \
                N /                 \ 1
                 /                   \
+------------------+               +------------------+
|    ATTENDEES     |               |     PAYMENTS     |
+------------------+               +------------------+


Table Definitions:

venues
venue_id (INT, Primary Key, Auto Increment)
venue_name (VARCHAR)
city (VARCHAR)
capacity (INT)
organizers
organizer_id (INT, Primary Key, Auto Increment)
organizer_name (VARCHAR)
email (VARCHAR)
events
event_id (INT, Primary Key, Auto Increment)
event_name (VARCHAR)
event_date (DATETIME)
venue_id (INT, Foreign Key referencing venues)
organizer_id (INT, Foreign Key referencing organizers)
total_seats (INT)
available_seats (INT)
ticket_price (DECIMAL)
attendees
attendee_id (INT, Primary Key, Auto Increment)
attendee_name (VARCHAR)
email (VARCHAR)
tickets
ticket_id (INT, Primary Key, Auto Increment)
event_id (INT, Foreign Key referencing events)
attendee_id (INT, Foreign Key referencing attendees)
booking_date (DATETIME)
Constraint: UNIQUE(event_id, attendee_id) to prevent multi-booking of the same event.
payments
payment_id (INT, Primary Key, Auto Increment)
ticket_id (INT, Foreign Key referencing tickets)
amount (DECIMAL)
payment_status (VARCHAR: 'Success', 'Pending', 'Failed')
payment_date (DATETIME)

🔑 Key Features & Business Rules

Unique Ticket Booking Guarantee: A UNIQUE composite constraint on (event_id, attendee_id) prevents attendees from purchasing multiple tickets to the exact same event.

Cascading Relationships: Foreign key constraints ensure relational integrity. Deleting a ticket automatically cleans up associated payment records (ON DELETE CASCADE).

Data Sanitation: String formatting routines (TRIM(), UPPER(), COALESCE()) handle trailing whitespace and missing values gracefully.

🚀 Detailed Breakdown of SQL Queries

1. Data Definition & Insertion
Creates tables with appropriate foreign keys and populates them with sample data representing organizers, venues, events, attendees, tickets, and payments.

2. Basic Data Aggregation
Chronological Sorting: Sorts all upcoming events in ascending order by date.
Attendee Counting: Calculates the number of ticket holders per event.
Revenue Per Event: Sums total revenue generated for each event.

3. Aggregate Functions
Calculates cumulative revenue across all events using SUM().
Identifies the single event with the highest attendee count using COUNT() and LIMIT 1.
Computes the global average ticket price using AVG().

4. Table Joins
INNER JOIN: Combines events and venue records to show event locations.
LEFT JOIN: Filters attendees who booked tickets but have incomplete/failed payments.
RIGHT JOIN: Identifies newly listed events that currently have zero ticket bookings.
FULL OUTER JOIN (Emulated via UNION): Uncovers unbooked attendees and orphaned ticket records.

6. Advanced Subqueries
Finds top-performing events that generated total revenue above the average ticket sales across all events.
Identifies frequent attendees who have booked tickets for more than one event.
Lists active organizers managing more than 3 distinct events.

6. Date & Time Manipulation.
MONTHNAME() / MONTH(): Extracts monthly trends from event dates.
DATEDIFF(): Calculates how many days remain before an upcoming event occurs.
DATE_FORMAT(): Standardizes payment dates into readable YYYY-MM-DD HH:MM:SS format.

7. String Functions & Cleaning
UPPER(): Converts all organizer names to uppercase for standardized reporting.
TRIM(): Cleans up trailing and leading spaces from attendee inputs.
COALESCE(): Replaces NULL values in attendee emails with a default string "Not Provided".

8. Window Functions
RANK() OVER (): Ranks events dynamically according to total revenue earned
SUM() OVER (): Calculates cumulative running totals for ticket sales over time.
COUNT() OVER (): Tracks a running total of registered attendees per event partitioned by event_id.

9. Conditional Logic (CASE Expressions)
Demand Classification: Categorizes events into High Demand, Moderate Demand, or Low Demand depending on seat availability percentages:


$$\text{Demand Status} = \begin{cases} \text{High Demand} & \text{if } \text{available\_seats} < 20\% \text{ of } \text{total\_seats} \\ \text{Moderate Demand} & \text{if } 20\% \le \text{available\_seats} \le 50\% \text{ of } \text{total\_seats} \\ \text{Low Demand} & \text{otherwise} \end{cases}$$

Payment Mapping: Maps raw payment statuses (Success, Failed, Pending) into clean user-facing status labels.
