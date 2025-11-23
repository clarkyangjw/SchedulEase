package com.cstar.schedulease.service.appointment.service.impl;

import com.cstar.schedulease.common.enums.AppointmentStatus;
import com.cstar.schedulease.service.appointment.dto.AppointmentDTO;
import com.cstar.schedulease.service.appointment.entity.Appointment;
import com.cstar.schedulease.service.appointment.repository.AppointmentRepository;
import com.cstar.schedulease.service.appointment.service.AppointmentService;
import com.cstar.schedulease.service.client.dto.ClientDTO;
import com.cstar.schedulease.service.client.entity.Client;
import com.cstar.schedulease.service.client.repository.ClientRepository;
import com.cstar.schedulease.service.provider.dto.ProviderDTO;
import com.cstar.schedulease.service.provider.entity.Provider;
import com.cstar.schedulease.service.provider.repository.ProviderRepository;
import com.cstar.schedulease.service.services.dto.ServiceDTO;
import com.cstar.schedulease.service.services.entity.Service;
import com.cstar.schedulease.service.services.repository.ServiceRepository;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@org.springframework.stereotype.Service
@RequiredArgsConstructor
public class AppointmentServiceImpl implements AppointmentService {

    private final AppointmentRepository appointmentRepository;
    private final ClientRepository clientRepository;
    private final ProviderRepository providerRepository;
    private final ServiceRepository serviceRepository;

    @Override
    @Transactional
    public AppointmentDTO createAppointment(AppointmentDTO appointmentDTO) {
        Client client = clientRepository.findById(appointmentDTO.getClientId())
            .orElseThrow(() -> new EntityNotFoundException("Client not found with id: " + appointmentDTO.getClientId()));

        Provider provider = providerRepository.findById(appointmentDTO.getProviderId())
            .orElseThrow(() -> new EntityNotFoundException("Provider not found with id: " + appointmentDTO.getProviderId()));

        Service service = serviceRepository.findById(appointmentDTO.getServiceId())
            .orElseThrow(() -> new EntityNotFoundException("Service not found with id: " + appointmentDTO.getServiceId()));

        if (service.getDuration() == null || service.getDuration() <= 0) {
            throw new IllegalArgumentException("Service duration must be greater than 0");
        }

        // Check if provider is active
        if (!provider.getIsActive()) {
            throw new IllegalStateException("Provider is not active");
        }

        // Check if the appointment time is within provider's availability
        if (provider.getAvailability() != null && !provider.getAvailability().trim().isEmpty()) {
            // Convert start time (seconds since epoch) to day of week
            // Java's DayOfWeek: MONDAY=1, TUESDAY=2, ..., SUNDAY=7
            java.time.Instant instant = java.time.Instant.ofEpochSecond(appointmentDTO.getStartTime());
            java.time.ZoneId zoneId = java.time.ZoneId.of("America/Toronto");
            java.time.LocalDateTime localDateTime = java.time.LocalDateTime.ofInstant(instant, zoneId);
            int dayOfWeek = localDateTime.getDayOfWeek().getValue(); // 1=Monday, 7=Sunday

            // Parse provider availability (comma-separated day numbers: 1=Monday, 7=Sunday)
            String[] availableDaysStr = provider.getAvailability().split(",");
            boolean isAvailable = false;
            for (String dayStr : availableDaysStr) {
                try {
                    int availableDay = Integer.parseInt(dayStr.trim());
                    if (availableDay == dayOfWeek) {
                        isAvailable = true;
                        break;
                    }
                } catch (NumberFormatException e) {
                    // Skip invalid day numbers
                }
            }

            if (!isAvailable) {
                throw new IllegalStateException("The appointment time is not within the provider's available days. Provider is available on: " + provider.getAvailability());
            }
        }

        // Calculate the end time of the new appointment based on service duration
        // Duration is stored in minutes, so multiply by 60 to get seconds
        // Example: 9:30 start + 90min duration = 11:00 end time
        Long calculatedEndTime = appointmentDTO.getStartTime() + service.getDuration() * 60L;

        // Check for conflicts: find any existing appointments for this provider
        // that overlap with the new appointment's time slot (considering service duration)
        List<Appointment> conflicts = appointmentRepository.findConflictingAppointments(
            appointmentDTO.getProviderId(),
            appointmentDTO.getStartTime(),
            calculatedEndTime
        );

        if (!conflicts.isEmpty()) {
            throw new IllegalStateException("Time slot is not available. The provider already has an appointment during this time period.");
        }

        Appointment appointment = new Appointment();
        appointment.setClient(client);
        appointment.setProvider(provider);
        appointment.setService(service);
        appointment.setStartTime(appointmentDTO.getStartTime());
        appointment.setStatus(AppointmentStatus.CONFIRMED);
        appointment.setNotes(appointmentDTO.getNotes());

        Appointment saved = appointmentRepository.save(appointment);
        return convertToDTO(saved);
    }

    @Override
    @Transactional
    public AppointmentDTO updateAppointmentStatus(Long id, AppointmentStatus status, String cancellationReason) {
        Appointment appointment = appointmentRepository.findById(id)
            .orElseThrow(() -> new EntityNotFoundException("Appointment not found with id: " + id));

        appointment.setStatus(status);
        
        if (status == AppointmentStatus.CANCELLED) {
            appointment.setCancellationReason(cancellationReason);
        }

        Appointment updated = appointmentRepository.save(appointment);
        return convertToDTO(updated);
    }

    @Override
    @Transactional(readOnly = true)
    public AppointmentDTO getAppointmentById(Long id) {
        Appointment appointment = appointmentRepository.findById(id)
            .orElseThrow(() -> new EntityNotFoundException("Appointment not found with id: " + id));
        return convertToDTO(appointment);
    }

