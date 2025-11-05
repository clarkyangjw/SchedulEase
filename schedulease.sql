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

COMMENT ON TABLE client IS 'Client table - stores basic client information (no registration/login required)';
COMMENT ON COLUMN client.id IS 'Unique client identifier';
COMMENT ON COLUMN client.first_name IS 'First name';
COMMENT ON COLUMN client.last_name IS 'Last name';
COMMENT ON COLUMN client.phone IS 'Phone number';

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

COMMENT ON TABLE provider IS 'Provider table - stores service provider information';
COMMENT ON COLUMN provider.id IS 'Unique provider identifier';
COMMENT ON COLUMN provider.first_name IS 'First name';
COMMENT ON COLUMN provider.last_name IS 'Last name';
COMMENT ON COLUMN provider.description IS 'Service description';
COMMENT ON COLUMN provider.availability IS 'Weekly availability as integer array (1=Monday, 2=Tuesday, 3=Wednesday, 4=Thursday, 5=Friday, 6=Saturday, 7=Sunday)';
COMMENT ON COLUMN provider.is_active IS 'Whether the provider is active';

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

COMMENT ON TABLE service IS 'Service table - stores service type information';
COMMENT ON COLUMN service.id IS 'Unique service identifier';
COMMENT ON COLUMN service.name IS 'Service name';
COMMENT ON COLUMN service.description IS 'Detailed service description';
COMMENT ON COLUMN service.category IS 'Service category: HAIRCUT, BEAUTY, MASSAGE - defined as enum in application';
COMMENT ON COLUMN service.duration IS 'Default service duration (minutes)';
COMMENT ON COLUMN service.price IS 'Default service price';
COMMENT ON COLUMN service.is_active IS 'Whether the service is active';

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

COMMENT ON TABLE provider_service IS 'Provider-Service association table - many-to-many relationship';
COMMENT ON COLUMN provider_service.id IS 'Unique association identifier';
COMMENT ON COLUMN provider_service.provider_id IS 'Provider ID';
COMMENT ON COLUMN provider_service.service_id IS 'Service ID';
COMMENT ON COLUMN provider_service.is_active IS 'Whether the association is active';

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

COMMENT ON TABLE appointments IS 'Appointments table - stores all appointment records';
COMMENT ON COLUMN appointments.id IS 'Unique appointment identifier';
COMMENT ON COLUMN appointments.client_id IS 'Client ID';
COMMENT ON COLUMN appointments.provider_service_id IS 'Provider-Service association ID';
COMMENT ON COLUMN appointments.start_time IS 'Start time (Unix timestamp in seconds, contains both date and time)';
COMMENT ON COLUMN appointments.end_time IS 'End time (Unix timestamp in seconds, contains both date and time)';
COMMENT ON COLUMN appointments.status IS 'Appointment status: CONFIRMED, CANCELLED, COMPLETED, NO_SHOW';
COMMENT ON COLUMN appointments.notes IS 'Client notes';
COMMENT ON COLUMN appointments.cancellation_reason IS 'Cancellation reason';
COMMENT ON COLUMN appointments.cancelled_at IS 'Cancellation timestamp (Unix timestamp in seconds)';

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

COMMENT ON FUNCTION check_availability_no_duplicates() IS 'Validates that availability array has no duplicate day numbers';

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
(1, 'Emma', 'Zhang', 'Senior hairstylist specializing in various hairstyle designs and coloring techniques, 10 years of experience', 
 ARRAY[1,2,3,4,5,6], TRUE), -- Monday to Saturday
(2, 'Sophia', 'Li', 'Professional beautician providing facial care and skin care services, 8 years of experience', 
 ARRAY[1,2,3,4,5], TRUE), -- Monday to Friday
(3, 'Michael', 'Wang', 'Massage therapist specializing in Chinese massage and sports rehabilitation, 12 years of experience', 
 ARRAY[2,3,4,5,6,7], TRUE), -- Tuesday to Sunday
(4, 'Olivia', 'Zhao', 'Senior hairstylist focusing on fashion coloring and perming, 6 years of experience', 
 ARRAY[1,3,4,5,6], TRUE), -- Monday, Wednesday to Saturday
(5, 'James', 'Chen', 'Professional massage technician providing deep tissue massage and relaxation therapy, 9 years of experience', 
 ARRAY[1,2,3,4,5,6,7], TRUE); -- All week

-- Reset provider sequence
SELECT setval('provider_id_seq', (SELECT MAX(id) FROM provider));

-- ---------------------------------------------------------------------------
-- 4.2 Insert Service Data (Services)
-- ---------------------------------------------------------------------------
INSERT INTO service (id, name, description, category, duration, price, is_active) VALUES
-- HAIRCUT services
(1, 'Basic Haircut', 'Includes hair wash, haircut, and blow dry', 'HAIRCUT', 30, 50.00, TRUE),
(2, 'Designer Haircut', 'Professional designer creates hairstyle based on face shape, includes wash, cut, and styling', 'HAIRCUT', 60, 120.00, TRUE),
(3, 'Kids Haircut', 'Haircut service specially designed for children', 'HAIRCUT', 20, 35.00, TRUE),
(4, 'Perm', 'Includes basic haircut and perm styling', 'HAIRCUT', 120, 280.00, TRUE),
(5, 'Hair Coloring', 'Fashion hair coloring service, multiple colors available', 'HAIRCUT', 90, 200.00, TRUE),

