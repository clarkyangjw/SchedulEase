package com.cstar.schedulease.service.provider.service.impl;

import com.cstar.schedulease.exception.ResourceNotFoundException;
import com.cstar.schedulease.service.provider.dto.ProviderDTO;
import com.cstar.schedulease.service.provider.entity.Provider;
import com.cstar.schedulease.service.provider.repository.ProviderRepository;
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

    @Override
    public ProviderDTO createProvider(ProviderDTO dto) {
        log.info("Creating new provider: {} {}", dto.getFirstName(), dto.getLastName());
        
        Provider provider = new Provider();
        provider.setFirstName(dto.getFirstName());
        provider.setLastName(dto.getLastName());
        provider.setDescription(dto.getDescription());
        provider.setAvailability(dto.getAvailability());
        provider.setIsActive(dto.getIsActive() != null ? dto.getIsActive() : true);
        
        // Note: Service associations are no longer managed through provider_service table
        // Services are directly associated with appointments
        
        Provider savedProvider = providerRepository.save(provider);
        log.info("Provider created successfully with id: {}", savedProvider.getId());
        
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
        if (dto.getAvailability() != null) {
            provider.setAvailability(dto.getAvailability());
        }
        if (dto.getIsActive() != null) {
            provider.setIsActive(dto.getIsActive());
        }
        
        // Note: Service associations are no longer managed through provider_service table
        // Services are directly associated with appointments
        
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
        dto.setAvailability(provider.getAvailability());
        dto.setIsActive(provider.getIsActive());
        
        // Note: Services are no longer managed through provider_service table
        // Services list is set to empty as they are now directly associated with appointments
        dto.setServices(new ArrayList<>());
        
        return dto;
    }
}
