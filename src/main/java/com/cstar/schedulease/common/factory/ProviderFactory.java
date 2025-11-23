package com.cstar.schedulease.common.factory;

import com.cstar.schedulease.service.provider.dto.ProviderDTO;
import com.cstar.schedulease.service.provider.entity.Provider;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

/**
 * Factory for creating Provider entities
 */
@Component
@Slf4j
public class ProviderFactory implements UserFactory<Provider, ProviderDTO> {

    @Override
    public Provider createUser(ProviderDTO dto) {
        log.debug("Creating Provider from DTO: {} {}", dto.getFirstName(), dto.getLastName());
        
        Provider provider = new Provider();
        provider.setFirstName(dto.getFirstName());
        provider.setLastName(dto.getLastName());
        provider.setDescription(dto.getDescription());
        provider.setIsActive(dto.getIsActive() != null ? dto.getIsActive() : true);
        provider.setAvailability(dto.getAvailability() != null ? dto.getAvailability() : "");
        
        return provider;
    }
}