-- BEAUTY services
(6, 'Basic Facial', 'Deep cleansing, hydration, and mask treatment', 'BEAUTY', 45, 150.00, TRUE),
(7, 'Premium Facial', 'Deep cleansing, serum infusion, mask, and massage', 'BEAUTY', 75, 280.00, TRUE),
(8, 'Eye Treatment', 'Deep eye care treatment, reduces dark circles', 'BEAUTY', 30, 100.00, TRUE),
(9, 'Manicure', 'Nail care, polish application, and nail art design', 'BEAUTY', 60, 80.00, TRUE),
(10, 'Makeup Service', 'Professional makeup suitable for various occasions', 'BEAUTY', 45, 200.00, TRUE),

-- MASSAGE services
(11, 'Full Body Massage', 'Full body deep relaxation massage, 60 minutes', 'MASSAGE', 60, 180.00, TRUE),
(12, 'Back Massage', 'Deep tissue massage targeting back muscles', 'MASSAGE', 30, 100.00, TRUE),
(13, 'Foot Massage', 'Foot reflexology massage, relaxes body and mind', 'MASSAGE', 45, 120.00, TRUE),
(14, 'Neck & Shoulder Massage', 'Relieves neck and shoulder fatigue and pain', 'MASSAGE', 30, 90.00, TRUE),
(15, 'Sports Recovery Massage', 'Professional therapy for sports injuries', 'MASSAGE', 90, 250.00, TRUE);

-- Reset service sequence
SELECT setval('service_id_seq', (SELECT MAX(id) FROM service));

-- ---------------------------------------------------------------------------
-- 4.3 Insert Provider-Service Association Data (Provider-Service Relationships)
-- ---------------------------------------------------------------------------

-- Emma Zhang (Provider ID: 1) - Hairstylist
INSERT INTO provider_service (id, provider_id, service_id, is_active) VALUES
(1, 1, 1, TRUE),  -- Basic Haircut
(2, 1, 2, TRUE),  -- Designer Haircut
(3, 1, 4, TRUE),  -- Perm
(4, 1, 5, TRUE);  -- Hair Coloring

-- Sophia Li (Provider ID: 2) - Beautician
INSERT INTO provider_service (id, provider_id, service_id, is_active) VALUES
(5, 2, 6, TRUE),  -- Basic Facial
(6, 2, 7, TRUE),  -- Premium Facial
(7, 2, 8, TRUE),  -- Eye Treatment
(8, 2, 9, TRUE),  -- Manicure
(9, 2, 10, TRUE); -- Makeup Service

-- Michael Wang (Provider ID: 3) - Massage Therapist
INSERT INTO provider_service (id, provider_id, service_id, is_active) VALUES
(10, 3, 11, TRUE), -- Full Body Massage
(11, 3, 12, TRUE), -- Back Massage
(12, 3, 13, TRUE), -- Foot Massage
(13, 3, 14, TRUE), -- Neck & Shoulder Massage
(14, 3, 15, TRUE); -- Sports Recovery Massage

-- Olivia Zhao (Provider ID: 4) - Senior Hairstylist
INSERT INTO provider_service (id, provider_id, service_id, is_active) VALUES
(15, 4, 1, TRUE),  -- Basic Haircut
(16, 4, 2, TRUE),  -- Designer Haircut
(17, 4, 3, TRUE),  -- Kids Haircut
(18, 4, 4, TRUE),  -- Perm
(19, 4, 5, TRUE);  -- Hair Coloring

-- James Chen (Provider ID: 5) - Massage Technician
INSERT INTO provider_service (id, provider_id, service_id, is_active) VALUES
(20, 5, 11, TRUE), -- Full Body Massage
(21, 5, 12, TRUE), -- Back Massage
(22, 5, 13, TRUE), -- Foot Massage
(23, 5, 14, TRUE); -- Neck & Shoulder Massage

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
-- Appointments on October 24, 2025
(1, 1, 1, 1729756800, 1729758600, 'CONFIRMED', 'Would like a shorter cut'),
(2, 2, 6, 1729760400, 1729763100, 'CONFIRMED', 'First time visit, dry skin'),
(3, 3, 11, 1729774800, 1729778400, 'CONFIRMED', 'Shoulder pain'),
(4, 4, 2, 1729778400, 1729782000, 'CONFIRMED', 'Looking for a new hairstyle'),
(5, 5, 13, 1729782000, 1729784700, 'CONFIRMED', NULL),