    @Override
    @Transactional(readOnly = true)
    public List<AppointmentDTO> getAllAppointments() {
        return appointmentRepository.findAll().stream()
            .map(this::convertToDTO)
            .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public List<AppointmentDTO> getAppointmentsByClientId(Long clientId) {
        return appointmentRepository.findByClientId(clientId).stream()
            .map(this::convertToDTO)
            .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public List<AppointmentDTO> getAppointmentsByProviderId(Long providerId) {
        return appointmentRepository.findByProviderId(providerId).stream()
            .map(this::convertToDTO)
            .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public List<AppointmentDTO> getAppointmentsByStatus(AppointmentStatus status) {
        return appointmentRepository.findByStatus(status).stream()
            .map(this::convertToDTO)
            .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public List<AppointmentDTO> getAppointmentsByTimeRange(Long startTime, Long endTime) {
        return appointmentRepository.findByTimeRange(startTime, endTime).stream()
            .map(this::convertToDTO)
            .collect(Collectors.toList());
    }

    @Override
    @Transactional
    public void deleteAppointment(Long id) {
        if (!appointmentRepository.existsById(id)) {
            throw new EntityNotFoundException("Appointment not found with id: " + id);
        }
        appointmentRepository.deleteById(id);
    }

    @Override
    @Transactional(readOnly = true)
    public List<ProviderDTO> getAvailableProviders(Long startTime, Long serviceId) {
        // Get service to determine duration
        Service service = serviceRepository.findById(serviceId)
            .orElseThrow(() -> new EntityNotFoundException("Service not found with id: " + serviceId));

        if (service.getDuration() == null || service.getDuration() <= 0) {
            throw new IllegalArgumentException("Service duration must be greater than 0");
        }

        // Calculate end time based on service duration
        Long endTime = startTime + service.getDuration() * 60L;

        // Get all active providers
        List<Provider> allProviders = providerRepository.findByIsActiveTrue();

        // Convert start time to day of week
        java.time.Instant instant = java.time.Instant.ofEpochSecond(startTime);
        java.time.ZoneId zoneId = java.time.ZoneId.of("America/Toronto");
        java.time.LocalDateTime localDateTime = java.time.LocalDateTime.ofInstant(instant, zoneId);
        int dayOfWeek = localDateTime.getDayOfWeek().getValue(); // 1=Monday, 7=Sunday

        // Filter providers that are available
        return allProviders.stream()
            .filter(provider -> {
                // Check if provider is available on this day of week
                if (provider.getAvailability() != null && !provider.getAvailability().trim().isEmpty()) {
                    String[] availableDaysStr = provider.getAvailability().split(",");
                    boolean isAvailableOnDay = false;
                    for (String dayStr : availableDaysStr) {
                        try {
                            int availableDay = Integer.parseInt(dayStr.trim());
                            if (availableDay == dayOfWeek) {
                                isAvailableOnDay = true;
                                break;
                            }
                        } catch (NumberFormatException e) {
                            // Skip invalid day numbers
                        }
                    }
                    if (!isAvailableOnDay) {
                        return false;
                    }
                }

                // Check for time conflicts
                List<Appointment> conflicts = appointmentRepository.findConflictingAppointments(
                    provider.getId(),
                    startTime,
                    endTime
                );

                return conflicts.isEmpty();
            })
            .map(this::convertProviderToDTO)
            .collect(Collectors.toList());
    }

    private ProviderDTO convertProviderToDTO(Provider provider) {
        ProviderDTO dto = new ProviderDTO();
        dto.setId(provider.getId());
        dto.setFirstName(provider.getFirstName());
        dto.setLastName(provider.getLastName());
        dto.setDescription(provider.getDescription());
        dto.setIsActive(provider.getIsActive());
        dto.setAvailability(provider.getAvailability());
        dto.setServices(new java.util.ArrayList<>()); // Services are not managed through provider
        return dto;
    }

    private AppointmentDTO convertToDTO(Appointment appointment) {
        AppointmentDTO dto = new AppointmentDTO();
        dto.setId(appointment.getId());
        dto.setStartTime(appointment.getStartTime());
        
        Service service = appointment.getService();
        Integer serviceDuration = service.getDuration();
        dto.setDuration(serviceDuration);
        dto.setEndTime(appointment.getStartTime() + serviceDuration * 60L);
        
        dto.setStatus(appointment.getStatus());
        dto.setNotes(appointment.getNotes());
        dto.setCancellationReason(appointment.getCancellationReason());

        Client client = appointment.getClient();
        ClientDTO clientDTO = new ClientDTO();
        clientDTO.setId(client.getId());
        clientDTO.setFirstName(client.getFirstName());
        clientDTO.setLastName(client.getLastName());
        clientDTO.setPhone(client.getPhone());
        dto.setClient(clientDTO);

        Provider provider = appointment.getProvider();
        ProviderDTO providerDTO = new ProviderDTO();
        providerDTO.setId(provider.getId());
        providerDTO.setFirstName(provider.getFirstName());
        providerDTO.setLastName(provider.getLastName());
        providerDTO.setDescription(provider.getDescription());
        providerDTO.setIsActive(provider.getIsActive());
        dto.setProvider(providerDTO);

        ServiceDTO serviceDTO = new ServiceDTO();
        serviceDTO.setId(service.getId());
        serviceDTO.setName(service.getName());
        serviceDTO.setDescription(service.getDescription());
        serviceDTO.setCategory(service.getCategory());
        serviceDTO.setDuration(service.getDuration());
        serviceDTO.setPrice(service.getPrice());
        serviceDTO.setIsActive(service.getIsActive());
        dto.setService(serviceDTO);

        return dto;
    }
}

