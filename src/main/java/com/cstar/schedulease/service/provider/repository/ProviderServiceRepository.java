package com.cstar.schedulease.service.provider.repository;

import com.cstar.schedulease.service.provider.entity.ProviderService;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ProviderServiceRepository extends JpaRepository<ProviderService, Long> {
    
    List<ProviderService> findByProviderId(Long providerId);
    
    List<ProviderService> findByServiceId(Long serviceId);
    
    List<ProviderService> findByIsActive(Boolean isActive);
    
    boolean existsByProviderIdAndServiceId(Long providerId, Long serviceId);
}

