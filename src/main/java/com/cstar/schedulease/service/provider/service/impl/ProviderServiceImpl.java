package com.cstar.schedulease.service.provider.service.impl;

import com.cstar.schedulease.exception.ResourceNotFoundException;
import com.cstar.schedulease.service.provider.dto.ProviderDTO;
import com.cstar.schedulease.service.provider.entity.Provider;
import com.cstar.schedulease.service.provider.entity.ProviderService;
import com.cstar.schedulease.service.provider.repository.ProviderRepository;
import com.cstar.schedulease.service.services.dto.ServiceDTO;
import com.cstar.schedulease.service.services.entity.Service;
import com.cstar.schedulease.service.services.repository.ServiceRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@org.springframework.stereotype.Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class ProviderServiceImpl implements com.cstar.schedulease.service.provider.service.ProviderService {

    private final ProviderRepository providerRepository;
    private final ServiceRepository serviceRepository;

    @Override
    public ProviderDTO createProvider(ProviderDTO dto) {
        log.info("Creating new provider: {} {}", dto.getFirstName(), dto.getLastName());
        
        Provider provider = new Provider();
        provider.setFirstName(dto.getFirstName());
        provider.setLastName(dto.getLastName());
        provider.setDescription(dto.getDescription());
        provider.setIsActive(dto.getIsActive() != null ? dto.getIsActive() : true);
        
        // Handle service associations
        if (dto.getServiceIds() != null && !dto.getServiceIds().isEmpty()) {
            List<ProviderService> providerServices = new ArrayList<>();
            
            for (Long serviceId : dto.getServiceIds()) {
                Service service = serviceRepository.findById(serviceId)
                    .orElseThrow(() -> ResourceNotFoundException.forId("Service", serviceId));
                
                ProviderService providerService = new ProviderService();
                providerService.setProvider(provider);
                providerService.setService(service);
                providerService.setIsActive(true);
                
                providerServices.add(providerService);
            }
            
            provider.setProviderServices(providerServices);
        }
        
        Provider savedProvider = providerRepository.save(provider);
        log.info("Provider created successfully with id: {} and {} services", 
            savedProvider.getId(), 
            dto.getServiceIds() != null ? dto.getServiceIds().size() : 0);
        
        return convertToDTO(savedProvider);
    }

    @Override
    @Transactional(readOnly = true)
    public ProviderDTO getProviderById(Long id) {
        log.info("Fetching provider with id: {}", id);
        
        Provider provider = providerRepository.findById(id)
            .orElseThrow(() -> ResourceNotFoundException.forId("Provider", id));
        
        return convertToDTO(provider);
    }

    @Override
    @Transactional(readOnly = true)
    public List<ProviderDTO> getAllProviders(Boolean activeOnly) {
        log.info("Fetching all providers, activeOnly: {}", activeOnly);
        
        List<Provider> providers;
        
        if (activeOnly != null && activeOnly) {
            providers = providerRepository.findByIsActiveTrue();
        } else if (activeOnly != null) {
            providers = providerRepository.findByIsActive(activeOnly);
        } else {
            providers = providerRepository.findAll();
        }
        
        log.info("Found {} providers", providers.size());
        return providers.stream()
            .map(this::convertToDTO)
            .collect(Collectors.toList());
    }

    @Override
    public ProviderDTO updateProvider(Long id, ProviderDTO dto) {
        log.info("Updating provider with id: {}", id);
        
        Provider provider = providerRepository.findById(id)
            .orElseThrow(() -> ResourceNotFoundException.forId("Provider", id));
        
        if (dto.getFirstName() != null) {
            provider.setFirstName(dto.getFirstName());
        }
        if (dto.getLastName() != null) {
            provider.setLastName(dto.getLastName());
        }
        if (dto.getDescription() != null) {
            provider.setDescription(dto.getDescription());
        }
        if (dto.getIsActive() != null) {
            provider.setIsActive(dto.getIsActive());
        }
        
        // Handle service associations update
        if (dto.getServiceIds() != null) {
            // Clear existing services (mark as inactive or remove)
            if (provider.getProviderServices() != null) {
                provider.getProviderServices().clear();
            }
            
            // Add new services
            if (!dto.getServiceIds().isEmpty()) {
                List<ProviderService> providerServices = new ArrayList<>();
                
                for (Long serviceId : dto.getServiceIds()) {
                    Service service = serviceRepository.findById(serviceId)
                        .orElseThrow(() -> ResourceNotFoundException.forId("Service", serviceId));
                    
                    ProviderService providerService = new ProviderService();
                    providerService.setProvider(provider);
                    providerService.setService(service);
                    providerService.setIsActive(true);
                    
                    providerServices.add(providerService);
                }
                
                provider.setProviderServices(providerServices);
            }
        }
        
        Provider updatedProvider = providerRepository.save(provider);
        log.info("Provider updated successfully with id: {}", updatedProvider.getId());
        
        return convertToDTO(updatedProvider);
    }

    private ProviderDTO convertToDTO(Provider provider) {
        ProviderDTO dto = new ProviderDTO();
        dto.setId(provider.getId());
        dto.setFirstName(provider.getFirstName());
        dto.setLastName(provider.getLastName());
        dto.setDescription(provider.getDescription());
        dto.setIsActive(provider.getIsActive());
        
        // Convert provider services to service DTOs
        if (provider.getProviderServices() != null && !provider.getProviderServices().isEmpty()) {
            List<ServiceDTO> serviceDTOs = provider.getProviderServices().stream()
                .filter(ps -> ps.getIsActive()) // Only include active provider-service relationships
                .map(ProviderService::getService)
                .filter(service -> service.getIsActive()) // Only include active services
                .map(this::convertServiceToDTO)
                .collect(Collectors.toList());
            dto.setServices(serviceDTOs);
        }
        
        return dto;
    }
    
    private ServiceDTO convertServiceToDTO(Service service) {
        ServiceDTO dto = new ServiceDTO();
        dto.setId(service.getId());
        dto.setName(service.getName());
        dto.setDescription(service.getDescription());
        dto.setCategory(service.getCategory());
        dto.setDuration(service.getDuration());
        dto.setPrice(service.getPrice());
        dto.setIsActive(service.getIsActive());
        return dto;
    }
}
