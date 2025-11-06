package com.cstar.schedulease.service.services.service.impl;

import com.cstar.schedulease.common.enums.Category;
import com.cstar.schedulease.exception.ResourceNotFoundException;
import com.cstar.schedulease.service.services.dto.ServiceDTO;
import com.cstar.schedulease.service.services.entity.Service;
import com.cstar.schedulease.service.services.repository.ServiceRepository;
import com.cstar.schedulease.service.services.service.ServiceService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@org.springframework.stereotype.Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class ServiceServiceImpl implements ServiceService {

    private final ServiceRepository serviceRepository;

    @Override
    public ServiceDTO createService(ServiceDTO dto) {
        log.info("Creating new service: {}", dto.getName());
        
        // Check if service with same name already exists
        if (serviceRepository.existsByName(dto.getName())) {
            throw new IllegalArgumentException("Service with name '" + dto.getName() + "' already exists");
        }
        
        Service service = new Service();
        service.setName(dto.getName());
        service.setDescription(dto.getDescription());
        service.setCategory(dto.getCategory());
        service.setDuration(dto.getDuration());
        service.setPrice(dto.getPrice());
        service.setIsActive(dto.getIsActive() != null ? dto.getIsActive() : true);
        
        Service savedService = serviceRepository.save(service);
        log.info("Service created successfully with id: {}", savedService.getId());
        
        return convertToDTO(savedService);
    }

    @Override
    @Transactional(readOnly = true)
    public ServiceDTO getServiceById(Long id) {
        log.info("Fetching service with id: {}", id);
        
        Service service = serviceRepository.findById(id)
            .orElseThrow(() -> ResourceNotFoundException.forId("Service", id));
        
        return convertToDTO(service);
    }

    @Override
    @Transactional(readOnly = true)
    public List<ServiceDTO> getAllServices(Boolean activeOnly, Category category) {
        log.info("Fetching all services, activeOnly: {}, category: {}", activeOnly, category);
        
        List<Service> services;
        
        if (category != null && activeOnly != null && activeOnly) {
            services = serviceRepository.findByCategoryAndIsActiveTrue(category);
        } else if (category != null) {
            services = serviceRepository.findByCategory(category);
        } else if (activeOnly != null && activeOnly) {
            services = serviceRepository.findByIsActiveTrue();
        } else if (activeOnly != null) {
            services = serviceRepository.findByIsActive(activeOnly);
        } else {
            services = serviceRepository.findAll();
        }
        
        log.info("Found {} services", services.size());
        return services.stream()
            .map(this::convertToDTO)
            .collect(Collectors.toList());
    }

    @Override
    public ServiceDTO updateService(Long id, ServiceDTO dto) {
        log.info("Updating service with id: {}", id);
        
        Service service = serviceRepository.findById(id)
            .orElseThrow(() -> ResourceNotFoundException.forId("Service", id));
        
        // Check if name is being changed and if new name already exists
        if (dto.getName() != null && !dto.getName().equals(service.getName())) {
            if (serviceRepository.existsByName(dto.getName())) {
                throw new IllegalArgumentException("Service with name '" + dto.getName() + "' already exists");
            }
            service.setName(dto.getName());
        }
        
        if (dto.getDescription() != null) {
            service.setDescription(dto.getDescription());
        }
        if (dto.getCategory() != null) {
            service.setCategory(dto.getCategory());
        }
        if (dto.getDuration() != null) {
            service.setDuration(dto.getDuration());
        }
        if (dto.getPrice() != null) {
            service.setPrice(dto.getPrice());
        }
        if (dto.getIsActive() != null) {
            service.setIsActive(dto.getIsActive());
        }
        
        Service updatedService = serviceRepository.save(service);
        log.info("Service updated successfully with id: {}", updatedService.getId());
        
        return convertToDTO(updatedService);
    }

    @Override
    public void deleteService(Long id) {
        log.info("Deleting (deactivating) service with id: {}", id);
        
        Service service = serviceRepository.findById(id)
            .orElseThrow(() -> ResourceNotFoundException.forId("Service", id));
        
        service.setIsActive(false);
        serviceRepository.save(service);
        
        log.info("Service deactivated successfully with id: {}", id);
    }

    private ServiceDTO convertToDTO(Service service) {
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

