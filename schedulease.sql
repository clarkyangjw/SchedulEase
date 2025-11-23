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
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    availability VARCHAR(20) DEFAULT ''
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
INSERT INTO provider (id, first_name, last_name, description, is_active, availability) VALUES
(1, 'Emma', 'Zhang', 'Senior hairstylist, 10 years experience', TRUE, '1,2,3,4,5'),
(2, 'Olivia', 'Zhao', 'Professional hairstylist, 6 years experience', FALSE, '1,2,4,5,6'),
(3, 'Lucas', 'Martinez', 'Expert hairstylist, 8 years experience', TRUE, '2,3,4,5,6'),
(4, 'Michael', 'Wang', 'Massage therapist, 12 years experience', TRUE, '1,3,4,6,7'); 

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
-- ---------------------------------------------------------------------------

INSERT INTO appointments (id, client_id, provider_id, service_id, start_time, status, notes) VALUES
(1, 1, 1, 1, EXTRACT(EPOCH FROM (TIMESTAMP '2025-11-17 09:00:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'COMPLETED', 'Very satisfied'),
(2, 2, 4, 3, EXTRACT(EPOCH FROM (TIMESTAMP '2025-11-17 10:30:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'COMPLETED', 'Excellent technique'),
(3, 3, 3, 1, EXTRACT(EPOCH FROM (TIMESTAMP '2025-11-18 13:00:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'COMPLETED', 'Great service'),
(4, 4, 1, 2, EXTRACT(EPOCH FROM (TIMESTAMP '2025-11-17 14:30:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'COMPLETED', 'Styling session completed'),
(5, 5, 4, 4, EXTRACT(EPOCH FROM (TIMESTAMP '2025-11-17 16:00:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'COMPLETED', 'Back massage completed');

INSERT INTO appointments (id, client_id, provider_id, service_id, start_time, status, notes) VALUES
(6, 6, 1, 1, EXTRACT(EPOCH FROM (TIMESTAMP '2025-11-18 10:00:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'COMPLETED', 'Basic haircut done'),
(7, 7, 3, 1, EXTRACT(EPOCH FROM (TIMESTAMP '2025-11-18 14:00:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'COMPLETED', 'Haircut appointment'),
(8, 8, 4, 3, EXTRACT(EPOCH FROM (TIMESTAMP '2025-11-19 15:30:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'COMPLETED', 'Full body massage');

INSERT INTO appointments (id, client_id, provider_id, service_id, start_time, status, notes) VALUES
(9, 9, 1, 2, EXTRACT(EPOCH FROM (TIMESTAMP '2025-11-19 09:00:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'COMPLETED', 'Designer haircut'),
(10, 10, 3, 1, EXTRACT(EPOCH FROM (TIMESTAMP '2025-11-19 10:30:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'COMPLETED', 'Hair styling'),
(11, 1, 4, 4, EXTRACT(EPOCH FROM (TIMESTAMP '2025-11-19 11:00:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'COMPLETED', 'Back massage'),
(12, 2, 1, 1, EXTRACT(EPOCH FROM (TIMESTAMP '2025-11-19 13:00:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'COMPLETED', 'Regular trim'),
(13, 3, 4, 3, EXTRACT(EPOCH FROM (TIMESTAMP '2025-11-19 14:30:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'COMPLETED', 'Massage therapy'),
(14, 4, 3, 1, EXTRACT(EPOCH FROM (TIMESTAMP '2025-11-19 16:00:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'COMPLETED', 'Haircut service');

INSERT INTO appointments (id, client_id, provider_id, service_id, start_time, status, notes) VALUES
(15, 5, 1, 1, EXTRACT(EPOCH FROM (TIMESTAMP '2025-11-20 11:00:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'COMPLETED', 'Monthly visit'),
(16, 6, 4, 4, EXTRACT(EPOCH FROM (TIMESTAMP '2025-11-20 15:00:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'COMPLETED', 'Back therapy');

INSERT INTO appointments (id, client_id, provider_id, service_id, start_time, status, notes) VALUES
(17, 7, 3, 1, EXTRACT(EPOCH FROM (TIMESTAMP '2025-11-21 09:30:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'COMPLETED', 'Haircut appointment'),
(18, 8, 1, 2, EXTRACT(EPOCH FROM (TIMESTAMP '2025-11-21 11:00:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'COMPLETED', 'Designer cut'),
(19, 9, 4, 3, EXTRACT(EPOCH FROM (TIMESTAMP '2025-11-22 13:30:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'COMPLETED', 'Full body massage'),
(20, 10, 1, 1, EXTRACT(EPOCH FROM (TIMESTAMP '2025-11-21 15:00:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'COMPLETED', 'Regular trim');

INSERT INTO appointments (id, client_id, provider_id, service_id, start_time, status, notes, cancellation_reason) VALUES
(21, 7, 1, 2, EXTRACT(EPOCH FROM (TIMESTAMP '2025-11-18 16:00:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CANCELLED', NULL, 'Client cancelled'),
(22, 8, 3, 1, EXTRACT(EPOCH FROM (TIMESTAMP '2025-11-20 14:00:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CANCELLED', NULL, 'Schedule conflict');

INSERT INTO appointments (id, client_id, provider_id, service_id, start_time, status, notes) VALUES
(23, 9, 4, 3, EXTRACT(EPOCH FROM (TIMESTAMP '2025-11-17 11:00:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'NO_SHOW', NULL),
(24, 10, 1, 1, EXTRACT(EPOCH FROM (TIMESTAMP '2025-11-21 10:00:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'NO_SHOW', 'Regular trim');

INSERT INTO appointments (id, client_id, provider_id, service_id, start_time, status, notes) VALUES
(25, 1, 1, 1, EXTRACT(EPOCH FROM (TIMESTAMP '2025-11-24 09:00:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Morning appointment'),
(26, 2, 4, 3, EXTRACT(EPOCH FROM (TIMESTAMP '2025-11-22 10:30:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Full body massage'),
(27, 3, 3, 1, EXTRACT(EPOCH FROM (TIMESTAMP '2025-11-22 13:00:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Haircut appointment'),
(28, 4, 1, 2, EXTRACT(EPOCH FROM (TIMESTAMP '2025-11-24 14:00:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Designer haircut'),
(29, 5, 4, 4, EXTRACT(EPOCH FROM (TIMESTAMP '2025-11-22 15:00:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Back massage'),
(30, 6, 1, 1, EXTRACT(EPOCH FROM (TIMESTAMP '2025-11-24 16:00:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Basic haircut');

INSERT INTO appointments (id, client_id, provider_id, service_id, start_time, status, notes) VALUES
(31, 7, 3, 1, EXTRACT(EPOCH FROM (TIMESTAMP '2025-11-25 14:00:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Hair styling');

INSERT INTO appointments (id, client_id, provider_id, service_id, start_time, status, notes) VALUES
(32, 8, 4, 3, EXTRACT(EPOCH FROM (TIMESTAMP '2025-11-24 09:00:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Full body massage'),
(33, 9, 1, 2, EXTRACT(EPOCH FROM (TIMESTAMP '2025-11-24 10:30:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Holiday styling'),
(34, 10, 3, 1, EXTRACT(EPOCH FROM (TIMESTAMP '2025-11-25 13:00:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Haircut appointment'),
(35, 1, 4, 4, EXTRACT(EPOCH FROM (TIMESTAMP '2025-11-24 14:30:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Back massage'),
(36, 2, 1, 1, EXTRACT(EPOCH FROM (TIMESTAMP '2025-11-24 15:30:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Regular maintenance');

INSERT INTO appointments (id, client_id, provider_id, service_id, start_time, status, notes) VALUES
(37, 3, 4, 3, EXTRACT(EPOCH FROM (TIMESTAMP '2025-11-27 11:00:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Relaxation massage'),
(38, 4, 3, 1, EXTRACT(EPOCH FROM (TIMESTAMP '2025-11-25 14:30:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Hair styling'),
(39, 5, 1, 2, EXTRACT(EPOCH FROM (TIMESTAMP '2025-11-25 15:30:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Designer cut');

INSERT INTO appointments (id, client_id, provider_id, service_id, start_time, status, notes) VALUES
(40, 6, 4, 4, EXTRACT(EPOCH FROM (TIMESTAMP '2025-11-26 09:00:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Back treatment'),
(41, 7, 3, 1, EXTRACT(EPOCH FROM (TIMESTAMP '2025-11-26 10:00:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Haircut service'),
(42, 8, 1, 1, EXTRACT(EPOCH FROM (TIMESTAMP '2025-11-26 11:30:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Basic trim'),
(43, 9, 4, 3, EXTRACT(EPOCH FROM (TIMESTAMP '2025-11-26 13:00:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Full body treatment'),
(44, 10, 1, 2, EXTRACT(EPOCH FROM (TIMESTAMP '2025-11-26 14:30:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Holiday special styling'),
(45, 1, 3, 1, EXTRACT(EPOCH FROM (TIMESTAMP '2025-11-26 16:00:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Hair maintenance');

INSERT INTO appointments (id, client_id, provider_id, service_id, start_time, status, notes) VALUES
(46, 2, 4, 4, EXTRACT(EPOCH FROM (TIMESTAMP '2025-11-27 10:00:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Back massage'),
(47, 3, 1, 1, EXTRACT(EPOCH FROM (TIMESTAMP '2025-11-27 14:00:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Monthly trim');

INSERT INTO appointments (id, client_id, provider_id, service_id, start_time, status, notes) VALUES
(48, 4, 4, 3, EXTRACT(EPOCH FROM (TIMESTAMP '2025-11-30 09:00:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Deep tissue massage'),
(49, 5, 3, 1, EXTRACT(EPOCH FROM (TIMESTAMP '2025-11-28 11:00:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Haircut appointment'),
(50, 6, 1, 2, EXTRACT(EPOCH FROM (TIMESTAMP '2025-11-28 13:30:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Holiday styling'),
(51, 7, 4, 4, EXTRACT(EPOCH FROM (TIMESTAMP '2025-11-30 15:00:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Back therapy');

INSERT INTO appointments (id, client_id, provider_id, service_id, start_time, status, notes) VALUES
(52, 8, 3, 1, EXTRACT(EPOCH FROM (TIMESTAMP '2025-11-29 10:00:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Hair styling'),
(53, 9, 1, 1, EXTRACT(EPOCH FROM (TIMESTAMP '2025-12-01 13:00:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Year-end haircut'),
(54, 10, 4, 3, EXTRACT(EPOCH FROM (TIMESTAMP '2025-11-29 15:00:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'New Year relaxation');

INSERT INTO appointments (id, client_id, provider_id, service_id, start_time, status, notes) VALUES
(55, 1, 4, 4, EXTRACT(EPOCH FROM (TIMESTAMP '2025-12-01 09:00:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Back massage'),
(56, 2, 1, 2, EXTRACT(EPOCH FROM (TIMESTAMP '2025-12-01 10:30:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Designer haircut'),
(57, 3, 3, 1, EXTRACT(EPOCH FROM (TIMESTAMP '2025-12-02 13:00:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Haircut service'),
(58, 4, 1, 1, EXTRACT(EPOCH FROM (TIMESTAMP '2025-12-01 14:30:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Basic haircut'),
(59, 5, 4, 3, EXTRACT(EPOCH FROM (TIMESTAMP '2025-12-01 16:00:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Full body treatment');

INSERT INTO appointments (id, client_id, provider_id, service_id, start_time, status, notes) VALUES
(60, 6, 3, 1, EXTRACT(EPOCH FROM (TIMESTAMP '2025-12-02 11:00:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Hair maintenance'),
(61, 7, 1, 2, EXTRACT(EPOCH FROM (TIMESTAMP '2025-12-02 14:00:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Holiday special styling');

INSERT INTO appointments (id, client_id, provider_id, service_id, start_time, status, notes) VALUES
(62, 8, 4, 4, EXTRACT(EPOCH FROM (TIMESTAMP '2025-12-03 09:00:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Back therapy'),
(63, 9, 3, 1, EXTRACT(EPOCH FROM (TIMESTAMP '2025-12-03 10:30:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Hair styling'),
(64, 10, 1, 1, EXTRACT(EPOCH FROM (TIMESTAMP '2025-12-03 13:00:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Regular trim'),
(65, 1, 4, 3, EXTRACT(EPOCH FROM (TIMESTAMP '2025-12-03 15:00:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Relaxation massage');

INSERT INTO appointments (id, client_id, provider_id, service_id, start_time, status, notes) VALUES
(66, 2, 3, 1, EXTRACT(EPOCH FROM (TIMESTAMP '2025-12-04 10:00:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Haircut appointment'),
(67, 3, 1, 2, EXTRACT(EPOCH FROM (TIMESTAMP '2025-12-04 14:00:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Designer cut'),
(68, 4, 4, 4, EXTRACT(EPOCH FROM (TIMESTAMP '2025-12-04 15:30:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Back massage');

INSERT INTO appointments (id, client_id, provider_id, service_id, start_time, status, notes) VALUES
(69, 5, 3, 1, EXTRACT(EPOCH FROM (TIMESTAMP '2025-12-05 09:00:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Hair styling'),
(70, 6, 1, 1, EXTRACT(EPOCH FROM (TIMESTAMP '2025-12-05 10:30:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Monthly trim'),
(71, 7, 4, 3, EXTRACT(EPOCH FROM (TIMESTAMP '2025-12-07 13:00:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Full body massage'),
(72, 8, 3, 1, EXTRACT(EPOCH FROM (TIMESTAMP '2025-12-05 14:30:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Haircut service'),
(73, 9, 1, 2, EXTRACT(EPOCH FROM (TIMESTAMP '2025-12-05 16:00:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Holiday styling');

INSERT INTO appointments (id, client_id, provider_id, service_id, start_time, status, notes) VALUES
(74, 10, 4, 4, EXTRACT(EPOCH FROM (TIMESTAMP '2025-12-06 10:00:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Back therapy'),
(75, 1, 3, 1, EXTRACT(EPOCH FROM (TIMESTAMP '2025-12-06 14:00:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Hair maintenance');

INSERT INTO appointments (id, client_id, provider_id, service_id, start_time, status, notes) VALUES
(76, 2, 1, 2, EXTRACT(EPOCH FROM (TIMESTAMP '2025-12-08 13:00:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Designer haircut');

INSERT INTO appointments (id, client_id, provider_id, service_id, start_time, status, notes) VALUES
(77, 3, 4, 3, EXTRACT(EPOCH FROM (TIMESTAMP '2025-12-08 09:00:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Deep tissue massage'),
(78, 4, 1, 1, EXTRACT(EPOCH FROM (TIMESTAMP '2025-12-08 10:00:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Basic haircut'),
(79, 5, 4, 4, EXTRACT(EPOCH FROM (TIMESTAMP '2025-12-08 11:30:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Back massage'),
(80, 6, 3, 1, EXTRACT(EPOCH FROM (TIMESTAMP '2025-12-09 13:00:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Haircut appointment'),
(81, 7, 1, 2, EXTRACT(EPOCH FROM (TIMESTAMP '2025-12-08 14:30:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Holiday special styling'),
(82, 8, 4, 3, EXTRACT(EPOCH FROM (TIMESTAMP '2025-12-08 16:00:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Full body treatment');

INSERT INTO appointments (id, client_id, provider_id, service_id, start_time, status, notes) VALUES
(83, 9, 3, 1, EXTRACT(EPOCH FROM (TIMESTAMP '2025-12-09 10:00:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Hair styling'),
(84, 10, 1, 1, EXTRACT(EPOCH FROM (TIMESTAMP '2025-12-09 13:00:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Regular trim'),
(85, 1, 4, 4, EXTRACT(EPOCH FROM (TIMESTAMP '2025-12-11 15:00:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Back therapy');

INSERT INTO appointments (id, client_id, provider_id, service_id, start_time, status, notes) VALUES
(86, 2, 3, 1, EXTRACT(EPOCH FROM (TIMESTAMP '2025-12-10 09:00:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Haircut service'),
(87, 3, 1, 2, EXTRACT(EPOCH FROM (TIMESTAMP '2025-12-10 11:00:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Designer cut'),
(88, 4, 4, 3, EXTRACT(EPOCH FROM (TIMESTAMP '2025-12-10 13:30:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Relaxation massage'),
(89, 5, 3, 1, EXTRACT(EPOCH FROM (TIMESTAMP '2025-12-10 15:00:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Hair maintenance');

INSERT INTO appointments (id, client_id, provider_id, service_id, start_time, status, notes) VALUES
(90, 6, 1, 1, EXTRACT(EPOCH FROM (TIMESTAMP '2025-12-11 10:00:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Basic haircut'),
(91, 7, 4, 4, EXTRACT(EPOCH FROM (TIMESTAMP '2025-12-11 14:00:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Back massage');

INSERT INTO appointments (id, client_id, provider_id, service_id, start_time, status, notes) VALUES
(92, 8, 3, 1, EXTRACT(EPOCH FROM (TIMESTAMP '2025-12-12 09:00:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Haircut appointment'),
(93, 9, 1, 2, EXTRACT(EPOCH FROM (TIMESTAMP '2025-12-12 10:30:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Holiday styling'),
(94, 10, 4, 3, EXTRACT(EPOCH FROM (TIMESTAMP '2025-12-14 13:00:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Full body massage'),
(95, 1, 3, 1, EXTRACT(EPOCH FROM (TIMESTAMP '2025-12-12 14:30:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Hair styling'),
(96, 2, 4, 4, EXTRACT(EPOCH FROM (TIMESTAMP '2025-12-14 16:00:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Back therapy');

INSERT INTO appointments (id, client_id, provider_id, service_id, start_time, status, notes) VALUES
(97, 3, 1, 1, EXTRACT(EPOCH FROM (TIMESTAMP '2025-12-15 11:00:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Monthly trim');

INSERT INTO appointments (id, client_id, provider_id, service_id, start_time, status, notes) VALUES
(98, 4, 4, 3, EXTRACT(EPOCH FROM (TIMESTAMP '2025-12-15 09:00:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Deep tissue massage'),
(99, 5, 3, 1, EXTRACT(EPOCH FROM (TIMESTAMP '2025-12-16 11:00:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Haircut appointment'),
(100, 6, 1, 2, EXTRACT(EPOCH FROM (TIMESTAMP '2025-12-15 13:30:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Designer cut'),
(101, 7, 4, 4, EXTRACT(EPOCH FROM (TIMESTAMP '2025-12-15 15:00:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Back massage');

INSERT INTO appointments (id, client_id, provider_id, service_id, start_time, status, notes) VALUES
(102, 8, 3, 1, EXTRACT(EPOCH FROM (TIMESTAMP '2025-12-16 10:00:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Hair styling'),
(103, 9, 1, 1, EXTRACT(EPOCH FROM (TIMESTAMP '2025-12-16 13:00:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Regular trim'),
(104, 10, 4, 3, EXTRACT(EPOCH FROM (TIMESTAMP '2025-12-18 15:00:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Relaxation massage');

INSERT INTO appointments (id, client_id, provider_id, service_id, start_time, status, notes) VALUES
(105, 1, 4, 4, EXTRACT(EPOCH FROM (TIMESTAMP '2025-12-17 09:00:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Back therapy'),
(106, 2, 3, 1, EXTRACT(EPOCH FROM (TIMESTAMP '2025-12-17 10:30:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Haircut service'),
(107, 3, 1, 2, EXTRACT(EPOCH FROM (TIMESTAMP '2025-12-17 13:00:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Holiday styling'),
(108, 4, 4, 3, EXTRACT(EPOCH FROM (TIMESTAMP '2025-12-17 14:30:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Full body treatment'),
(109, 5, 3, 1, EXTRACT(EPOCH FROM (TIMESTAMP '2025-12-17 16:00:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Hair maintenance');

INSERT INTO appointments (id, client_id, provider_id, service_id, start_time, status, notes) VALUES
(110, 6, 1, 1, EXTRACT(EPOCH FROM (TIMESTAMP '2025-12-18 10:00:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Basic haircut'),
(111, 7, 4, 4, EXTRACT(EPOCH FROM (TIMESTAMP '2025-12-18 14:00:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Back massage');

INSERT INTO appointments (id, client_id, provider_id, service_id, start_time, status, notes) VALUES
(112, 8, 3, 1, EXTRACT(EPOCH FROM (TIMESTAMP '2025-12-19 09:00:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Haircut appointment'),
(113, 9, 1, 2, EXTRACT(EPOCH FROM (TIMESTAMP '2025-12-19 11:00:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Holiday styling'),
(114, 10, 4, 3, EXTRACT(EPOCH FROM (TIMESTAMP '2025-12-21 13:30:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Full body massage'),
(115, 1, 3, 1, EXTRACT(EPOCH FROM (TIMESTAMP '2025-12-19 15:00:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Hair styling');

INSERT INTO appointments (id, client_id, provider_id, service_id, start_time, status, notes) VALUES
(116, 2, 1, 1, EXTRACT(EPOCH FROM (TIMESTAMP '2025-12-22 09:00:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Basic haircut'),
(117, 3, 4, 3, EXTRACT(EPOCH FROM (TIMESTAMP '2025-12-20 11:00:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Deep tissue massage'),
(118, 4, 3, 1, EXTRACT(EPOCH FROM (TIMESTAMP '2025-12-20 14:00:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CONFIRMED', 'Haircut service');

INSERT INTO appointments (id, client_id, provider_id, service_id, start_time, status, notes, cancellation_reason) VALUES
(119, 4, 1, 2, EXTRACT(EPOCH FROM (TIMESTAMP '2025-12-01 14:00:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CANCELLED', NULL, 'Client rescheduled'),
(120, 5, 4, 3, EXTRACT(EPOCH FROM (TIMESTAMP '2025-12-07 11:00:00' AT TIME ZONE 'America/Toronto'))::BIGINT, 'CANCELLED', NULL, 'Schedule conflict');

SELECT setval('appointments_id_seq', (SELECT MAX(id) FROM appointments));


