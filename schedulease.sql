/*
PostgreSQL Database Schema for SchedulEase (Online Appointment System)

Source Server         : PostgreSQL Database
Source Server Version : 15+
Source Host           : localhost:5432
Source Database       : schedulease

Target Server Type    : PostgreSQL
Target Server Version : 15+
File Encoding         : UTF8

Date: 2025-10-23

SchedulEase - Online Appointment System Database Design
*/

-- ============================================================================
-- 1. DROP TABLES
-- ============================================================================

DROP TABLE IF EXISTS appointments CASCADE;
DROP TABLE IF EXISTS service CASCADE;
DROP TABLE IF EXISTS provider CASCADE;
DROP TABLE IF EXISTS client CASCADE;


-- ============================================================================
-- 2 CREATE TABLES
-- ============================================================================

-- ---------------------------------------------------------------------------
-- 2.1 Client Table
-- ---------------------------------------------------------------------------
CREATE TABLE client (
    id BIGSERIAL PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone VARCHAR(15) NOT NULL
);

-- ---------------------------------------------------------------------------
-- 2.2 Provider Table
-- ---------------------------------------------------------------------------
CREATE TABLE provider (
    id BIGSERIAL PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    description TEXT,
    is_active BOOLEAN NOT NULL DEFAULT TRUE
);

-- ---------------------------------------------------------------------------
-- 2.3 Service Table
-- ---------------------------------------------------------------------------
CREATE TABLE service (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL UNIQUE,
    description TEXT,
    category VARCHAR(50) NOT NULL,
    duration INTEGER NOT NULL,
    price DECIMAL(10,2),
    is_active BOOLEAN NOT NULL DEFAULT TRUE
);

-- ---------------------------------------------------------------------------
-- 2.4 Appointments Table
-- ---------------------------------------------------------------------------
CREATE TABLE appointments (
    id BIGSERIAL PRIMARY KEY,
    client_id BIGINT NOT NULL,
    provider_id BIGINT NOT NULL,
    service_id BIGINT NOT NULL,
    start_time BIGINT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'CONFIRMED',
    notes TEXT,
    cancellation_reason TEXT,
    CONSTRAINT fk_appointments_client FOREIGN KEY (client_id) 
        REFERENCES client(id) ON DELETE CASCADE,
    CONSTRAINT fk_appointments_provider FOREIGN KEY (provider_id) 
        REFERENCES provider(id) ON DELETE CASCADE,
    CONSTRAINT fk_appointments_service FOREIGN KEY (service_id) 
        REFERENCES service(id) ON DELETE CASCADE,
    CONSTRAINT check_appointment_status CHECK (status IN ('CONFIRMED', 'CANCELLED', 'COMPLETED', 'NO_SHOW'))
);

CREATE UNIQUE INDEX uk_appointments_time_slot 
    ON appointments(provider_id, service_id, start_time) 
    WHERE status NOT IN ('CANCELLED');

-- ============================================================================
-- 3. CREATE INDEXES
-- ============================================================================


CREATE INDEX idx_provider_active ON provider(is_active);
CREATE INDEX idx_service_active ON service(is_active);
CREATE INDEX idx_service_category ON service(category);

CREATE INDEX idx_appointments_client ON appointments(client_id);
CREATE INDEX idx_appointments_provider ON appointments(provider_id);
CREATE INDEX idx_appointments_service ON appointments(service_id);
CREATE INDEX idx_appointments_start_time ON appointments(start_time);
CREATE INDEX idx_appointments_status ON appointments(status);

-- ============================================================================
-- 4. INSERT TEST DATA
-- ============================================================================

-- ---------------------------------------------------------------------------
-- 4.1 Provider Data
-- ---------------------------------------------------------------------------
INSERT INTO provider (id, first_name, last_name, description, is_active) VALUES
(1, 'Emma', 'Zhang', 'Senior hairstylist, 10 years experience', TRUE),
(2, 'Olivia', 'Zhao', 'Professional hairstylist, 6 years experience', TRUE),
(3, 'Lucas', 'Martinez', 'Expert hairstylist, 8 years experience', FALSE),
(4, 'Michael', 'Wang', 'Massage therapist, 12 years experience', TRUE),
(5, 'James', 'Chen', 'Professional massage technician, 9 years experience', TRUE),
(6, 'Sophia', 'Li', 'Certified massage therapist, 7 years experience', TRUE); 

SELECT setval('provider_id_seq', (SELECT MAX(id) FROM provider));

-- ---------------------------------------------------------------------------
-- 4.2 Service Data
-- ---------------------------------------------------------------------------
INSERT INTO service (id, name, description, category, duration, price, is_active) VALUES
(1, 'Basic Haircut', 'Includes wash, cut, and blow dry', 'HAIRCUT', 30, 50.00, TRUE),
(2, 'Designer Haircut', 'Professional styling based on face shape', 'HAIRCUT', 60, 120.00, TRUE),
(3, 'Full Body Massage', 'Full body deep relaxation massage', 'MASSAGE', 90, 180.00, TRUE),
(4, 'Back Massage', 'Deep tissue massage for back muscles', 'MASSAGE', 30, 100.00, TRUE);

SELECT setval('service_id_seq', (SELECT MAX(id) FROM service));

