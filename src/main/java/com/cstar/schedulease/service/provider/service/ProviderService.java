package com.cstar.schedulease.service.provider.service;

import com.cstar.schedulease.service.provider.dto.ProviderDTO;

import java.util.List;

public interface ProviderService {
    ProviderDTO createProvider(ProviderDTO dto);

    ProviderDTO getProviderById(Long id);

    List<ProviderDTO> getAllProviders(Boolean activeOnly);

    ProviderDTO updateProvider(Long id, ProviderDTO dto);
}
