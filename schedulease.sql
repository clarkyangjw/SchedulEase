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
-- 1. DROP TABLES (in reverse order of dependencies)
-- ============================================================================

DROP TABLE IF EXISTS appointments CASCADE;
DROP TABLE IF EXISTS provider_service CASCADE;
DROP TABLE IF EXISTS service CASCADE;
DROP TABLE IF EXISTS provider CASCADE;
DROP TABLE IF EXISTS client CASCADE;

-- ============================================================================
-- 2 CREATE TABLES
-- ============================================================================

-- ---------------------------------------------------------------------------
-- 2.1 Client Table (client)
-- Purpose: Store basic client information (no registration/login required)
-- ---------------------------------------------------------------------------
CREATE TABLE client (
    id BIGSERIAL PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL
);

-- ---------------------------------------------------------------------------
-- 2.2 Provider Table (provider)
-- Purpose: Store service provider information (pre-configured, selected by clients during booking)
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
-- 2.3 Service Table (service)
-- Purpose: Store service types (e.g., haircut, coloring, massage, etc.)
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
-- 2.4 Provider-Service Association Table (provider_service)
-- Purpose: Associates providers with services (many-to-many relationship)
-- ---------------------------------------------------------------------------
CREATE TABLE provider_service (
    id BIGSERIAL PRIMARY KEY,
    provider_id BIGINT NOT NULL,
    service_id BIGINT NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT fk_provider_service_provider FOREIGN KEY (provider_id) 
        REFERENCES provider(id) ON DELETE CASCADE,
    CONSTRAINT fk_provider_service_service FOREIGN KEY (service_id) 
        REFERENCES service(id) ON DELETE CASCADE,
    CONSTRAINT uk_provider_service UNIQUE (provider_id, service_id)
);

-- ---------------------------------------------------------------------------
-- 2.5 Appointments Table (appointments)
-- Purpose: Store all appointment records
-- ---------------------------------------------------------------------------
CREATE TABLE appointments (
    id BIGSERIAL PRIMARY KEY,
    client_id BIGINT NOT NULL,
    provider_service_id BIGINT NOT NULL,
    start_time BIGINT NOT NULL,
    end_time BIGINT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'CONFIRMED',
    notes TEXT,
    cancellation_reason TEXT,
    cancelled_at BIGINT,
    CONSTRAINT fk_appointments_client FOREIGN KEY (client_id) 
        REFERENCES client(id) ON DELETE CASCADE,
    CONSTRAINT fk_appointments_provider_service FOREIGN KEY (provider_service_id) 
        REFERENCES provider_service(id) ON DELETE CASCADE,
    CONSTRAINT check_appointment_time CHECK (end_time > start_time),
    CONSTRAINT check_appointment_status CHECK (status IN ('CONFIRMED', 'CANCELLED', 'COMPLETED', 'NO_SHOW'))
);

-- Create partial unique index (excluding cancelled appointments)
CREATE UNIQUE INDEX uk_appointments_time_slot 
    ON appointments(provider_service_id, start_time) 
    WHERE status NOT IN ('CANCELLED');

-- ============================================================================
-- 2.6 Trigger Function: Validate Provider Availability (No Duplicates)
-- ============================================================================

-- Function to check for duplicate days in availability array
CREATE OR REPLACE FUNCTION check_availability_no_duplicates()
RETURNS TRIGGER AS $$
BEGIN
    -- Check if array has duplicates by comparing length with distinct count
    IF array_length(NEW.availability, 1) != (SELECT COUNT(DISTINCT x) FROM unnest(NEW.availability) x) THEN
        RAISE EXCEPTION 'Availability array cannot contain duplicate days';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to validate availability on INSERT or UPDATE
CREATE TRIGGER trg_check_availability_duplicates
    BEFORE INSERT OR UPDATE OF availability ON provider
    FOR EACH ROW
    EXECUTE FUNCTION check_availability_no_duplicates();

