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
DROP TABLE IF EXISTS provider_service CASCADE;
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
    phone VARCHAR(20) NOT NULL
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
-- 2.4 Provider-Service Association Table
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
-- 2.5 Appointments Table
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

CREATE UNIQUE INDEX uk_appointments_time_slot 
    ON appointments(provider_service_id, start_time) 
    WHERE status NOT IN ('CANCELLED');

-- ============================================================================
-- 2.6 Trigger Function
-- ============================================================================

CREATE OR REPLACE FUNCTION check_availability_no_duplicates()
RETURNS TRIGGER AS $$
BEGIN
    IF array_length(NEW.availability, 1) != (SELECT COUNT(DISTINCT x) FROM unnest(NEW.availability) x) THEN
        RAISE EXCEPTION 'Availability array cannot contain duplicate days';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_availability_duplicates
    BEFORE INSERT OR UPDATE OF availability ON provider
    FOR EACH ROW
    EXECUTE FUNCTION check_availability_no_duplicates();

-- ============================================================================
-- 3. CREATE INDEXES
-- ============================================================================

CREATE INDEX idx_provider_active ON provider(is_active);
CREATE INDEX idx_provider_availability ON provider USING GIN(availability);

CREATE INDEX idx_service_active ON service(is_active);
CREATE INDEX idx_service_category ON service(category);

CREATE INDEX idx_provider_service_provider ON provider_service(provider_id);
CREATE INDEX idx_provider_service_service ON provider_service(service_id);
CREATE INDEX idx_provider_service_active ON provider_service(is_active);

CREATE INDEX idx_appointments_client ON appointments(client_id);
CREATE INDEX idx_appointments_provider_service ON appointments(provider_service_id);
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
-- 4.3 Provider-Service Association Data
-- ---------------------------------------------------------------------------

INSERT INTO provider_service (id, provider_id, service_id, is_active) VALUES
(1, 1, 1, TRUE),
(2, 1, 2, TRUE),
(3, 1, 3, TRUE);

INSERT INTO provider_service (id, provider_id, service_id, is_active) VALUES
(4, 2, 1, TRUE),
(5, 2, 2, TRUE),
(6, 2, 3, TRUE);

INSERT INTO provider_service (id, provider_id, service_id, is_active) VALUES
(7, 3, 1, TRUE),
(8, 3, 2, TRUE);

INSERT INTO provider_service (id, provider_id, service_id, is_active) VALUES
(9, 4, 4, TRUE),
(10, 4, 5, TRUE),
(11, 4, 6, TRUE);

INSERT INTO provider_service (id, provider_id, service_id, is_active) VALUES
(12, 5, 4, TRUE),
(13, 5, 5, TRUE),
(14, 5, 6, TRUE);

INSERT INTO provider_service (id, provider_id, service_id, is_active) VALUES
(15, 6, 4, TRUE),
(16, 6, 6, TRUE);

SELECT setval('provider_service_id_seq', (SELECT MAX(id) FROM provider_service));

-- ---------------------------------------------------------------------------
-- 4.4 Client Data
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

SELECT setval('client_id_seq', (SELECT MAX(id) FROM client));

-- ---------------------------------------------------------------------------
-- 4.5 Appointment Data
-- ---------------------------------------------------------------------------

INSERT INTO appointments (id, client_id, provider_service_id, start_time, end_time, status, notes) VALUES
(1, 1, 1, 1730995200, 1730997000, 'CONFIRMED', 'Would like a shorter cut'),
(2, 2, 4, 1730998800, 1731002400, 'CONFIRMED', 'First time visit'),
(3, 3, 9, 1731006000, 1731009600, 'CONFIRMED', 'Shoulder pain'),
(4, 4, 2, 1731009600, 1731013200, 'CONFIRMED', 'Looking for a new hairstyle'),
(5, 5, 14, 1731013200, 1731015000, 'CONFIRMED', 'Neck and shoulder tension'),
(6, 6, 3, 1731081600, 1731087000, 'CONFIRMED', 'Want brown color'),
(7, 7, 12, 1731085200, 1731088800, 'CONFIRMED', 'Full body relaxation'),
(8, 8, 10, 1731088800, 1731090600, 'CONFIRMED', 'Back discomfort'),
(9, 9, 7, 1731099600, 1731101400, 'CONFIRMED', 'Regular trim'),
(10, 10, 16, 1731103200, 1731105000, 'CONFIRMED', 'Long hours at computer'),
(11, 1, 5, 1731168000, 1731171600, 'CONFIRMED', 'Special occasion styling'),
(12, 2, 15, 1731171600, 1731175200, 'CONFIRMED', 'Deep tissue massage'),
(13, 3, 8, 1731182400, 1731186000, 'CONFIRMED', 'Modern style cut'),
(14, 4, 13, 1731186000, 1731189600, 'CONFIRMED', 'Relaxation session'),
(15, 5, 1, 1731189600, 1731191400, 'CONFIRMED', 'Quick trim'),
(16, 1, 1, 1730390400, 1730392200, 'COMPLETED', 'Very satisfied'),
(17, 2, 9, 1730394000, 1730397600, 'COMPLETED', 'Excellent technique'),
(18, 3, 4, 1730476800, 1730478600, 'COMPLETED', 'Great service'),
(19, 4, 2, 1730480400, 1730484000, 'COMPLETED', 'Love the new style'),
(20, 5, 14, 1730570400, 1730572200, 'COMPLETED', 'Very relaxing');

INSERT INTO appointments (id, client_id, provider_service_id, start_time, end_time, status, notes, cancellation_reason, cancelled_at) VALUES
(21, 6, 6, 1730649600, 1730654400, 'CANCELLED', 'Want highlights', 'Emergency, need to reschedule', 1730602200),
(22, 7, 12, 1730653200, 1730656800, 'CANCELLED', NULL, 'Client cancelled', 1730607600);

INSERT INTO appointments (id, client_id, provider_service_id, start_time, end_time, status, notes) VALUES
(23, 8, 10, 1730556000, 1730557800, 'NO_SHOW', NULL);

SELECT setval('appointments_id_seq', (SELECT MAX(id) FROM appointments));