-- Appointments on October 25, 2025
(6, 6, 5, 1729843200, 1729848600, 'CONFIRMED', 'Want brown color'),
(7, 7, 7, 1729846800, 1729851300, 'CONFIRMED', 'Preparing for a party'),
(8, 8, 12, 1729850400, 1729852200, 'CONFIRMED', 'Back discomfort'),
(9, 9, 3, 1729861200, 1729862400, 'CONFIRMED', '5 year old child'),
(10, 10, 14, 1729864800, 1729866600, 'CONFIRMED', 'Long hours at computer'),

-- Appointments on October 26, 2025
(11, 1, 4, 1729929600, 1729936800, 'CONFIRMED', 'Want curly perm'),
(12, 2, 8, 1729933200, 1729935000, 'CONFIRMED', 'Eye fatigue'),
(13, 3, 15, 1729947600, 1729953000, 'CONFIRMED', 'Sports injury'),
(14, 4, 9, 1729936800, 1729940400, 'CONFIRMED', 'Want French manicure'),
(15, 5, 1, 1729951200, 1729953000, 'CONFIRMED', NULL);

-- Past appointments (COMPLETED)
INSERT INTO appointments (id, client_id, provider_service_id, start_time, end_time, status, notes) VALUES
(16, 1, 1, 1729411200, 1729413000, 'COMPLETED', 'Very satisfied'),
(17, 2, 6, 1729414800, 1729417500, 'COMPLETED', NULL),
(18, 3, 11, 1729515600, 1729519200, 'COMPLETED', 'Excellent technique'),
(19, 4, 2, 1729519200, 1729522800, 'COMPLETED', NULL),
(20, 5, 13, 1729609200, 1729611900, 'COMPLETED', NULL);

-- Cancelled appointments (CANCELLED)
INSERT INTO appointments (id, client_id, provider_service_id, start_time, end_time, status, notes, cancellation_reason, cancelled_at) VALUES
(21, 6, 5, 1729670400, 1729675800, 'CANCELLED', 'Want brown color', 'Emergency, need to reschedule', 1729623000),
(22, 7, 7, 1729674000, 1729678500, 'CANCELLED', NULL, 'Client cancelled', 1729628400);

-- No-show appointments (NO_SHOW)
INSERT INTO appointments (id, client_id, provider_service_id, start_time, end_time, status, notes) VALUES
(23, 8, 12, 1729594800, 1729596600, 'NO_SHOW', NULL);

-- Reset appointments sequence
SELECT setval('appointments_id_seq', (SELECT MAX(id) FROM appointments));


-- ============================================================================
-- QUERY EXAMPLES FOR AVAILABILITY (INTEGER ARRAY)
-- ============================================================================

-- Example 1: Find providers available on Monday (day 1)
-- SELECT * FROM provider WHERE 1 = ANY(availability) AND is_active = TRUE;

-- Example 2: Find providers available on weekends (Saturday=6 or Sunday=7)
-- SELECT * FROM provider WHERE availability && ARRAY[6,7] AND is_active = TRUE;

-- Example 3: Find providers available on both Monday AND Friday (days 1 and 5)
-- SELECT * FROM provider WHERE availability @> ARRAY[1,5] AND is_active = TRUE;

-- Example 4: Find providers available on Monday OR Friday
-- SELECT * FROM provider WHERE availability && ARRAY[1,5] AND is_active = TRUE;

-- Example 5: Count work days for each provider
-- SELECT id, first_name, last_name, array_length(availability, 1) as work_days 
-- FROM provider ORDER BY work_days DESC;

-- Example 6: List all available days for a specific provider (formatted)
-- SELECT id, first_name, last_name,
--        CASE WHEN 1 = ANY(availability) THEN 'Mon ' ELSE '' END ||
--        CASE WHEN 2 = ANY(availability) THEN 'Tue ' ELSE '' END ||
--        CASE WHEN 3 = ANY(availability) THEN 'Wed ' ELSE '' END ||
--        CASE WHEN 4 = ANY(availability) THEN 'Thu ' ELSE '' END ||
--        CASE WHEN 5 = ANY(availability) THEN 'Fri ' ELSE '' END ||
--        CASE WHEN 6 = ANY(availability) THEN 'Sat ' ELSE '' END ||
--        CASE WHEN 7 = ANY(availability) THEN 'Sun' ELSE '' END AS available_days
-- FROM provider WHERE id = 1;

-- Example 7: Find providers with specific availability pattern
-- SELECT * FROM provider WHERE availability = ARRAY[1,2,3,4,5]; -- Exactly Mon-Fri

-- Example 8: Add a day to provider's availability (e.g., add Sunday=7)
-- UPDATE provider SET availability = array_append(availability, 7) WHERE id = 1;

-- Example 9: Remove a day from provider's availability (e.g., remove Saturday=6)
-- UPDATE provider SET availability = array_remove(availability, 6) WHERE id = 1;

-- Example 10: Get all unique working days across all providers
-- SELECT DISTINCT unnest(availability) as day_number FROM provider ORDER BY day_number;

-- ============================================================================
-- END OF SCRIPT
-- ============================================================================


