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

DROP TRIGGER IF EXISTS trg_check_availability_duplicates ON provider;
DROP FUNCTION IF EXISTS check_availability_no_duplicates();

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
    availability INTEGER[] DEFAULT ARRAY[1,2,3,4,5], -- 1=Monday, 2=Tuesday, ..., 7=Sunday
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT check_availability_values CHECK (
        availability <@ ARRAY[1,2,3,4,5,6,7] -- Only valid day numbers (1-7)
    )
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
CREATE INDEX idx_provider_availability ON provider USING GIN(availability);

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
INSERT INTO provider (id, first_name, last_name, description, availability, is_active) VALUES
(1, 'Emma', 'Zhang', 'Senior hairstylist, 10 years experience', ARRAY[1,2,3,4,5,6], TRUE),
(2, 'Olivia', 'Zhao', 'Professional hairstylist, 6 years experience', ARRAY[1,3,4,5,6], TRUE),
(3, 'Lucas', 'Martinez', 'Expert hairstylist, 8 years experience', ARRAY[2,3,4,5,6,7], TRUE),
(4, 'Michael', 'Wang', 'Massage therapist, 12 years experience', ARRAY[2,3,4,5,6,7], TRUE),
(5, 'James', 'Chen', 'Professional massage technician, 9 years experience', ARRAY[1,2,3,4,5,6,7], TRUE),
(6, 'Sophia', 'Li', 'Certified massage therapist, 7 years experience', ARRAY[1,2,3,4,5], TRUE); 

SELECT setval('provider_id_seq', (SELECT MAX(id) FROM provider));

-- ---------------------------------------------------------------------------
-- 4.2 Service Data
-- ---------------------------------------------------------------------------
INSERT INTO service (id, name, description, category, duration, price, is_active) VALUES
(1, 'Basic Haircut', 'Includes wash, cut, and blow dry', 'HAIRCUT', 30, 50.00, TRUE),
(2, 'Designer Haircut', 'Professional styling based on face shape', 'HAIRCUT', 60, 120.00, TRUE),
(3, 'Hair Coloring', 'Fashion hair coloring service', 'HAIRCUT', 90, 200.00, TRUE),
(4, 'Full Body Massage', 'Full body deep relaxation massage', 'MASSAGE', 60, 180.00, TRUE),
(5, 'Back Massage', 'Deep tissue massage for back muscles', 'MASSAGE', 30, 100.00, TRUE),
(6, 'Neck & Shoulder Massage', 'Relieves neck and shoulder tension', 'MASSAGE', 30, 90.00, TRUE);

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
INSERT INTO appointments (id, client_id, provider_id, service_id, start_time, status, notes) VALUES
(1, 1, 1, 1, EXTRACT(EPOCH FROM (CURRENT_DATE - INTERVAL '5 days' + TIME '09:00:00'))::BIGINT, 'COMPLETED', 'Very satisfied'),
(2, 2, 4, 4, EXTRACT(EPOCH FROM (CURRENT_DATE - INTERVAL '4 days' + TIME '14:00:00'))::BIGINT, 'COMPLETED', 'Excellent technique'),
(3, 3, 2, 1, EXTRACT(EPOCH FROM (CURRENT_DATE - INTERVAL '3 days' + TIME '10:30:00'))::BIGINT, 'COMPLETED', 'Great service');

-- CANCELLED appointments (past dates: 2-3 days ago)
INSERT INTO appointments (id, client_id, provider_id, service_id, start_time, status, notes, cancellation_reason) VALUES
(4, 6, 1, 3, EXTRACT(EPOCH FROM (CURRENT_DATE - INTERVAL '3 days' + TIME '15:00:00'))::BIGINT, 'CANCELLED', 'Want highlights', 'Emergency, need to reschedule'),
(5, 7, 5, 4, EXTRACT(EPOCH FROM (CURRENT_DATE - INTERVAL '2 days' + TIME '11:00:00'))::BIGINT, 'CANCELLED', NULL, 'Client cancelled');

-- NO_SHOW appointments (past dates: 1-2 days ago)
INSERT INTO appointments (id, client_id, provider_id, service_id, start_time, status, notes) VALUES
(6, 8, 4, 5, EXTRACT(EPOCH FROM (CURRENT_DATE - INTERVAL '2 days' + TIME '16:00:00'))::BIGINT, 'NO_SHOW', NULL),
(7, 9, 3, 1, EXTRACT(EPOCH FROM (CURRENT_DATE - INTERVAL '1 day' + TIME '13:30:00'))::BIGINT, 'NO_SHOW', 'Regular trim');

-- CONFIRMED appointments (today and future dates)
INSERT INTO appointments (id, client_id, provider_id, service_id, start_time, status, notes) VALUES
(8, 1, 1, 1, EXTRACT(EPOCH FROM (CURRENT_DATE + TIME '10:00:00'))::BIGINT, 'CONFIRMED', 'Would like a shorter cut'),
(9, 2, 2, 1, EXTRACT(EPOCH FROM (CURRENT_DATE + TIME '14:30:00'))::BIGINT, 'CONFIRMED', 'First time visit'),
(10, 3, 4, 4, EXTRACT(EPOCH FROM (CURRENT_DATE + INTERVAL '1 day' + TIME '09:30:00'))::BIGINT, 'CONFIRMED', 'Shoulder pain'),
(11, 4, 1, 2, EXTRACT(EPOCH FROM (CURRENT_DATE + INTERVAL '1 day' + TIME '15:00:00'))::BIGINT, 'CONFIRMED', 'Looking for a new hairstyle'),
(12, 5, 5, 6, EXTRACT(EPOCH FROM (CURRENT_DATE + INTERVAL '2 days' + TIME '10:00:00'))::BIGINT, 'CONFIRMED', 'Neck and shoulder tension'),
(13, 6, 1, 3, EXTRACT(EPOCH FROM (CURRENT_DATE + INTERVAL '2 days' + TIME '14:00:00'))::BIGINT, 'CONFIRMED', 'Want brown color'),
(14, 7, 5, 4, EXTRACT(EPOCH FROM (CURRENT_DATE + INTERVAL '3 days' + TIME '11:00:00'))::BIGINT, 'CONFIRMED', 'Full body relaxation'),
(15, 8, 4, 5, EXTRACT(EPOCH FROM (CURRENT_DATE + INTERVAL '3 days' + TIME '16:00:00'))::BIGINT, 'CONFIRMED', 'Back discomfort'),
(16, 9, 3, 1, EXTRACT(EPOCH FROM (CURRENT_DATE + INTERVAL '4 days' + TIME '09:00:00'))::BIGINT, 'CONFIRMED', 'Regular trim'),
(17, 10, 6, 6, EXTRACT(EPOCH FROM (CURRENT_DATE + INTERVAL '4 days' + TIME '13:00:00'))::BIGINT, 'CONFIRMED', 'Long hours at computer'),
(18, 1, 2, 2, EXTRACT(EPOCH FROM (CURRENT_DATE + INTERVAL '5 days' + TIME '10:30:00'))::BIGINT, 'CONFIRMED', 'Special occasion styling'),
(19, 2, 6, 4, EXTRACT(EPOCH FROM (CURRENT_DATE + INTERVAL '5 days' + TIME '14:00:00'))::BIGINT, 'CONFIRMED', 'Deep tissue massage');

SELECT setval('appointments_id_seq', (SELECT MAX(id) FROM appointments));