-- ============================================================================
-- 3. CREATE INDEXES
-- ============================================================================

-- provider table indexes
CREATE INDEX idx_provider_active ON provider(is_active);
CREATE INDEX idx_provider_availability ON provider USING GIN(availability); -- For array queries

-- service table indexes
CREATE INDEX idx_service_active ON service(is_active);
CREATE INDEX idx_service_category ON service(category);

-- provider_service table indexes
CREATE INDEX idx_provider_service_provider ON provider_service(provider_id);
CREATE INDEX idx_provider_service_service ON provider_service(service_id);
CREATE INDEX idx_provider_service_active ON provider_service(is_active);

-- appointments table indexes
CREATE INDEX idx_appointments_client ON appointments(client_id);
CREATE INDEX idx_appointments_provider_service ON appointments(provider_service_id);
CREATE INDEX idx_appointments_start_time ON appointments(start_time);
CREATE INDEX idx_appointments_status ON appointments(status);

-- ============================================================================
-- 4. INSERT TEST DATA
-- ============================================================================

-- ---------------------------------------------------------------------------
-- 4.1 Insert Provider Data (Providers)
-- ---------------------------------------------------------------------------
INSERT INTO provider (id, first_name, last_name, description, availability, is_active) VALUES
-- Hairstylists
(1, 'Emma', 'Zhang', 'Senior hairstylist specializing in various hairstyle designs and coloring techniques, 10 years of experience', 
 ARRAY[1,2,3,4,5,6], TRUE),
(2, 'Olivia', 'Zhao', 'Professional hairstylist focusing on fashion coloring and perming, 6 years of experience', 
 ARRAY[1,3,4,5,6], TRUE),
(3, 'Lucas', 'Martinez', 'Expert hairstylist specializing in modern cuts and styling, 8 years of experience',
 ARRAY[2,3,4,5,6,7], TRUE),

-- Massage Therapists
(4, 'Michael', 'Wang', 'Massage therapist specializing in Chinese massage and sports rehabilitation, 12 years of experience', 
 ARRAY[2,3,4,5,6,7], TRUE),
(5, 'James', 'Chen', 'Professional massage technician providing deep tissue massage and relaxation therapy, 9 years of experience', 
 ARRAY[1,2,3,4,5,6,7], TRUE), 
(6, 'Sophia', 'Li', 'Certified massage therapist specializing in therapeutic and relaxation massage, 7 years of experience',
 ARRAY[1,2,3,4,5], TRUE); 

-- Reset provider sequence
SELECT setval('provider_id_seq', (SELECT MAX(id) FROM provider));

-- ---------------------------------------------------------------------------
-- 4.2 Insert Service Data (Services)
-- ---------------------------------------------------------------------------
INSERT INTO service (id, name, description, category, duration, price, is_active) VALUES
-- HAIRCUT services (3 services)
(1, 'Basic Haircut', 'Includes hair wash, haircut, and blow dry', 'HAIRCUT', 30, 50.00, TRUE),
(2, 'Designer Haircut', 'Professional designer creates hairstyle based on face shape, includes wash, cut, and styling', 'HAIRCUT', 60, 120.00, TRUE),
(3, 'Hair Coloring', 'Fashion hair coloring service, multiple colors available', 'HAIRCUT', 90, 200.00, TRUE),

-- MASSAGE services (3 services)
(4, 'Full Body Massage', 'Full body deep relaxation massage, 60 minutes', 'MASSAGE', 60, 180.00, TRUE),
(5, 'Back Massage', 'Deep tissue massage targeting back muscles', 'MASSAGE', 30, 100.00, TRUE),
(6, 'Neck & Shoulder Massage', 'Relieves neck and shoulder fatigue and pain', 'MASSAGE', 30, 90.00, TRUE);

-- Reset service sequence
SELECT setval('service_id_seq', (SELECT MAX(id) FROM service));

