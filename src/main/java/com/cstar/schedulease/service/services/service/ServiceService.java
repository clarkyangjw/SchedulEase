package com.cstar.schedulease.service.services.service;

import com.cstar.schedulease.common.enums.Category;
import com.cstar.schedulease.service.services.dto.ServiceDTO;

import java.util.List;

public interface ServiceService {
    
    ServiceDTO createService(ServiceDTO dto);
    
    ServiceDTO getServiceById(Long id);
    
    List<ServiceDTO> getAllServices(Boolean activeOnly, Category category);
    
    ServiceDTO updateService(Long id, ServiceDTO dto);
    
    void deleteService(Long id);
}

