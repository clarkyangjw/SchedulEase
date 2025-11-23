package com.cstar.schedulease.service.appointment.repository;

import com.cstar.schedulease.common.enums.AppointmentStatus;
import com.cstar.schedulease.service.appointment.entity.Appointment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface AppointmentRepository extends JpaRepository<Appointment, Long> {
    
    List<Appointment> findByClientId(Long clientId);
    
    List<Appointment> findByProviderId(Long providerId);
    
    List<Appointment> findByServiceId(Long serviceId);
    
    List<Appointment> findByStatus(AppointmentStatus status);
    
    /**
     * Find conflicting appointments for a provider within a time range.
     * Checks if there's any time overlap considering the service duration.
     * 
     * Example: If an appointment starts at 9:30 with 90min duration (ends at 11:00),
     * then the provider is busy until 11:00 and cannot have another appointment
     * that overlaps with this time slot.
     * 
     * Conflict condition: existingStartTime < newEndTime AND existingEndTime > newStartTime
     * where existingEndTime = existingStartTime + service.duration * 60
     */
    @Query("SELECT a FROM Appointment a WHERE a.provider.id = :providerId " +
           "AND a.startTime < :endTime AND (a.startTime + a.service.duration * 60) > :startTime " +
           "AND a.status NOT IN ('CANCELLED')")
    List<Appointment> findConflictingAppointments(
        @Param("providerId") Long providerId,
        @Param("startTime") Long startTime,
        @Param("endTime") Long endTime
    );
    
    /**
     * Find conflicting appointments for a provider within a time range,
     * excluding the current appointment being updated.
     * Same conflict detection logic as findConflictingAppointments but excludes
     * the appointment with the given ID (used when updating an existing appointment).
     */
    @Query("SELECT a FROM Appointment a WHERE a.id != :appointmentId " +
           "AND a.provider.id = :providerId " +
           "AND a.startTime < :endTime AND (a.startTime + a.service.duration * 60) > :startTime " +
           "AND a.status NOT IN ('CANCELLED')")
    List<Appointment> findConflictingAppointmentsExcludingCurrent(
        @Param("appointmentId") Long appointmentId,
        @Param("providerId") Long providerId,
        @Param("startTime") Long startTime,
        @Param("endTime") Long endTime
    );
    
    @Query("SELECT a FROM Appointment a " +
           "WHERE a.startTime < :endTime AND (a.startTime + a.service.duration * 60) > :startTime " +
           "ORDER BY a.startTime ASC")
    List<Appointment> findByTimeRange(
        @Param("startTime") Long startTime,
        @Param("endTime") Long endTime
    );
}