-- ---------------------------------------------------------------------------
-- 4.3 Insert Provider-Service Association Data (Provider-Service Relationships)
-- Each service has 2-3 providers to demonstrate client choice
-- ---------------------------------------------------------------------------

-- Emma Zhang (Provider ID: 1) - Senior Hairstylist
INSERT INTO provider_service (id, provider_id, service_id, is_active) VALUES
(1, 1, 1, TRUE),  -- Basic Haircut
(2, 1, 2, TRUE),  -- Designer Haircut
(3, 1, 3, TRUE);  -- Hair Coloring

-- Olivia Zhao (Provider ID: 2) - Professional Hairstylist
INSERT INTO provider_service (id, provider_id, service_id, is_active) VALUES
(4, 2, 1, TRUE),  -- Basic Haircut
(5, 2, 2, TRUE),  -- Designer Haircut
(6, 2, 3, TRUE);  -- Hair Coloring

-- Lucas Martinez (Provider ID: 3) - Expert Hairstylist
INSERT INTO provider_service (id, provider_id, service_id, is_active) VALUES
(7, 3, 1, TRUE),  -- Basic Haircut
(8, 3, 2, TRUE);  -- Designer Haircut

-- Michael Wang (Provider ID: 4) - Massage Therapist
INSERT INTO provider_service (id, provider_id, service_id, is_active) VALUES
(9, 4, 4, TRUE),  -- Full Body Massage
(10, 4, 5, TRUE), -- Back Massage
(11, 4, 6, TRUE); -- Neck & Shoulder Massage

-- James Chen (Provider ID: 5) - Professional Massage Technician
INSERT INTO provider_service (id, provider_id, service_id, is_active) VALUES
(12, 5, 4, TRUE), -- Full Body Massage
(13, 5, 5, TRUE), -- Back Massage
(14, 5, 6, TRUE); -- Neck & Shoulder Massage

-- Sophia Li (Provider ID: 6) - Certified Massage Therapist
INSERT INTO provider_service (id, provider_id, service_id, is_active) VALUES
(15, 6, 4, TRUE), -- Full Body Massage
(16, 6, 6, TRUE); -- Neck & Shoulder Massage

-- Reset provider_service sequence
SELECT setval('provider_service_id_seq', (SELECT MAX(id) FROM provider_service));

-- ---------------------------------------------------------------------------
-- 4.4 Insert Client Data (Clients)
-- ---------------------------------------------------------------------------
INSERT INTO client (id, first_name, last_name, phone) VALUES
(1, 'John', 'Smith', '416-555-0001'),
(2, 'Emily', 'Johnson', '416-555-0002'),
(3, 'David', 'Brown', '416-555-0003'),
(4, 'Sarah', 'Davis', '416-555-0004'),
(5, 'Robert', 'Wilson', '416-555-0005'),
(6, 'Jessica', 'Taylor', '416-555-0006'),
(7, 'William', 'Anderson', '416-555-0007'),
(8, 'Jennifer', 'Thomas', '416-555-0008'),
(9, 'Daniel', 'Martinez', '416-555-0009'),
(10, 'Lisa', 'Garcia', '416-555-0010');

-- Reset client sequence
SELECT setval('client_id_seq', (SELECT MAX(id) FROM client));

-- ---------------------------------------------------------------------------
-- 4.5 Insert Appointment Data (Appointments)
-- ---------------------------------------------------------------------------

