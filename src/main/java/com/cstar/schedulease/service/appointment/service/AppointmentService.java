package com.cstar.schedulease.service.appointment.service;

import com.cstar.schedulease.common.enums.AppointmentStatus;
import com.cstar.schedulease.service.appointment.dto.AppointmentDTO;

import java.util.List;

public interface AppointmentService {
    
    AppointmentDTO createAppointment(AppointmentDTO appointmentDTO);
    
    AppointmentDTO updateAppointmentStatus(Long id, AppointmentStatus status, String cancellationReason);
    
    AppointmentDTO getAppointmentById(Long id);
    
    List<AppointmentDTO> getAllAppointments();
    
    List<AppointmentDTO> getAppointmentsByClientId(Long clientId);
    
    List<AppointmentDTO> getAppointmentsByProviderId(Long providerId);
    
    List<AppointmentDTO> getAppointmentsByStatus(AppointmentStatus status);
    
    List<AppointmentDTO> getAppointmentsByTimeRange(Long startTime, Long endTime);
    
    void deleteAppointment(Long id);
}

