package com.cstar.schedulease.service.appointment.service;

import com.cstar.schedulease.common.enums.AppointmentStatus;
import com.cstar.schedulease.service.appointment.dto.AppointmentDTO;
import com.cstar.schedulease.service.provider.dto.ProviderDTO;

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
    
    /**
     * Get list of available providers for a given time slot and service.
     * Returns providers that are:
     * - Active
     * - Available on the specified day of week
     * - Have no conflicting appointments during the time slot
     * 
     * @param startTime Start time in seconds since epoch
     * @param serviceId Service ID to determine duration
     * @return List of available providers
     */
    List<ProviderDTO> getAvailableProviders(Long startTime, Long serviceId);
}

