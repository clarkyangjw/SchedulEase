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
    
    List<Appointment> findByProviderServiceProviderId(Long providerId);
    
    List<Appointment> findByStatus(AppointmentStatus status);
    
    @Query("SELECT a FROM Appointment a WHERE a.providerService.id = :providerServiceId " +
           "AND a.startTime < :endTime AND a.endTime > :startTime " +
           "AND a.status NOT IN ('CANCELLED')")
    List<Appointment> findConflictingAppointments(
        @Param("providerServiceId") Long providerServiceId,
        @Param("startTime") Long startTime,
        @Param("endTime") Long endTime
    );
    
    @Query("SELECT a FROM Appointment a WHERE a.id != :appointmentId " +
           "AND a.providerService.id = :providerServiceId " +
           "AND a.startTime < :endTime AND a.endTime > :startTime " +
           "AND a.status NOT IN ('CANCELLED')")
    List<Appointment> findConflictingAppointmentsExcludingCurrent(
        @Param("appointmentId") Long appointmentId,
        @Param("providerServiceId") Long providerServiceId,
        @Param("startTime") Long startTime,
        @Param("endTime") Long endTime
    );
    
    @Query("SELECT a FROM Appointment a " +
           "WHERE a.startTime >= :startTime AND a.endTime <= :endTime " +
           "ORDER BY a.startTime ASC")
    List<Appointment> findByTimeRange(
        @Param("startTime") Long startTime,
        @Param("endTime") Long endTime
    );
}

