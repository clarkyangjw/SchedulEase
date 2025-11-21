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
    
    @Query("SELECT a FROM Appointment a WHERE a.provider.id = :providerId " +
           "AND a.service.id = :serviceId " +
           "AND a.startTime < :endTime AND (a.startTime + a.service.duration * 60) > :startTime " +
           "AND a.status NOT IN ('CANCELLED')")
    List<Appointment> findConflictingAppointments(
        @Param("providerId") Long providerId,
        @Param("serviceId") Long serviceId,
        @Param("startTime") Long startTime,
        @Param("endTime") Long endTime
    );
    
    @Query("SELECT a FROM Appointment a WHERE a.id != :appointmentId " +
           "AND a.provider.id = :providerId " +
           "AND a.service.id = :serviceId " +
           "AND a.startTime < :endTime AND (a.startTime + a.service.duration * 60) > :startTime " +
           "AND a.status NOT IN ('CANCELLED')")
    List<Appointment> findConflictingAppointmentsExcludingCurrent(
        @Param("appointmentId") Long appointmentId,
        @Param("providerId") Long providerId,
        @Param("serviceId") Long serviceId,
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