-- Future appointments (CONFIRMED)
INSERT INTO appointments (id, client_id, provider_service_id, start_time, end_time, status, notes) VALUES
-- Appointments on November 7, 2025 (Tomorrow)
(1, 1, 1, 1730995200, 1730997000, 'CONFIRMED', 'Would like a shorter cut'),  -- Emma: Basic Haircut, 9:00-9:30 AM
(2, 2, 4, 1730998800, 1731002400, 'CONFIRMED', 'First time visit'),  -- Olivia: Basic Haircut, 10:00-10:30 AM
(3, 3, 9, 1731006000, 1731009600, 'CONFIRMED', 'Shoulder pain'),  -- Michael: Full Body Massage, 12:00-1:00 PM
(4, 4, 2, 1731009600, 1731013200, 'CONFIRMED', 'Looking for a new hairstyle'),  -- Emma: Designer Haircut, 1:00-2:00 PM
(5, 5, 14, 1731013200, 1731015000, 'CONFIRMED', 'Neck and shoulder tension'),  -- James: Neck & Shoulder Massage, 2:00-2:30 PM
-- Appointments on November 8, 2025
(6, 6, 3, 1731081600, 1731087000, 'CONFIRMED', 'Want brown color'),  -- Emma: Hair Coloring, 9:00-10:30 AM
(7, 7, 12, 1731085200, 1731088800, 'CONFIRMED', 'Full body relaxation'),  -- James: Full Body Massage, 10:00-11:00 AM
(8, 8, 10, 1731088800, 1731090600, 'CONFIRMED', 'Back discomfort'),  -- Michael: Back Massage, 11:00-11:30 AM
(9, 9, 7, 1731099600, 1731101400, 'CONFIRMED', 'Regular trim'),  -- Lucas: Basic Haircut, 2:00-2:30 PM
(10, 10, 16, 1731103200, 1731105000, 'CONFIRMED', 'Long hours at computer'),  -- Sophia: Neck & Shoulder Massage, 3:00-3:30 PM
-- Appointments on November 9, 2025
(11, 1, 5, 1731168000, 1731171600, 'CONFIRMED', 'Special occasion styling'),  -- Olivia: Designer Haircut, 9:00-10:00 AM
(12, 2, 15, 1731171600, 1731175200, 'CONFIRMED', 'Deep tissue massage'),  -- Sophia: Full Body Massage, 10:00-11:00 AM
(13, 3, 8, 1731182400, 1731186000, 'CONFIRMED', 'Modern style cut'),  -- Lucas: Designer Haircut, 1:00-2:00 PM
(14, 4, 13, 1731186000, 1731189600, 'CONFIRMED', 'Relaxation session'),  -- James: Full Body Massage, 2:00-3:00 PM
(15, 5, 1, 1731189600, 1731191400, 'CONFIRMED', 'Quick trim'),  -- Emma: Basic Haircut, 3:00-3:30 PM
-- Past appointments (COMPLETED)
(16, 1, 1, 1730390400, 1730392200, 'COMPLETED', 'Very satisfied'),  -- Emma: Basic Haircut
(17, 2, 9, 1730394000, 1730397600, 'COMPLETED', 'Excellent technique'),  -- Michael: Full Body Massage
(18, 3, 4, 1730476800, 1730478600, 'COMPLETED', 'Great service'),  -- Olivia: Basic Haircut
(19, 4, 2, 1730480400, 1730484000, 'COMPLETED', 'Love the new style'),  -- Emma: Designer Haircut
(20, 5, 14, 1730570400, 1730572200, 'COMPLETED', 'Very relaxing');  -- James: Neck & Shoulder Massage

-- Cancelled appointments (CANCELLED)
INSERT INTO appointments (id, client_id, provider_service_id, start_time, end_time, status, notes, cancellation_reason, cancelled_at) VALUES
(21, 6, 6, 1730649600, 1730654400, 'CANCELLED', 'Want highlights', 'Emergency, need to reschedule', 1730602200),  -- Olivia: Hair Coloring
(22, 7, 12, 1730653200, 1730656800, 'CANCELLED', NULL, 'Client cancelled', 1730607600);  -- James: Full Body Massage

-- No-show appointments (NO_SHOW)
INSERT INTO appointments (id, client_id, provider_service_id, start_time, end_time, status, notes) VALUES
(23, 8, 10, 1730556000, 1730557800, 'NO_SHOW', NULL);  -- Michael: Back Massage

-- Reset appointments sequence
SELECT setval('appointments_id_seq', (SELECT MAX(id) FROM appointments));