-- ---------------------------------------------------------------------------
-- 4.3 Client Data
-- ---------------------------------------------------------------------------
INSERT INTO client (id, first_name, last_name, phone) VALUES
(1, 'John', 'Smith', '4165550001'),
(2, 'Emily', 'Johnson', '4165550002'),
(3, 'David', 'Brown', '4165550003'),
(4, 'Sarah', 'Davis', '4165550004'),
(5, 'Robert', 'Wilson', '4165550005'),
(6, 'Jessica', 'Taylor', '4165550006'),
(7, 'William', 'Anderson', '4165550007'),
(8, 'Jennifer', 'Thomas', '4165550008'),
(9, 'Daniel', 'Martinez', '4165550009'),
(10, 'Lisa', 'Garcia', '4165550010');

SELECT setval('client_id_seq', (SELECT MAX(id) FROM client));

-- ---------------------------------------------------------------------------
-- 4.4 Appointment Data
-- Using dates relative to today (CURRENT_DATE)
-- ---------------------------------------------------------------------------

-- COMPLETED appointments (past dates: 3-5 days ago)
-- Using America/Toronto timezone to ensure times are in Toronto local time
INSERT INTO appointments (id, client_id, provider_id, service_id, start_time, status, notes) VALUES
(1, 1, 1, 1, EXTRACT(EPOCH FROM (((NOW() AT TIME ZONE 'America/Toronto')::DATE - INTERVAL '5 days' + TIME '09:00:00') AT TIME ZONE 'America/Toronto'))::BIGINT, 'COMPLETED', 'Very satisfied'),
(2, 2, 4, 3, EXTRACT(EPOCH FROM (((NOW() AT TIME ZONE 'America/Toronto')::DATE - INTERVAL '4 days' + TIME '14:00:00') AT TIME ZONE 'America/Toronto'))::BIGINT, 'COMPLETED', 'Excellent technique'),
(3, 3, 2, 1, EXTRACT(EPOCH FROM (((NOW() AT TIME ZONE 'America/Toronto')::DATE - INTERVAL '3 days' + TIME '10:30:00') AT TIME ZONE 'America/Toronto'))::BIGINT, 'COMPLETED', 'Great service');

-- CANCELLED appointments (past dates: 2-3 days ago)
INSERT INTO appointments (id, client_id, provider_id, service_id, start_time, status, notes, cancellation_reason) VALUES
(4, 7, 5, 3, EXTRACT(EPOCH FROM (((NOW() AT TIME ZONE 'America/Toronto')::DATE - INTERVAL '2 days' + TIME '11:00:00') AT TIME ZONE 'America/Toronto'))::BIGINT, 'CANCELLED', NULL, 'Client cancelled');

-- NO_SHOW appointments (past dates: 1-2 days ago)
INSERT INTO appointments (id, client_id, provider_id, service_id, start_time, status, notes) VALUES
(5, 8, 4, 4, EXTRACT(EPOCH FROM (((NOW() AT TIME ZONE 'America/Toronto')::DATE - INTERVAL '2 days' + TIME '15:00:00') AT TIME ZONE 'America/Toronto'))::BIGINT, 'NO_SHOW', NULL),
(6, 9, 3, 1, EXTRACT(EPOCH FROM (((NOW() AT TIME ZONE 'America/Toronto')::DATE - INTERVAL '1 day' + TIME '13:30:00') AT TIME ZONE 'America/Toronto'))::BIGINT, 'NO_SHOW', 'Regular trim');

-- CONFIRMED appointments (today and future dates)
INSERT INTO appointments (id, client_id, provider_id, service_id, start_time, status, notes) VALUES
(7, 1, 1, 1, EXTRACT(EPOCH FROM (((NOW() AT TIME ZONE 'America/Toronto')::DATE + TIME '10:00:00') AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Would like a shorter cut'),
(8, 2, 2, 1, EXTRACT(EPOCH FROM (((NOW() AT TIME ZONE 'America/Toronto')::DATE + TIME '14:30:00') AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'First time visit'),
(9, 3, 4, 3, EXTRACT(EPOCH FROM (((NOW() AT TIME ZONE 'America/Toronto')::DATE + INTERVAL '1 day' + TIME '09:30:00') AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Full body relaxation'),
(10, 4, 1, 2, EXTRACT(EPOCH FROM (((NOW() AT TIME ZONE 'America/Toronto')::DATE + INTERVAL '1 day' + TIME '15:00:00') AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Looking for a new hairstyle'),
(11, 7, 5, 3, EXTRACT(EPOCH FROM (((NOW() AT TIME ZONE 'America/Toronto')::DATE + INTERVAL '3 days' + TIME '11:00:00') AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Full body relaxation'),
(12, 8, 4, 4, EXTRACT(EPOCH FROM (((NOW() AT TIME ZONE 'America/Toronto')::DATE + INTERVAL '3 days' + TIME '15:00:00') AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Back discomfort'),
(13, 9, 3, 1, EXTRACT(EPOCH FROM (((NOW() AT TIME ZONE 'America/Toronto')::DATE + INTERVAL '4 days' + TIME '09:00:00') AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Regular trim'),
(14, 1, 2, 2, EXTRACT(EPOCH FROM (((NOW() AT TIME ZONE 'America/Toronto')::DATE + INTERVAL '5 days' + TIME '10:30:00') AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Special occasion styling'),
(15, 2, 6, 3, EXTRACT(EPOCH FROM (((NOW() AT TIME ZONE 'America/Toronto')::DATE + INTERVAL '5 days' + TIME '14:00:00') AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Deep tissue massage');

SELECT setval('appointments_id_seq', (SELECT MAX(id) FROM appointments));


